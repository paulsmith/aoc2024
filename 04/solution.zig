const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    try part1();
    try part2();
}

const Cardinal = enum {
    up,
    right,
    down,
    left,
    null,

    fn xtest(self: Cardinal, word: []const u8, x: usize, width: usize) bool {
        return switch (self) {
            .up, .down, .null => true,
            .right => x + word.len <= width,
            .left => x >= word.len - 1,
        };
    }

    fn ytest(self: Cardinal, word: []const u8, y: usize, height: usize) bool {
        return switch (self) {
            .up => y >= word.len - 1,
            .down => y + word.len <= height,
            .right, .left, .null => true,
        };
    }

    fn boundsTest(self: Cardinal, word: []const u8, x: usize, y: usize, width: usize, height: usize) bool {
        return self.xtest(word, x, width) and self.ytest(word, y, height);
    }

    fn xcoord(self: Cardinal, x: usize, i: usize) usize {
        return switch (self) {
            .up, .down, .null => x,
            .right => x + i,
            .left => x - i,
        };
    }

    fn ycoord(self: Cardinal, y: usize, i: usize) usize {
        return switch (self) {
            .up => y - i,
            .down => y + i,
            .right, .left, .null => y,
        };
    }
};

const Direction = enum {
    up,
    up_right,
    right,
    down_right,
    down,
    down_left,
    left,
    up_left,

    fn boundsTest(self: Direction, word: []const u8, x: usize, y: usize, width: usize, height: usize) bool {
        return switch (self) {
            .up => Cardinal.up.boundsTest(word, x, y, width, height),
            .up_right => Cardinal.up.boundsTest(word, x, y, width, height) and Cardinal.right.boundsTest(word, x, y, width, height),
            .right => Cardinal.right.boundsTest(word, x, y, width, height),
            .down_right => Cardinal.down.boundsTest(word, x, y, width, height) and Cardinal.right.boundsTest(word, x, y, width, height),
            .down => Cardinal.down.boundsTest(word, x, y, width, height),
            .down_left => Cardinal.down.boundsTest(word, x, y, width, height) and Cardinal.left.boundsTest(word, x, y, width, height),
            .left => Cardinal.left.boundsTest(word, x, y, width, height),
            .up_left => Cardinal.up.boundsTest(word, x, y, width, height) and Cardinal.left.boundsTest(word, x, y, width, height),
        };
    }

    fn ycoord(self: Direction, y: usize, i: usize) usize {
        return switch (self) {
            .up, .up_right, .up_left => Cardinal.up.ycoord(y, i),
            .right, .left => Cardinal.null.ycoord(y, i),
            .down_right, .down, .down_left => Cardinal.down.ycoord(y, i),
        };
    }

    fn xcoord(self: Direction, x: usize, i: usize) usize {
        return switch (self) {
            .right, .up_right, .down_right => Cardinal.right.xcoord(x, i),
            .left, .up_left, .down_left => Cardinal.left.xcoord(x, i),
            .up, .down => Cardinal.null.xcoord(x, i),
        };
    }
};

const Grid = struct {
    width: usize,
    height: usize,

    fn findWord(self: Grid, word: []const u8, x: usize, y: usize, dir: Direction) bool {
        if (!dir.boundsTest(word, x, y, self.width, self.height)) return false;
        var found = true;
        for (word, 0..word.len) |ch, i| {
            const index = dir.ycoord(y, i) * self.width + dir.xcoord(x, i);
            if (input[index] != ch) {
                found = false;
                break;
            }
        }
        return found;
    }

    fn print(self: Grid, x: usize, y: usize, word: []const u8, dir: Direction) !void {
        const stdout = std.io.getStdOut();
        const writer = stdout.writer();
        for (0..self.height) |row| {
            for (0..self.width) |col| {
                const index = row * self.width + col;
                const ch = input[index];
                if (ch == 0) break;
                if (x == col and y == row) try writer.writeAll("\x1b[4m");
                var drawn = false;
                if (dir.boundsTest(word, x, y, self.width, self.height)) {
                    for (word, 0..) |nextch, i| {
                        const wy = dir.ycoord(y, i);
                        const wx = dir.xcoord(x, i);
                        if (wx == col and wy == row) {
                            if (nextch == ch)
                                try std.fmt.format(writer, "\x1b[1;34m{c}\x1b[0m", .{ch})
                            else
                                try std.fmt.format(writer, "\x1b[31m{c}\x1b[0m", .{ch});
                            drawn = true;
                        }
                    }
                }
                if (!drawn) {
                    if (x == col and y == row)
                        try std.fmt.format(writer, "\x1b[33m{c}\x1b[0m", .{ch})
                    else
                        try writer.writeByte(ch);
                }
            }
        }
        try std.fmt.format(writer, "\n", .{});
    }
};

fn part1() !void {
    var width: usize = 0;
    var height: usize = 1;

    for (input, 1..) |ch, i| {
        if (ch == '\n') {
            if (width == 0) width = i;
            height += 1;
        }
    }

    const grid = Grid{ .width = width, .height = height };
    var total: u64 = 0;
    const word = "XMAS";

    for (0..height) |y| {
        for (0..width) |x| {
            if (grid.findWord(word, x, y, .up)) total += 1;
            if (grid.findWord(word, x, y, .up_right)) total += 1;
            if (grid.findWord(word, x, y, .right)) total += 1;
            if (grid.findWord(word, x, y, .down_right)) total += 1;
            if (grid.findWord(word, x, y, .down)) total += 1;
            if (grid.findWord(word, x, y, .down_left)) total += 1;
            if (grid.findWord(word, x, y, .left)) total += 1;
            if (grid.findWord(word, x, y, .up_left)) total += 1;
        }
    }

    std.debug.print("{}\n", .{total});
}

fn part2() !void {
    var width: usize = 0;
    var height: usize = 1;

    for (input, 1..) |ch, i| {
        if (ch == '\n') {
            if (width == 0) width = i;
            height += 1;
        }
    }

    const grid = Grid{ .width = width, .height = height };
    var total: u64 = 0;
    total += 0;
    const word = "MAS";

    const stdout = std.io.getStdIn();
    const writer = stdout.writer();

    for (0..height) |y| {
        for (0..width - 1) |x| {
            if (grid.findWord(word, x, y, .down_right) and
                grid.findWord(word, x, y + word.len - 1, .up_right)) total += 1;
            if (grid.findWord(word, x, y, .up_right) and
                grid.findWord(word, x + word.len - 1, y, .up_left)) total += 1;
            if (grid.findWord(word, x, y, .down_left) and
                grid.findWord(word, x, y + word.len - 1, .up_left)) total += 1;
            if (grid.findWord(word, x, y, .down_right) and
                grid.findWord(word, x + word.len - 1, y, .down_left)) total += 1;
        }
    }

    try std.fmt.format(writer, "{}\n", .{total});
}
