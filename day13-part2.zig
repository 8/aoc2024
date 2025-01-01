const print = @import("std").debug.print;
const std = @import("std");

fn lenOfNum(buf: []const u8) usize {
  for (buf, 0..) |c, i| {
    if (!std.ascii.isDigit(c)) {
      return i;
    }
  }
  return buf.len;
}

fn parseNumberAfter(comptime T: type, haystack: []const u8, needle: []const u8) !?T {
  if (std.ascii.indexOfIgnoreCase(haystack, needle)) |index| {
    const start = index+needle.len;
    const end = start + lenOfNum(haystack[start..]);
    return try std.fmt.parseInt(T, haystack[start..end], 10);
  }
  else {
    return null;
  }
}

const Point = struct {
  x: i64,
  y: i64,
};

const Machine = struct {
  a: Point,
  b: Point,
  prize: Point,

  pub fn from(file_path: []const u8, alloc: std.mem.Allocator) ![]Machine {
    var machines = std.ArrayList(Machine).init(alloc);

    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const reader = file.reader();

    const offset = 10000000000000;

    var buf: [1014]u8 = undefined;
    var i:u32 = 0;
    var a : Point = undefined;
    var b : Point = undefined;
    var prize : Point = undefined;
    while (reader.readUntilDelimiter(&buf, '\n')) |read| {
      switch (i%4) {
        0 => {
          a = .{
            .x = (try parseNumberAfter(i64, read, "X+")).?,
            .y = (try parseNumberAfter(i64, read, "Y+")).?,
           };
        },
        1 => {
          b = .{
            .x = (try parseNumberAfter(i64, read, "X+")).?,
            .y = (try parseNumberAfter(i64, read, "Y+")).?,
           };
        },
        2 => {
          prize = .{
            .x = (try parseNumberAfter(i64, read, "X=")).? + offset,
            .y = (try parseNumberAfter(i64, read, "Y=")).? + offset,
           };
        },
        else => {
          try machines.append(Machine{ .a = a, .b = b, .prize = prize });
        },
      }
      i = i+1;
    } else |err| {
      if (err == error.EndOfStream) {
        try machines.append(Machine{ .a = a, .b = b, .prize = prize });
      } else {
        return err;
      }
    }

    return machines.toOwnedSlice();
  }

  pub fn solve(self: *const @This()) ?i64 {

    const a_count = @divFloor(
      ((self.b.x * self.prize.y) - (self.b.y * self.prize.x)),
      ((self.b.x * self.a.y) - (self.b.y * self.a.x))
    );
    
    const b_count = @divFloor(
      ((self.a.x * self.prize.y) - (self.a.y * self.prize.x)),
      ((self.a.x * self.b.y) - (self.a.y * self.b.x))
    );

    const x = (a_count * self.a.x) + (b_count * self.b.x);
    const y = (a_count * self.a.y) + (b_count * self.b.y);

    if (x == self.prize.x and y == self.prize.y)
      return (a_count*3)+(b_count)
    else
      return null;
  }

};

pub fn day13(file_path: []const u8, allocator: std.mem.Allocator) !i64 {
  const machines = try Machine.from(file_path, allocator);
  var sum : i64 = 0;
  for (machines) |machine| {
    const solution = machine.solve();
    if (solution) |s| {
      sum = sum + s;
    }
  }

  return sum;
}

pub fn main() !void {
  var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer allocator.deinit();

  print("{}\n", .{ try day13("13-ex1.txt", allocator.allocator())});
  print( "{}\n", .{ try day13("13.txt", allocator.allocator())});
}