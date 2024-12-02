const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    try part1();
    //try part1();
}

fn part1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() == .leak) @panic("leak");

    var reports = std.ArrayList([]i64).init(allocator);
    defer reports.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');
        var numlist = std.ArrayList(i64).init(allocator);
        while (numbers.next()) |level| {
            const n = try std.fmt.parseInt(i64, level, 10);
            try numlist.append(n);
        }
        try reports.append(try numlist.toOwnedSlice());
    }

    var safe: u64 = 0;

    outer: for (reports.items) |report| {
        var last = report[0];
        var lastDiff: i64 = 0;
        for (1..report.len) |i| {
            const level = report[i];
            const diff = level - last;
            if (@abs(diff) < 1 or @abs(diff) > 3) continue :outer;
            if (i > 1 and lastDiff ^ diff < 0) continue :outer;
            last = level;
            lastDiff = diff;
        }
        safe += 1;
    }

    for (reports.items) |report| {
        allocator.free(report);
    }

    std.debug.print("{}\n", .{safe});
}
