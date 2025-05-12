const std = @import("std");

const stdout =  std.io.getStdOut().writer();

pub fn print(comptime format: []const u8, args: anytype) void {
  stdout.print(format, args) catch {};
}
pub fn println(comptime format: []const u8, args: anytype) void {
  print(format ++ "\n", args);
}

pub fn read_file_to_list(file_path: []const u8, lines: *std.ArrayList([]const u8), allocator: std.mem.Allocator) !void {
  var file = try std.fs.cwd().openFile(file_path, .{});
  defer file.close();
  var reader = file.reader();
  var buf: [1024]u8 = undefined;
  while (reader.readUntilDelimiterOrEof(&buf, '\n')) |read| {
    if (read) |r| {
      try lines.append(try allocator.dupe(u8, r));
    } else break;
  } else |err| {
    return err;
  }
}
