const std = @import("std");
const startsWith = std.mem.startsWith;
const input = @embedFile("input.txt");

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    var answer: i64 = 0;

    var pos: u64 = 0;
    const inst = "mul";

    while (pos < input.len) {
        var opa: i64 = undefined;
        var opb: i64 = undefined;
        while (!std.mem.startsWith(u8, input[pos..], inst)) pos += 1;
        pos += inst.len;
        if (input[pos] == '(') pos += 1 else continue;
        if (matchDigitRun(input[pos..])) |len| {
            opa = try std.fmt.parseInt(i64, input[pos .. pos + len], 10);
            pos += len;
        } else continue;
        if (input[pos] == ',') pos += 1 else continue;
        if (matchDigitRun(input[pos..])) |len| {
            opb = try std.fmt.parseInt(i64, input[pos .. pos + len], 10);
            pos += len;
        } else continue;
        if (input[pos] == ')') pos += 1 else continue;
        answer += opa * opb;
    }

    std.debug.print("{}\n", .{answer});
}

fn matchDigitRun(s: []const u8) ?u64 {
    var len: u64 = 0;
    while (len < s.len and std.ascii.isDigit(s[len])) len += 1;
    if (len == 0) return null;
    return len;
}

fn part2() !void {
    var answer: i64 = 0;

    var pos: u64 = 0;
    const mul = "mul";
    const do = "do()";
    const dont = "don't()";
    var enabled = true;

    while (pos < input.len) {
        var opa: i64 = undefined;
        var opb: i64 = undefined;
        while (!(startsWith(u8, input[pos..], mul) or
            startsWith(u8, input[pos..], do) or
            startsWith(u8, input[pos..], dont))) pos += 1;
        if (startsWith(u8, input[pos..], do)) {
            pos += do.len;
            enabled = true;
            continue;
        }
        if (startsWith(u8, input[pos..], dont)) {
            pos += dont.len;
            enabled = false;
            continue;
        }
        pos += mul.len;
        if (input[pos] == '(') pos += 1 else continue;
        if (matchDigitRun(input[pos..])) |len| {
            opa = try std.fmt.parseInt(i64, input[pos .. pos + len], 10);
            pos += len;
        } else continue;
        if (input[pos] == ',') pos += 1 else continue;
        if (matchDigitRun(input[pos..])) |len| {
            opb = try std.fmt.parseInt(i64, input[pos .. pos + len], 10);
            pos += len;
        } else continue;
        if (input[pos] == ')') pos += 1 else continue;
        if (enabled) answer += opa * opb;
    }

    std.debug.print("{}\n", .{answer});
}
