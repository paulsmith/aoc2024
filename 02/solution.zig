const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    try part1();
    try part2();
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

fn part2() !void {
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

    for (reports.items) |levels| {
        if (reportIsSafe(levels)) safe += 1 else {
            const candidates = try permuteReport(allocator, levels);
            defer allocator.free(candidates);
            var found = false;
            for (candidates) |candidate| {
                defer allocator.free(candidate);
                if (reportIsSafe(candidate)) found = true;
            }
            if (found) safe += 1;
        }
    }

    for (reports.items) |report| {
        allocator.free(report);
    }

    std.debug.print("{}\n", .{safe});
}

fn permuteReport(allocator: std.mem.Allocator, levels: []i64) ![][]i64 {
    const candidates = try allocator.alloc([]i64, levels.len);
    for (0..levels.len) |i| {
        candidates[i] = try allocator.alloc(i64, levels.len - 1);
        if (i > 0) std.mem.copyForwards(i64, candidates[i], levels[0..i]);
        if (i < levels.len - 1) std.mem.copyForwards(i64, candidates[i][i..], levels[i + 1 ..]);
    }
    return candidates;
}

fn reportIsSafe(levels: []i64) bool {
    var last = levels[0];
    var lastDiff: i64 = 0;
    for (1..levels.len) |i| {
        const level = levels[i];
        const diff = level - last;
        if (@abs(diff) < 1 or @abs(diff) > 3) return false;
        if (i > 1 and lastDiff ^ diff < 0) return false;
        last = level;
        lastDiff = diff;
    }
    return true;
}
