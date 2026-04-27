// Build graph for the embedded DLL and font assets
const std = @import("std");
const builtin = @import("builtin");
const app = @import("build.efu.zon");
const strings = @import("src/strings.zig");

const parsed_version = parseAppVersion(app.version);
const version_str = std.fmt.comptimePrint("v{d}.{d}.{d}.{d}", .{
    parsed_version[0],
    parsed_version[1],
    parsed_version[2],
    parsed_version[3],
});
const file_version_rc = std.fmt.comptimePrint("{d},{d},{d},{d}", .{
    parsed_version[0],
    parsed_version[1],
    parsed_version[2],
    parsed_version[3],
});

const exe_output_name = app.outputs.exe;
const dll_output_name = app.outputs.dll;
const exe_artifact_name = stripRequiredSuffix(exe_output_name, ".exe", "build.efu.zon outputs.exe");

comptime {
    const required_zig_version = std.SemanticVersion.parse(app.zig_version) catch {
        @compileError("build.efu.zon zig_version must be a semantic version, like 0.16.0.");
    };

    if (builtin.zig_version.order(required_zig_version) != .eq) {
        @compileError("This project is pinned to Zig " ++ app.zig_version ++ ".");
    }

    _ = stripRequiredSuffix(dll_output_name, ".dll", "build.efu.zon outputs.dll");
}

const FontSubsetSpec = struct {
    input_font_path: []const u8,
    subset_text_name: []const u8,
    subset_text: []const u8,
    output_name: []const u8,
};

fn asciiLower(ch: u8) u8 {
    return if (ch >= 'A' and ch <= 'Z') ch + ('a' - 'A') else ch;
}

fn endsWithIgnoreCase(comptime text: []const u8, comptime suffix: []const u8) bool {
    if (text.len < suffix.len) return false;

    const start = text.len - suffix.len;
    for (suffix, 0..) |suffix_ch, idx| {
        if (asciiLower(text[start + idx]) != asciiLower(suffix_ch)) return false;
    }

    return true;
}

fn stripRequiredSuffix(comptime text: []const u8, comptime suffix: []const u8, comptime label: []const u8) []const u8 {
    if (!endsWithIgnoreCase(text, suffix)) {
        @compileError(label ++ " must end with " ++ suffix ++ ".");
    }

    const stem = text[0 .. text.len - suffix.len];
    if (stem.len == 0) {
        @compileError(label ++ " must not be just " ++ suffix ++ ".");
    }

    return stem;
}

fn hasVersionPrefix(comptime version: []const u8) bool {
    return version.len > 0 and (version[0] == 'v' or version[0] == 'V');
}

fn trimVersionPrefix(comptime version: []const u8) []const u8 {
    return if (hasVersionPrefix(version)) version[1..] else version;
}

fn parseAppVersion(comptime raw_version: []const u8) [4]u32 {
    const trimmed = trimVersionPrefix(raw_version);

    var values = [_]u32{ 0, 0, 0, 0 };
    var parts = std.mem.splitScalar(u8, trimmed, '.');
    var count: usize = 0;

    while (parts.next()) |part| : (count += 1) {
        if (count >= 4) {
            @compileError("build.efu.zon version must be major.minor.patch.build, like 5.0.0.1.");
        }

        values[count] = parseUnsigned(part, "build.efu.zon version");
    }

    if (count != 4) {
        @compileError("build.efu.zon version must be major.minor.patch.build, like 5.0.0.1.");
    }

    return values;
}

fn parseUnsigned(comptime text: []const u8, comptime label: []const u8) u32 {
    if (text.len == 0) {
        @compileError(label ++ " contains an empty numeric part.");
    }

    var value: u32 = 0;
    for (text) |ch| {
        if (ch < '0' or ch > '9') {
            @compileError(label ++ " must be numeric here.");
        }

        value = value * 10 + (ch - '0');
    }

    return value;
}

fn addSubsetFont(
    b: *std.Build,
    subsetter: *std.Build.Step.Compile,
    generated_files: anytype,
    input_font: std.Build.LazyPath,
    subset_text_name: []const u8,
    subset_text: []const u8,
    output_name: []const u8,
) std.Build.LazyPath {
    const text_file = generated_files.add(subset_text_name, subset_text);
    const subset = b.addRunArtifact(subsetter);
    subset.addFileArg(input_font);
    subset.addFileArg(text_file);
    return subset.addOutputFileArg(output_name);
}

fn linkLoaderLibraries(module: *std.Build.Module) void {
    inline for ([_][]const u8{ "user32", "gdi32", "opengl32", "glu32", "shell32", "dwmapi" }) |library_name| {
        module.linkSystemLibrary(library_name, .{});
    }
}

fn addEmbeddedAsset(module: *std.Build.Module, name: []const u8, path: std.Build.LazyPath) void {
    module.addAnonymousImport(name, .{
        .root_source_file = path,
    });
}

