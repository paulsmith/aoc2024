const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    try part1();
    try part2();
}

const WORD = "XMAS";

const Cardinal = enum {
    up,
    right,
    down,
    left,
    null,

    fn xtest(self: Cardinal, x: usize, width: usize) bool {
        return switch (self) {
            .up, .down, .null => true,
            .right => x + WORD.len <= width,
            .left => x >= WORD.len - 1,
        };
    }

    fn ytest(self: Cardinal, y: usize, height: usize) bool {
        return switch (self) {
            .up => y >= WORD.len - 1,
            .down => y + WORD.len <= height,
            .right, .left, .null => true,
        };
    }

    fn boundaryTest(self: Cardinal, x: usize, y: usize, width: usize, height: usize) bool {
        return self.xtest(x, width) and self.ytest(y, height);
    }

    fn xindex(self: Cardinal, x: usize, i: usize) usize {
        return switch (self) {
            .up, .down, .null => x,
            .right => x + i,
            .left => x - i,
        };
    }

    fn yindex(self: Cardinal, y: usize, i: usize) usize {
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

    fn boundaryTest(self: Direction, x: usize, y: usize, width: usize, height: usize) bool {
        return switch (self) {
            .up => Cardinal.up.boundaryTest(x, y, width, height),
            .up_right => Cardinal.up.boundaryTest(x, y, width, height) and Cardinal.right.boundaryTest(x, y, width, height),
            .right => Cardinal.right.boundaryTest(x, y, width, height),
            .down_right => Cardinal.down.boundaryTest(x, y, width, height) and Cardinal.right.boundaryTest(x, y, width, height),
            .down => Cardinal.down.boundaryTest(x, y, width, height),
            .down_left => Cardinal.down.boundaryTest(x, y, width, height) and Cardinal.left.boundaryTest(x, y, width, height),
            .left => Cardinal.left.boundaryTest(x, y, width, height),
            .up_left => Cardinal.up.boundaryTest(x, y, width, height) and Cardinal.left.boundaryTest(x, y, width, height),
        };
    }

    fn yindex(self: Direction, y: usize, i: usize) usize {
        return switch (self) {
            .up, .up_right, .up_left => Cardinal.up.yindex(y, i),
            .right, .left => Cardinal.null.yindex(y, i),
            .down_right, .down, .down_left => Cardinal.down.yindex(y, i),
        };
    }

    fn xindex(self: Direction, x: usize, i: usize) usize {
        return switch (self) {
            .right, .up_right, .down_right => Cardinal.right.xindex(x, i),
            .left, .up_left, .down_left => Cardinal.left.xindex(x, i),
            .up, .down => Cardinal.null.xindex(x, i),
        };
    }
};

const Grid = struct {
    width: usize,
    height: usize,

    fn findWord(self: Grid, x: usize, y: usize, dir: Direction) bool {
        if (!dir.boundaryTest(x, y, self.width, self.height)) return false;
        var found = true;
        for (WORD, 0..WORD.len) |ch, i| {
            const index = dir.yindex(y, i) * self.width + dir.xindex(x, i);
            if (input[index] != ch) {
                found = false;
                break;
            }
        }
        return found;
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

    for (0..height) |y| {
        for (0..width) |x| {
            if (grid.findWord(x, y, .up)) total += 1;
            if (grid.findWord(x, y, .up_right)) total += 1;
            if (grid.findWord(x, y, .right)) total += 1;
            if (grid.findWord(x, y, .down_right)) total += 1;
            if (grid.findWord(x, y, .down)) total += 1;
            if (grid.findWord(x, y, .down_left)) total += 1;
            if (grid.findWord(x, y, .left)) total += 1;
            if (grid.findWord(x, y, .up_left)) total += 1;
        }
    }

    std.debug.print("{}\n", .{total});
}

fn part2() !void {}
