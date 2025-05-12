const std = @import("std");
const aoc = @import("./aoc.zig");

fn Pos(comptime T: type) type {
  return struct {
    x: T,
    y: T,

    pub fn add(self: @This(), pos: @This()) @This() {
      return @This() {
        .x = self.x + pos.x,
        .y = self.y + pos.y,
      };
    }
    pub fn scale(self: @This(), factor: T) @This() {
      return @This() {
        .x = self.x * factor,
        .y = self.y * factor,
      };
    }
  };
}

const directions = [_] Pos(i64) {
  Pos(i64) {.x =  1, .y =  0},
  Pos(i64) {.x =  1, .y =  1},
  Pos(i64) {.x =  0, .y =  1},
  Pos(i64) {.x = -1, .y =  1},
  Pos(i64) {.x = -1, .y =  0},
  Pos(i64) {.x = -1, .y = -1},
  Pos(i64) {.x =  0, .y = -1},
  Pos(i64) {.x =  1, .y = -1},
};

fn get_char(lines: std.ArrayList([]const u8), pos: Pos(i64)) ?u8 {
  return if (pos.y >= 0 and pos.x >= 0 and lines.items.len > pos.y and lines.items[@intCast(pos.y)].len > pos.x)
    lines.items[@intCast(pos.y)][@intCast(pos.x)]
  else
    null;
}

fn get_slice(lines: std.ArrayList([]const u8), pos: Pos(i64), buf: []u8 , direction: Pos(i64)) []u8 {
  var i: usize = 0;
  while (i < buf.len) : (i += 1) {
    if (get_char(lines, pos.add(direction.scale(@intCast(i))))) |c| {
      buf[i] = c;
    } else {
      break;
    }
  }
  return buf[0..i];
}

fn solve(file_path: []const u8, allocator: std.mem.Allocator) !void {

  // load the file
  var lines = std.ArrayList([]const u8).init(allocator);
  try aoc.read_file_to_list(file_path, &lines, allocator);

  // count the XMAS
  var result: i64 = 0;
  var buf: [4]u8 = undefined;
  for (0..lines.items.len) |y|{
    for (0..lines.items[@intCast(y)].len) |x| {
      for (directions) |d| {
        const s = get_slice(lines, .{.x = @intCast(x), .y = @intCast(y)}, &buf, d);
        if (std.mem.eql(u8, s, "XMAS")) {
          result += 1;
        }
      }
    }
  }

  // print the result
  aoc.println("result: {}", .{result});
}

pub fn main() !void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();

  var arena = std.heap.ArenaAllocator.init(gpa.allocator());
  defer arena.deinit();
  const allocator = arena.allocator();

  try solve("04-ex.txt", allocator);
  try solve("04.txt", allocator);
}