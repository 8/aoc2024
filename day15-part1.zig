const std = @import("std");
const print = @import("std").debug.print;
const Allocator = std.mem.Allocator;

const Input = struct {
  allocator: Allocator,
  map: [][]u8,
  moves: []u8,

  pub fn deinit(self: @This()) void {
    for (self.map) |line| {
      self.allocator.free(line);
    }
    self.allocator.free(self.map);
    self.allocator.free(self.moves);
  }
  pub fn init_from_file(file_path: []const u8, allocator: Allocator) !Input {

    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const reader = file.reader();

    var map_list = std.ArrayList([]u8).init(allocator);
    defer map_list.deinit();

    var moves_list = std.ArrayList(u8).init(allocator);
    defer moves_list.deinit();

    var isMap: bool = true;
    var buf: [1024]u8 = undefined;
    while (reader.readUntilDelimiter(&buf, '\n')) |read| {

      if (read.len == 0) {
        isMap = false;
      }
      else if (isMap) {
        const line = try allocator.dupe(u8, read);
        try map_list.append(line);
      }
      else {
        try moves_list.appendSlice(read);
      }

    } else | e | { if (e != error.EndOfStream) { return e; } }

    return Input {
      .allocator = allocator,
      .map = (try map_list.toOwnedSlice()),
      .moves = (try moves_list.toOwnedSlice()),
    };
  }
};

const Pos = struct {
  y: i32,
  x: i32,

  pub fn add(pos1: @This(), pos2: @This()) @This() {
    return Pos {
      .x = pos1.x + pos2.x,
      .y = pos1.y + pos2.y,
    };
  }

  pub fn sub(pos1: @This(), pos2: @This()) @This() {
    return Pos {
      .x = pos1.x - pos2.x,
      .y = pos1.y - pos2.y,
    };
  }

  pub fn fromMove(move: u8) ?@This() {
    return switch (move) {
      '^' => Pos { .y = -1, .x =  0 },
      '<' => Pos { .y =  0, .x = -1 },
      '>' => Pos { .y =  0, .x =  1 },
      'v' => Pos { .y =  1, .x =  0 },
      else => null
    };
  }
};

fn findRobot(map: [][]u8) ?Pos {
  for (map, 0..) |line, y| {
    for (line, 0..) |c, x| {
      if (c == '@') {
        return Pos {.y = @intCast(y) , .x = @intCast(x)};
      }
    }
  }
  return null;
}

fn getYX(map: [][]u8, y: i32, x: i32) ?u8 {
  if (y >= 0 and y < map.len) {
    const line = map[@intCast(y)];
    if (x >= 0 and x < line.len) {
      return line[@intCast(x)];
    }
  }
  return null;
}

fn moveRobot(map: [][]u8, move: u8) void {
  if (findRobot(map)) |robot| {
    
    if (Pos.fromMove(move)) |step| {
      var p = robot;

      // find the next free spot that comes before a wall in that direction
      const empty: ?Pos =
        while (getYX(map, p.y, p.x)) |obj| {
          if (obj == '.') {
            break p;
          } else if (obj == '#') {
            break null;
          }
          p = Pos.add(p, step);
        } else null;

      if (empty) |e| {
        // move all items in reverse order in that free spot
        p = e;
        while (true) {
          // once we reached the starting tile mark it as empty and stop
          if (p.x == robot.x and p.y == robot.y) {
            map[@intCast(robot.y)][@intCast(robot.x)] = '.';
            break;
          } else {
            const prev = Pos.sub(p, step);
            if (getYX(map, prev.y, prev.x)) |c| {
              map[@intCast(p.y)][@intCast(p.x)] = c;
            }
            p = prev;
          }
        }
      }
    }

  }
}

fn printMap(map: [][]u8) void {
  for (map) |line| {
    print("{s}\n", .{line});
  }
}

fn calcScore(map: [][]u8) u64 {
  var sum: u64 = 0;
  for (map, 0..) |line, y| {
    for (line, 0..) |c, x| {
      if (c == 'O') {
        sum += (y*100+x);
      }
    }
  }
  return sum;
}

fn day15(file_path: [] const u8, allocator: Allocator) !void {

  const input = try Input.init_from_file(file_path, allocator);
  defer input.deinit();
  // printMap(input.map);
  for (input.moves) |move| {
    moveRobot(input.map, move);
    // printMap(input.map);
  }

  const result = calcScore(input.map);
  print("file_path: {s}, result: {}\n", .{file_path, result});
}

pub fn main() !void {
  var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer allocator.deinit();
 
  try day15("15-ex.txt", allocator.allocator());
  try day15("15-ex2.txt", allocator.allocator());
  try day15("15.txt", allocator.allocator());
}