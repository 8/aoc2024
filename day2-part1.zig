const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
  try print_part1("02-ex.txt");
  try print_part1("02.txt");
}

fn print_part1(file_path: []const u8) !void {
  const result = try solve_part1(file_path);
  try stdout.print("file: '{s}', result: {}\n", .{file_path, result});
}

fn solve_part1(file_path: []const u8) !u32 {
  const file = try std.fs.cwd().openFile(file_path, .{});
  defer file.close();

  var safe_lines: u32 = 0;
  var buf: [256]u8 = undefined;
  var reader = file.reader();
  while (reader.readUntilDelimiterOrEof(&buf, std.ascii.control_code.lf)) |read| {
    if (read) |line| {
      if (try is_line_safe(line))
        safe_lines += 1;
    } else break;
  }
  else |err| {
    return err;
  }

  return safe_lines;
}

const Direction = enum {
  asc, desc,

  pub fn from_diff(diff: i32) @This() {
    return if (diff < 0) Direction.desc else Direction.asc;
  }
};

fn is_line_safe(line: []const u8) !bool {
  var buf: [8]u8 = undefined;
  var fbs = std.io.fixedBufferStream(line);
  var reader = fbs.reader();

  var last_dir: ?Direction = null;
  var last_num: ?i32 = null;
  while (reader.readUntilDelimiterOrEof(&buf, ' ')) |read|{
    if (read) |s_num| {
      const n = try std.fmt.parseInt(i32, s_num, 10);
      if (last_num != null) {
        const diff = last_num.? - n;
        switch (@abs(diff)) {
          1...3 => {},
          else => return false,
        }
        if (last_dir == null) {
          last_dir = Direction.from_diff(diff);
        } else if (last_dir.? != Direction.from_diff(diff)) {
          return false;
        }
      }
      last_num = n;
      
    } else break;
  } else |err| {
    return err;
  }

  return true;
}

test "is_line_safe" {
  try std.testing.expect(try is_line_safe("7 6 4 2 1"));
}
