const std = @import("std");
const Allocator = std.mem.Allocator;

const stdout = std.io.getStdOut().writer();
fn print(comptime format: [] const u8, args: anytype) !void {
  try stdout.print(format, args);
}

fn readPatterns(line: []const u8, patterns: *std.StringHashMap(void), allocator: Allocator) !void {
  var fbs = std.io.fixedBufferStream(line);
  var reader = fbs.reader();
  var buf : [1024]u8 = undefined;
  while (reader.readUntilDelimiterOrEof(&buf, ',')) |read_maybe| {
    if (read_maybe) |read| {
      const s = if (read[0] == ' ') read[1..] else read;
      try patterns.put(try allocator.dupe(u8, s), {});
    } else break;
  } else |err| {
    return err;
  }
}

fn printPatterns(patterns: std.StringHashMap(void)) !void {
  try print("read patterns: {}\n", .{patterns.count()});
  var iterator = patterns.keyIterator();
  while (iterator.next()) |p| {
    try print("\t'{s}'\n",.{p.*});
  }
}

fn getMaxPatternLength(patterns: std.StringHashMap(void)) usize {
  var iterator = patterns.keyIterator();
  var max : usize = 0;
  while (iterator.next()) |p| {
    if (p.len > max) {
      max = p.len;
    }
  }
  return max;
}

// fn solve(line: []const u8, patterns: std.StringHashMap(void), max_pattern_length: usize, allocator: Allocator) !bool {

//   var queue = std.ArrayList([]const u8).init(allocator);
//   defer queue.deinit();
//   try queue.append(line);

//   while (queue.popOrNull()) |item| {

//     for (0..(@min(item.len, max_pattern_length))) |i| {
//       const s = item[0..i+1];

//       if (patterns.contains(s)) {
//         const rem = item[i+1..];

//         if (rem.len == 0) {
//           return true;
//         }
//         try queue.append(rem);
//       }
//     }
//   }
  
//   return false;
// }

fn solve(line: []const u8, patterns: std.StringHashMap(void), max_pattern_length: usize, allocator: Allocator) !bool {

  const Item = struct {
    line: []const u8,
    i: usize,
  };

  var queue = std.ArrayList(Item).init(allocator);
  defer queue.deinit();

  try queue.append(.{.line = line, .i = 1});

  while (queue.popOrNull()) |item| {

    const s = item.line[0..item.i];
    // try print("checking: '{s}'\n", .{});

    if (patterns.contains(s)) {
      const rem = item.line[item.i..];
      try print("rem: '{s}\n'", .{rem});
      if (rem.len == 0) {
        return true;
      }
      try queue.append(.{.line = rem, .i = 1});
    }
    else if (item.i < @min(item.line.len, max_pattern_length)) {
      try queue.append(.{.line = item.line, .i = item.i+1});
    }
  }

  return false;
}

fn day19(file_path: []const u8, allocator: Allocator) !void {

  var file = try std.fs.cwd().openFile(file_path, .{});
  defer file.close();

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  var patterns = std.StringHashMap(void).init(arena.allocator());
  
  var reader = file.reader();
  var buf : [3000]u8 = undefined;
  var i: usize = 0;
  var possible_count: usize = 0;
  var max_pattern_length: usize = 0;
  while (reader.readUntilDelimiter(&buf, '\n')) |read| : (i+=1) {
    if (i == 0) {
      try readPatterns(read, &patterns, arena.allocator());
      max_pattern_length = getMaxPatternLength(patterns);
      // try printPatterns(patterns);
    } else if (i > 1) {

      try print("try solve '{s}'...", .{read});
      if (try solve(read, patterns, max_pattern_length, allocator)) {
        possible_count+=1;
        try print("true\n", .{});
      } else {
        try print("false\n", .{});
      }
    }
  } else |err|{ 
    if (err != error.EndOfStream) {
      return err;
    }
  }

  try print("{s}: {}\n", .{file_path, possible_count});
}

pub fn main() !void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  try day19("19-ex1.txt", allocator);
  // try day19("19.txt", allocator);
}