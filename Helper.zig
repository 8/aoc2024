const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Input = struct {
  lines: [][]const u8 = undefined,
  allocator: Allocator = undefined,

  pub fn init(file_path: []const u8, allocator: Allocator) !@This() {
    var file = try std.fs.cwd().openFile(file_path, .{});
    const reader = file.reader();
    var lines_list = std.ArrayList([]u8).init(allocator);
    defer lines_list.deinit();

    while (reader.readUntilDelimiterAlloc(allocator, '\n', 1024)) |line| {
      try lines_list.append(line);
    }
    else |e| {
      if (e != error.EndOfStream) return e;
    }

    return @This() {
      .allocator = allocator,
      .lines = try lines_list.toOwnedSlice(),
    };
  }
  pub fn deinit(self: @This()) void {
    for (self.lines) |line| {
      self.allocator.free(line);
    }
    self.allocator.free(self.lines);
  }

  pub fn getYX(self: @This(), y: i32, x: i32) ?u8 {
    if (y >= 0 and y < self.lines.len) {
      const line = self.lines[@intCast(y)];
      if (x >= 0 and x < line.len) {
        return line[@intCast(x)];
      }
    }
    return null;
  }
};

test "init/deinit" {
  const allocator = std.testing.allocator;
  const input = try Input.init("16.txt", allocator);
  defer input.deinit();
}

pub const Pos = struct {
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
};