const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) @panic("memory leak");
    }
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var lista = std.ArrayList(i64).init(allocator);
    defer lista.deinit();
    var listb = std.ArrayList(i64).init(allocator);
    defer listb.deinit();
    while (lines.next()) |line| {
        var pairs = std.mem.tokenizeScalar(u8, line, ' ');
        const a = try std.fmt.parseInt(i64, pairs.next().?, 10);
        const b = try std.fmt.parseInt(i64, pairs.next().?, 10);
        try lista.append(a);
        try listb.append(b);
    }
    std.sort.insertion(i64, lista.items, {}, std.sort.asc(i64));
    std.sort.insertion(i64, listb.items, {}, std.sort.asc(i64));
    var total: i64 = 0;
    for (lista.items, 0..) |a, i| {
        const b = listb.items[i];
        const dist: i64 = @intCast(@abs(a - b));
        total += dist;
    }
    std.debug.print("{}\n", .{total});
}

fn part2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) @panic("memory leak");
    }
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var lista = std.ArrayList(i64).init(allocator);
    defer lista.deinit();
    var mapb = std.AutoHashMap(i64, i64).init(allocator);
    defer mapb.deinit();
    while (lines.next()) |line| {
        var pairs = std.mem.tokenizeScalar(u8, line, ' ');
        const a = try std.fmt.parseInt(i64, pairs.next().?, 10);
        const b = try std.fmt.parseInt(i64, pairs.next().?, 10);
        try lista.append(a);
        const entry = try mapb.getOrPut(b);
        if (entry.found_existing) {
            entry.value_ptr.* = entry.value_ptr.* + 1;
        } else {
            entry.value_ptr.* = 1;
        }
    }
    var total: i64 = 0;
    for (lista.items) |a| {
        const b = mapb.get(a) orelse continue;
        const sim = a * b;
        total += sim;
    }
    std.debug.print("{}\n", .{total});
}
