#include "Endfield Uncensored.h"
#include <string>
#include <vector>
#include <thread>
#include <memory>
#include <tlhelp32.h>
#include <shlwapi.h>
#include <shellapi.h>
#include <gdiplus.h>
#include <dwmapi.h>
#include <mmsystem.h>
#include <cmath>
#include <algorithm>

#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "gdiplus.lib")
#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "dwmapi.lib")
#pragma comment(lib, "winmm.lib")

using namespace Gdiplus;

// Constants
#define WM_APPEND_OUTPUT (WM_USER + 1)
#define WINDOW_WIDTH 500
#define WINDOW_HEIGHT 200
#define CORNER_RADIUS 15
#define TARGET_EXE L"Endfield.exe"
#define DLL_NAME L"EFU.dll"

// Global Variables
HINSTANCE g_hInst = nullptr;
HWND g_hWnd = nullptr;
std::wstring g_tempDllPath;
std::wstring g_outputText;
bool g_isClosing = false;
float g_windowOpacity = 1.0f;
float g_dpiScale = 1.0f;

// Cached bitmap for layered window (avoids full GDI+ re-render on every frame)
HDC g_cachedDC = nullptr;
HBITMAP g_cachedBitmap = nullptr;
HBITMAP g_cachedOldBitmap = nullptr;
bool g_contentDirty = true;

// GDI+ resources (managed via smart pointers)
static std::unique_ptr<Gdiplus::GraphicsPath> g_pLogoPath;
static std::unique_ptr<Gdiplus::GraphicsPath> g_pTextPath;
static std::unique_ptr<Gdiplus::Font> g_pButtonFont;
static std::unique_ptr<Gdiplus::Font> g_pMinButtonFont;
static std::unique_ptr<Gdiplus::Font> g_pInfoButtonFont;
static std::unique_ptr<Gdiplus::Font> g_pConsoleFont;
static std::unique_ptr<Gdiplus::Font> g_pVersionFont;

// High-precision timing
LARGE_INTEGER g_qpcFrequency;

inline double GetPreciseTimeMs()
{
    LARGE_INTEGER now;
    QueryPerformanceCounter(&now);
    return (double)now.QuadPart * 1000.0 / (double)g_qpcFrequency.QuadPart;
}

// Custom rendering state
int g_hoveredButton = 0; // 0=none, 1=close, 2=minimize, 3=info
bool g_mouseTracking = false;
RECT g_closeBtn = { 465, 5, 495, 35 };
RECT g_minBtn = { 443, 1.15, 460, 35 };
RECT g_infoBtn = { 7, 7, 27, 27 };
RECT g_outputRect = { 252, 42, 476, 157 };
RECT g_versionRect = { 10, 175, 250, 195 };

// Animation state
#define TIMER_ANIMATION 1
#define TIMER_CLOSE_DELAY 2
struct ButtonColorAnim {
    Color start;
    Color current;
    Color target;
    double startTime;
    bool animating;
} g_buttonAnims[5] = {}; // 0=unused, 1=close, 2=minimize, 3=info, 4=version

struct WindowAnim {
    enum Type { None, SlideIn, SlideOutClose, FadeOutMinimize, FadeInRestore } type = None;
    double startTime;
    int startX;
    int startY;
    double startOpacity;
} g_windowAnim;

// Forward declarations
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
void StartInjectionThread();
DWORD FindTargetProcess(const wchar_t* name);
BOOL InjectDll(DWORD pid, const wchar_t* dllPath);
bool ExtractEmbeddedDll();
bool IsAdmin();
void AppendOutput(const std::wstring& text, bool replaceClosing = false);
void CleanupTempFiles();
void RenderContent(HWND hWnd);
void PresentWindow(HWND hWnd, const POINT* pNewPos = nullptr);
void UpdateWindowGraphics(HWND hWnd);
Color LerpColor(const Color& a, const Color& b, float t);
float EaseOutQuad(float t);
void StartButtonColorAnim(int buttonId, const Color& target);
void UpdateAnimations(HWND hWnd);
void StartWindowAnimation(WindowAnim::Type type, HWND hWnd);
void ParseSVGPathToGDIPlus(const char* svgPath, GraphicsPath& gdiPath);
void FreeCachedBitmap();

inline bool IsAnimating()
{
    if (g_windowAnim.type != WindowAnim::None) return true;
    for (int i = 1; i <= 4; i++)
        if (g_buttonAnims[i].animating) return true;
    return false;
}

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPWSTR lpCmdLine,
                     _In_ int nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    // Set DPI awareness programmatically (Windows 10 1607+)
    typedef BOOL(WINAPI* SetProcessDpiAwarenessContextProc)(DPI_AWARENESS_CONTEXT);
    HMODULE user32 = GetModuleHandleW(L"user32.dll");
    if (user32)
    {
        auto SetProcessDpiAwarenessContextFunc = (SetProcessDpiAwarenessContextProc)GetProcAddress(user32, "SetProcessDpiAwarenessContext");
        if (SetProcessDpiAwarenessContextFunc)
        {
            // Use Per-Monitor V2 awareness for best results
            SetProcessDpiAwarenessContextFunc(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
        }
        else
        {
            // Fallback for older Windows 10 versions
            typedef HRESULT(WINAPI* SetProcessDpiAwarenessProc)(int);
            HMODULE shcore = LoadLibraryW(L"shcore.dll");
            if (shcore)
            {
                auto SetProcessDpiAwarenessFunc = (SetProcessDpiAwarenessProc)GetProcAddress(shcore, "SetProcessDpiAwareness");
                if (SetProcessDpiAwarenessFunc)
                {
                    SetProcessDpiAwarenessFunc(2); // PROCESS_PER_MONITOR_DPI_AWARE
                }
                FreeLibrary(shcore);
            }
        }
    }

    g_hInst = hInstance;

    // Initialize high-precision timing
    QueryPerformanceFrequency(&g_qpcFrequency);
    timeBeginPeriod(1);

    // Initialize GDI+
    GdiplusStartupInput gdiplusStartupInput;
    ULONG_PTR gdiplusToken;
    GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, nullptr);

    // Check admin privileges
    if (!IsAdmin())
    {
        MessageBox(nullptr, L"This application must be run as administrator!", L"Admin Required", MB_OK | MB_ICONERROR);
        return 1;
    }

    // Extract DLL to temp directory
    if (!ExtractEmbeddedDll())
    {
        MessageBox(nullptr, L"Failed to extract embedded DLL!", L"Error", MB_OK | MB_ICONERROR);
        return 1;
    }

    // Register window class
    WNDCLASSEXW wcex = {};
    wcex.cbSize = sizeof(WNDCLASSEX);
    wcex.style = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc = WndProc;
    wcex.hInstance = hInstance;
    wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_ENDFIELDUNCENSOREDC));
    wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground = CreateSolidBrush(RGB(255, 255, 255));
    wcex.lpszClassName = L"EndfieldUncensoredClass";
    wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

    if (!RegisterClassExW(&wcex))
    {
        return 1;
    }

    // Get DPI for scaling
    HDC hdcScreen = GetDC(nullptr);
    int dpiX = GetDeviceCaps(hdcScreen, LOGPIXELSX);
    ReleaseDC(nullptr, hdcScreen);
    g_dpiScale = dpiX / 96.0f; // 96 is the default DPI

    // Calculate scaled window size
    int scaledWidth = (int)(WINDOW_WIDTH * g_dpiScale);
    int scaledHeight = (int)(WINDOW_HEIGHT * g_dpiScale);

    // Calculate centered position
    int screenWidth = GetSystemMetrics(SM_CXSCREEN);
    int screenHeight = GetSystemMetrics(SM_CYSCREEN);
    int posX = (screenWidth - scaledWidth) / 2;
    int posY = (screenHeight - scaledHeight) / 2;

    // Create main window (layered for smooth rounded corners)
    g_hWnd = CreateWindowExW(
        WS_EX_LAYERED,
        L"EndfieldUncensoredClass",
        L"Endfield Uncensored",
        WS_POPUP,
        posX, posY,
        scaledWidth, scaledHeight,
        nullptr, nullptr, hInstance, nullptr);

    if (!g_hWnd)
    {
        return 1;
    }

    // Set initial opacity to 0 to prevent flash before animation
    g_windowOpacity = 0.0f;

    // Render initial frame at 0 opacity
    UpdateWindowGraphics(g_hWnd);

    ShowWindow(g_hWnd, nCmdShow);

    // Start slide-in animation
    StartWindowAnimation(WindowAnim::SlideIn, g_hWnd);

    // Start injection thread
    StartInjectionThread();

    // Main message loop — V-Sync'd animation via DwmFlush()
    MSG msg = {};
    while (msg.message != WM_QUIT)
    {
        if (IsAnimating())
        {
            // Animation active: drain messages, update, sync to compositor
            while (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE))
            {
                if (msg.message == WM_QUIT) break;
                TranslateMessage(&msg);
                DispatchMessage(&msg);
            }
            if (msg.message == WM_QUIT) break;

            UpdateAnimations(g_hWnd);
            DwmFlush(); // V-Sync with desktop compositor (~60 Hz)
        }
        else
        {
            // Idle: block until a message arrives (zero CPU)
            BOOL ret = GetMessage(&msg, nullptr, 0, 0);
            if (ret <= 0) break;
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }

    // Cleanup
    CleanupTempFiles();
    GdiplusShutdown(gdiplusToken);
    timeEndPeriod(1);

    return (int)msg.wParam;
}

