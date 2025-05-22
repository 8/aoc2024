const std = @import("std");
const aoc = @import("./aoc.zig");

pub fn main()!void {
  
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  var arena = std.heap.ArenaAllocator.init(gpa.allocator());
  defer arena.deinit();

  try solve("05-ex.txt", arena.allocator());
  try solve("05.txt", arena.allocator());
}

const Lookup = std.AutoHashMap(u32, *std.AutoHashMap(u32, void));

fn is_valid(numbers: []const u32, lookup: *Lookup) bool {
  for (numbers, 0..) |number, i| {
    if (lookup.get(number)) |forbidden| {
      for (numbers[i+1..]) |next_number| {
        if (forbidden.contains(next_number)) {
          return false;
        }
      }
    }
  }
  return true;
}

fn get_empty_line_index(lines: [][]const u8) ?usize {
  for (lines, 0..) |line,i| {
    if (std.mem.eql(u8, line, ""))
      return i;
  }
  return null;
}

fn read_lines_to_lookup(lines: [][]const u8, lookup: *Lookup, allocator: std.mem.Allocator) !void {
  for (lines) |line| {
    var iter = std.mem.splitScalar(u8, line, '|');
    var i: u32 = 0;
    var n1: u32 = undefined;
    while (iter.next()) |part| : (i+=1) {
      if (i == 0) {
        n1 = try std.fmt.parseInt(u32, part, 10);
      } else if (i == 1) {
        const n2 = try std.fmt.parseInt(u32, part, 10);
        var forbidden: *std.AutoHashMap(u32, void) = undefined;
        if (lookup.get(n2)) |f| {
          forbidden = f;
        } else {
          forbidden = try allocator.create(std.AutoHashMap(u32, void));
          forbidden.* = std.AutoHashMap(u32, void).init(allocator);
          try lookup.put(n2, forbidden);
        }
        try forbidden.put(n1, {});
      }
    }
  }
}

fn solve(file_path: []const u8, allocator: std.mem.Allocator) !void {

  var lines = std.ArrayList([]const u8).init(allocator);
  try aoc.read_file_to_list(file_path, &lines, allocator);

  const empty_line_index = get_empty_line_index(lines.items) orelse return error.NoEmptyLine;

  var lookup = Lookup.init(allocator);
  try read_lines_to_lookup(lines.items[0..empty_line_index], &lookup, allocator);

  var result: u32 = 0;

  for (lines.items[empty_line_index+1..]) |line|{
    var iter = std.mem.splitScalar(u8, line, ',');
    var numbers = std.ArrayList(u32).init(allocator);
    defer numbers.deinit();

    while(iter.next()) |part| {
      const n = try std.fmt.parseInt(u32, part, 10);
      try numbers.append(n);
    }

    if (is_valid(numbers.items, &lookup)) {
      result += numbers.items[(numbers.items.len / 2)];
    }
  }

  aoc.println("result: {}",.{result});
}
