const std = @import("std");
const Allocator = std.mem.Allocator;

fn print(comptime format: []const u8, args: anytype) !void {
  const stdout = std.io.getStdOut().writer();
  return stdout.print(format, args);
}

fn readNumber(file_path: []const u8, list: *std.ArrayList(u64)) !void {
  const file = try std.fs.cwd().openFile(file_path, .{});
  defer file.close();

  var reader = file.reader();

  var buf: [1024]u8 = undefined;
  while (reader.readUntilDelimiterOrEof(&buf, '\n')) |read| {
    if (read) |r| {
      var fbs = std.io.fixedBufferStream(r);
      var number_reader = fbs.reader();
      var buf2: [20]u8 = undefined;
      while (number_reader.readUntilDelimiterOrEof(&buf2, ' ')) |read2| {
        if (read2) |r2| {
          try list.append(try std.fmt.parseInt(u64, r2, 10));
        } else break;
      } else |err2| return err2;
    } else break;
  } else |err| return err;
}

fn blink(list: *std.ArrayList(u64)) !void {

  var i : usize = 0;

  while (i < list.items.len) { 
    const n = list.items[i];

    if (n == 0) {
      list.items[i] = 1;
    } else {
      var buf : [20]u8 = undefined;
      const len = std.fmt.formatIntBuf(&buf, n, 10,  std.fmt.Case.lower, .{});
      if (len % 2 == 0) {
        list.items[i] = try std.fmt.parseInt(u64, buf[0..len/2] , 10);
        try list.insert(i+1, try std.fmt.parseInt(u64, buf[len/2..len] , 10));
        i = i + 1;
      } else  {
        list.items[i] = list.items[i] * 2024;
      }
    }

    i = i + 1;
  }
}

fn day11(file_path: []const u8, allocator: Allocator) !u64 {

  var numbers = std.ArrayList(u64).init(allocator);
  defer numbers.deinit();

  try readNumber(file_path, &numbers);

  for (0..25) |_| {
    try blink(&numbers);
  }

  // for (numbers.items) |item| {
  //   try print("{}\n", .{item});
  // }

  return numbers.items.len;
}

pub fn main() !void {

  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  const allocator = gpa.allocator();
  try print("result: {}\n", .{ try day11("11.txt", allocator) });
}