const std = @import("std");
const app_version = @import("src/version.zig");
const strings = @import("src/strings.zig");

fn addSubsetFont(
    b: *std.Build,
    generated_files: anytype,
    input_font: std.Build.LazyPath,
    subset_text_name: []const u8,
    subset_text: []const u8,
    output_name: []const u8,
) std.Build.LazyPath {
    const text_file = generated_files.add(subset_text_name, subset_text);
    const subset = b.addSystemCommand(&.{ "python", "-m", "fontTools.subset" });
    subset.addFileArg(input_font);
    subset.addPrefixedFileArg("--text-file=", text_file);
    subset.addArgs(&.{
        "--layout-features=*",
        "--hinting",
        "--legacy-kern",
        "--notdef-glyph",
        "--notdef-outline",
        "--recommended-glyphs",
    });
    return subset.addPrefixedOutputFileArg("--output-file=", output_name);
}

// Build Graph
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const generated_files = b.addWriteFiles();
    const mono_subset_text = strings.buildMonoSubsetText(b.allocator, app_version.version_str) catch @panic("OOM");
    const toggle_subset_font = addSubsetFont(
        b,
        generated_files,
        b.path("fonts/Inter/Inter_18pt-Regular.ttf"),
        "Inter_18pt-Regular.subset.txt",
        strings.label_minimize,
        "Inter_18pt-Regular.ttf",
    );
    const launch_subset_font = addSubsetFont(
        b,
        generated_files,
        b.path("fonts/Inter/Inter_18pt-SemiBold.ttf"),
        "Inter_18pt-SemiBold.subset.txt",
        strings.label_launch,
        "Inter_18pt-SemiBold.ttf",
    );
    const mono_subset_font = addSubsetFont(
        b,
        generated_files,
        b.path("fonts/JetBrainsMono/JetBrainsMono-Regular.ttf"),
        "JetBrainsMono-Regular.subset.txt",
        mono_subset_text,
        "JetBrainsMono-Regular.ttf",
    );
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

    _ = generated_files.add("version_generated.h", std.fmt.comptimePrint(
        \\#define VERSION_STR "{s}"
        \\#define VERSION_FILEVERSION {s}
        \\
    , .{
        app_version.version_str,
        app_version.file_version_rc,
    }));

    // DLL Artifact
    const dll = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "EFUHook",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/dll.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Loader Artifact
    const exe = b.addExecutable(.{
        .name = "EFU",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/window.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.subsystem = .Windows;
    exe.root_module.link_libc = true;
    exe.root_module.linkSystemLibrary("user32", .{});
    exe.root_module.linkSystemLibrary("gdi32", .{});
    exe.root_module.linkSystemLibrary("opengl32", .{});
    exe.root_module.linkSystemLibrary("shell32", .{});
    exe.root_module.linkSystemLibrary("dwmapi", .{});
    exe.root_module.addIncludePath(b.path("src"));
    exe.root_module.addImport("bytegui_c", bytegui_c.createModule());

    // Embedded DLL Import
    exe.root_module.addAnonymousImport("EFUHook", .{
        .root_source_file = dll.getEmittedBin(),
    });
    exe.root_module.addAnonymousImport("Inter_18pt-Regular.ttf", .{
        .root_source_file = toggle_subset_font,
    });
    exe.root_module.addAnonymousImport("Inter_18pt-SemiBold.ttf", .{
        .root_source_file = launch_subset_font,
    });
    exe.root_module.addAnonymousImport("JetBrainsMono-Regular.ttf", .{
        .root_source_file = mono_subset_font,
    });

    exe.root_module.addWin32ResourceFile(.{
        .file = b.path("src/version.rc"),
        .include_paths = &.{generated_files.getDirectory()},
    });
    b.installArtifact(exe);
}
