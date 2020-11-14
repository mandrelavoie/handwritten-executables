// zig build-lib shared-library-zig.zig -dynamic --release-small --single-threaded --strip

const std = @import("std");

export fn say_hello() void {
    std.io.getStdOut().outStream().print("Hello from shared lib!\n", .{}) catch unreachable;
}