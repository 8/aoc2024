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
    for (line, 0..) |c,x| {
      if (c == needle) {
        return .{.x = @intCast(x), .y = @intCast(y)};
      }
    }
  }
  return null;
}

fn day16(file_path: []const u8, allocator: Allocator) !void {

  const input = try Input.init(file_path, allocator);
  defer input.deinit();

  const OrderedPos = struct{
    pos: Pos,
    distance: u32,
    dir: Pos,

    pub fn sort(_: void, pos1: @This(), pos2: @This()) bool {
      return pos1.distance > pos2.distance;
    }
  };

  var queue = std.ArrayList(OrderedPos).init(allocator);
  defer queue.deinit();

  const start = find(input.lines, 'S').?;
  try queue.append(.{ .pos = start, .distance = 0, .dir = .{.x = 1, .y = 0}});

  var visited = std.AutoHashMap(Pos, u32).init(allocator);
  defer visited.deinit();

  while (queue.popOrNull()) |item| {

    if (!visited.contains(item.pos)) {
      try visited.put(item.pos, item.distance);

      const dirs = [_]Pos {
        .{.y = -1, .x = 0 },
        .{.y = 1, .x = 0 },
        .{.y = 0, .x = -1 },
        .{.y = 0, .x = 1 },
      };

      for (dirs) |dir| {
        const n = Pos.add(item.pos, dir);
        if (input.getYX(n.y, n.x)) |c| {
          if (c == '.' or c == 'E') {
            if (!visited.contains(n)) {
              const cost: u32 = if (item.dir.eql(dir)) 1 else 1001;
              try queue.insert(0, .{
                .pos = n,
                .distance = item.distance + cost,
                .dir = dir,
              });
            }
          }
        }
      }

      // sort
      std.mem.sort(OrderedPos, queue.items, {}, OrderedPos.sort);
    }
  }

  const end = find(input.lines, 'E').?;
  const result = visited.get(end).?;

  try print("{s}: {}\n", .{file_path, result});
}

pub fn main() !void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  const allocator = gpa.allocator();
  try day16("16-ex1.txt", allocator);
  try day16("16.txt", allocator);
}