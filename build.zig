const std = @import("std");
const version = @import("version.zig");
const builtin = std.builtin;
pub const Step = std.Build.Step;

pub fn build(b: *std.Build.Builder) void {
    const lib = b.addStaticLibrary(.{
    .name = "hashes",
    .root_source_file = .{.path = "src/std.zig"},
    .optimize = .ReleaseSafe,
    .version = .{.major = version.major, .minor = version.minor, .patch = version.patch},
    .target = .{}
    });
    b.installArtifact(lib);

    const main_tests = addTests(b, &.{
    .{.root_source_file = .{.path = "src/std.zig"}},
    .{.root_source_file = .{.path = "src/djb2.zig"}},
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

}


fn addTests(b: *std.Build.Builder, tests: []const std.Build.TestOptions) *Step.Compile {
    var result: *Step.Compile = undefined;
    for (tests) |testElem| {
        result = b.addTest(testElem);
    }
    return result;
}
