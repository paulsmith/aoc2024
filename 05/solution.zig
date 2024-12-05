const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    try part1();
    try part2();
}

const List = std.ArrayList(u64);

fn part1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() == .leak) @panic("memory leak");

    var ordering = std.AutoHashMap(u64, List).init(allocator);
    defer deinitMap(&ordering);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.peek()) |line| {
        if (!std.mem.containsAtLeast(u8, line, 1, "|")) {
            break;
        }
        const prec = try std.fmt.parseInt(u64, line[0..2], 10);
        const page = try std.fmt.parseInt(u64, line[3..], 10);
        const entry = try ordering.getOrPut(prec);
        if (!entry.found_existing) entry.value_ptr.* = List.init(allocator);
        try entry.value_ptr.*.append(page);
        _ = lines.next();
    }

    var total: u64 = 0;

    while (lines.next()) |line| {
        var update = List.init(allocator);
        defer update.deinit();

        var pages = std.mem.tokenizeScalar(u8, line, ',');
        while (pages.next()) |page| {
            try update.append(try std.fmt.parseInt(u64, page, 10));
        }

        if (correct(ordering, update.items)) total += update.items[update.items.len / 2];
    }

    std.debug.print("{}\n", .{total});
}

fn part2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() == .leak) @panic("memory leak");

    var ordering = std.AutoHashMap(u64, List).init(allocator);
    defer deinitMap(&ordering);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.peek()) |line| {
        if (!std.mem.containsAtLeast(u8, line, 1, "|")) {
            break;
        }
        const prec = try std.fmt.parseInt(u64, line[0..2], 10);
        const page = try std.fmt.parseInt(u64, line[3..], 10);
        const entry = try ordering.getOrPut(prec);
        if (!entry.found_existing) entry.value_ptr.* = List.init(allocator);
        try entry.value_ptr.*.append(page);
        _ = lines.next();
    }

    var total: u64 = 0;

    while (lines.next()) |line| {
        var update = List.init(allocator);
        defer update.deinit();

        var pages = std.mem.tokenizeScalar(u8, line, ',');
        while (pages.next()) |page| {
            try update.append(try std.fmt.parseInt(u64, page, 10));
        }

        if (!correct(ordering, update.items)) {
            std.sort.insertion(usize, update.items, ordering, customSort);
            total += update.items[update.items.len / 2];
        }
    }

    std.debug.print("{}\n", .{total});
}

fn customSort(ordering: std.AutoHashMap(u64, List), lhs: u64, rhs: u64) bool {
    if (ordering.get(lhs)) |list| {
        return std.mem.containsAtLeast(u64, list.items, 1, &[_]u64{rhs});
    }
    return false;
}

fn correct(ordering: std.AutoHashMap(u64, List), update: []const u64) bool {
    for (0..update.len - 1) |i| {
        const prec = update[i];
        const succ = update[i + 1];
        if (!ordering.contains(prec) or
            (ordering.contains(succ) and
            std.mem.containsAtLeast(u64, ordering.get(succ).?.items, 1, &[_]u64{prec})))
        {
            return false;
        }
        if (ordering.contains(prec) and
            !std.mem.containsAtLeast(u64, ordering.get(prec).?.items, 1, &[_]u64{succ}))
        {
            std.debug.print("expected {} to be in rules for {} but wasn't found\n", .{ succ, prec });
            unreachable;
        }
    }
    return true;
}

fn deinitMap(map: *std.AutoHashMap(u64, List)) void {
    var it = map.iterator();
    while (it.next()) |entry| {
        entry.value_ptr.*.deinit();
    }
    map.deinit();
}
