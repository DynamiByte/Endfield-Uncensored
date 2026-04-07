const std = @import("std");
const app_version = @import("src/version.zig");

// Build Graph
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const generated_files = b.addWriteFiles();
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
    exe.root_module.linkSystemLibrary("gdiplus", .{});
    exe.root_module.linkSystemLibrary("msimg32", .{});
    exe.root_module.linkSystemLibrary("shell32", .{});
    exe.root_module.linkSystemLibrary("d3d11", .{});
    exe.root_module.linkSystemLibrary("dxgi", .{});
    exe.root_module.linkSystemLibrary("dcomp", .{});
    exe.root_module.linkSystemLibrary("d3dcompiler_47", .{});

    // Embedded DLL Import
    exe.root_module.addAnonymousImport("EFUHook", .{
        .root_source_file = dll.getEmittedBin(),
    });

    exe.root_module.addWin32ResourceFile(.{
        .file = b.path("src/version.rc"),
        .include_paths = &.{generated_files.getDirectory()},
    });
    b.installArtifact(exe);

}