void FreeCachedBitmap()
{
    if (g_cachedDC)
    {
        SelectObject(g_cachedDC, g_cachedOldBitmap);
        DeleteObject(g_cachedBitmap);
        DeleteDC(g_cachedDC);
        g_cachedDC = nullptr;
        g_cachedBitmap = nullptr;
        g_cachedOldBitmap = nullptr;
    }
}

void FreeGdiResources()
{
    // Release GDI+ heap objects
    g_pLogoPath.reset();
    g_pTextPath.reset();
    g_pButtonFont.reset();
    g_pMinButtonFont.reset();
    g_pInfoButtonFont.reset();
    g_pConsoleFont.reset();
    g_pVersionFont.reset();
}

void RenderContent(HWND hWnd)
{
    HDC hdcScreen = GetDC(nullptr);

    int scaledWidth = (int)(WINDOW_WIDTH * g_dpiScale);
    int scaledHeight = (int)(WINDOW_HEIGHT * g_dpiScale);

    // Recreate cached bitmap if needed
    FreeCachedBitmap();

    BITMAPINFO bmi = {};
    bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bmi.bmiHeader.biWidth = scaledWidth;
    bmi.bmiHeader.biHeight = -scaledHeight;
    bmi.bmiHeader.biPlanes = 1;
    bmi.bmiHeader.biBitCount = 32;
    bmi.bmiHeader.biCompression = BI_RGB;

    void* pBits = nullptr;
    g_cachedDC = CreateCompatibleDC(hdcScreen);
    g_cachedBitmap = CreateDIBSection(hdcScreen, &bmi, DIB_RGB_COLORS, &pBits, nullptr, 0);
    g_cachedOldBitmap = (HBITMAP)SelectObject(g_cachedDC, g_cachedBitmap);

    Graphics graphics(g_cachedDC);
    graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    graphics.SetTextRenderingHint(TextRenderingHintAntiAlias);
    graphics.ScaleTransform(g_dpiScale, g_dpiScale);
    graphics.Clear(Color(255, 255, 255, 255));

    // Draw yellow diagonal rectangle behind logo (matches original WPF layout)
    {
        GraphicsState bgState = graphics.Save();

        // WPF Margin="-103,1,200,5" in a 500x200 window
        float rectLeft = -95.0f;
        float rectTop = 1.0f;
        float rectWidth = 403.0f;  // (500 - 200) - (-103)
        float rectHeight = 194.0f; // (200 - 5) - 1

        // RenderTransformOrigin="0.3,0.5" — rotation pivot in window coords
        float pivotX = rectLeft + rectWidth * 0.3f;
        float pivotY = rectTop + rectHeight * 0.5f;

        graphics.TranslateTransform(pivotX, pivotY);
        graphics.RotateTransform(-45.0f);
        graphics.TranslateTransform(-pivotX, -pivotY);

        SolidBrush yellowBrush(Color(255, 255, 250, 0)); // #fffa00
        graphics.FillRectangle(&yellowBrush, rectLeft, rectTop, rectWidth, rectHeight);

        graphics.Restore(bgState);
    }

    // Render the logo
    {
        static GraphicsPath* pLogoPath = nullptr;
        if (!pLogoPath)
        {
            pLogoPath = new GraphicsPath();
            const char* logoSVG = "M3.37,13.25h7.9V9.68H3.37V7.37H9.68L11.46,5.6V3.82H0V19.45H11.6V15.81H3.37ZM7.52,1.18h.23l.36.62h.52L8.2,1.1A.51.51,0,0,0,8.53.59C8.53.16,8.19,0,7.77,0H7.05V1.8h.47Zm0-.81h.21c.22,0,.34,0,.34.22S8,.84,7.73.84H7.52ZM0,37H3.38V30.8H11V27.24H3.38v-2.3h7.8V21.41H0ZM.59,1.4h.58l.12.4h.49L1.17,0H.61L0,1.8H.48ZM.73.92C.78.74.83.54.88.35h0c0,.18.1.39.15.57l0,.15H.68Zm54.69.55a.82.82,0,0,1-.48-.18l-.27.29a1.19,1.19,0,0,0,.74.26c.47,0,.74-.26.74-.56A.49.49,0,0,0,55.77.8L55.52.71c-.17-.06-.3-.1-.3-.2s.09-.15.24-.15a.67.67,0,0,1,.4.14L56.1.23A1,1,0,0,0,55.46,0c-.42,0-.71.24-.71.54a.52.52,0,0,0,.39.48l.26.1c.16.06.27.09.27.2S55.59,1.47,55.42,1.47ZM12.46,37h3.39V26.09H12.5l3.35-3.34V21.41H12.46ZM21.35,1.22c0-.22,0-.46-.06-.66h0l.19.39L22,1.8h.48V0H22V.62a6.26,6.26,0,0,0,.06.65h0L21.87.88,21.38,0H20.9V1.8h.45ZM28.45,0H28V1.8h.48ZM39.34,19a6.45,6.45,0,0,0,2.22-1.22A5.88,5.88,0,0,0,42.9,16a7.87,7.87,0,0,0,.69-2,11.46,11.46,0,0,0,.18-2.09v-.63a11,11,0,0,0-.14-1.77,9.85,9.85,0,0,0-.45-1.69,4.78,4.78,0,0,0-.89-1.55A7.34,7.34,0,0,0,40.89,5a6.33,6.33,0,0,0-2-.85,12.06,12.06,0,0,0-2.74-.29H28.9V19.45h7.21A9.93,9.93,0,0,0,39.34,19Zm-7-3.28H28.94l3.36-3.36V7.52h3.54c2.91,0,4.36,1.33,4.36,4v.12q0,4-4.36,4ZM41.42,1.08h.65V1.8h.46V0h-.46V.71h-.65V0H41V1.8h.47Zm7,.72h.47V.39h.53V0H47.9V.39h.53Zm-13.59,0a1,1,0,0,0,.65-.22V.79h-.73v.35h.32v.29a.53.53,0,0,1-.19,0,.49.49,0,0,1-.54-.56.5.5,0,0,1,.5-.55.53.53,0,0,1,.36.14l.25-.27A.91.91,0,0,0,34.83,0a.91.91,0,0,0-1,.93A.88.88,0,0,0,34.84,1.84Zm-20.39-.5.21-.26.46.72h.52L14.93.74l.6-.71H15l-.56.7h0V0H14V1.8h.48Zm6.46,29.43h7.9V27.2h-7.9V24.88h6.33L29,23.13v-1.8H17.55V37h11.6V33.33H20.91Zm38.47,0h-.09v.12h.09ZM27.18,16.12V3.87H23.82v9.81L16.9,3.87H13.12v15.6h3.35V9.14l7.35,10.33ZM59.38,31h-.09v.13h.09Zm.56,0h-.18v.11h.18Zm8.89,2H66.91v.46h1.57v.74H66.91v.15l1.82,1.26v-.36l.5-.18V33.68h-.4ZM58.64,21.41V36.9h15.5V21.41Zm3.56,9.26h.22a.56.56,0,0,0,0-.12h.2l-.07.11h.32V31H63v.15h-.13v.25c0,.07,0,.11-.06.13a.36.36,0,0,1-.19,0,.42.42,0,0,0,0-.15h.1s0,0,0,0v-.24h-.39a.64.64,0,0,1-.20.42.63.63,0,0,0-.12-.11.52.52,0,0,0,.16-.31h-.14V31h.15Zm.38.75a.73.73,0,0,0-.18-.16l.1-.08a.55.55,0,0,1,.19.14Zm-1.51-.55v-.15h.45a.75.75,0,0,0-.06-.13l.16-.06s.06.12.08.16l-.08,0h.44v.15h-.55a.37.37,0,0,1,0,.11H62v.07c0,.29,0,.41-.09.46a.2.2,0,0,1-.13.06h-.19a.32.32,0,0,0-.06-.15h.24s0-.11.06-.28h-.32a.65.65,0,0,1-.31.46.45.45,0,0,0-.11-.13.61.61,0,0,0,.28-.59Zm-.87-.26H61v1h-.17V31.5h-.45v.07H60.2Zm-.59,0h.48v.82c0,.08,0,.12-.06.14a.38.38,0,0,1-.20,0,.47.47,0,0,0-.06-.15h.14s0,0,0,0v-.17h-.2a.54.54,0,0,1-.18.35.58.58,0,0,0-.12-.1.61.61,0,0,0,.17-.50Zm-.47,0h.38v.67h-.23v.09h-.15Zm0,2.74L60,31.76h.92l-1.23,2.33h-.57Zm2,2.84-2,.4v-.7l2-.41Zm12.79.41H71.45l-.72-.37V34.37l-.42.16v-.85h-.24v1l.46-.17v1l-1.62.6v.44l-2-1.42v1.38H66V35.21L64,36.6H62.82l-1.67-1.19.62-.46,1.65,1.14L66,34.31v-.15H64.41v-.74H66V33h-2v.18l-.86.6,1,.64v.88l-1.6-1.1-1.47,1v.12l-1.92.41v-.25l1.6-2.76H61l.68-.91h.9l-.32.43H66v-.46h.92v.46h2v.72h.27V32h.84v.94h.46v.6l.2-.08V32.29h.84v.85l.21-.08v-1.3h.84v1l1-.40v2.54l-.84.35V33.57l-.21.08V35.3l-.84.35V34l-.21.08v1.78h2.32Zm-12-1.78.63-.46.86.59v.92Zm.59-1.5L63,33H61.89Zm-2.5-2.58h-.18v.11h.18Zm1.14,3.07h-.21l-.43.83.38-.09v-.1l1-.72-.47-.32ZM42.62,33.2h0ZM34.05,21.39H30.66V37H41.59V33.11H34.05Zm22.86,3.87A4.74,4.74,0,0,0,56,23.72a6.75,6.75,0,0,0-1.4-1.24,6.06,6.06,0,0,0-2-.85,11.64,11.64,0,0,0-2.75-.3h-7.2V33.19l3.4-3.4V25h3.54q4.36,0,4.36,4v.13q0,4-4.36,4H42.63V37h7.22a9.91,9.91,0,0,0,3.22-.48,6.29,6.29,0,0,0,2.22-1.22,5.84,5.84,0,0,0,1.34-1.78,7.62,7.62,0,0,0,.69-2,11.54,11.54,0,0,0,.18-2.09v-.63A11.17,11.17,0,0,0,57.36,27,9.43,9.43,0,0,0,56.91,25.26Zm3.91,5.51h-.45V31h.45Zm0,.36h-.45v.21h.45Zm1.59-.23.1-.08h-.15V31h.19A.55.55,0,0,0,62.41,30.9Zm.17.12h.16v-.2h-.22a.61.61,0,0,1,.15.12Z";
            ParseSVGPathToGDIPlus(logoSVG, *pLogoPath);
        }

        GraphicsState state = graphics.Save();
        float logoLeft = 75.0f;
        float logoTop = 55.0f;
        float logoScale = 2.211f;

        graphics.TranslateTransform(logoLeft, logoTop);
        graphics.ScaleTransform(logoScale, logoScale);

        SolidBrush logoBlackBrush(Color(255, 0, 0, 0));
        graphics.FillPath(&logoBlackBrush, pLogoPath);
        graphics.Restore(state);

        // Draw "UNCENSORED" text below the logo
        static GraphicsPath* pTextPath = nullptr;
        if (!pTextPath)
        {
            pTextPath = new GraphicsPath();
            FontFamily fontFamily(L"Impact");
            pTextPath->AddString(L"UNCENSORED", -1, &fontFamily, FontStyleBold, 36, PointF(0, 0), nullptr);

            Matrix matrix;
            matrix.Scale(0.8405f, 0.20f);
            matrix.Translate(68.75f / 0.8405f, 136.0f / 0.20f);
            pTextPath->Transform(&matrix);
        }

        SolidBrush blackBrush(Color(255, 0, 0, 0));
        graphics.FillPath(&blackBrush, pTextPath);
    }

    if (!g_pButtonFont)
        g_pButtonFont = std::make_unique<Font>(L"Segoe UI", 20, FontStyleBold, UnitPixel);
    if (!g_pMinButtonFont)
        g_pMinButtonFont = std::make_unique<Font>(L"Segoe UI", 22, FontStyleBold, UnitPixel);
    if (!g_pInfoButtonFont)
        g_pInfoButtonFont = std::make_unique<Font>(L"Segoe UI", 13, FontStyleBold, UnitPixel);
    if (!g_pConsoleFont)
        g_pConsoleFont = std::make_unique<Font>(L"Consolas", 13, FontStyleRegular, UnitPixel);
    if (!g_pVersionFont)
        g_pVersionFont = std::make_unique<Font>(L"Segoe UI", 12, FontStyleRegular, UnitPixel);

    StringFormat centerFormat;
    centerFormat.SetAlignment(StringAlignmentCenter);
    centerFormat.SetLineAlignment(StringAlignmentCenter);

    static bool initialized = false;
    if (!initialized)
    {
        g_buttonAnims[1].current = Color(255, 51, 51, 51);
        g_buttonAnims[2].current = Color(255, 51, 51, 51);
        g_buttonAnims[3].current = Color(255, 51, 51, 51);
        g_buttonAnims[4].current = Color(255, 51, 51, 51);
        initialized = true;
    }

    // Draw buttons at full alpha
    SolidBrush closeBrush(g_buttonAnims[1].current);
    RectF closeRectF((REAL)g_closeBtn.left, (REAL)g_closeBtn.top, 
                     (REAL)(g_closeBtn.right - g_closeBtn.left), 
                     (REAL)(g_closeBtn.bottom - g_closeBtn.top));
    graphics.DrawString(L"\u2715", -1, g_pButtonFont.get(), closeRectF, &centerFormat, &closeBrush);

    SolidBrush minBrush(g_buttonAnims[2].current);
    RectF minRectF((REAL)g_minBtn.left, (REAL)g_minBtn.top, 
                   (REAL)(g_minBtn.right - g_minBtn.left), 
                   (REAL)(g_minBtn.bottom - g_minBtn.top));
    graphics.DrawString(L"\u2014", -1, g_pMinButtonFont.get(), minRectF, &centerFormat, &minBrush);

    SolidBrush infoBrush(g_buttonAnims[3].current);
    RectF infoRectF((REAL)g_infoBtn.left, (REAL)g_infoBtn.top, 
                    (REAL)(g_infoBtn.right - g_infoBtn.left), 
                    (REAL)(g_infoBtn.bottom - g_infoBtn.top));
    graphics.DrawString(L"\u24D8", -1, g_pInfoButtonFont.get(), infoRectF, &centerFormat, &infoBrush);

    StringFormat leftFormat;
    leftFormat.SetAlignment(StringAlignmentNear);
    leftFormat.SetLineAlignment(StringAlignmentNear);

    // Version text should not wrap or be trimmed — draw full string on one line
    StringFormat verFormat;
    verFormat.SetAlignment(StringAlignmentNear);
    verFormat.SetLineAlignment(StringAlignmentNear);
    verFormat.SetFormatFlags(StringFormatFlagsNoWrap);
    verFormat.SetTrimming(StringTrimmingNone);

    RectF outputRectF((REAL)g_outputRect.left, (REAL)g_outputRect.top,
                      (REAL)(g_outputRect.right - g_outputRect.left),
                      (REAL)(g_outputRect.bottom - g_outputRect.top));
    SolidBrush textBrush(Color(255, 0, 0, 0));
    graphics.DrawString(g_outputText.c_str(), -1, g_pConsoleFont.get(), outputRectF, &leftFormat, &textBrush);

    RectF versionRectF((REAL)g_versionRect.left, (REAL)g_versionRect.top,
                       (REAL)(g_versionRect.right - g_versionRect.left),
                       (REAL)(g_versionRect.bottom - g_versionRect.top));
    // VERSION comes from the shared header
    std::wstring ver = VERSION;
    if (!ver.empty() && (ver[0] == L'v' || ver[0] == L'V'))
        ver = ver.substr(1);
    std::vector<std::wstring> parts;
    size_t pos = 0;
    while (pos < ver.size()) {
        size_t dot = ver.find(L'.', pos);
        if (dot == std::wstring::npos) dot = ver.size();
        parts.push_back(ver.substr(pos, dot - pos));
        pos = dot + 1;
    }
    std::wstring displayVersion;
    if (parts.size() >= 4) {
        // Format: "vMajor.Minor.Patch PREVIEW Build" using the 4th component as the preview/build
        displayVersion = L"v" + parts[0] + L"." + parts[1] + L"." + parts[2] + L" PREVIEW " + parts[3];
    } else if (parts.size() == 3) {
        displayVersion = L"v" + parts[0] + L"." + parts[1] + L"." + parts[2];
    } else {
        displayVersion = std::wstring(VERSION);
    }
    // Measure and expand the layout rect if the text is wider than the allocated space
    // Note: Graphics has a scale transform applied (g_dpiScale), so MeasureString
    // returns sizes in device-scaled units. Convert back to logical coordinates
    // before updating versionRectF so hit-testing (which uses logical coords)
    // remains consistent.
    RectF measuredRect;
    graphics.MeasureString(displayVersion.c_str(), -1, g_pVersionFont.get(), PointF(0, 0), &measuredRect);
    float measuredLogicalWidth = measuredRect.Width / g_dpiScale;
    if (measuredLogicalWidth + 4.0f > versionRectF.Width) // small padding (logical coords)
        versionRectF.Width = measuredLogicalWidth + 4.0f;

    // Draw version text; also record its clickable region in logical coords (for hit-testing)
    SolidBrush versionBrush(g_buttonAnims[4].current);
    graphics.DrawString(displayVersion.c_str(), -1, g_pVersionFont.get(), versionRectF, &verFormat, &versionBrush);

    // Update g_versionRect to tightly fit the measured text (in logical coords)
    // (versionRectF was potentially expanded above to measured width)
    // Convert back to integer RECT for hit-testing
    g_versionRect.left = (int)ceilf(versionRectF.X);
    g_versionRect.top = (int)ceilf(versionRectF.Y);
    g_versionRect.right = (int)ceilf(versionRectF.X + versionRectF.Width);
    g_versionRect.bottom = (int)ceilf(versionRectF.Y + versionRectF.Height);

    // Apply rounded-rect alpha mask for smooth AA edges
    // (avoids jagged corners from hard SetClip boundaries)
    {
        void* pMaskBits = nullptr;
        HDC maskDC = CreateCompatibleDC(hdcScreen);
        HBITMAP maskBitmap = CreateDIBSection(hdcScreen, &bmi, DIB_RGB_COLORS, &pMaskBits, nullptr, 0);
        HBITMAP maskOldBitmap = (HBITMAP)SelectObject(maskDC, maskBitmap);

        Graphics maskGraphics(maskDC);
        maskGraphics.SetSmoothingMode(SmoothingModeAntiAlias);
        maskGraphics.ScaleTransform(g_dpiScale, g_dpiScale);
        maskGraphics.Clear(Color(0, 0, 0, 0));

        GraphicsPath roundedRect;
        int radius = CORNER_RADIUS;
        roundedRect.AddArc(0, 0, radius * 2, radius * 2, 180, 90);
        roundedRect.AddArc(WINDOW_WIDTH - radius * 2 - 1, 0, radius * 2, radius * 2, 270, 90);
        roundedRect.AddArc(WINDOW_WIDTH - radius * 2 - 1, WINDOW_HEIGHT - radius * 2 - 1, radius * 2, radius * 2, 0, 90);
        roundedRect.AddArc(0, WINDOW_HEIGHT - radius * 2 - 1, radius * 2, radius * 2, 90, 90);
        roundedRect.CloseFigure();

        SolidBrush maskBrush(Color(255, 255, 255, 255));
        maskGraphics.FillPath(&maskBrush, &roundedRect);

        // Multiply all channels by mask alpha (premultiplied-alpha safe)
        BYTE* content = (BYTE*)pBits;
        BYTE* mask = (BYTE*)pMaskBits;
        int count = scaledWidth * scaledHeight;
        for (int i = 0; i < count; i++)
        {
            BYTE ma = mask[i * 4 + 3];
            if (ma == 255) continue;
            content[i * 4 + 0] = (BYTE)((content[i * 4 + 0] * ma + 127) / 255);
            content[i * 4 + 1] = (BYTE)((content[i * 4 + 1] * ma + 127) / 255);
            content[i * 4 + 2] = (BYTE)((content[i * 4 + 2] * ma + 127) / 255);
            content[i * 4 + 3] = (BYTE)((content[i * 4 + 3] * ma + 127) / 255);
        }

        SelectObject(maskDC, maskOldBitmap);
        DeleteObject(maskBitmap);
        DeleteDC(maskDC);
    }

    ReleaseDC(nullptr, hdcScreen);
    g_contentDirty = false;
}

