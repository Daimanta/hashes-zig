const std = @import("std");
const version = @import("version.zig");
const builtin = std.builtin;
const Builder = std.Build;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("hashes", .{.root_source_file = b.path("src/std.zig"), .target = target, .optimize = optimize});

    const lib = b.addLibrary(.{.name = "hashes", .root_module = module});
    b.installArtifact(lib);
}
