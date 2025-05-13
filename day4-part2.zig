const std = @import("std");
const aoc = @import("./aoc.zig");

fn solve(file_path: []const u8, allocator: std.mem.Allocator) !void {

  // load the file
  var lines = std.ArrayList([]const u8).init(allocator);
  try aoc.read_file_to_list(file_path, &lines, allocator);

  // count the X-MAS
  var result: i64 = 0;
  for (0..lines.items.len) |y|{
    for (0..lines.items[@intCast(y)].len) |x| {
      if (y > 0 and y < lines.items.len-1 and
          x > 0 and x < lines.items[y].len-1 and
          lines.items[y][x] == 'A') {
        if ( ((lines.items[y-1][x-1] == 'M' and lines.items[y+1][x+1] == 'S') or (lines.items[y+1][x+1] == 'M' and lines.items[y-1][x-1] == 'S'))
          and ((lines.items[y+1][x-1] == 'M' and lines.items[y-1][x+1] == 'S') or (lines.items[y-1][x+1] == 'M' and lines.items[y+1][x-1] == 'S')) )
        result += 1;
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

  try solve("04-ex-2.txt", allocator);
  try solve("04.txt", allocator);
}