void PresentWindow(HWND hWnd, const POINT* pNewPos)
{
    if (!g_cachedDC) return;

    HDC hdcScreen = GetDC(nullptr);
    if (!g_pButtonFont)
        g_pButtonFont = std::make_unique<Font>(L"Segoe UI", 20, FontStyleBold, UnitPixel);
    if (!g_pMinButtonFont)
        g_pMinButtonFont = std::make_unique<Font>(L"Segoe UI", 18, FontStyleBold, UnitPixel);
    if (!g_pInfoButtonFont)
        g_pInfoButtonFont = std::make_unique<Font>(L"Segoe UI", 13, FontStyleBold, UnitPixel);
    if (!g_pConsoleFont)
        g_pConsoleFont = std::make_unique<Font>(L"Consolas", 13, FontStyleRegular, UnitPixel);
    if (!g_pVersionFont)
        g_pVersionFont = std::make_unique<Font>(L"Segoe UI", 12, FontStyleRegular, UnitPixel);
    int scaledWidth = (int)(WINDOW_WIDTH * g_dpiScale);
    int scaledHeight = (int)(WINDOW_HEIGHT * g_dpiScale);

    POINT ptSrc = { 0, 0 };
    POINT ptDst;
    POINT* pDst = nullptr;
    if (pNewPos)
    {
        ptDst = *pNewPos;
        pDst = &ptDst;
    }
    SIZE sizeWnd = { scaledWidth, scaledHeight };
    BYTE windowAlpha = (BYTE)(255 * g_windowOpacity);
    BLENDFUNCTION blend = { AC_SRC_OVER, 0, windowAlpha, AC_SRC_ALPHA };

    UpdateLayeredWindow(hWnd, hdcScreen, pDst, &sizeWnd, g_cachedDC, &ptSrc, 0, &blend, ULW_ALPHA);
    ReleaseDC(nullptr, hdcScreen);
}

