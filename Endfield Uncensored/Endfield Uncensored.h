// Single shared header for both C++ and resource compiler
#pragma once

#include <SDKDDKVer.h>

//////////////////////////////////////////////////////////////////
// Display version (Majow.Minor.Patch.Preview)                  //
#define VERSION_STR "v2.0.0"                                    //
// Numeric file version for resource compiler (comma-separated) //
#define VERSION_FILEVERSION 2,0,0,0                             //
//////////////////////////////////////////////////////////////////

// Helper to create a wide-string literal from a narrow string literal macro
#define WIDEN2(x) L##x
#define WIDEN(x) WIDEN2(x)

// Backwards-compatible macro used in C++ sources (wide string)
#define VERSION WIDEN(VERSION_STR)

// Resource IDs
#define IDS_APP_TITLE 103

#define IDR_MAINFRAME 128
#define IDD_ENDFIELDUNCENSOREDC_DIALOG 102
#define IDD_ABOUTBOX 103
#define IDM_ABOUT 104
#define IDM_EXIT 105
#define IDI_ENDFIELDUNCENSOREDC 107
#define IDI_SMALL 108
#define IDC_ENDFIELDUNCENSOREDC 109
#define IDR_GAME_MOD 129
#define IDC_MYICON 2
#ifndef IDC_STATIC
#define IDC_STATIC -1
#endif

#ifdef APSTUDIO_INVOKED
#ifndef APSTUDIO_READONLY_SYMBOLS
#define _APS_NO_MFC 130
#define _APS_NEXT_RESOURCE_VALUE 130
#define _APS_NEXT_COMMAND_VALUE 32771
#define _APS_NEXT_CONTROL_VALUE 1000
#define _APS_NEXT_SYMED_VALUE 110
#endif
#endif

// Only include C runtime and Windows headers for C/C++ compilation
#ifndef RC_INVOKED
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <stdlib.h>
#include <malloc.h>
#include <memory.h>
#include <tchar.h>
#endif
