#include <windows.h>
#include <stdint.h>

// IL2CPP API function pointer typedefs
typedef void* (*Il2CppDomainGetFunc)(void);
typedef void* (*Il2CppDomainAssemblyOpenFunc)(void*, const char*);
typedef void* (*Il2CppAssemblyGetImageFunc)(void*);
typedef void* (*Il2CppClassFromNameFunc)(void*, const char*, const char*);
typedef struct { uintptr_t address; } *Il2CppMethod;
typedef Il2CppMethod (*Il2CppClassGetMethodFromNameFunc)(void*, const char*, int);

// Wait for a DLL to load
HMODULE wait_for_module(const wchar_t* module_name) {
    HMODULE module_handle = NULL;
    while (!module_handle) {
        module_handle = GetModuleHandleW(module_name);
        Sleep(200);
    }
    Sleep(2000);
    return module_handle;
}

// Patch CameraMono::EvaluateAllTouchedEntities to RET
void patch_camera_censorship() {
    // Wait for GameAssembly.dll
    HMODULE game_assembly_handle = wait_for_module(L"GameAssembly.dll");
    if (!game_assembly_handle) return;

    // Get IL2CPP API
    Il2CppDomainGetFunc il2cpp_domain_get = (Il2CppDomainGetFunc)GetProcAddress(game_assembly_handle, "il2cpp_domain_get");
    Il2CppDomainAssemblyOpenFunc il2cpp_domain_assembly_open = (Il2CppDomainAssemblyOpenFunc)GetProcAddress(game_assembly_handle, "il2cpp_domain_assembly_open");
    Il2CppAssemblyGetImageFunc il2cpp_assembly_get_image = (Il2CppAssemblyGetImageFunc)GetProcAddress(game_assembly_handle, "il2cpp_assembly_get_image");
    Il2CppClassFromNameFunc il2cpp_class_from_name = (Il2CppClassFromNameFunc)GetProcAddress(game_assembly_handle, "il2cpp_class_from_name");
    Il2CppClassGetMethodFromNameFunc il2cpp_class_get_method_from_name = (Il2CppClassGetMethodFromNameFunc)GetProcAddress(game_assembly_handle, "il2cpp_class_get_method_from_name");

    // Check API
    if (!il2cpp_domain_get || !il2cpp_domain_assembly_open || !il2cpp_assembly_get_image || !il2cpp_class_from_name || !il2cpp_class_get_method_from_name)
        return;

    // Get domain
    void* il2cpp_domain = il2cpp_domain_get();
    // Open Gameplay.Beyond.dll
    void* gameplay_assembly = il2cpp_domain_assembly_open(il2cpp_domain, "Gameplay.Beyond.dll");
    if (!gameplay_assembly) return;
    // Get image
    void* gameplay_image = il2cpp_assembly_get_image(gameplay_assembly);
    if (!gameplay_image) return;
    // Find CameraMono class
    void* camera_mono_class = il2cpp_class_from_name(gameplay_image, "Beyond.Gameplay.View", "CameraMono");
    if (!camera_mono_class) return;
    // Get method
    Il2CppMethod eval_all_touched_entities_method = il2cpp_class_get_method_from_name(camera_mono_class, "EvaluateAllTouchedEntities", 0);
    if (!eval_all_touched_entities_method) return;

    // Patch first byte with RET (0xC3)
    DWORD old_protect;
    VirtualProtect((void*)eval_all_touched_entities_method->address, 1, PAGE_EXECUTE_READWRITE, &old_protect);
    *(uint8_t*)eval_all_touched_entities_method->address = 0xC3; // x86 RET instruction
    VirtualProtect((void*)eval_all_touched_entities_method->address, 1, old_protect, &old_protect);
}

// DllMain entry point
BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    if (ul_reason_for_call == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hModule);
        CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)patch_camera_censorship, NULL, 0, NULL);
    }
    return TRUE;
}