const std = @import("std");

const flags = [_][]const u8{
    "-Wall",
    "-Wextra",
    "-Werror=return-type",
};
const cflags = flags ++ [_][]const u8{
    "-std=c99",
};

const cxxflags = cflags ++ [_][]const u8{
    "-std=c++17", "-fno-exceptions",
};

pub fn build(b: *std.Build) void {
    const targets = [_]Target{
        .{ .name = "hello_window", .src = "src/1.getting_started/1.hello_window/main.cpp" },
        .{ .name = "hello_triangle", .src = "src/1.getting_started/2.hello_triangle/main.cpp" },
    };

    for (targets) |target| {
        target.build(b);
    }
}

const Target = struct {
    name: []const u8,
    src: []const u8,

    pub fn build(self: Target, b: *std.Build) void {
        const exe = b.addExecutable(.{
            .name = self.name,
            .target = b.host,
        });
        exe.root_module.addCSourceFile(.{
            .file = b.path(self.src),
            .flags = &cxxflags,
        });

        // Includes
        exe.addIncludePath(b.path("include"));

        // Sources
        exe.addCSourceFile(.{
            .file = b.path("src/glad.c"),
            .flags = &cflags,
        });

        // Libraries
        exe.addLibraryPath(b.path("lib"));

        exe.linkLibC();
        exe.linkLibCpp();

        exe.linkSystemLibrary("glfw3");
        exe.linkSystemLibrary("GL");
        exe.linkSystemLibrary("X11");
        exe.linkSystemLibrary("pthread");
        exe.linkSystemLibrary("Xrandr");
        exe.linkSystemLibrary("Xi");
        exe.linkSystemLibrary("dl");

        b.installArtifact(exe);
    }
};
