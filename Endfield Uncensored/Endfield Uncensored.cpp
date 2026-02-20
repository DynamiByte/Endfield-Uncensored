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

#include <fstream>
#include <regex>
#include <sstream>

static bool ContainsEndfieldExe(const std::wstring& dir) {
    WIN32_FIND_DATAW findData;
    std::wstring pattern = dir + L"\\*";
    HANDLE hFind = FindFirstFileW(pattern.c_str(), &findData);
    if (hFind == INVALID_HANDLE_VALUE) return false;
    do {
        if (!(findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
            std::wstring name = findData.cFileName;
            std::transform(name.begin(), name.end(), name.begin(), ::towlower);
            if (name == L"endfield.exe")
            {
                FindClose(hFind);
                return true;
            }
        }
    } while (FindNextFileW(hFind, &findData));
    FindClose(hFind);
    return false;
}

static std::wstring DetectGameExe() {
    // Try Player.log
    wchar_t* appdata = nullptr;
    size_t len = 0;
    _wdupenv_s(&appdata, &len, L"APPDATA");
    if (appdata) {
        std::wstring logPath = std::wstring(appdata);
        free(appdata);
        size_t pos = logPath.find_last_of(L"\\/");
        if (pos != std::wstring::npos) logPath = logPath.substr(0, pos);
        logPath += L"\\LocalLow\\Gryphline\\Endfield\\Player.log";
        std::wifstream fin(logPath);
        if (fin) {
            std::wregex re(L"([a-zA-Z]:[\\\\/][^\r\n]*?EndField[^\r\n]*)", std::regex_constants::icase);
            std::wstring line, match;
            while (std::getline(fin, line)) {
                std::wsmatch m;
                if (std::regex_search(line, m, re)) {
                    match = m[1].str();
                    std::wstring low = match;
                    std::transform(low.begin(), low.end(), low.begin(), ::towlower);
                    size_t pos = low.rfind(L"endfield_data");
                    if (pos != std::wstring::npos) {
                        match = match.substr(0, pos);
                    }
                    match.erase(match.find_last_not_of(L"\\/") + 1);
                    if (ContainsEndfieldExe(match)) {
                        return match + L"\\Endfield.exe";
                    }
                }
            }
        }
    }

    // Known install locations
    std::vector<std::wstring> knownPaths = {
        L"C:\\Program Files\\GRYPHLINK\\games\\EndField Game"
    };
    for (wchar_t d = L'D'; d <= L'Z'; ++d)
        knownPaths.push_back(std::wstring(1, d) + L":\\GRYPHLINK\\games\\EndField Game");
    // idk why not use a floppy drive letter
    knownPaths.push_back(L"A:\\GRYPHLINK\\games\\EndField Game");
    knownPaths.push_back(L"B:\\GRYPHLINK\\games\\EndField Game");

    for (const auto& dir : knownPaths) {
        if (ContainsEndfieldExe(dir)) {
            return dir + L"\\Endfield.exe";
        }
    }
    return L"";
}

using namespace Gdiplus;

constexpr UINT WM_APPEND_OUTPUT = WM_USER + 1;
constexpr UINT WM_CLEAR_OUTPUT = WM_USER + 2;
constexpr int WINDOW_WIDTH = 500;
constexpr int WINDOW_HEIGHT = 200;
constexpr int CORNER_RADIUS = 15;
constexpr wchar_t TARGET_EXE[] = L"Endfield.exe";
constexpr wchar_t DLL_NAME[] = L"EFU.dll";

HINSTANCE g_hInst = nullptr;
HWND g_hWnd = nullptr;
std::wstring g_tempDllPath;
std::wstring g_outputText;
bool g_isClosing = false;
float g_windowOpacity = 1.0f;
float g_dpiScale = 1.0f;

// UI state
std::wstring g_gameExePath;
RECT g_launchBtn = { 350, 150, 480, 185 };
RECT g_minOnLoadBtn = { 290, 10, 430, 32 };
bool g_launchBtnEnabled = false;
float g_launchBtnAnim = 0.0f;
float g_launchBtnAnimTarget = 0.0f;
double g_launchBtnAnimStartTime = 0.0;
float g_launchBtnAnimStartValue = 0.0f;
bool g_launchBtnAnimating = false;

float g_minOnLoadBtnAnim = 0.0f;
float g_minOnLoadBtnAnimTarget = 0.0f;
double g_minOnLoadBtnAnimStartTime = 0.0;
float g_minOnLoadBtnAnimStartValue = 0.0f;
bool g_minOnLoadBtnAnimating = false;
Color g_minOnLoadBtnColor = Color(255, 220, 220, 220);
Color g_minOnLoadBtnTargetColor = Color(255, 255, 250, 0);
Color g_minOnLoadBtnCurrentColor = Color(255, 220, 220, 220);
bool g_minimizeOnInject = false;

// Layered window bitmap
HDC g_cachedDC = nullptr;
HBITMAP g_cachedBitmap = nullptr;
HBITMAP g_cachedOldBitmap = nullptr;
bool g_contentDirty = true;

// GDI+ resources
static std::unique_ptr<Gdiplus::GraphicsPath> g_pLogoPath;
static std::unique_ptr<Gdiplus::GraphicsPath> g_pTextPath;
static std::unique_ptr<Gdiplus::Font> g_pButtonFont;
static std::unique_ptr<Gdiplus::Font> g_pMinButtonFont;
static std::unique_ptr<Gdiplus::Font> g_pInfoButtonFont;
static std::unique_ptr<Gdiplus::Font> g_pConsoleFont;
static std::unique_ptr<Gdiplus::Font> g_pVersionFont;

LARGE_INTEGER g_qpcFrequency;

static inline double GetPreciseTimeMs()
{
    LARGE_INTEGER now;
    QueryPerformanceCounter(&now);
    return (double)now.QuadPart * 1000.0 / (double)g_qpcFrequency.QuadPart;
}


// UI geometry and animation
int g_hoveredButton = 0;
bool g_mouseTracking = false;
RECT g_closeBtn = { 465, 2, 495, 32 };
RECT g_minBtn = { 443, 0, 460, 32 };
float g_closeBtnYOffset = 1.8f;
float g_minBtnYOffset = 1.5f;
float g_minOnLoadBtnYOffset = -1.3f;
const int g_minBtnHitPad = 5;
RECT g_infoBtn = { 7, 7, 27, 27 };
RECT g_outputRect = { 252, 42, 476, 157 };
RECT g_versionRect = { 10, 175, 250, 195 };

constexpr int TIMER_ANIMATION = 1;
constexpr int TIMER_CLOSE_DELAY = 2;
struct ButtonColorAnim {
    Color start;
    Color current;
    Color target;
    double startTime;
    bool animating;
} g_buttonAnims[5] = {};

struct WindowAnim {
    enum Type { None, SlideIn, SlideOutClose, FadeOutMinimize, FadeInRestore } type = None;
    double startTime = 0.0;
    int startX = 0;
    int startY = 0;
    double startOpacity = 0.0;
} g_windowAnim;

// Declarations
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
void StartLoaderThread();
DWORD FindTargetProcess(const wchar_t* name);
BOOL LoadDll(DWORD pid, const wchar_t* dllPath);
bool ExtractEmbeddedDll();
bool IsAdmin();
void AppendOutput(const std::wstring& text, bool replaceClosing = false);
void CleanupTempFiles();
void RenderContent(HWND hWnd);
void PresentWindow(HWND hWnd, const POINT* pNewPos = nullptr);
void UpdateWindowGraphics(HWND hWnd);
float EaseOutQuad(float t);
void StartButtonColorAnim(int buttonId, const Color& target);
void UpdateAnimations(HWND hWnd);
void StartWindowAnimation(WindowAnim::Type type, HWND hWnd);
void ParseSVGPathToGDIPlus(const char* svgPath, GraphicsPath& gdiPath);
void FreeCachedBitmap();

// Helper: returns true if any UI animation is running
static bool AnyUIAnimating()
{
    if (g_windowAnim.type != WindowAnim::None) return true;
    for (int i = 1; i <= 4; i++)
        if (g_buttonAnims[i].animating) return true;
    if (g_launchBtnAnimating) return true;
    if (g_minOnLoadBtnAnimating) return true;
    return false;
}

static inline bool IsAnimating()
{
    if (g_windowAnim.type != WindowAnim::None) return true;
    for (int i = 1; i <= 4; i++)
        if (g_buttonAnims[i].animating) return true;
    if (g_launchBtnAnimating) return true;
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
        if (SetProcessDpiAwarenessContextFunc) SetProcessDpiAwarenessContextFunc(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
        else
        {
            // Fallback for older Windows 10 versions
            typedef HRESULT(WINAPI* SetProcessDpiAwarenessProc)(int);
            HMODULE shcore = LoadLibraryW(L"shcore.dll");
            if (shcore)
            {
                auto SetProcessDpiAwarenessFunc = (SetProcessDpiAwarenessProc)GetProcAddress(shcore, "SetProcessDpiAwareness");
                if (SetProcessDpiAwarenessFunc) SetProcessDpiAwarenessFunc(2);
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

    // detect game exe
    g_gameExePath = DetectGameExe();
    g_launchBtnEnabled = !g_gameExePath.empty();
    if (g_launchBtnEnabled) {
        AppendOutput(L"Game found!");
        AppendOutput(L"You can now launch the game here or from the official launcher.");
    } else {
        AppendOutput(L"Game not found.");
        AppendOutput(L"Please launch the game from the official launcher.");
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

    if (!RegisterClassExW(&wcex)) return 1;

    // DPI for scaling stuff
    HDC hdcScreen = GetDC(nullptr);
    int dpiX = GetDeviceCaps(hdcScreen, LOGPIXELSX);
    ReleaseDC(nullptr, hdcScreen);
    g_dpiScale = dpiX / 96.0f; // default

    int scaledWidth = (int)(WINDOW_WIDTH * g_dpiScale);
    int scaledHeight = (int)(WINDOW_HEIGHT * g_dpiScale);

    int screenWidth = GetSystemMetrics(SM_CXSCREEN);
    int screenHeight = GetSystemMetrics(SM_CYSCREEN);
    int posX = (screenWidth - scaledWidth) / 2;
    int posY = (screenHeight - scaledHeight) / 2;

    g_hWnd = CreateWindowExW(
        WS_EX_LAYERED,
        L"EndfieldUncensoredClass",
        L"Endfield Uncensored",
        WS_POPUP,
        posX, posY,
        scaledWidth, scaledHeight,
        nullptr, nullptr, hInstance, nullptr);
    if (!g_hWnd) return 1;

    g_windowOpacity = 0.0f;
    UpdateWindowGraphics(g_hWnd);
    ShowWindow(g_hWnd, nCmdShow);
    StartWindowAnimation(WindowAnim::SlideIn, g_hWnd);
    StartLoaderThread();

    MSG msg = {};
    bool timerActive = false;
    while (msg.message != WM_QUIT)
    {
        if (AnyUIAnimating())
        {
            if (!timerActive) {
                SetTimer(g_hWnd, TIMER_ANIMATION, 16, NULL);
                timerActive = true;
            }
        } else if (timerActive) {
            KillTimer(g_hWnd, TIMER_ANIMATION);
            timerActive = false;
        }
        if (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE))
        {
            if (msg.message == WM_QUIT) break;
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
        else
        {
            Sleep(1);
        }
    }
    CleanupTempFiles();
    GdiplusShutdown(gdiplusToken);
    timeEndPeriod(1);

    return (int)msg.wParam;
}

static void FreeCachedBitmap()
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

static void FreeGdiResources()
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

static void RenderContent(HWND hWnd)
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
    if (!g_cachedBitmap) {
        DeleteDC(g_cachedDC);
        g_cachedDC = nullptr;
        ReleaseDC(nullptr, hdcScreen);
        return;
    }
    g_cachedOldBitmap = (HBITMAP)SelectObject(g_cachedDC, g_cachedBitmap);

    Graphics graphics(g_cachedDC);
    graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    graphics.SetTextRenderingHint(TextRenderingHintAntiAlias);
    graphics.ScaleTransform(g_dpiScale, g_dpiScale);
    graphics.Clear(Color(255, 255, 255, 255));

	// Yellow half of window
    {
        GraphicsState bgState = graphics.Save();

        float rectLeft = -95.0f;
        float rectTop = 1.0f;
        float rectWidth = 403.0f;
        float rectHeight = 194.0f;

        float pivotX = rectLeft + rectWidth * 0.3f;
        float pivotY = rectTop + rectHeight * 0.5f;

        graphics.TranslateTransform(pivotX, pivotY);
        graphics.RotateTransform(-45.0f);
        graphics.TranslateTransform(-pivotX, -pivotY);

        SolidBrush yellowBrush(Color(255, 255, 250, 0));
        graphics.FillRectangle(&yellowBrush, rectLeft, rectTop, rectWidth, rectHeight);

        graphics.Restore(bgState);
    }

    // Render the logo
    {
        static GraphicsPath* pLogoPath = nullptr;
        if (!pLogoPath)
        {
            pLogoPath = new GraphicsPath(); // SVG path from the official Endfield website
            const char* logoSVG = "M3.37,13.25h7.9V9.68H3.37V7.37H9.68L11.46,5.6V3.82H0V19.45H11.6V15.81H3.37ZM7.52,1.18h.23l.36.62h.52L8.2,1.1A.51.51,0,0,0,8.53.59C8.53.16,8.19,0,7.77,0H7.05V1.8h.47Zm0-.81h.21c.22,0,.34,0,.34.22S8,.84,7.73.84H7.52ZM0,37H3.38V30.8H11V27.24H3.38v-2.3h7.8V21.41H0ZM.59,1.4h.58l.12.4h.49L1.17,0H.61L0,1.8H.48ZM.73.92C.78.74.83.54.88.35h0c0,.18.1.39.15.57l0,.15H.68Zm54.69.55a.82.82,0,0,1-.48-.18l-.27.29a1.19,1.19,0,0,0,.74.26c.47,0,.74-.26.74-.56A.49.49,0,0,0,55.77.8L55.52.71c-.17-.06-.3-.1-.3-.2s.09-.15.24-.15a.67.67,0,0,1,.4.14L56.1.23A1,1,0,0,0,55.46,0c-.42,0-.71.24-.71.54a.52.52,0,0,0,.39.48l.26.1c.16.06.27.09.27.2S55.59,1.47,55.42,1.47ZM12.46,37h3.39V26.09H12.5l3.35-3.34V21.41H12.46ZM21.35,1.22c0-.22,0-.46-.06-.66h0l.19.39L22,1.8h.48V0H22V.62a6.26,6.26,0,0,0,.06.65h0L21.87.88,21.38,0H20.9V1.8h.45ZM28.45,0H28V1.8h.48ZM39.34,19a6.45,6.45,0,0,0,2.22-1.22A5.88,5.88,0,0,0,42.9,16a7.87,7.87,0,0,0,.69-2,11.46,11.46,0,0,0,.18-2.09v-.63a11,11,0,0,0-.14-1.77,9.85,9.85,0,0,0-.45-1.69,4.78,4.78,0,0,0-.89-1.55A7.34,7.34,0,0,0,40.89,5a6.33,6.33,0,0,0-2-.85,12.06,12.06,0,0,0-2.74-.29H28.9V19.45h7.21A9.93,9.93,0,0,0,39.34,19Zm-7-3.28H28.94l3.36-3.36V7.52h3.54c2.91,0,4.36,1.33,4.36,4v.12q0,4-4.36,4ZM41.42,1.08h.65V1.8h.46V0h-.46V.71h-.65V0H41V1.8h.47Zm7,.72h.47V.39h.53V0H47.9V.39h.53Zm-13.59,0a1,1,0,0,0,.65-.22V.79h-.73v.35h.32v.29a.53.53,0,0,1-.19,0,.49.49,0,0,1-.54-.56.5.5,0,0,1,.5-.55.53.53,0,0,1,.36.14l.25-.27A.91.91,0,0,0,34.83,0a.91.91,0,0,0-1,.93A.88.88,0,0,0,34.84,1.84Zm-20.39-.5.21-.26.46.72h.52L14.93.74l.6-.71H15l-.56.7h0V0H14V1.8h.48Zm6.46,29.43h7.9V27.2h-7.9V24.88h6.33L29,23.13v-1.8H17.55V37h11.6V33.33H20.91Zm38.47,0h-.09v.12h.09ZM27.18,16.12V3.87H23.82v9.81L16.9,3.87H13.12v15.6h3.35V9.14l7.35,10.33ZM59.38,31h-.09v.13h.09Zm.56,0h-.18v.11h.18Zm8.89,2H66.91v.46h1.57v.74H66.91v.15l1.82,1.26v-.36l.5-.18V33.68h-.4ZM58.64,21.41V36.9h15.5V21.41Zm3.56,9.26h.22a.56.56,0,0,0,0-.12h.2l-.07.11h.32V31H63v.15h-.13v.25c0,.07,0,.11-.06.13a.36.36,0,0,1-.19,0,.42.42,0,0,0,0-.15h.1s0,0,0,0v-.24h-.39a.64.64,0,0,1-.2.42.63.63,0,0,0-.12-.11.52.52,0,0,0,.16-.31h-.14V31h.15Zm.38.75a.73.73,0,0,0-.18-.16l.1-.08a.55.55,0,0,1,.19.14Zm-1.51-.55v-.15h.45a.75.75,0,0,0-.06-.13l.16-.06s.06.12.08.16l-.08,0h.44v.15h-.55a.37.37,0,0,1,0,.11H62v.07c0,.29,0,.41-.09.46a.2.2,0,0,1-.13.06h-.19a.32.32,0,0,0-.06-.15h.24s0-.11.06-.28h-.32a.65.65,0,0,1-.31.46.45.45,0,0,0-.11-.13.61.61,0,0,0,.28-.59Zm-.87-.26H61v1h-.17V31.5h-.45v.07H60.2Zm-.59,0h.48v.82c0,.08,0,.12-.06.14a.38.38,0,0,1-.2,0,.47.47,0,0,0-.06-.15h.14s0,0,0,0v-.17h-.2a.54.54,0,0,1-.18.35.58.58,0,0,0-.12-.1.61.61,0,0,0,.17-.5Zm-.47,0h.38v.67h-.23v.09h-.15Zm0,2.74L60,31.76h.92l-1.23,2.33h-.57Zm2,2.84-2,.4v-.7l2-.41Zm12.79.41H71.45l-.72-.37V34.37l-.42.16v-.85h-.24v1l.46-.17v1l-1.62.6v.44l-2-1.42v1.38H66V35.21L64,36.6H62.82l-1.67-1.19.62-.46,1.65,1.14L66,34.31v-.15H64.41v-.74H66V33h-2v.18l-.86.6,1,.64v.88l-1.6-1.1-1.47,1v.12l-1.92.41v-.25l1.6-2.76H61l.68-.91h.9l-.32.43H66v-.46h.92v.46h2v.72h.27V32h.84v.94h.46v.6l.2-.08V32.29h.84v.85l.21-.08v-1.3h.84v1l1-.4v2.54l-.84.35V33.57l-.21.08V35.3l-.84.35V34l-.21.08v1.78h2.32Zm-12-1.78.63-.46.86.59v.92Zm.59-1.5L63,33H61.89Zm-2.5-2.58h-.18v.11h.18Zm1.14,3.07h-.21l-.43.83.38-.09v-.1l1-.72-.47-.32ZM42.62,33.2h0ZM34.05,21.39H30.66V37H41.59V33.11H34.05Zm22.86,3.87A4.74,4.74,0,0,0,56,23.72a6.75,6.75,0,0,0-1.4-1.24,6.06,6.06,0,0,0-2-.85,11.64,11.64,0,0,0-2.75-.3h-7.2V33.19l3.4-3.4V25h3.54q4.36,0,4.36,4v.13q0,4-4.36,4H42.63V37h7.22a9.91,9.91,0,0,0,3.22-.48,6.29,6.29,0,0,0,2.22-1.22,5.84,5.84,0,0,0,1.34-1.78,7.62,7.62,0,0,0,.69-2,11.54,11.54,0,0,0,.18-2.09v-.63A11.17,11.17,0,0,0,57.36,27,9.43,9.43,0,0,0,56.91,25.26Zm3.91,5.51h-.45V31h.45Zm0,.36h-.45v.21h.45Zm1.59-.23.1-.08h-.15V31h.19A.55.55,0,0,0,62.41,30.9Zm.17.12h.16v-.2h-.22a.61.61,0,0,1,.15.12Z";
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

        // "UNCENSORED" text below the logo
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
        g_pVersionFont = std::make_unique<Font>(L"Consolas", 12, FontStyleRegular, UnitPixel);

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

    // close button
    float closeYOffset = g_closeBtnYOffset;
    RectF closeRectF(
        static_cast<REAL>(g_closeBtn.left),
        static_cast<REAL>(g_closeBtn.top + closeYOffset),
        static_cast<REAL>(g_closeBtn.right - g_closeBtn.left),
        static_cast<REAL>(g_closeBtn.bottom - g_closeBtn.top));
    {
        Color col = g_buttonAnims[1].current;
        REAL stroke = max(1.0f, min(closeRectF.Width, closeRectF.Height) * 0.07f);
        Pen pen(col, stroke);
        pen.SetLineJoin(LineJoinMiter);
        pen.SetStartCap(LineCapFlat);
        pen.SetEndCap(LineCapFlat);

        float cx = closeRectF.X + closeRectF.Width * 0.5f;
        float cy = closeRectF.Y + closeRectF.Height * 0.5f;
        float pad = min(closeRectF.Width, closeRectF.Height) * 0.24f;
        float x1 = cx - pad;
        float y1 = cy - pad;
        float x2 = cx + pad;
        float y2 = cy + pad;

        graphics.DrawLine(&pen, x1, y1, x2, y2);
        graphics.DrawLine(&pen, x1, y2, x2, y1);
    }

    // minimize button
    float minYOffset = g_minBtnYOffset;
    RectF minRectF(
        static_cast<REAL>(g_minBtn.left),
        static_cast<REAL>(g_minBtn.top + minYOffset),
        static_cast<REAL>(g_minBtn.right - g_minBtn.left),
        static_cast<REAL>(g_minBtn.bottom - g_minBtn.top));
    {
        Color col = g_buttonAnims[2].current;
        REAL strokeLogical = max(1.0f, min(static_cast<REAL>(g_closeBtn.right - g_closeBtn.left), static_cast<REAL>(g_closeBtn.bottom - g_closeBtn.top)) * 0.08f);
        float barLength = minRectF.Width * 0.95f;
        float xStart = minRectF.X + (minRectF.Width - barLength) * 0.5f;
        float cy = minRectF.Y + minRectF.Height * 0.57f;

        GraphicsState gs = graphics.Save();
        graphics.ResetTransform();

        float dx = xStart * g_dpiScale;
        float dy = cy * g_dpiScale;
        float dlen = barLength * g_dpiScale;
        float dstroke = strokeLogical * g_dpiScale;

        int left = (int)roundf(dx);
        int top = (int)roundf(dy - dstroke * 0.5f);
        int width = (int)roundf(dlen);
        int height = (int)max(1.0f, dstroke);

        if (pBits)
        {
            BYTE* content = (BYTE*)pBits;
            int bmpW = scaledWidth;
            int bmpH = scaledHeight;

            int rl = max(0, left);
            int rt = max(0, top);
            int rr = min(bmpW, left + width);
            int rb = min(bmpH, top + height);

            BYTE sa = col.GetA();
            BYTE sr = col.GetR();
            BYTE sg = col.GetG();
            BYTE sb = col.GetB();

            for (int y = rt; y < rb; ++y)
            {
                int row = y * bmpW * 4;
                for (int x = rl; x < rr; ++x)
                {
                    int idx = row + x * 4;
                    if (sa == 255)
                    {
                        content[idx + 0] = sb;
                        content[idx + 1] = sg;
                        content[idx + 2] = sr;
                        content[idx + 3] = sa;
                    }
                    else if (sa == 0)
                    {
                        // do nothing
                    }
                    else
                    {
                        BYTE da = content[idx + 3];
                        BYTE db = content[idx + 0];
                        BYTE dg = content[idx + 1];
                        BYTE dr = content[idx + 2];

                        int psr = (sr * sa + 127) / 255;
                        int psg = (sg * sa + 127) / 255;
                        int psb = (sb * sa + 127) / 255;

                        int outA = sa + (da * (255 - sa) + 127) / 255;
                        int outR = psr + (dr * (255 - sa) + 127) / 255;
                        int outG = psg + (dg * (255 - sa) + 127) / 255;
                        int outB = psb + (db * (255 - sa) + 127) / 255;

                        content[idx + 0] = (BYTE)min(255, outB);
                        content[idx + 1] = (BYTE)min(255, outG);
                        content[idx + 2] = (BYTE)min(255, outR);
                        content[idx + 3] = (BYTE)min(255, outA);
                    }
                }
            }
        }
        graphics.Restore(gs);
    }

    // info button
    SolidBrush infoBrush(g_buttonAnims[3].current);
    RectF infoRectF(
        static_cast<REAL>(g_infoBtn.left),
        static_cast<REAL>(g_infoBtn.top),
        static_cast<REAL>(g_infoBtn.right - g_infoBtn.left),
        static_cast<REAL>(g_infoBtn.bottom - g_infoBtn.top));
    {
        GraphicsPath iconPath;

        float w = infoRectF.Width;
        float h = infoRectF.Height;
        float size = min(w, h);
        float padding = max(1.0f, size * 0.12f);

        RectF circleRect(infoRectF.X + (w - size) * 0.5f + padding * 0.0f,
                         static_cast<Gdiplus::REAL>(infoRectF.Y + (h - size) * 0.5f),
                         static_cast<Gdiplus::REAL>(size - padding * 2.0f),
                         static_cast<Gdiplus::REAL>(size - padding * 2.0f));

        GraphicsPath circlePath;
        circlePath.AddEllipse(circleRect);
        REAL strokeWidth = max(1.0f, circleRect.Width * 0.07f);
        Color penColor;
        infoBrush.GetColor(&penColor);
        Pen pen(penColor, strokeWidth);
        pen.SetLineJoin(LineJoinRound);
        graphics.DrawPath(&pen, &circlePath);

        GraphicsPath innerPath;
        float cx = circleRect.X + circleRect.Width * 0.5f;
        float stemWidth = circleRect.Width * 0.12f;
        float stemHeight = circleRect.Height * 0.42f;
        float stemX = cx - stemWidth * 0.5f;
        float stemY = circleRect.Y + circleRect.Height * 0.40f;
        innerPath.AddRectangle(RectF(stemX, stemY, stemWidth, stemHeight));
        float dotDiameter = circleRect.Width * 0.14f;
        float dotX = cx - dotDiameter * 0.5f;
        float dotY = circleRect.Y + circleRect.Height * 0.20f;
        innerPath.AddEllipse(RectF(static_cast<Gdiplus::REAL>(dotX), static_cast<Gdiplus::REAL>(dotY), static_cast<Gdiplus::REAL>(dotDiameter), static_cast<Gdiplus::REAL>(dotDiameter)));
        graphics.FillPath(&infoBrush, &innerPath);
    }

    StringFormat leftFormat;
    leftFormat.SetAlignment(StringAlignmentNear);
    leftFormat.SetLineAlignment(StringAlignmentNear);

    // Version text should not wrap or trim
    StringFormat verFormat;
    verFormat.SetAlignment(StringAlignmentNear);
    verFormat.SetLineAlignment(StringAlignmentNear);
    verFormat.SetFormatFlags(StringFormatFlagsNoWrap);
    verFormat.SetTrimming(StringTrimmingNone);

    RectF outputRectF(
        static_cast<Gdiplus::REAL>(g_outputRect.left),
        static_cast<Gdiplus::REAL>(g_outputRect.top),
        static_cast<Gdiplus::REAL>(g_outputRect.right - g_outputRect.left),
        static_cast<Gdiplus::REAL>(g_outputRect.bottom - g_outputRect.top));
    SolidBrush textBrush(Color(255, 0, 0, 0));
    graphics.DrawString(g_outputText.c_str(), -1, g_pConsoleFont.get(), outputRectF, &leftFormat, &textBrush);

    RectF versionRectF(
        static_cast<Gdiplus::REAL>(g_versionRect.left),
        static_cast<Gdiplus::REAL>(g_versionRect.top),
        static_cast<Gdiplus::REAL>(g_versionRect.right - g_versionRect.left),
        static_cast<Gdiplus::REAL>(g_versionRect.bottom - g_versionRect.top));
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
        displayVersion = L"v" + parts[0] + L"." + parts[1] + L"." + parts[2] + L" PREVIEW " + parts[3];
    } else if (parts.size() == 3) {
        displayVersion = L"v" + parts[0] + L"." + parts[1] + L"." + parts[2];
    } else {
        displayVersion = std::wstring(VERSION);
    }
    
	// Extremely shitty DPI-"aware" text measurement
    RectF measuredRect;
    bool measuredByGdi = false;
    if (hdcScreen)
    {
        // try to match the GDI+ font size (12 UnitPixel) to device pixels
        int fontPixelHeight = (int)ceilf(12.0f * g_dpiScale);
        HFONT hFont = CreateFontW(-fontPixelHeight, 0, 0, 0, FW_NORMAL,
            FALSE, FALSE, FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
            CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_DONTCARE, L"Consolas");
        if (hFont)
        {
            HFONT hOldFont = (HFONT)SelectObject(hdcScreen, hFont);
            SIZE sz = { 0, 0 };
            if (GetTextExtentPoint32W(hdcScreen, displayVersion.c_str(), (int)displayVersion.size(), &sz))
            {
                measuredRect.Width = (REAL)sz.cx;
                measuredRect.Height = (REAL)sz.cy;
                measuredByGdi = true;
            }
            SelectObject(hdcScreen, hOldFont);
            DeleteObject(hFont);
        }
    }

    if (!measuredByGdi)
    {
        // Fallback to GDI+ MeasureCharacterRanges
        try {
            StringFormat mf;
            mf.SetFormatFlags(StringFormatFlagsNoWrap | StringFormatFlagsMeasureTrailingSpaces);
            CharacterRange cr(0, (INT)displayVersion.size());
            mf.SetMeasurableCharacterRanges(1, &cr);
            RectF layoutRect(static_cast<Gdiplus::REAL>(0.0f), static_cast<Gdiplus::REAL>(0.0f), static_cast<Gdiplus::REAL>(WINDOW_WIDTH), static_cast<Gdiplus::REAL>(WINDOW_HEIGHT));
            Region ranges[1] = { Region() };
            graphics.MeasureCharacterRanges(displayVersion.c_str(), -1, g_pVersionFont.get(), layoutRect, &mf, 1, ranges);
            ranges[0].GetBounds(&measuredRect, &graphics);
        }
        catch (...) {
            graphics.MeasureString(displayVersion.c_str(), -1, g_pVersionFont.get(), PointF(static_cast<Gdiplus::REAL>(0.0f), static_cast<Gdiplus::REAL>(0.0f)), &measuredRect);
        }
    }

    // Convert to logical (unscaled) coordinates
    float measuredLogicalWidth = measuredRect.Width / g_dpiScale;
    float measuredLogicalHeight = measuredRect.Height / g_dpiScale;

    // Shitty padding

    float maxAvailable = (float)WINDOW_WIDTH - versionRectF.X - 6.0f;
    const float basePadding = 6.0f;
    const float maxPadding = 60.0f;

    // Compute character width using the monospaced font cuz im lazy (still sucks)
    RectF charRect;
    try {
        StringFormat cf;
        cf.SetFormatFlags(StringFormatFlagsNoWrap | StringFormatFlagsMeasureTrailingSpaces);
        CharacterRange crc(0, 1);
        cf.SetMeasurableCharacterRanges(1, &crc);
        RectF layoutCharRect(static_cast<Gdiplus::REAL>(0.0f), static_cast<Gdiplus::REAL>(0.0f), static_cast<Gdiplus::REAL>(64.0f), static_cast<Gdiplus::REAL>(64.0f));
        Region cranges[1] = { Region() };
        graphics.MeasureCharacterRanges(L"0", -1, g_pVersionFont.get(), layoutCharRect, &cf, 1, cranges);
        cranges[0].GetBounds(&charRect, &graphics);
    }
    catch (...) {
        graphics.MeasureString(L"0", -1, g_pVersionFont.get(), PointF(static_cast<Gdiplus::REAL>(0.0f), static_cast<Gdiplus::REAL>(0.0f)), &charRect);
    }
    float charLogicalWidth = charRect.Width / g_dpiScale;
    float estimatedWidth = charLogicalWidth * static_cast<float>(displayVersion.size());
    if (estimatedWidth > measuredLogicalWidth) measuredLogicalWidth = estimatedWidth;

    float originalWidth = (float)(g_versionRect.right - g_versionRect.left);
    float paddingX = basePadding * g_dpiScale;
    float lengthFactor = static_cast<float>(displayVersion.size()) * 0.02f;
    paddingX += charLogicalWidth * lengthFactor * g_dpiScale;
    if (paddingX > maxPadding) paddingX = maxPadding;

    float desiredWidth = measuredLogicalWidth + paddingX;
    desiredWidth = min(desiredWidth, maxAvailable);
    float minWidth = estimatedWidth + basePadding;
    if (desiredWidth < minWidth) desiredWidth = minWidth;
    if (g_dpiScale <= 1.25f) if (desiredWidth > originalWidth) desiredWidth = originalWidth;

    versionRectF.Width = max(16.0f, desiredWidth); // minimum width

    // Compute vertical padding from font metrics so height matches glyph bounds
    float fontHeightLogical = (g_pVersionFont->GetHeight(&graphics) / g_dpiScale);
    float paddingY = max(2.0f, fontHeightLogical * 0.15f); // 15% of font height or min 2px
    float desiredHeight = measuredLogicalHeight + paddingY * 2.0f;
    float maxHeight = (float)WINDOW_HEIGHT - versionRectF.Y - 6.0f;
    if (desiredHeight > maxHeight) desiredHeight = maxHeight;
    float minHeight = fontHeightLogical + 2.0f;
    if (desiredHeight < minHeight) desiredHeight = minHeight;
    versionRectF.Height = desiredHeight;

    // Draw version text
    SolidBrush versionBrush(g_buttonAnims[4].current);
    graphics.DrawString(displayVersion.c_str(), -1, g_pVersionFont.get(), versionRectF, &verFormat, &versionBrush);

    // Update g_versionRect to fit the measured text (in logical coords)
    g_versionRect.left = (int)ceilf(versionRectF.X);
    g_versionRect.top = (int)ceilf(versionRectF.Y);
    g_versionRect.right = (int)ceilf(versionRectF.X + versionRectF.Width);
    g_versionRect.bottom = (int)ceilf(versionRectF.Y + versionRectF.Height);

    // Apply rounded-rect alpha mask for smooth AA edges
    {
        void* pMaskBits = nullptr;
        HDC maskDC = CreateCompatibleDC(hdcScreen);
        HBITMAP maskBitmap = CreateDIBSection(hdcScreen, &bmi, DIB_RGB_COLORS, &pMaskBits, nullptr, 0);
        if (!maskBitmap) {
            DeleteDC(maskDC);
            // If mask allocation fails, skip mask operation
        } else {
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

            // Multiply all channels by mask alpha
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
    }

    // launch button
    {
        float anim = g_launchBtnAnim;
        float baseW = (float)(g_launchBtn.right - g_launchBtn.left);
        float baseH = (float)(g_launchBtn.bottom - g_launchBtn.top);
        float expandW = 12.0f;
        float expandH = 4.0f;
        float w = baseW + expandW * anim;
        float h = baseH + expandH * anim;
        float cx = (g_launchBtn.left + g_launchBtn.right) * 0.5f;
        float cy = (g_launchBtn.top + g_launchBtn.bottom) * 0.5f;
        float x = cx - w * 0.5f;
        float y = cy - h * 0.5f;
        float radius = 16.0f + 8.0f * anim;
        RectF launchRectF(x, y, w, h);

        // rounded rectangle
        GraphicsPath path;
        path.AddArc(x, y, radius, radius, 180, 90);
        path.AddArc(x + w - radius, y, radius, radius, 270, 90);
        path.AddArc(x + w - radius, y + h - radius, radius, radius, 0, 90);
        path.AddArc(x, y + h - radius, radius, radius, 90, 90);
        path.CloseFigure();

        SolidBrush btnBrush(g_launchBtnEnabled ? Color(255, 255, 250, 0) : Color(255, 180, 180, 180));
        graphics.FillPath(&btnBrush, &path);

        // text
        StringFormat centerFmt;
        centerFmt.SetAlignment(StringAlignmentCenter);
        centerFmt.SetLineAlignment(StringAlignmentCenter);
        Font launchFont(L"Segoe UI", 16 + 2 * anim, FontStyleBold, UnitPixel);
        SolidBrush textBrush(Color(255, 0, 0, 0));
        graphics.DrawString(L"Launch Game", -1, &launchFont, launchRectF, &centerFmt, &textBrush);
    }

	// Minimize on Load button
    float animBtn = g_minOnLoadBtnAnim;
    float minInjectYOffset = g_minOnLoadBtnYOffset; //lazy
    float baseWBtn = (float)(g_minOnLoadBtn.right - g_minOnLoadBtn.left);
    float baseHBtn = (float)(g_minOnLoadBtn.bottom - g_minOnLoadBtn.top);
    float expandWBtn = 12.0f;
    float expandHBtn = 3.0f;
    float wBtn = baseWBtn + expandWBtn * animBtn;
    float hBtn = baseHBtn + expandHBtn * animBtn;
    float cxBtn = (g_minOnLoadBtn.left + g_minOnLoadBtn.right) * 0.5f;
    float cyBtn = (g_minOnLoadBtn.top + g_minOnLoadBtn.bottom) * 0.5f + minInjectYOffset;
    float xBtn = cxBtn - wBtn * 0.5f;
    float yBtn = cyBtn - hBtn * 0.5f;
    float radiusBtn = 10.0f + 4.0f * animBtn;
    RectF btnRectF(xBtn, yBtn, wBtn, hBtn);
    Color offColor(255, 220, 220, 220);
    Color onColor(255, 255, 250, 0);
    Color btnColor;
    if (g_minOnLoadBtnAnimating) btnColor = g_minOnLoadBtnCurrentColor;
    else if (g_minimizeOnInject) btnColor = onColor;
    else btnColor = offColor;
    SolidBrush btnBrush(btnColor);
    GraphicsPath pathBtn;
    pathBtn.AddArc(xBtn, yBtn, radiusBtn, radiusBtn, 180, 90);
    pathBtn.AddArc(xBtn + wBtn - radiusBtn, yBtn, radiusBtn, radiusBtn, 270, 90);
    pathBtn.AddArc(xBtn + wBtn - radiusBtn, yBtn + hBtn - radiusBtn, radiusBtn, radiusBtn, 0, 90);
    pathBtn.AddArc(xBtn, yBtn + hBtn - radiusBtn, radiusBtn, radiusBtn, 90, 90);
    pathBtn.CloseFigure();
    graphics.FillPath(&btnBrush, &pathBtn);
    StringFormat centerFmtBtn;
    centerFmtBtn.SetAlignment(StringAlignmentCenter);
    centerFmtBtn.SetLineAlignment(StringAlignmentCenter);
    Font btnFont(L"Segoe UI", 13 + 1.5f * animBtn, FontStyleRegular, UnitPixel);
    SolidBrush textBrushBtn(Color(255, 0, 0, 0));
    graphics.DrawString(L"Minimize on Launch", -1, &btnFont, btnRectF, &centerFmtBtn, &textBrushBtn);
    if (hdcScreen)
        ReleaseDC(nullptr, hdcScreen);
    g_contentDirty = false;
}

static void PresentWindow(HWND hWnd, const POINT* pNewPos)
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

static void UpdateWindowGraphics(HWND hWnd)
{
    RenderContent(hWnd);
    PresentWindow(hWnd);
}


LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    static POINT s_dragPoint;
    static bool s_isDragging = false;
    static bool s_wasMinimized = false;
    static int s_pressedButton = 0; // 0=none, 1=close,2=min,3=info,4=version,5=launch,6=minInject
    static POINT s_pressScreen = { 0, 0 };
    static RECT s_pressRect = { 0, 0, 0, 0 };
    static bool s_pressCaptured = false;
    static bool s_pressCanceled = false;
    const int DRAG_THRESHOLD = 12;

    // Handle custom minimize-on-injection animation message
    if (message == WM_USER + 100) {
        StartWindowAnimation(WindowAnim::FadeOutMinimize, hWnd);
        return 0;
    }

    switch (message)
    {
    case WM_CREATE:
    {
        // Render the window graphics once
        UpdateWindowGraphics(hWnd);
        break;
    }

    case WM_DPICHANGED:
    {
        // Per-monitor DPI changed
        int dpiX = LOWORD(wParam);
        float newScale = dpiX / 96.0f;
        if (fabs(newScale - g_dpiScale) > 0.001f)
        {
            float oldScale = g_dpiScale;
            g_dpiScale = newScale;

            RECT* prc = (RECT*)lParam;
            if (prc)
            {
                SetWindowPos(hWnd, nullptr, prc->left, prc->top, prc->right - prc->left, prc->bottom - prc->top,
                    SWP_NOZORDER | SWP_NOACTIVATE);
            }
            else
            {
                int scaledWidth = (int)(WINDOW_WIDTH * g_dpiScale);
                int scaledHeight = (int)(WINDOW_HEIGHT * g_dpiScale);
                RECT rect;
                GetWindowRect(hWnd, &rect);
                SetWindowPos(hWnd, nullptr, rect.left, rect.top, scaledWidth, scaledHeight, SWP_NOZORDER | SWP_NOACTIVATE);
            }

            // when dragging, scale the drag offset so drag is smooth
            if (s_isDragging)
            {
                s_dragPoint.x = (LONG)ceilf(s_dragPoint.x * (g_dpiScale / oldScale));
                s_dragPoint.y = (LONG)ceilf(s_dragPoint.y * (g_dpiScale / oldScale));
            }

            // Recreate cached content and fonts on new DPI
            FreeCachedBitmap();
            FreeGdiResources();
            UpdateWindowGraphics(hWnd);
        }
        return 0;
    }

    case WM_LBUTTONDOWN:
    {
        POINT ptClient = { LOWORD(lParam), HIWORD(lParam) };
        POINT ptLogical = ptClient;
        ptLogical.x = (LONG)(ptLogical.x / g_dpiScale);
        ptLogical.y = (LONG)(ptLogical.y / g_dpiScale);

        float animMinDown = g_minOnLoadBtnAnim;
        float baseWMinD = (float)(g_minOnLoadBtn.right - g_minOnLoadBtn.left);
        float baseHMinD = (float)(g_minOnLoadBtn.bottom - g_minOnLoadBtn.top);
        float expandWMinD = 12.0f;
        float expandHMinD = 3.0f;
        float wMinD = baseWMinD + expandWMinD * animMinDown;
        float hMinD = baseHMinD + expandHMinD * animMinDown;
        float cxMinD = (g_minOnLoadBtn.left + g_minOnLoadBtn.right) * 0.5f;
        float cyMinD = (g_minOnLoadBtn.top + g_minOnLoadBtn.bottom) * 0.5f + g_minOnLoadBtnYOffset;
        float xMinD = cxMinD - wMinD * 0.5f;
        float yMinD = cyMinD - hMinD * 0.5f;
        RECT minInjectRect = { (int)floorf(xMinD), (int)floorf(yMinD), (int)ceilf(xMinD + wMinD), (int)ceilf(yMinD + hMinD) };

        RECT closeHit = { g_closeBtn.left, (int)floorf(g_closeBtn.top + g_closeBtnYOffset), g_closeBtn.right, (int)ceilf(g_closeBtn.bottom + g_closeBtnYOffset) };
        int minPad = max(1, (int)roundf(g_minBtnHitPad * g_dpiScale));
        RECT minHit = { g_minBtn.left - minPad, (int)floorf(g_minBtn.top + g_minBtnYOffset), g_minBtn.right + minPad, (int)ceilf(g_minBtn.bottom + g_minBtnYOffset) };

        // Launch button
        float animLDown = g_launchBtnAnim;
        float baseWL = (float)(g_launchBtn.right - g_launchBtn.left);
        float baseHL = (float)(g_launchBtn.bottom - g_launchBtn.top);
        float expandWL = 24.0f;
        float expandHL = 8.0f;
        float wL = baseWL + expandWL * animLDown;
        float hL = baseHL + expandHL * animLDown;
        float cxL = (g_launchBtn.left + g_launchBtn.right) * 0.5f;
        float cyL = (g_launchBtn.top + g_launchBtn.bottom) * 0.5f;
        float xL = cxL - wL * 0.5f;
        float yL = cyL - hL * 0.5f;
        RECT launchRect = { (int)floorf(xL), (int)floorf(yL), (int)ceilf(xL + wL), (int)ceilf(yL + hL) };

        int hitId = 0;
        if (PtInRect(&minInjectRect, ptLogical))
            hitId = 6;
        else if (PtInRect(&closeHit, ptLogical))
            hitId = 1;
        else if (PtInRect(&minHit, ptLogical))
            hitId = 2;
        else if (PtInRect(&g_infoBtn, ptLogical))
            hitId = 3;
        else if (PtInRect(&g_versionRect, ptLogical))
            hitId = 4;
        else if (PtInRect(&launchRect, ptLogical) && g_launchBtnEnabled)
            hitId = 5;

        if (hitId != 0)
        {
            s_pressedButton = hitId;
            s_pressCaptured = true;
            s_pressCanceled = false;
            SetCapture(hWnd);
            GetCursorPos(&s_pressScreen);
            switch (hitId) {
            case 6: s_pressRect = minInjectRect; break;
            case 1: s_pressRect = closeHit; break;
            case 2: s_pressRect = minHit; break;
            case 3: s_pressRect = g_infoBtn; break;
            case 4: s_pressRect = g_versionRect; break;
            case 5: s_pressRect = launchRect; break;
            default: s_pressRect = {0,0,0,0}; break;
            }
        }
        else
        {
            s_pressedButton = 0;
            s_pressCaptured = false;
            s_pressCanceled = false;

            s_isDragging = true;
            s_dragPoint.x = LOWORD(lParam);
            s_dragPoint.y = HIWORD(lParam);
            SetCapture(hWnd);
        }

        break;
    }

    case WM_MOUSEMOVE:
    {
        POINT ptClient = { LOWORD(lParam), HIWORD(lParam) };

        // drag
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
            if (s_pressCaptured && !s_isDragging)
            {
                POINT curr;
                GetCursorPos(&curr);
                int dx = abs(curr.x - s_pressScreen.x);
                int dy = abs(curr.y - s_pressScreen.y);
                if (dx >= DRAG_THRESHOLD || dy >= DRAG_THRESHOLD) s_pressCanceled = true;
            }

            // Normal hover/animation logic
            if (!g_mouseTracking)
            {
                TRACKMOUSEEVENT tme = {};
                tme.cbSize = sizeof(TRACKMOUSEEVENT);
                tme.dwFlags = TME_LEAVE;
                tme.hwndTrack = hWnd;
                TrackMouseEvent(&tme);
                g_mouseTracking = true;
            }

            POINT ptLogical = ptClient;
            ptLogical.x = (LONG)(ptLogical.x / g_dpiScale);
            ptLogical.y = (LONG)(ptLogical.y / g_dpiScale);

            int prevHover = g_hoveredButton;
            g_hoveredButton = 0;
            // Minimize on load hover
            float animMin = g_minOnLoadBtnAnim;
            float baseWMin = (float)(g_minOnLoadBtn.right - g_minOnLoadBtn.left);
            float baseHMin = (float)(g_minOnLoadBtn.bottom - g_minOnLoadBtn.top);
            float expandWMin = 12.0f;
            float expandHMin = 3.0f;
            float wMin = baseWMin + expandWMin * animMin;
            float hMin = baseHMin + expandHMin * animMin;
            float cxMin = (g_minOnLoadBtn.left + g_minOnLoadBtn.right) * 0.5f;
            float cyMin = (g_minOnLoadBtn.top + g_minOnLoadBtn.bottom) * 0.5f + g_minOnLoadBtnYOffset;
            float xMin = cxMin - wMin * 0.5f;
            float yMin = cyMin - hMin * 0.5f;
            RECT minBtnRect = { (int)floorf(xMin), (int)floorf(yMin), (int)ceilf(xMin + wMin), (int)ceilf(yMin + hMin) };
            bool minBtnWasHovered = (prevHover == 6);
            bool minBtnNowHovered = (ptLogical.x >= minBtnRect.left && ptLogical.x < minBtnRect.right && ptLogical.y >= minBtnRect.top && ptLogical.y < minBtnRect.bottom);

            int minPad = max(1, (int)roundf(g_minBtnHitPad * g_dpiScale));
            RECT paddedMinBtn = { g_minBtn.left - minPad, (int)floorf(g_minBtn.top + g_minBtnYOffset), g_minBtn.right + minPad, (int)ceilf(g_minBtn.bottom + g_minBtnYOffset) };

            g_hoveredButton = 0;
            if (minBtnNowHovered) g_hoveredButton = 6;
            // Use offset-aware hit rect for close so visual and hit areas match
            RECT closeHitRect = { g_closeBtn.left, (int)floorf(g_closeBtn.top + g_closeBtnYOffset), g_closeBtn.right, (int)ceilf(g_closeBtn.bottom + g_closeBtnYOffset) };
            if (g_hoveredButton == 0 && (ptLogical.x >= closeHitRect.left && ptLogical.x < closeHitRect.right && ptLogical.y >= closeHitRect.top && ptLogical.y < closeHitRect.bottom)) g_hoveredButton = 1;
            if (g_hoveredButton == 0 && (ptLogical.x >= paddedMinBtn.left && ptLogical.x < paddedMinBtn.right && ptLogical.y >= paddedMinBtn.top && ptLogical.y < paddedMinBtn.bottom)) g_hoveredButton = 2;
            if (g_hoveredButton == 0 && (ptLogical.x >= g_infoBtn.left && ptLogical.x < g_infoBtn.right && ptLogical.y >= g_infoBtn.top && ptLogical.y < g_infoBtn.bottom)) g_hoveredButton = 3;
            if (g_hoveredButton == 0 && (ptLogical.x >= g_versionRect.left && ptLogical.x < g_versionRect.right && ptLogical.y >= g_versionRect.top && ptLogical.y < g_versionRect.bottom)) g_hoveredButton = 4;

            // Launch button hover
            float animL = g_launchBtnAnim;
            float baseWL2 = (float)(g_launchBtn.right - g_launchBtn.left);
            float baseHL2 = (float)(g_launchBtn.bottom - g_launchBtn.top);
            float expandWL2 = 24.0f;
            float expandHL2 = 8.0f;
            float wL2 = baseWL2 + expandWL2 * animL;
            float hL2 = baseHL2 + expandHL2 * animL;
            float cxL2 = (g_launchBtn.left + g_launchBtn.right) * 0.5f;
            float cyL2 = (g_launchBtn.top + g_launchBtn.bottom) * 0.5f;
            float xL2 = cxL2 - wL2 * 0.5f;
            float yL2 = cyL2 - hL2 * 0.5f;
            RECT launchRect2 = { (int)floorf(xL2), (int)floorf(yL2), (int)ceilf(xL2 + wL2), (int)ceilf(yL2 + hL2) };
            bool launchBtnWasHovered = (prevHover == 5);
            bool launchBtnNowHovered = PtInRect(&launchRect2, ptLogical);
            if (launchBtnNowHovered)
                g_hoveredButton = 5;

            // Show hand cursor on hover for clickable buttons
            HCURSOR hCur = LoadCursor(nullptr, (g_hoveredButton == 5 || g_hoveredButton == 6) ? IDC_HAND : IDC_ARROW);
            SetCursor(hCur);

            // independently trigger expand/collapse for each button
            if (minBtnWasHovered != minBtnNowHovered) {
                g_minOnLoadBtnAnimStartValue = g_minOnLoadBtnAnim;
                g_minOnLoadBtnAnimTarget = minBtnNowHovered ? 1.0f : 0.0f;
                g_minOnLoadBtnAnimStartTime = GetPreciseTimeMs();
                g_minOnLoadBtnAnimating = true;
                Color stateColor = g_minimizeOnInject ? Color(255, 255, 250, 0) : Color(255, 220, 220, 220);
                g_minOnLoadBtnTargetColor = stateColor;
                g_minOnLoadBtnCurrentColor = stateColor;
            }
            if (launchBtnWasHovered != launchBtnNowHovered) {
                g_launchBtnAnimStartValue = g_launchBtnAnim;
                g_launchBtnAnimTarget = launchBtnNowHovered ? 1.0f : 0.0f;
                g_launchBtnAnimStartTime = GetPreciseTimeMs();
                g_launchBtnAnimating = true;
            }
            // Color animation for toolbar buttons
            if (prevHover != g_hoveredButton) {
                if (prevHover != 0 && prevHover <= 4)
                    StartButtonColorAnim(prevHover, Color(255, 51, 51, 51));
                if (g_hoveredButton == 1)
                    StartButtonColorAnim(1, Color(255, 255, 127, 80));
                else if (g_hoveredButton == 2)
                    StartButtonColorAnim(2, Color(255, 218, 165, 32));
                else if (g_hoveredButton == 3)
                    StartButtonColorAnim(3, Color(255, 100, 149, 237));
                else if (g_hoveredButton == 4)
                    StartButtonColorAnim(4, Color(255, 100, 149, 237));
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
            s_pressedButton = 0;
            s_pressCaptured = false;
            s_pressCanceled = false;
        }
        else if (s_pressCaptured)
        {
            ReleaseCapture();
            POINT ptScreen;
            GetCursorPos(&ptScreen);
            POINT ptClientNow = ptScreen;
            ScreenToClient(hWnd, &ptClientNow);
            POINT ptLogicalNow = ptClientNow;
            ptLogicalNow.x = (LONG)(ptLogicalNow.x / g_dpiScale);
            ptLogicalNow.y = (LONG)(ptLogicalNow.y / g_dpiScale);
            if (ptLogicalNow.x < s_pressRect.left || ptLogicalNow.x > s_pressRect.right || ptLogicalNow.y < s_pressRect.top || ptLogicalNow.y > s_pressRect.bottom)
            {
                s_pressCanceled = true;
            }

            if (!s_pressCanceled && s_pressedButton != 0)
            {
                switch (s_pressedButton)
                {
                case 6: // Minimize-on-inject toggle
                {
                    g_minOnLoadBtnTargetColor = g_minOnLoadBtnCurrentColor;
                    g_minimizeOnInject = !g_minimizeOnInject;
                    g_minOnLoadBtnAnimStartValue = g_minOnLoadBtnAnim;
                    g_minOnLoadBtnAnimTarget = (g_hoveredButton == 6) ? 1.0f : 0.0f;
                    g_minOnLoadBtnAnimStartTime = GetPreciseTimeMs();
                    g_minOnLoadBtnAnimating = true;
                    break;
                }
                case 1: // Close
                    if (!g_isClosing)
                    {
                        g_isClosing = true;
                        StartWindowAnimation(WindowAnim::SlideOutClose, hWnd);
                    }
                    break;
                case 2: // Minimize
                    StartWindowAnimation(WindowAnim::FadeOutMinimize, hWnd);
                    break;
                case 3: // Info (open README)
                    ShellExecute(nullptr, L"open",
                        L"https://github.com/DynamiByte/Endfield-Uncensored/blob/master/README.md",
                        nullptr, nullptr, SW_SHOWNORMAL);
                    break;
                case 4: // Version (open releases)
                {
                    std::wstring tag = VERSION;
                    if (tag.empty() || (tag[0] != L'v' && tag[0] != L'V'))
                        tag = std::wstring(L"v") + tag;
                    std::wstring url = L"https://github.com/DynamiByte/Endfield-Uncensored/releases/tag/" + tag;
                    ShellExecute(nullptr, L"open", url.c_str(), nullptr, nullptr, SW_SHOWNORMAL);
                    break;
                }
                case 5: // Launch
                    if (g_launchBtnEnabled)
                    {
                        ShellExecuteW(nullptr, L"open", g_gameExePath.c_str(), nullptr, nullptr, SW_SHOWNORMAL);
                        AppendOutput(L"Launching game...");
                    }
                    break;
                default:
                    break;
                }
            }

            // Clear press tracking
            s_pressedButton = 0;
            s_pressCaptured = false;
            s_pressCanceled = false;
        }
        break;
    }

    case WM_MOUSELEAVE:
    {
        g_mouseTracking = false;
        if (g_hoveredButton >= 1 && g_hoveredButton <= 4)
            StartButtonColorAnim(g_hoveredButton, Color(255, 51, 51, 51));
        // Collapse launch button
        if (g_launchBtnAnim > 0.001f || g_launchBtnAnimating || g_launchBtnAnimTarget != 0.0f)
        {
            g_launchBtnAnimStartValue = g_launchBtnAnim;
            g_launchBtnAnimTarget = 0.0f;
            g_launchBtnAnimStartTime = GetPreciseTimeMs();
            g_launchBtnAnimating = true;
        }
        // Only collapse minimize on injection button if it was hovered or expanded
        if (g_minOnLoadBtnAnim > 0.0f || g_hoveredButton == 6) {
            g_minOnLoadBtnAnimStartValue = g_minOnLoadBtnAnim;
            g_minOnLoadBtnAnimTarget = 0.0f;
            g_minOnLoadBtnAnimStartTime = GetPreciseTimeMs();
            g_minOnLoadBtnAnimating = true;
        }
        g_hoveredButton = 0;
        break;
    }

    case WM_TIMER:
    {
        if (wParam == TIMER_ANIMATION)
        {
            UpdateAnimations(hWnd);
            if (!AnyUIAnimating())
                KillTimer(hWnd, TIMER_ANIMATION);
        }
        else if (wParam == TIMER_CLOSE_DELAY)
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
            // Try both markers
            const std::wstring markers[2] = { L"Closing in ", L"Minimizing in " };
            for (const auto& marker : markers) {
                size_t pos = g_outputText.rfind(marker);
                if (pos != std::wstring::npos)
                {
                    // find start of that line
                    size_t lineStart = g_outputText.rfind(L"\r\n", pos);
                    if (lineStart == std::wstring::npos)
                        lineStart = 0;
                    else
                        lineStart += 2;

                    // find end of that line (include the trailing CRLF when present)
                    size_t lineEnd = g_outputText.find(L"\r\n", pos);
                    if (lineEnd == std::wstring::npos)
                        lineEnd = g_outputText.size();
                    else
                        lineEnd += 2;

                    // erase the old line (including terminating CRLF if it existed)
                    g_outputText.erase(lineStart, lineEnd - lineStart);

                    // Collapse any accidental double-CRLF sequences
                    while (g_outputText.size() >= 4 &&
                           g_outputText.compare(g_outputText.size() - 4, 4, L"\r\n\r\n") == 0)
                    {
                        g_outputText.erase(g_outputText.size() - 2, 2);
                    }
                    break;
                }
            }
        }

        g_outputText += incoming;

        // Content changed, re-render
        g_contentDirty = true;
        RenderContent(hWnd);
        PresentWindow(hWnd);
        break;
    }

    case WM_CLEAR_OUTPUT:
    {
        g_outputText.clear();
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

// LOADER AND HELPER FUNCTIONS:

void AppendOutput(const std::wstring& text, bool replaceClosing)
{
    std::wstring fullText = text + L"\r\n";

    // If window hasn't been created yet, append to buffer
    // the window thread handles replacement logic for the closing/minimizing countdown.
    if (!g_hWnd)
    {
        if (replaceClosing)
        {
            const std::wstring markers[2] = { L"Closing in ", L"Minimizing in " };
            for (const auto& marker : markers) {
                size_t pos = g_outputText.rfind(marker);
                if (pos != std::wstring::npos)
                {
                    size_t lineStart = g_outputText.rfind(L"\r\n", pos);
                    if (lineStart == std::wstring::npos)
                        lineStart = 0;
                    else
                        lineStart += 2;

                    size_t lineEnd = g_outputText.find(L"\r\n", pos);
                    if (lineEnd == std::wstring::npos)
                        lineEnd = g_outputText.size();
                    else
                        lineEnd += 2;

                    g_outputText.erase(lineStart, lineEnd - lineStart);

                    while (g_outputText.size() >= 4 &&
                           g_outputText.compare(g_outputText.size() - 4, 4, L"\r\n\r\n") == 0)
                    {
                        g_outputText.erase(g_outputText.size() - 2, 2);
                    }
                    break;
                }
            }
        }

        g_outputText += fullText;
        g_contentDirty = true;
        return;
    }

    wchar_t* pText = new wchar_t[fullText.length() + 1];
    wcscpy_s(pText, fullText.length() + 1, fullText.c_str());
    PostMessage(g_hWnd, WM_APPEND_OUTPUT, replaceClosing ? 1 : 0, (LPARAM)pText);
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
    unsigned long long tick = GetTickCount64();
    swprintf_s(uniqueDir, L"%sEndfieldUncensored_%016llX\\", tempPath, tick);
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

BOOL LoadDll(DWORD pid, const wchar_t* dllPath)
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

    HMODULE hKernel32 = GetModuleHandleW(L"kernel32.dll");
    if (!hKernel32) {
        VirtualFreeEx(hProcess, remoteMem, 0, MEM_RELEASE);
        CloseHandle(hProcess);
        return FALSE;
    }
    LPVOID loadLibAddr = (LPVOID)GetProcAddress(hKernel32, "LoadLibraryW");
    if (!loadLibAddr) {
        VirtualFreeEx(hProcess, remoteMem, 0, MEM_RELEASE);
        CloseHandle(hProcess);
        return FALSE;
    }
    HANDLE hThread = CreateRemoteThread(hProcess, nullptr, 0,
        (LPTHREAD_START_ROUTINE)loadLibAddr, remoteMem, 0, nullptr);

    BOOL result = FALSE;
    if (hThread)
    {
        WaitForSingleObject(hThread, 5000);
        CloseHandle(hThread);
        result = TRUE;
    }

    VirtualFreeEx(hProcess, remoteMem, 0, MEM_RELEASE);
    CloseHandle(hProcess);
    return result;
}

static void LoaderThreadProc()
{
    AppendOutput(L"Waiting for " + std::wstring(TARGET_EXE) + L"...");

    DWORD pid = 0;
    while ((pid = FindTargetProcess(TARGET_EXE)) == 0)
    {
        Sleep(100);
    }

    // Clear the log
    if (g_hWnd)
    {
        SendMessage(g_hWnd, WM_CLEAR_OUTPUT, 0, 0);
    }
    
    wchar_t pidText[64];
    swprintf_s(pidText, L"Process found (PID: %d)", pid);
    AppendOutput(pidText);

    Sleep(10);

    AppendOutput(L"Attempting injection...");

    if (LoadDll(pid, g_tempDllPath.c_str()))
    {
        AppendOutput(L"[OK] Injection successful!");
        if (g_minimizeOnInject) {
            for (int i = 5; i > 0; i--) {
                wchar_t countText[64];
                swprintf_s(countText, L"Minimizing in %d...", i);
                AppendOutput(countText, true);
                Sleep(1000);
            }
            PostMessage(g_hWnd, WM_USER + 100, 0, 0);
            AppendOutput(L"Waiting for " + std::wstring(TARGET_EXE) + L" to close...");
            // Wait
            while (FindTargetProcess(TARGET_EXE) != 0) {
                Sleep(500);
            }

            // Clear the log
            if (g_hWnd)
            {
                SendMessage(g_hWnd, WM_CLEAR_OUTPUT, 0, 0);
            }

            // Restore window and reset state
            PostMessage(g_hWnd, WM_SYSCOMMAND, SC_RESTORE, 0);
            AppendOutput(L"Ready for injection again.");
            StartLoaderThread();
        } else {
            for (int i = 5; i > 0; i--)
            {
                wchar_t countText[64];
                swprintf_s(countText, L"Closing in %d...", i);
                AppendOutput(countText, true);
                Sleep(1000);
            }
            PostMessage(g_hWnd, WM_CLOSE, 0, 0);
        }
    }
    else
    {
        AppendOutput(L"[FAIL] Injection failed.");
    }
}

void StartLoaderThread()
{
    std::thread loaderThread(LoaderThreadProc);
    loaderThread.detach();
}

// SVG PATH PARSING:

// Helper for SVG arc: angle between two vectors
static float SvgAngleBetween(float ux, float uy, float vx, float vy) {
    float dot = ux * vx + uy * vy;
    float len = sqrtf((ux * ux + uy * uy) * (vx * vx + vy * vy));
    float arg = dot / len;
    if (arg < -1.0f) arg = -1.0f;
    if (arg > 1.0f) arg = 1.0f;
    float ang = acosf(arg);
    if (ux * vy - uy * vx < 0) ang = -ang;
    return ang;
}

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

        case 'A': // Arc (absolute)
        case 'a': // Arc (relative)
        {
            auto arcToBezier = [&](float x0, float y0, float rx, float ry, float angle, int largeArcFlag, int sweepFlag, float x1, float y1) {
                if (rx == 0.0f || ry == 0.0f) {
                    gdiPath.AddLine(x0, y0, x1, y1);
                    return;
                }
                float sinPhi = sinf(angle * 3.14159265358979323846f / 180.0f);
                float cosPhi = cosf(angle * 3.14159265358979323846f / 180.0f);
                float dx2 = (x0 - x1) / 2.0f;
                float dy2 = (y0 - y1) / 2.0f;
                float x1p = cosPhi * dx2 + sinPhi * dy2;
                float y1p = -sinPhi * dx2 + cosPhi * dy2;
                float rx_sq = rx * rx;
                float ry_sq = ry * ry;
                float x1p_sq = x1p * x1p;
                float y1p_sq = y1p * y1p;
                float radicant = (rx_sq * ry_sq - rx_sq * y1p_sq - ry_sq * x1p_sq);
                float denom = (rx_sq * y1p_sq + ry_sq * x1p_sq);
                if (denom == 0.0f) denom = 1.0f; // avoid div by zero
                radicant /= denom;
                radicant = (radicant < 0) ? 0 : radicant;
                float coef = (largeArcFlag != sweepFlag ? 1 : -1) * sqrtf(radicant);
                float cxp = coef * (rx * y1p) / ry;
                float cyp = coef * (-ry * x1p) / rx;
                float cx = cosPhi * cxp - sinPhi * cyp + (x0 + x1) / 2.0f;
                float cy = sinPhi * cxp + cosPhi * cyp + (y0 + y1) / 2.0f;
                float theta1 = SvgAngleBetween(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry);
                float deltaTheta = SvgAngleBetween(
                    (x1p - cxp) / rx, (y1p - cyp) / ry,
                    (-x1p - cxp) / rx, (-y1p - cyp) / ry);
                if (!sweepFlag && deltaTheta > 0) deltaTheta -= 2 * 3.14159265358979323846f;
                else if (sweepFlag && deltaTheta < 0) deltaTheta += 2 * 3.14159265358979323846f;
                int segments = (int)ceilf(fabsf(deltaTheta / (3.14159265358979323846f / 2.0f)));
                float delta = deltaTheta / segments;
                float t = theta1;
                for (int i = 0; i < segments; ++i) {
                    float t1 = t;
                    float t2 = t + delta;
                    float sin_t1 = sinf(t1), cos_t1 = cosf(t1);
                    float sin_t2 = sinf(t2), cos_t2 = cosf(t2);
                    float e = tanf(delta / 4.0f) * 4.0f / 3.0f;
                    float xA = rx * cos_t1, yA = ry * sin_t1;
                    float xB = rx * cos_t2, yB = ry * sin_t2;
                    float cp1x = xA - e * ry * sin_t1;
                    float cp1y = yA + e * rx * cos_t1;
                    float cp2x = xB + e * ry * sin_t2;
                    float cp2y = yB - e * rx * cos_t2;
                    float fromX = cosPhi * xA - sinPhi * yA + cx;
                    float fromY = sinPhi * xA + cosPhi * yA + cy;
                    float c1x = cosPhi * cp1x - sinPhi * cp1y + cx;
                    float c1y = sinPhi * cp1x + cosPhi * cp1y + cy;
                    float c2x = cosPhi * cp2x - sinPhi * cp2y + cx;
                    float c2y = sinPhi * cp2x + cosPhi * cp2y + cy;
                    float toX = cosPhi * xB - sinPhi * yB + cx;
                    float toY = sinPhi * xB + cosPhi * yB + cy;
                    gdiPath.AddBezier(fromX, fromY, c1x, c1y, c2x, c2y, toX, toY);
                    t += delta;
                }
            };
            do {
                float rx = parseNumber();
                float ry = parseNumber();
                float angle = parseNumber();
                int largeArc = (int)parseNumber();
                int sweep = (int)parseNumber();
                float x = parseNumber();
                float y = parseNumber();
                float x1 = (cmd == 'a') ? currentX + x : x;
                float y1 = (cmd == 'a') ? currentY + y : y;
                arcToBezier(currentX, currentY, rx, ry, angle, largeArc, sweep, x1, y1);
                currentX = x1;
                currentY = y1;
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
            break;
        }
    }
}

// ANIMATION:

static Color LerpColor(const Color& a, const Color& b, float t)
{

    t = max(0.0f, min(1.0f, t));
    return Color(
        (BYTE)(a.GetA() + (b.GetA() - a.GetA()) * t),
        (BYTE)(a.GetR() + (b.GetR() - a.GetR()) * t),
        (BYTE)(a.GetG() + (b.GetG() - a.GetG()) * t),
        (BYTE)(a.GetB() + (b.GetB() - a.GetB()) * t)
    );
}

// Helper: compare two Gdiplus::Color values by ARGB
static bool ColorEquals(const Color& a, const Color& b) {
    return a.GetValue() == b.GetValue();
}

static float EaseOutQuad(float t)
{
    return 1.0f - (1.0f - t) * (1.0f - t);
}

static float EaseInQuad(float t)
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
        int startPos = rect.top + (int)(50 * g_dpiScale);
        g_windowAnim.startY = startPos;
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

static void UpdateAnimations(HWND hWnd)
{
    bool needsContentRender = false;
    bool needsPresent = false;
    POINT newPos = {};
    bool hasNewPos = false;
    double currentTime = GetPreciseTimeMs();

    // Update button color animations
    for (int i = 1; i <= 4; i++)
    {
        if (g_buttonAnims[i].animating)
        {
            float elapsed = (float)(currentTime - g_buttonAnims[i].startTime) / 100.0f;

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

    // Update launch button expand/collapse animation
    if (g_launchBtnAnimating)
    {
        float animDuration = 0.18f;
        float elapsed = (float)(currentTime - g_launchBtnAnimStartTime) / (animDuration * 1000.0f);
        if (elapsed >= 1.0f)
        {
            g_launchBtnAnim = g_launchBtnAnimTarget;
            g_launchBtnAnimating = false;
        }
        else
        {
            float t = EaseOutQuad(elapsed);
            g_launchBtnAnim = g_launchBtnAnimStartValue + (g_launchBtnAnimTarget - g_launchBtnAnimStartValue) * t;
        }
        needsContentRender = true;
    }

    // Update minimize on load button animation
    if (g_minOnLoadBtnAnimating)
    {
        float animDuration = 0.18f;
        float elapsed = (float)(currentTime - g_minOnLoadBtnAnimStartTime) / (animDuration * 1000.0f);
        if (elapsed >= 1.0f)
        {
            g_minOnLoadBtnAnim = g_minOnLoadBtnAnimTarget;
            g_minOnLoadBtnAnimating = false;
            g_minOnLoadBtnCurrentColor = g_minimizeOnInject ? Color(255, 255, 250, 0) : Color(255, 220, 220, 220);
        }
        else
        {
            float t = EaseOutQuad(elapsed);
            g_minOnLoadBtnAnim = g_minOnLoadBtnAnimStartValue + (g_minOnLoadBtnAnimTarget - g_minOnLoadBtnAnimStartValue) * t;
            Color targetColor = g_minimizeOnInject ? Color(255, 255, 250, 0) : Color(255, 220, 220, 220);
            if (!ColorEquals(g_minOnLoadBtnTargetColor, targetColor)) {
                Color from = g_minOnLoadBtnTargetColor;
                Color to = targetColor;
                g_minOnLoadBtnCurrentColor = LerpColor(from, to, t);
            } else {
                g_minOnLoadBtnCurrentColor = targetColor;
            }
        }
        needsContentRender = true;
    }

    // Update window animations
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
            float elapsed = (float)(currentTime - g_windowAnim.startTime) / 250.0f;
            if (elapsed >= 1.0f)
            {
                g_windowOpacity = 0.0f;
                newPos = { g_windowAnim.startX, g_windowAnim.startY + (int)(80 * g_dpiScale) };
                hasNewPos = true;
                needsPresent = true;

                g_windowAnim.type = WindowAnim::None;
                SetTimer(hWnd, TIMER_CLOSE_DELAY, 10, nullptr);
            }
            else
            {
                float t = elapsed * elapsed * elapsed;
                int newY = (int)(g_windowAnim.startY + 80 * g_dpiScale * t);

                newPos = { g_windowAnim.startX, newY };
                hasNewPos = true;
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
