const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

const Pos = struct {
  x: i32,
  y: i32,

  pub fn from_line(line: []const u8) !Pos {
    const i  = std.ascii.indexOfIgnoreCase(line, ",");
    if (i) |i_| {
      const x = try std.fmt.parseInt(u8, line[0..i_], 10);
      const y = try std.fmt.parseInt(u8, line[i_+1..], 10);
      return Pos { .x = x, .y = y };
    }
    else {
      return error.WrongFormat;
    }
  }

  pub fn add(self: @This(), p: Pos) Pos {
    return Pos {
      .x = self.x + p.x,
      .y = self.y + p.y,
    };
  }
};

pub fn Input(comptime item_count: u16, comptime width: u8, comptime height: u8) type {
  return struct {
    items: [item_count]Pos,
    grid: [height][width]u8,

    pub fn from_file(file_path: []const u8) !@This() {
      var file = try std.fs.cwd().openFile(file_path, .{});
      defer file.close();

      var buf: [1024]u8 = undefined;
      const reader = file.reader();
      var i: usize = 0;
      var input = @This(){ .items = undefined, .grid = undefined};
      while (reader.readUntilDelimiter(&buf, '\n')) |line| : (i = i + 1) {
        if (i < input.items.len) {
          input.items[i] = try Pos.from_line(line);
        } else { break; }
      } else |err| {
        if (err != error.EndOfStream) {
          return err;
        }
      }
      return input;
    }

    fn setObstacle(self: *@This(), pos: Pos) void {
      self.grid[@intCast(pos.y)][@intCast(pos.x)] = '#';
    }

    fn getField(self: @This(), pos: Pos) ?u8 {
      if (pos.y >= 0 and pos.y < self.grid.len) {
        const line = self.grid[@intCast(pos.y)];
        if (pos.x >= 0 and pos.x < line.len) {
          return line[@intCast(pos.x)];
        }
      }
      return null;
    }

    fn initGrid(self: *@This()) void {
      for (&self.grid) |*line| {
        for (0..line.len) |i| {
          line[i] = '.';
        }
      }
      for (self.items) |item| {
        self.setObstacle(item);
      }
    }

    fn printGrid(self: @This()) void {
      for (self.grid) |line| {
        print("{s}\n", .{line});
      }
    }

    fn printVisited(self: @This(), visited: std.AutoHashMap(Pos, u64)) void {
      _ =self;

      for (0..height) |h| {
        for (0..width) |w| {

          const order = visited.get(Pos{.x = @intCast(w), .y = @intCast(h)});
          if (order) |o| {
            print("{:02} ", .{ o });
          } else {
            print(" - ", .{});
          }
        }
        print("\n",.{});
      }
    }

    fn solve(self: *@This(), allocator: Allocator) !?u64 {

      const OrderedPos = struct {
        pos: Pos,
        order: u64,
      };

      var queue = std.ArrayList(OrderedPos).init(allocator);

      const start = OrderedPos { .pos = Pos {.x = 0, .y = 0}, .order = 0 };
      try queue.append(start);
      defer queue.deinit();

      var visited = std.AutoHashMap(Pos, u64).init(allocator);
      defer visited.deinit();

      while (queue.popOrNull()) |pos| {

        if (visited.contains(pos.pos)) {
          continue;
        }

        const neighbours : [4]OrderedPos = [_]OrderedPos{
          .{ .order = pos.order+1, .pos = pos.pos.add(.{.x = -1, .y =  0})},
          .{ .order = pos.order+1, .pos = pos.pos.add(.{.x =  1, .y =  0})},
          .{ .order = pos.order+1, .pos = pos.pos.add(.{.x =  0, .y = -1})},
          .{ .order = pos.order+1, .pos = pos.pos.add(.{.x =  0, .y =  1})},
        };

        for (neighbours) |n| {
          if (getField(self.*, n.pos)) |c| {
            if (c == '.') {
              try queue.insert(0, n);
            }
          }
        }

        try visited.put(pos.pos, pos.order);

        if (pos.pos.x == width-1 and pos.pos.y == height-1) {
          break;
        }
      }

      // printVisited(self.*, visited);
      
      return visited.get(Pos { .y = height-1, .x = width-1});
    }

  };
}

fn day18(comptime item_count: u16, comptime grid_width: u8, comptime grid_height: u8, allocator: Allocator, file_path: []const u8) !void {
  var input = try Input(item_count, grid_width, grid_height).from_file(file_path);
  input.initGrid();
  // input.printGrid();
  const result = try input.solve(allocator);
  print("result: {?}\n", .{result});
}

pub fn main() !void {

  var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer arena_allocator.deinit();
  const allocator = arena_allocator.allocator();

  try day18(12, 7,7, allocator, "18-ex1.txt");
  try day18(1024, 71, 71, allocator, "18.txt",);
}