void UpdateWindowGraphics(HWND hWnd)
{
    RenderContent(hWnd);
    PresentWindow(hWnd);
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    static POINT s_dragPoint;
    static bool s_isDragging = false;
    static bool s_wasMinimized = false;

    switch (message)
    {
    case WM_CREATE:
    {
        // Render the window graphics once
        UpdateWindowGraphics(hWnd);
        break;
    }

    case WM_LBUTTONDOWN:
    {
        POINT pt = { LOWORD(lParam), HIWORD(lParam) };

        // Scale mouse coordinates to logical coordinates
        pt.x = (LONG)(pt.x / g_dpiScale);
        pt.y = (LONG)(pt.y / g_dpiScale);

        // Check button clicks
        if (PtInRect(&g_closeBtn, pt))
        {
            if (!g_isClosing)
            {
                g_isClosing = true;
                StartWindowAnimation(WindowAnim::SlideOutClose, hWnd);
            }
            break;
        }
        else if (PtInRect(&g_minBtn, pt))
        {
            StartWindowAnimation(WindowAnim::FadeOutMinimize, hWnd);
            break;
        }
        else if (PtInRect(&g_infoBtn, pt))
        {
            ShellExecute(nullptr, L"open",
                L"https://github.com/DynamiByte/Endfield-Uncensored/blob/master/README.md",
                nullptr, nullptr, SW_SHOWNORMAL);
            break;
        }
        else if (PtInRect(&g_versionRect, pt))
        {
            // Open release tag for current VERSION macro
            std::wstring tag = VERSION;
            // Ensure tag starts with 'v'
            if (tag.empty() || (tag[0] != L'v' && tag[0] != L'V'))
                tag = std::wstring(L"v") + tag;

            std::wstring url = L"https://github.com/DynamiByte/Endfield-Uncensored/releases/tag/" + tag;
            ShellExecute(nullptr, L"open", url.c_str(), nullptr, nullptr, SW_SHOWNORMAL);
            break;
        }

        // Start dragging if not clicking a button
        s_isDragging = true;
        s_dragPoint.x = LOWORD(lParam);
        s_dragPoint.y = HIWORD(lParam);
        SetCapture(hWnd);
        break;
    }

    case WM_MOUSEMOVE:
    {
        POINT pt = { LOWORD(lParam), HIWORD(lParam) };

        if (s_isDragging)
        {
            POINT cursorPt;
            GetCursorPos(&cursorPt);
            SetWindowPos(hWnd, nullptr,
                cursorPt.x - s_dragPoint.x,
                cursorPt.y - s_dragPoint.y,
                0, 0, SWP_NOSIZE | SWP_NOZORDER);
        }
        else
        {
            // Enable mouse tracking for hover
            if (!g_mouseTracking)
            {
                TRACKMOUSEEVENT tme = {};
                tme.cbSize = sizeof(TRACKMOUSEEVENT);
                tme.dwFlags = TME_LEAVE;
                tme.hwndTrack = hWnd;
                TrackMouseEvent(&tme);
                g_mouseTracking = true;
            }

            // Scale mouse coordinates to logical coordinates
            pt.x = (LONG)(pt.x / g_dpiScale);
            pt.y = (LONG)(pt.y / g_dpiScale);

            // Update hover state
            int prevHover = g_hoveredButton;
            g_hoveredButton = 0;

            if (PtInRect(&g_closeBtn, pt))
                g_hoveredButton = 1;
            else if (PtInRect(&g_minBtn, pt))
                g_hoveredButton = 2;
            else if (PtInRect(&g_infoBtn, pt))
                g_hoveredButton = 3;
            else if (PtInRect(&g_versionRect, pt))
                g_hoveredButton = 4;

            // Update cursor: never use hand cursor on any button; always show arrow
            SetCursor(LoadCursor(nullptr, IDC_ARROW));

            // Start color animations if hover changed
            if (prevHover != g_hoveredButton)
            {
                // Animate old button back to default
                if (prevHover != 0)
                    StartButtonColorAnim(prevHover, Color(255, 51, 51, 51));

                // Animate new button to hover color
                if (g_hoveredButton == 1)
                    StartButtonColorAnim(1, Color(255, 255, 127, 80)); // Coral
                else if (g_hoveredButton == 2)
                    StartButtonColorAnim(2, Color(255, 218, 165, 32)); // Goldenrod
                else if (g_hoveredButton == 3)
                    StartButtonColorAnim(3, Color(255, 100, 149, 237)); // CornflowerBlue
                else if (g_hoveredButton == 4)
                    StartButtonColorAnim(4, Color(255, 100, 149, 237)); // Same as info (CornflowerBlue)
            }
        }
        break;
    }

    case WM_LBUTTONUP:
    {
        if (s_isDragging)
        {
            s_isDragging = false;
            ReleaseCapture();
        }
        break;
    }

    case WM_MOUSELEAVE:
    {
        g_mouseTracking = false;
        if (g_hoveredButton != 0)
        {
            StartButtonColorAnim(g_hoveredButton, Color(255, 51, 51, 51));
            g_hoveredButton = 0;
        }
        break;
    }

    case WM_TIMER:
    {
        if (wParam == TIMER_CLOSE_DELAY)
        {
            KillTimer(hWnd, TIMER_CLOSE_DELAY);
            DestroyWindow(hWnd);
        }
        break;
    }

    case WM_SIZE:
    {
        // Detect window restoration from minimized state
        if (wParam == SIZE_MINIMIZED)
        {
            s_wasMinimized = true;
        }
        else if (wParam == SIZE_RESTORED && s_wasMinimized)
        {
            s_wasMinimized = false;
            // Set opacity to 0 immediately to prevent flash
            g_windowOpacity = 0.0f;
            PresentWindow(hWnd);
            // Start fade-in animation on restore
            StartWindowAnimation(WindowAnim::FadeInRestore, hWnd);
        }
        break;
    }

    case WM_APPEND_OUTPUT:
    {
        // Append text to output buffer (replacing the previous "Closing in ..." line)
        wchar_t* pText = (wchar_t*)lParam;
        std::wstring incoming = pText;
        delete[] pText;

        bool replace = (wParam != 0);
        if (replace)
        {
            // Look for last occurrence of the closing countdown marker and replace that entire line
            const std::wstring marker = L"Closing in ";
            size_t pos = g_outputText.rfind(marker);
            if (pos != std::wstring::npos)
            {
                // find start of that line
                size_t lineStart = g_outputText.rfind(L"\r\n", pos);
                if (lineStart == std::wstring::npos)
                    lineStart = 0;
                else
                    lineStart += 2; // move past CRLF

                // find end of that line (include the trailing CRLF when present)
                size_t lineEnd = g_outputText.find(L"\r\n", pos);
                if (lineEnd == std::wstring::npos)
                    lineEnd = g_outputText.size();
                else
                    lineEnd += 2; // include CRLF

                // erase the old line (including terminating CRLF if it existed)
                g_outputText.erase(lineStart, lineEnd - lineStart);

                // Collapse any accidental double-CRLF sequences left behind so we don't get
                // an extra empty line before the replacement text.
                while (g_outputText.size() >= 4 &&
                       g_outputText.compare(g_outputText.size() - 4, 4, L"\r\n\r\n") == 0)
                {
                    // remove one CRLF (2 chars)
                    g_outputText.erase(g_outputText.size() - 2, 2);
                }
            }
        }

        // Append incoming text (which already includes CRLF)
        g_outputText += incoming;

        // Content changed, need full re-render
        g_contentDirty = true;
        RenderContent(hWnd);
        PresentWindow(hWnd);
        break;
    }

    case WM_CLOSE:
        if (!g_isClosing)
        {
            g_isClosing = true;
            StartWindowAnimation(WindowAnim::SlideOutClose, hWnd);
        }
        break;

    case WM_DESTROY:
        KillTimer(hWnd, TIMER_CLOSE_DELAY);
        FreeCachedBitmap();
        FreeGdiResources();
        PostQuitMessage(0);
        break;

    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}

// ============================================================================
// INJECTION AND HELPER FUNCTIONS
// ============================================================================

void AppendOutput(const std::wstring& text, bool replaceClosing)
{
    if (g_hWnd)
    {
        std::wstring fullText = text + L"\r\n";
        wchar_t* pText = new wchar_t[fullText.length() + 1];
        wcscpy_s(pText, fullText.length() + 1, fullText.c_str());
        PostMessage(g_hWnd, WM_APPEND_OUTPUT, replaceClosing ? 1 : 0, (LPARAM)pText);
    }
}

bool IsAdmin()
{
    BOOL isAdmin = FALSE;
    PSID administratorsGroup = nullptr;
    SID_IDENTIFIER_AUTHORITY ntAuthority = SECURITY_NT_AUTHORITY;

    if (AllocateAndInitializeSid(&ntAuthority, 2,
        SECURITY_BUILTIN_DOMAIN_RID,
        DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0,
        &administratorsGroup))
    {
        CheckTokenMembership(nullptr, administratorsGroup, &isAdmin);
        FreeSid(administratorsGroup);
    }

    return isAdmin == TRUE;
}

bool ExtractEmbeddedDll()
{
    // Create temp directory
    wchar_t tempPath[MAX_PATH];
    GetTempPath(MAX_PATH, tempPath);

    wchar_t uniqueDir[MAX_PATH];
    swprintf_s(uniqueDir, L"%sEndfieldUncensored_%08X\\", tempPath, GetTickCount());
    CreateDirectory(uniqueDir, nullptr);

    g_tempDllPath = std::wstring(uniqueDir) + DLL_NAME;


    // Extract DLL from resources
    HRSRC hRes = FindResource(g_hInst, MAKEINTRESOURCE(IDR_GAME_MOD), L"DLL");
    if (!hRes) return false;

    HGLOBAL hResData = LoadResource(g_hInst, hRes);
    if (!hResData) return false;

    void* pData = LockResource(hResData);
    DWORD size = SizeofResource(g_hInst, hRes);

    if (!pData || size == 0) return false;

    // Write to file
    HANDLE hFile = CreateFile(g_tempDllPath.c_str(), GENERIC_WRITE, 0, nullptr,
        CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);

    if (hFile == INVALID_HANDLE_VALUE) return false;

    DWORD written;
    BOOL result = WriteFile(hFile, pData, size, &written, nullptr);
    CloseHandle(hFile);

    return result && written == size;
}

void CleanupTempFiles()
{
    if (!g_tempDllPath.empty())
    {
        DeleteFile(g_tempDllPath.c_str());

        // Remove directory
        wchar_t dirPath[MAX_PATH];
        wcscpy_s(dirPath, g_tempDllPath.c_str());
        PathRemoveFileSpec(dirPath);
        RemoveDirectory(dirPath);
    }
}

DWORD FindTargetProcess(const wchar_t* name)
{
    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE) return 0;

    PROCESSENTRY32W pe = { sizeof(pe) };
    DWORD pid = 0;

    if (Process32FirstW(snapshot, &pe))
    {
        do
        {
            if (_wcsicmp(pe.szExeFile, name) == 0)
            {
                pid = pe.th32ProcessID;
                break;
            }
        } while (Process32NextW(snapshot, &pe));
    }

    CloseHandle(snapshot);
    return pid;
}

