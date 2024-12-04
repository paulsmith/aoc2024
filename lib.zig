const std = @import("std");

fn rawMode() !void {
    const stdin = std.io.getStdIn();
    var term = try std.posix.tcgetattr(stdin.handle);
    term.lflag.ICANON = false;
    try std.posix.tcsetattr(stdin.handle, .NOW, term);
}

fn unsetRawMode() !void {
    const stdin = std.io.getStdIn();
    const term = try std.posix.tcgetattr(stdin.handle);
    try std.posix.tcsetattr(stdin.handle, .NOW, term);
}
