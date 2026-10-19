const std = @import("std");
const version = @import("version.zig");
const builtin = std.builtin;
const Builder = std.Build;

pub fn build(b: *Builder) void {
    const current_zig_version = @import("builtin").zig_version;
    if (current_zig_version.major != 0 or current_zig_version.minor < 17) {
        std.debug.print("This project does not compile with a Zig version <0.17.x. Exiting.", .{});
        std.os.exit(1);
    }

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("hashes", .{.root_source_file = b.path("src/std.zig"), .target = target, .optimize = optimize});

    const lib = b.addLibrary(.{.name = "hashes", .root_module = module});
    b.installArtifact(lib);
}