BOOL InjectDll(DWORD pid, const wchar_t* dllPath)
{
    HANDLE hProcess = OpenProcess(
        PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION |
        PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ,
        FALSE, pid);

    if (!hProcess) return FALSE;

    size_t pathSize = (wcslen(dllPath) + 1) * sizeof(wchar_t);
    LPVOID remoteMem = VirtualAllocEx(hProcess, nullptr, pathSize,
        MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);

    if (!remoteMem)
    {
        CloseHandle(hProcess);
        return FALSE;
    }

    if (!WriteProcessMemory(hProcess, remoteMem, dllPath, pathSize, nullptr))
    {
        VirtualFreeEx(hProcess, remoteMem, 0, MEM_RELEASE);
        CloseHandle(hProcess);
        return FALSE;
    }

    LPVOID loadLibAddr = (LPVOID)GetProcAddress(GetModuleHandleW(L"kernel32.dll"), "LoadLibraryW");
    HANDLE hThread = CreateRemoteThread(hProcess, nullptr, 0,
        (LPTHREAD_START_ROUTINE)loadLibAddr, remoteMem, 0, nullptr);

    if (hThread)
    {
        WaitForSingleObject(hThread, 5000);
        CloseHandle(hThread);
    }

    VirtualFreeEx(hProcess, remoteMem, 0, MEM_RELEASE);
    CloseHandle(hProcess);

    return hThread != nullptr;
}