fn wantsDllOnly(b: *std.Build) bool {
    return (b.option(bool, "LL", "Build only EFU.dll") orelse false) or
        (b.option(bool, "ll", "Build only EFU.dll") orelse false);
}

fn addGeneratedVersionModule(
    b: *std.Build,
    generated_files: anytype,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Module {
    const version_source = generated_files.add("version.zig", b.fmt(
        \\const std = @import("std");
        \\
        \\pub const version_str = "{s}";
        \\pub const parsed_version = [4]u32{{ {d}, {d}, {d}, {d} }};
        \\pub const file_version_rc = "{s}";
        \\
        \\pub fn hasVersionPrefix(version: []const u8) bool {{
        \\    return version.len > 0 and (version[0] == 'v' or version[0] == 'V');
        \\}}
        \\
        \\pub fn trimVersionPrefix(version: []const u8) []const u8 {{
        \\    return if (hasVersionPrefix(version)) version[1..] else version;
        \\}}
        \\
        \\pub fn normalizedTag(out_buf: []u8, version: []const u8) ![]const u8 {{
        \\    if (hasVersionPrefix(version)) return version;
        \\    return std.fmt.bufPrint(out_buf, "v{{s}}", .{{version}});
        \\}}
        \\
    , .{
        version_str,
        parsed_version[0],
        parsed_version[1],
        parsed_version[2],
        parsed_version[3],
        file_version_rc,
    }));

    return b.createModule(.{
        .root_source_file = version_source,
        .target = target,
        .optimize = optimize,
    });
}

fn addGeneratedVersionHeader(b: *std.Build, generated_files: anytype) void {
    _ = generated_files.add("version_generated.h", b.fmt(
        \\#define VERSION_STR "{s}"
        \\#define VERSION_FILEVERSION {s}
        \\
    , .{
        version_str,
        file_version_rc,
    }));
}

fn addGeneratedManifest(b: *std.Build, generated_files: anytype) void {
    _ = generated_files.add("app.manifest", b.fmt(
        \\<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        \\<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
        \\  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
        \\    <security>
        \\      <requestedPrivileges>
        \\        <requestedExecutionLevel level="{s}" uiAccess="false"/>
        \\      </requestedPrivileges>
        \\    </security>
        \\  </trustInfo>
        \\  <compatibility xmlns="urn:schemas-microsoft-com:compatibility.v1">
        \\    <application>
        \\      <!-- Windows 10 and 11 -->
        \\      <supportedOS Id="{{8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a}}"/>
        \\      <!-- Windows 8.1 -->
        \\      <supportedOS Id="{{1f676c76-80e1-4239-95bb-83d0f6d0da78}}"/>
        \\      <!-- Windows 8 -->
        \\      <supportedOS Id="{{4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38}}"/>
        \\      <!-- Windows 7 -->
        \\      <supportedOS Id="{{35138b9a-5d96-4fbd-8e2d-a2440225f93a}}"/>
        \\    </application>
        \\  </compatibility>
        \\</assembly>
        \\
    , .{
        app.manifest.requested_execution_level,
    }));
}

fn addGeneratedVersionResource(
    b: *std.Build,
    generated_files: anytype,
    rc_name: []const u8,
    file_type: []const u8,
    original_filename: []const u8,
    include_exe_resources: bool,
) std.Build.LazyPath {
    const exe_resources = if (include_exe_resources)
        \\1 ICON "EFU.ico"
        \\1 24 "app.manifest"
        \\
    else
        "";

    return generated_files.add(rc_name, b.fmt(
        \\#pragma code_page(65001)
        \\#include <winver.h>
        \\#include "version_generated.h"
        \\
        \\VS_VERSION_INFO VERSIONINFO
        \\FILEVERSION     VERSION_FILEVERSION
        \\PRODUCTVERSION  VERSION_FILEVERSION
        \\FILEFLAGSMASK   0x3FL
        \\FILEFLAGS       0x0L
        \\FILEOS          0x40004L
        \\FILETYPE        {s}
        \\FILESUBTYPE     0x0L
        \\BEGIN
        \\    BLOCK "StringFileInfo"
        \\    BEGIN
        \\        BLOCK "040904B0"
        \\        BEGIN
        \\            VALUE "CompanyName",      "{s}\0"
        \\            VALUE "FileDescription",  "{s}\0"
        \\            VALUE "FileVersion",      VERSION_STR "\0"
        \\            VALUE "InternalName",     "{s}\0"
        \\            VALUE "LegalCopyright",   "{s}\0"
        \\            VALUE "OriginalFilename", "{s}\0"
        \\            VALUE "ProductName",      "{s}\0"
        \\            VALUE "ProductVersion",   VERSION_STR "\0"
        \\            VALUE "Comments",         "{s}\0"
        \\        END
        \\    END
        \\    BLOCK "VarFileInfo"
        \\    BEGIN
        \\        VALUE "Translation", 0x0409, 1200
        \\    END
        \\END
        \\
        \\{s}
    , .{
        file_type,
        app.version_info.company_name,
        app.version_info.file_description,
        app.version_info.internal_name,
        app.version_info.legal_copyright,
        original_filename,
        app.name,
        app.version_info.comments,
        exe_resources,
    }));
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.option(std.builtin.OptimizeMode, "optimize", "Build optimization mode") orelse .ReleaseSmall;
    const dll_only = wantsDllOnly(b);

    const generated_files = b.addWriteFiles();
    addGeneratedVersionHeader(b, generated_files);

    const dll = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "EFUHook",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/dll.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    if (dll_only) {
        const dll_rc = addGeneratedVersionResource(
            b,
            generated_files,
            "dll-version.rc",
            "VFT_DLL",
            dll_output_name,
            false,
        );

        dll.root_module.addWin32ResourceFile(.{
            .file = dll_rc,
            .include_paths = &.{generated_files.getDirectory()},
        });
    }

    const install_dll = b.addInstallFileWithDir(dll.getEmittedBin(), .bin, dll_output_name);

    if (dll_only) {
        b.getInstallStep().dependOn(&install_dll.step);
        return;
    }

    const version_module = addGeneratedVersionModule(b, generated_files, target, optimize);

    const version_info_subset_text = strings.buildVersionInfoSubsetText(b.allocator, version_str) catch @panic("OOM");
    const textbox_subset_text = strings.buildTextboxSubsetText(b.allocator) catch @panic("OOM");

    const font_subsetter = b.addExecutable(.{
        .name = "font-subset",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/bytetype.zig"),
            .target = b.graph.host,
            .optimize = .ReleaseSmall,
        }),
    });
    font_subsetter.root_module.link_libc = true;

    const font_subset_specs = [_]FontSubsetSpec{
        .{
            .input_font_path = "fonts/Inter/Inter_18pt-Regular.ttf",
            .subset_text_name = "toggle-label.subset.txt",
            .subset_text = strings.ui_toggle_labels_subset,
            .output_name = "toggle-label.ttf",
        },
        .{
            .input_font_path = "fonts/Inter/Inter_18pt-SemiBold.ttf",
            .subset_text_name = "launch-button.subset.txt",
            .subset_text = strings.label_launch,
            .output_name = "launch-button.ttf",
        },
        .{
            .input_font_path = "fonts/JetBrainsMono/JetBrainsMono-Regular.ttf",
            .subset_text_name = "version-info.subset.txt",
            .subset_text = version_info_subset_text,
            .output_name = "version-info.ttf",
        },
        .{
            .input_font_path = "fonts/DejaVuSansMono/DejaVuSansMono.ttf",
            .subset_text_name = "text-box.subset.txt",
            .subset_text = textbox_subset_text,
            .output_name = "text-box.ttf",
        },
    };

    var subset_fonts: [font_subset_specs.len]std.Build.LazyPath = undefined;
    for (font_subset_specs, 0..) |spec, idx| {
        subset_fonts[idx] = addSubsetFont(
            b,
            font_subsetter,
            generated_files,
            b.path(spec.input_font_path),
            spec.subset_text_name,
            spec.subset_text,
            spec.output_name,
        );
    }

    const bytegui_c_header = generated_files.add("bytegui_c.h",
        \\#include <windows.h>
        \\#include <wtypes.h>
        \\
    );

    const bytegui_c = b.addTranslateC(.{
        .root_source_file = bytegui_c_header,
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    bytegui_c.defineCMacro("WIN32_LEAN_AND_MEAN", null);
    bytegui_c.defineCMacro("NOMINMAX", null);
    bytegui_c.defineCMacro("CINTERFACE", null);
    bytegui_c.defineCMacro("COBJMACROS", null);

    addGeneratedManifest(b, generated_files);
    const exe_rc = addGeneratedVersionResource(
        b,
        generated_files,
        "exe-version.rc",
        "VFT_APP",
        exe_output_name,
        true,
    );

    const exe = b.addExecutable(.{
        .name = exe_artifact_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/window.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.subsystem = .Windows;
    exe.root_module.link_libc = true;

    linkLoaderLibraries(exe.root_module);

    exe.root_module.addIncludePath(b.path("src"));
    exe.root_module.addImport("bytegui_c", bytegui_c.createModule());
    exe.root_module.addImport("version", version_module);

    addEmbeddedAsset(exe.root_module, "EFUHook", dll.getEmittedBin());
    for (font_subset_specs, subset_fonts) |spec, subset_font| {
        addEmbeddedAsset(exe.root_module, spec.output_name, subset_font);
    }

    exe.root_module.addWin32ResourceFile(.{
        .file = exe_rc,
        .include_paths = &.{ generated_files.getDirectory(), b.path("src") },
    });

    b.installArtifact(exe);
}
