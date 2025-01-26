const std = @import("std");
const Allocator = std.mem.Allocator;
const stdout = std.io.getStdOut().writer();

fn print(comptime format: []const u8, args: anytype) !void {
  try stdout.print(format, args);
}

fn day23(file_path: [] const u8, allocator: Allocator) !void {

  var sum : u32 = 0;

  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  const a = arena.allocator();

  var network_map = std.StringHashMap(std.StringHashMap(void)).init(a);

  var file = try std.fs.cwd().openFile(file_path, .{});
  var reader = file.reader();
  var buf: [6]u8 = undefined;
  while (reader.readUntilDelimiter(&buf, '\n')) |read| {
    const n1 = read[0..2];
    const n2 = read[3..5];

    // add them to the lookup
    if (network_map.getEntry(n1)) |n1_entry| {
      try n1_entry.value_ptr.put(try a.dupe(u8, n2), {});
    } else {
      var n1_connections = std.StringHashMap(void).init(a);
      try n1_connections.put(try a.dupe(u8, n2), {});
      try network_map.put(try a.dupe(u8, n1), n1_connections);
    }

    if (network_map.getEntry(n2)) |n2_entry| {
      try n2_entry.value_ptr.put(try a .dupe(u8, n1), {});
    } else {
      var n2_connections = std.StringHashMap(void).init(a);
      try n2_connections.put(try a.dupe(u8, n1), {});
      try network_map.put(try a.dupe(u8, n2), n2_connections);
    }

    // check if it completes a triangle
    // by finding all nodes that are common between the n1 and n2 connections
    const n1_connections: std.StringHashMap(void) = network_map.get(n1).?;
    const n2_connections: std.StringHashMap(void) = network_map.get(n2).?;

    var iterator = n1_connections.keyIterator();
    while (iterator.next()) |n1_neighbour| {
      if (n2_connections.contains(n1_neighbour.*)) {
        // try print("triangle: {s},{s},{s}\n", .{n1, n2, n1_neighbour.*});
        if (n1[0] == 't' or 
            n2[0] == 't' or
            n1_neighbour.*[0] == 't') {
          sum+=1;
        }
      }
    }

  } else |err| {
    if (err != error.EndOfStream) {
      return err;
    }
  }

  try print("{s}: {}\n", .{file_path, sum});
}

pub fn main() !void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();

  try day23("23-ex1.txt", allocator);
  try day23("23.txt", allocator);
}
