const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // DLL
    const dll = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "EFU",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/dll.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(dll);

    // Loader EXE
    const exe = b.addExecutable(.{
        .name = "EFULoader",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/loader.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.root_module.addWin32ResourceFile(.{ .file = b.path("src/version.rc") });
    b.installArtifact(exe);
}
