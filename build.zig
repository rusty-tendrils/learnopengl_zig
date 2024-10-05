const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "hello",
        .link_libc = true,
        .target = b.host,
    });
    exe.root_module.addCSourceFile(.{
        .file = b.path("hello.c"),
    });

    b.installArtifact(exe);
}