void InjectionThreadProc()
{
    AppendOutput(L"Waiting for " + std::wstring(TARGET_EXE) + L"...");

    DWORD pid = 0;
    while ((pid = FindTargetProcess(TARGET_EXE)) == 0)
    {
        Sleep(100);
    }

    wchar_t pidText[64];
    swprintf_s(pidText, L"Process found (PID: %d)", pid);
    AppendOutput(pidText);

    Sleep(10);

    AppendOutput(L"Attempting injection...");

    if (InjectDll(pid, g_tempDllPath.c_str()))
    {
        AppendOutput(L"[OK] Injection successful!");

        for (int i = 5; i > 0; i--)
        {
            wchar_t countText[64];
            swprintf_s(countText, L"Closing in %d...", i);
            AppendOutput(countText, true);
            Sleep(1000);
        }

        PostMessage(g_hWnd, WM_CLOSE, 0, 0);
    }
    else
    {
        AppendOutput(L"[FAIL] Injection failed.");
    }
}

void StartInjectionThread()
{
    std::thread injectionThread(InjectionThreadProc);
    injectionThread.detach();
}

// ============================================================================
// SVG PATH PARSING
// ============================================================================

void ParseSVGPathToGDIPlus(const char* svgPath, GraphicsPath& gdiPath)
{
    float currentX = 0, currentY = 0;
    float startX = 0, startY = 0;
    float lastControlX = 0, lastControlY = 0;
    char lastCmd = 0;
    const char* p = svgPath;

    // Helper: skip whitespace and commas
    auto skipWhitespace = [&]() {
        while (*p && (*p == ' ' || *p == ',' || *p == '\t' || *p == '\n' || *p == '\r'))
            p++;
    };

    // Helper: parse a single number (handles decimals, negatives, and no-space concatenation)
    auto parseNumber = [&]() -> float {
        skipWhitespace();

        // Handle numbers that start with decimal point
        bool negative = false;
        if (*p == '-') {
            negative = true;
            p++;
        } else if (*p == '+') {
            p++;
        }

        float result = 0;
        bool hasDigits = false;

        // Parse integer part
        while (*p >= '0' && *p <= '9') {
            result = result * 10 + (*p - '0');
            hasDigits = true;
            p++;
        }

        // Parse decimal part
        if (*p == '.') {
            p++;
            float decimal = 0;
            float divisor = 10;
            while (*p >= '0' && *p <= '9') {
                decimal += (*p - '0') / divisor;
                divisor *= 10;
                hasDigits = true;
                p++;
            }
            result += decimal;
        }

        // Parse exponent (e.g., 1e-5)
        if (*p == 'e' || *p == 'E') {
            p++;
            bool expNegative = false;
            if (*p == '-') {
                expNegative = true;
                p++;
            } else if (*p == '+') {
                p++;
            }
            int exponent = 0;
            while (*p >= '0' && *p <= '9') {
                exponent = exponent * 10 + (*p - '0');
                p++;
            }
            if (expNegative) exponent = -exponent;
            result *= powf(10.0f, (float)exponent);
        }

        return negative ? -result : result;
    };

    // Helper: check if more numbers are available for the current command
    auto hasMoreNumbers = [&]() -> bool {
        skipWhitespace();
        return *p && (*p == '-' || *p == '+' || *p == '.' || (*p >= '0' && *p <= '9'));
    };

    while (*p) {
        skipWhitespace();
        if (!*p) break;

        // Check if it's a command or a number (for implicit commands)
        char cmd;
        if ((*p >= 'A' && *p <= 'Z') || (*p >= 'a' && *p <= 'z')) {
            cmd = *p++;
            lastCmd = cmd;
        } else {
            // Implicit command repetition
            cmd = lastCmd;
            // For M/m, subsequent coordinates are treated as L/l
            if (cmd == 'M') cmd = 'L';
            else if (cmd == 'm') cmd = 'l';
        }

        switch (cmd) {
        case 'M': // Move to (absolute)
        {
            currentX = startX = parseNumber();
            currentY = startY = parseNumber();
            gdiPath.StartFigure();

            // Subsequent coordinate pairs are treated as line-to
            while (hasMoreNumbers()) {
                currentX = parseNumber();
                currentY = parseNumber();
                gdiPath.AddLine(currentX - 0.01f, currentY - 0.01f, currentX, currentY);
            }
            break;
        }

        case 'm': // Move to (relative)
        {
            float dx = parseNumber();
            float dy = parseNumber();
            currentX = startX = currentX + dx;
            currentY = startY = currentY + dy;
            gdiPath.StartFigure();

            // Subsequent coordinate pairs are treated as line-to (relative)
            while (hasMoreNumbers()) {
                dx = parseNumber();
                dy = parseNumber();
                float newX = currentX + dx;
                float newY = currentY + dy;
                gdiPath.AddLine(currentX, currentY, newX, newY);
                currentX = newX;
                currentY = newY;
            }
            break;
        }

        case 'L': // Line to (absolute)
        {
            do {
                float x = parseNumber();
                float y = parseNumber();
                gdiPath.AddLine(currentX, currentY, x, y);
                currentX = x;
                currentY = y;
            } while (hasMoreNumbers());
            break;
        }

        case 'l': // Line to (relative)
        {
            do {
                float dx = parseNumber();
                float dy = parseNumber();
                float newX = currentX + dx;
                float newY = currentY + dy;
                gdiPath.AddLine(currentX, currentY, newX, newY);
                currentX = newX;
                currentY = newY;
            } while (hasMoreNumbers());
            break;
        }

        case 'H': // Horizontal line (absolute)
        {
            do {
                float x = parseNumber();
                gdiPath.AddLine(currentX, currentY, x, currentY);
                currentX = x;
            } while (hasMoreNumbers());
            break;
        }

        case 'h': // Horizontal line (relative)
        {
            do {
                float dx = parseNumber();
                float newX = currentX + dx;
                gdiPath.AddLine(currentX, currentY, newX, currentY);
                currentX = newX;
            } while (hasMoreNumbers());
            break;
        }

        case 'V': // Vertical line (absolute)
        {
            do {
                float y = parseNumber();
                gdiPath.AddLine(currentX, currentY, currentX, y);
                currentY = y;
            } while (hasMoreNumbers());
            break;
        }

        case 'v': // Vertical line (relative)
        {
            do {
                float dy = parseNumber();
                float newY = currentY + dy;
                gdiPath.AddLine(currentX, currentY, currentX, newY);
                currentY = newY;
            } while (hasMoreNumbers());
            break;
        }

        case 'C': // Cubic Bezier (absolute)
        {
            do {
                float x1 = parseNumber();
                float y1 = parseNumber();
                float x2 = parseNumber();
                float y2 = parseNumber();
                float x = parseNumber();
                float y = parseNumber();
                gdiPath.AddBezier(currentX, currentY, x1, y1, x2, y2, x, y);
                lastControlX = x2;
                lastControlY = y2;
                currentX = x;
                currentY = y;
            } while (hasMoreNumbers());
            break;
        }

        case 'c': // Cubic Bezier (relative)
        {
            do {
                float dx1 = parseNumber();
                float dy1 = parseNumber();
                float dx2 = parseNumber();
                float dy2 = parseNumber();
                float dx = parseNumber();
                float dy = parseNumber();
                float x1 = currentX + dx1;
                float y1 = currentY + dy1;
                float x2 = currentX + dx2;
                float y2 = currentY + dy2;
                float x = currentX + dx;
                float y = currentY + dy;
                gdiPath.AddBezier(currentX, currentY, x1, y1, x2, y2, x, y);
                lastControlX = x2;
                lastControlY = y2;
                currentX = x;
                currentY = y;
            } while (hasMoreNumbers());
            break;
        }

        case 'S': // Smooth cubic Bezier (absolute)
        {
            do {
                float x2 = parseNumber();
                float y2 = parseNumber();
                float x = parseNumber();
                float y = parseNumber();
                // Reflect last control point
                float x1 = 2 * currentX - lastControlX;
                float y1 = 2 * currentY - lastControlY;
                gdiPath.AddBezier(currentX, currentY, x1, y1, x2, y2, x, y);
                lastControlX = x2;
                lastControlY = y2;
                currentX = x;
                currentY = y;
            } while (hasMoreNumbers());
            break;
        }

        case 's': // Smooth cubic Bezier (relative)
        {
            do {
                float dx2 = parseNumber();
                float dy2 = parseNumber();
                float dx = parseNumber();
                float dy = parseNumber();
                float x2 = currentX + dx2;
                float y2 = currentY + dy2;
                float x = currentX + dx;
                float y = currentY + dy;
                float x1 = 2 * currentX - lastControlX;
                float y1 = 2 * currentY - lastControlY;
                gdiPath.AddBezier(currentX, currentY, x1, y1, x2, y2, x, y);
                lastControlX = x2;
                lastControlY = y2;
                currentX = x;
                currentY = y;
            } while (hasMoreNumbers());
            break;
        }

        case 'Q': // Quadratic Bezier (absolute)
        {
            do {
                float x1 = parseNumber();
                float y1 = parseNumber();
                float x = parseNumber();
                float y = parseNumber();
                // Convert quadratic to cubic
                float cx1 = currentX + 2.0f/3.0f * (x1 - currentX);
                float cy1 = currentY + 2.0f/3.0f * (y1 - currentY);
                float cx2 = x + 2.0f/3.0f * (x1 - x);
                float cy2 = y + 2.0f/3.0f * (y1 - y);
                gdiPath.AddBezier(currentX, currentY, cx1, cy1, cx2, cy2, x, y);
                lastControlX = x1;
                lastControlY = y1;
                currentX = x;
                currentY = y;
            } while (hasMoreNumbers());
            break;
        }

        case 'q': // Quadratic Bezier (relative)
        {
            do {
                float dx1 = parseNumber();
                float dy1 = parseNumber();
                float dx = parseNumber();
                float dy = parseNumber();
                float x1 = currentX + dx1;
                float y1 = currentY + dy1;
                float x = currentX + dx;
                float y = currentY + dy;
                float cx1 = currentX + 2.0f/3.0f * (x1 - currentX);
                float cy1 = currentY + 2.0f/3.0f * (y1 - currentY);
                float cx2 = x + 2.0f/3.0f * (x1 - x);
                float cy2 = y + 2.0f/3.0f * (y1 - y);
                gdiPath.AddBezier(currentX, currentY, cx1, cy1, cx2, cy2, x, y);
                lastControlX = x1;
                lastControlY = y1;
                currentX = x;
                currentY = y;
            } while (hasMoreNumbers());
            break;
        }

        case 'A': // Arc (absolute) - simplified to line
        case 'a': // Arc (relative) - simplified to line
        {
            do {
                // Skip arc parameters (rx, ry, x-axis-rotation, large-arc-flag, sweep-flag)
                parseNumber(); // rx
                parseNumber(); // ry
                parseNumber(); // rotation
                parseNumber(); // large-arc
                parseNumber(); // sweep
                float x = parseNumber();
                float y = parseNumber();
                if (cmd == 'a') {
                    x += currentX;
                    y += currentY;
                }
                gdiPath.AddLine(currentX, currentY, x, y);
                currentX = x;
                currentY = y;
            } while (hasMoreNumbers());
            break;
        }

        case 'Z': // Close path
        case 'z':
            gdiPath.CloseFigure();
            currentX = startX;
            currentY = startY;
            break;

        default:
            // Unknown command - try to skip it
            break;
        }
    }
}

