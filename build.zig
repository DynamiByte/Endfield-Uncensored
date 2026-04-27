// Build graph for the embedded DLL and font assets
const std = @import("std");
const app_version = @import("src/version.zig");
const strings = @import("src/strings.zig");

const FontSubsetSpec = struct {
    input_font_path: []const u8,
    subset_text_name: []const u8,
    subset_text: []const u8,
    output_name: []const u8,
};

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

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.option(std.builtin.OptimizeMode, "optimize", "Build optimization mode") orelse .ReleaseSmall;

    const dll = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "EFUHook",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/dll.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const install_dll = b.addInstallFileWithDir(dll.getEmittedBin(), .bin, "EFU.dll");

    if (wantsDllOnly(b)) {
        b.getInstallStep().dependOn(&install_dll.step);
        return;
    }

    const generated_files = b.addWriteFiles();

    const version_info_subset_text = strings.buildVersionInfoSubsetText(b.allocator, app_version.version_str) catch @panic("OOM");
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

    _ = generated_files.add("version_generated.h", std.fmt.comptimePrint(
        \\#define VERSION_STR "{s}"
        \\#define VERSION_FILEVERSION {s}
        \\
    , .{
        app_version.version_str,
        app_version.file_version_rc,
    }));

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

    linkLoaderLibraries(exe.root_module);

    exe.root_module.addIncludePath(b.path("src"));
    exe.root_module.addImport("bytegui_c", bytegui_c.createModule());

    addEmbeddedAsset(exe.root_module, "EFUHook", dll.getEmittedBin());
    for (font_subset_specs, subset_fonts) |spec, subset_font| {
        addEmbeddedAsset(exe.root_module, spec.output_name, subset_font);
    }

    exe.root_module.addWin32ResourceFile(.{
        .file = b.path("src/version.rc"),
        .include_paths = &.{generated_files.getDirectory()},
    });

    b.installArtifact(exe);
}
