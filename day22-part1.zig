const std = @import("std");
const stdout = std.io.getStdOut().writer();

fn print(comptime format: []const u8, args: anytype) !void {
  try stdout.print(format, args);
}

fn mix(value: u64, secret_number: u64) u64 {
  return value ^ secret_number;
}

test "mix" {
  try std.testing.expectEqual(37, mix(15,42));
}

fn prune(secret_number: u64) u64 {
  return secret_number % 16777216;
}

test "prune" {
  try std.testing.expectEqual(16113920, prune(100000000));
}

fn next(n: u64) u64 {
  const n1 = prune(mix(n * 64, n));
  const n2 = prune(mix(n1 / 32, n1));
  const n3 = prune(mix((n2*2048), n2));
  return n3;
}

test "next" {
  try std.testing.expectEqual(15887950, next(123));
}

fn nextTimes(n: u64, times: usize) u64 {
  var num = n;
  for (0..times) |_| {
    num = next(num);
  }
  return num;
}

test "nextTimes" {
  const result = nextTimes(123, 10);
  try std.testing.expectEqual(5908254, result);
}

fn day22(file_path: [] const u8) !u64 {
  try print("{s}\n", .{file_path});

  const file = try std.fs.cwd().openFile(file_path, .{});
  var reader = file.reader();
  var buf :[10]u8 = undefined;
  var sum: u64 = 0;
  while (reader.readUntilDelimiter(&buf, '\n')) |read| {
    const number = try std.fmt.parseInt(u64, read, 10);
    const new_number = nextTimes(number, 2000);
    sum += new_number;
  } else |err| {
    if (err != error.EndOfStream) {
      return err;
    }
  }

  try print("{s}: {}\n", .{file_path, sum});
  return sum;
}

pub fn main() !void {
  _ = try day22("22-ex1.txt");
  _ = try day22("22.txt");
}