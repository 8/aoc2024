const std = @import("std");
const Allocator = std.mem.Allocator;
const Input = @import("Helper.zig").Input;
const Pos = @import("Helper.zig").Pos;
const stdout = std.io.getStdOut().writer();
fn print(comptime format: []const u8, args: anytype) !void {
  try stdout.print(format, args);
}

fn find(haystack: [][]const u8, needle: u8) ?Pos {
  for (haystack, 0..) |line, y| {
    for (line, 0..) |c, x| {
      if (c == needle) {
        return Pos { .x = @intCast(x), .y = @intCast(y) };
      }
    }
  }
  return null;
}

fn getDistance(allocator: Allocator, input: Input, cheat: Pos) !u32 {

  const OrderedPos = struct {
    pos: Pos,
    distance: u32,
  };

  var queue = std.ArrayList(OrderedPos).init(allocator);
  defer queue.deinit();

  const start_pos = find(input.lines, 'S').?;
  try queue.append(.{.pos = start_pos, .distance = 0});

  var hashmap = std.AutoHashMap(Pos, u32).init(allocator);
  defer hashmap.deinit();

  while (queue.popOrNull()) |item| {
    try hashmap.put(item.pos, item.distance);

    const neighbours = [_]Pos{
      Pos.add(item.pos, .{.x= -1, .y =  0}),
      Pos.add(item.pos, .{.x=  1, .y =  0}),
      Pos.add(item.pos, .{.x=  0, .y = -1}),
      Pos.add(item.pos, .{.x=  0, .y =  1}),
    };

    for (neighbours) |n| {
      if (input.getYX(n.y, n.x)) |c| {
        if (c == '.' or c == 'E' or n.eql(cheat)) {
          if (!hashmap.contains(.{.y = n.y, .x = n.x})) {
            try queue.insert(0, .{.pos =  n, .distance = item.distance+1});
          }
        }
      }
    }
  }

  const end_pos = find(input.lines, 'E').?;

  const distance = hashmap.get(end_pos).?;

  return distance;
}

fn day20(allocator: Allocator, file_path: []const u8) !void {
  const input = try Input.init(file_path, allocator);
  defer input.deinit();

  const default_distance = try getDistance(allocator, input, .{.x = -1, .y = -1});
  try print("default distance: {}\n", .{default_distance});

  var count: u32 = 0;
  for (input.lines, 0..) |line, y| {
    for (line, 0..) |c, x| {
      if (c == '#') {
        const distance = try getDistance(allocator, input, .{ .x = @intCast(x), .y = @intCast(y)});
        const saved = default_distance - distance;
        if (saved >= 100) {
          try print("cheat saved: {}\n", .{saved});
          count += 1;
        }
      }
    }
  }
  
  try print("{s} {}\n", .{file_path, count});
}

pub fn main() !void {
  var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer arena_allocator.deinit();
  const allocator = arena_allocator.allocator();

  // try day20(allocator, "20-ex1.txt");
  try day20(allocator, "20.txt");
}