// ============================================================================
// ANIMATION SYSTEM
// ============================================================================

Color LerpColor(const Color& a, const Color& b, float t)
{
    t = max(0.0f, min(1.0f, t));
    return Color(
        (BYTE)(a.GetA() + (b.GetA() - a.GetA()) * t),
        (BYTE)(a.GetR() + (b.GetR() - a.GetR()) * t),
        (BYTE)(a.GetG() + (b.GetG() - a.GetG()) * t),
        (BYTE)(a.GetB() + (b.GetB() - a.GetB()) * t)
    );
}

float EaseOutQuad(float t)
{
    return 1.0f - (1.0f - t) * (1.0f - t);
}

float EaseInQuad(float t)
{
    return t * t;
}

void StartButtonColorAnim(int buttonId, const Color& target)
{
    if (buttonId < 1 || buttonId > 4) return;

    g_buttonAnims[buttonId].start = g_buttonAnims[buttonId].current;
    g_buttonAnims[buttonId].target = target;
    g_buttonAnims[buttonId].startTime = GetPreciseTimeMs();
    g_buttonAnims[buttonId].animating = true;
}

void StartWindowAnimation(WindowAnim::Type type, HWND hWnd)
{
    g_windowAnim.type = type;
    g_windowAnim.startTime = GetPreciseTimeMs();

    RECT rect;
    GetWindowRect(hWnd, &rect);
    g_windowAnim.startOpacity = g_windowOpacity;
    g_windowAnim.startX = rect.left;

    if (type == WindowAnim::SlideIn)
    {
        g_windowOpacity = 0.0f;
        // Start 50 pixels BELOW target position (slide UP)
        int startPos = rect.top + (int)(50 * g_dpiScale);
        g_windowAnim.startY = startPos;
        // Move to start position atomically via PresentWindow
        POINT pt = { rect.left, startPos };
        PresentWindow(hWnd, &pt);
    }
    else if (type == WindowAnim::FadeInRestore)
    {
        g_windowOpacity = 0.0f;
        g_windowAnim.startY = rect.top;
    }
    else
    {
        g_windowAnim.startY = rect.top;
    }
}

