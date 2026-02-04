#include <windows.h>
#include <tlhelp32.h>

__declspec(dllexport) DWORD __cdecl FindTargetProcess(const char* name) {
    HANDLE s = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (s == INVALID_HANDLE_VALUE) return 0;
    PROCESSENTRY32 p = { sizeof(p) };
    DWORD pid = 0;
    if (Process32First(s, &p)) {
        do {
            if (_stricmp(p.szExeFile, name) == 0) {
                pid = p.th32ProcessID;
                break;
            }
        } while (Process32Next(s, &p));
    }
    CloseHandle(s);
    return pid;
}

__declspec(dllexport) BOOL __cdecl InjectDll(DWORD pid, const char* dllPath) {
    HANDLE p = OpenProcess(PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION |
        PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ, FALSE, pid);
    if (!p) return FALSE;

    size_t len = strlen(dllPath) + 1;
    LPVOID mem = VirtualAllocEx(p, NULL, len, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
    if (!mem) { CloseHandle(p); return FALSE; }

    WriteProcessMemory(p, mem, dllPath, len, NULL);
    HANDLE t = CreateRemoteThread(p, NULL, 0,
        (LPTHREAD_START_ROUTINE)GetProcAddress(GetModuleHandleA("kernel32.dll"), "LoadLibraryA"),
        mem, 0, NULL);

    if (t) { WaitForSingleObject(t, 5000); CloseHandle(t); }
    VirtualFreeEx(p, mem, 0, MEM_RELEASE);
    CloseHandle(p);
    return t != NULL;
}