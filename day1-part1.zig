const print = @import("std").debug.print;
const std = @import("std");
const NumberType = i64;
const NumberList = std.ArrayList(NumberType);

const Lists = struct {
  left: NumberList,
  right: NumberList,
};

fn getLists(allocator: std.mem.Allocator, file_path: []const u8) !Lists {

  var left_list = NumberList.init(allocator);
  left_list.deinit();
  var right_list = NumberList.init(allocator);
  right_list.deinit();

  {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const reader = file.reader();

    var buf: [1024]u8 = undefined;
    var buf_n1: [10]u8 = undefined;
    var buf_n2: [10]u8 = undefined;
    while (reader.readUntilDelimiter(&buf, '\n')) |read|{
      if (read.len > 0) {
        var switch_to_n2 = false;
        var n1: usize = 0;
        var n2: usize = 0;
        for (0..read.len) |i| {
          if (std.ascii.isDigit(read[i])) {
            if (!switch_to_n2) {
              buf_n1[n1] = read[i];
              n1 = n1 + 1;
            } else {
              buf_n2[n2] = read[i];
              n2 = n2 + 1;
            }
          } else {
            switch_to_n2 = true;
          }
        }

        const left = try std.fmt.parseInt(NumberType, buf_n1[0..n1], 10);
        const right = try std.fmt.parseInt(NumberType, buf_n2[0..n2], 10);

        try left_list.append(left);
        try right_list.append(right);
      }
    } else |err|
      switch (err) {
        error.EndOfStream => {},
        else => return err,
      }
  }

  return Lists {
    .left = left_list,
    .right = right_list,
  };

}

fn day1(allocator: std.mem.Allocator, file_path: []const u8) !NumberType {

  const lists = try getLists(allocator, file_path);

  const less_than = std.sort.asc(NumberType);
  std.mem.sort(NumberType, lists.left.items, {}, less_than);
  std.mem.sort(NumberType, lists.right.items, {}, less_than);

  var sum : NumberType = 0;
  for (0..lists.left.items.len) |i| {
    const diff_abs :i64 = @intCast(@abs(lists.left.items[i] - lists.right.items[i]));
    sum = sum + diff_abs;
  }

  return sum;
}

pub fn main() !void {
  var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer alloc.deinit();

  print("example: {}\n", .{try day1(alloc.allocator(), "01-ex.txt")});
  print("file: {}\n", .{try day1(alloc.allocator(), "01.txt")});
}