void UpdateAnimations(HWND hWnd)
{
    bool needsContentRender = false;
    bool needsPresent = false;
    POINT newPos = {};
    bool hasNewPos = false;
    double currentTime = GetPreciseTimeMs();

    // Update button color animations (require content re-render)
    for (int i = 1; i <= 4; i++)
    {
        if (g_buttonAnims[i].animating)
        {
            float elapsed = (float)(currentTime - g_buttonAnims[i].startTime) / 100.0f; // 100ms duration

            if (elapsed >= 1.0f)
            {
                g_buttonAnims[i].current = g_buttonAnims[i].target;
                g_buttonAnims[i].animating = false;
            }
            else
            {
                float t = EaseOutQuad(elapsed);
                g_buttonAnims[i].current = LerpColor(g_buttonAnims[i].start, g_buttonAnims[i].target, t);
            }
            needsContentRender = true;
        }
    }

    // Update window animations (only need cheap PresentWindow for opacity/position)
    if (g_windowAnim.type != WindowAnim::None)
    {
        switch (g_windowAnim.type)
        {
        case WindowAnim::SlideIn:
        {
            float elapsed = (float)(currentTime - g_windowAnim.startTime) / 500.0f; // 500ms
            if (elapsed >= 1.0f)
            {
                g_windowAnim.type = WindowAnim::None;
                g_windowOpacity = 1.0f;

                newPos = { g_windowAnim.startX, g_windowAnim.startY - (int)(50 * g_dpiScale) };
                hasNewPos = true;
                needsPresent = true;
            }
            else
            {
                float t = EaseOutQuad(elapsed);
                int newY = (int)(g_windowAnim.startY - 50 * g_dpiScale * t);

                newPos = { g_windowAnim.startX, newY };
                hasNewPos = true;
                g_windowOpacity = t;
                needsPresent = true;
            }
            break;
        }

        case WindowAnim::SlideOutClose:
        {
            float elapsed = (float)(currentTime - g_windowAnim.startTime) / 250.0f; // 250ms — snappier than 300
            if (elapsed >= 1.0f)
            {
                // Render final frame at full displacement / zero opacity
                g_windowOpacity = 0.0f;
                newPos = { g_windowAnim.startX, g_windowAnim.startY + (int)(80 * g_dpiScale) };
                hasNewPos = true;
                needsPresent = true;

                g_windowAnim.type = WindowAnim::None;
                SetTimer(hWnd, TIMER_CLOSE_DELAY, 10, nullptr);
            }
            else
            {
                // Cubic ease-in (t^3) — slow start, aggressive acceleration at end
                float t = elapsed * elapsed * elapsed;
                int newY = (int)(g_windowAnim.startY + 80 * g_dpiScale * t);

                newPos = { g_windowAnim.startX, newY };
                hasNewPos = true;
                // Fade opacity faster so window is mostly gone by the time it's moving fast
                float fadeT = elapsed * elapsed;
                g_windowOpacity = 1.0f - fadeT;
                needsPresent = true;
            }
            break;
        }

        case WindowAnim::FadeOutMinimize:
        {
            float elapsed = (float)(currentTime - g_windowAnim.startTime) / 200.0f; // 200ms
            if (elapsed >= 1.0f)
            {
                g_windowAnim.type = WindowAnim::None;
                g_windowOpacity = 0.0f;
                ShowWindow(hWnd, SW_MINIMIZE);
            }
            else
            {
                g_windowOpacity = 1.0f - elapsed;
            }
            needsPresent = true;
            break;
        }

        case WindowAnim::FadeInRestore:
        {
            float elapsed = (float)(currentTime - g_windowAnim.startTime) / 300.0f; // 300ms
            if (elapsed >= 1.0f)
            {
                g_windowAnim.type = WindowAnim::None;
                g_windowOpacity = 1.0f;
            }
            else
            {
                g_windowOpacity = elapsed;
            }
            needsPresent = true;
            break;
        }
        }
    }

    if (needsContentRender)
    {
        RenderContent(hWnd);
        PresentWindow(hWnd, hasNewPos ? &newPos : nullptr);
    }
    else if (needsPresent)
    {
        if (!g_cachedDC)
            RenderContent(hWnd);
        PresentWindow(hWnd, hasNewPos ? &newPos : nullptr);
    }
}
