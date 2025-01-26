const std = @import("std");
const Allocator = std.mem.Allocator;
const stdout = std.io.getStdOut().writer();
fn print (comptime format: []const u8, args: anytype) !void {
  try stdout.print(format, args);
}

const Schematic = struct {
  columns: [5]u8,
};

fn char2Num(c: u8) !u8 {
  return switch (c) {
    '.' => 0,
    '#' => 1,
    else => error.InvalidChar,
  };
}

fn getValue(buf: [6*7+1] u8, row: u8, col: u8) !u8 {
  return try char2Num(buf[6*row+col]);
}

fn getCol(buf: [6*7+1]u8, col:u8) !u8 {
  return
    try getValue(buf, 0, col) +
    try getValue(buf, 1, col) +
    try getValue(buf, 2, col) +
    try getValue(buf, 3, col) +
    try getValue(buf, 4, col) +
    try getValue(buf, 5, col) +
    try getValue(buf, 6, col)
    - 1;
}

fn day25(file_path: []const u8, allocator: Allocator) !void {

  var aa = std.heap.ArenaAllocator.init(allocator);
  defer aa.deinit();
  const a = aa.allocator();

  // read inputs
  var keys = std.ArrayList(Schematic).init(a);
  defer keys.deinit();
  var locks = std.ArrayList(Schematic).init(a);
  defer locks.deinit();

  var file = try std.fs.cwd().openFile(file_path, .{});
  defer file.close();

  var reader = file.reader();

  var buf: [6*7+1]u8 = undefined;
  while (reader.read(&buf)) |read| {
    if (read == 0) {
      break;
    } else {

      var columns: [5] u8 = undefined;

      for (0..columns.len) |i| {
        columns[i] = try getCol(buf, @intCast(i));
      }

      if (buf[0] == '#') {
        try locks.append(Schematic {.columns = columns});
      } else {
        try keys.append(Schematic {.columns = columns});
      }
    }
  } else |err| { 
    if (err != error.EndOfStream) {
      return err;
    }
  }

  // // print locks & keys
  // for (locks.items) |lock| {
  //   try print("lock: {d}\n", .{lock.columns});
  // }
  // for (keys.items) |key| {
  //   try print("key: {d}\n", .{key.columns});
  // }

  // count the matches
  var result : u32 = 0;
  const Vec5 = @Vector(5, u8);

  const max: Vec5 = @splat(6);

  for (locks.items) |lock| {
    const lock_v : Vec5 = lock.columns;
    for (keys.items) |key| {
      const key_v: Vec5 = key.columns;

      const res = lock_v + key_v;
      if (@reduce(std.builtin.ReduceOp.And, res < max)) {
        result += 1;
      }
    }
  }

  try print("{s}: {}\n", .{file_path, result});
  // try print("locks: {}, keys: {}\n", .{locks.items.len, keys.items.len});
}

pub fn main() !void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  try day25("25-ex1.txt", allocator);
  try day25("25.txt", allocator);
}