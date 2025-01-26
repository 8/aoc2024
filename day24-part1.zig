const std = @import("std");
const Allocator = std.mem.Allocator;
const stdout = std.io.getStdOut().writer();

fn print(comptime format: []const u8, args: anytype) !void {
  try stdout.print(format, args);
}

const GateType = enum {
  AND,
  OR,
  XOR,

  pub fn output(self: @This(), input0: bool, input1: bool) bool {
    return switch (self) {
      GateType.AND => input0 and input1,
      GateType.OR => input0 or input1,
      GateType.XOR => input0 != input1,
    };
  }
};

const Gate = struct {
  i0: []const u8,
  i1: []const u8,
  type: GateType,
  o: []const u8,
};

const SwitchedWire = struct {
  name: []const u8,
  value: bool,
};

fn day24(file_path: []const u8, allocator: Allocator) !void {

  var aa = std.heap.ArenaAllocator.init(allocator);
  defer aa.deinit();
  const a = aa.allocator();

  // var wires = Wires.init(a);
  var wires = std.ArrayList(SwitchedWire).init(a);
  var gates = std.ArrayList(Gate).init(a);

  // read input
  var file = try std.fs.cwd().openFile(file_path, .{});
  defer file.close();
  var var_name : [1024]u8 = undefined;
  var reader = file.reader();
  var readingGates = false;
  while (reader.readUntilDelimiter(&var_name, '\n')) |read| {
    if (read.len == 0) {
      readingGates = true;
    } else if (!readingGates) {
      const wire = read[0..3];
      const value = read[5] == '1';
      // try print("wire: {s}={}\n",.{wire, value});
      try wires.append(SwitchedWire{
        .name = try a.dupe(u8, wire),
        .value = value
        });
    } else {
      const input0 = read[0..3];
      const gate_type =
        switch (read[4]) {
          'A' => GateType.AND,
          'X' => GateType.XOR,
          'O' => GateType.OR,
          else => unreachable,
        };
      const input1 =
        switch (gate_type) {
          GateType.OR => read[7..10],
          else => read[8..11],
        };
      const output =
        switch (gate_type) {
          GateType.OR => read[14..17],
          else => read[15..18],
        };
      // try print("{s} {s} {s} {}\n", .{input0, input1, output, gate_type});
      const gate = Gate {
        .i0 = try a.dupe(u8, input0),
        .i1 = try a.dupe(u8, input1),
        .type = gate_type,
        .o = try a.dupe(u8, output),
      };
      try gates.append(gate);
    }
  } else |err| {
    if (err != error.EndOfStream) {
      return err;
    }
  }

  // switch the wires
  var wire_states = std.StringHashMap(bool).init(a);
  while (wires.popOrNull()) |wire| {
    try wire_states.put(wire.name, wire.value);

    // find all gates that use the wire as an input
    for (gates.items) |gate| {
      if ((std.mem.eql(u8, gate.i0, wire.name) and wire_states.contains(gate.i1))
      or  (std.mem.eql(u8, gate.i1, wire.name) and wire_states.contains(gate.i0))) {
        const value = gate.type.output(wire_states.get(gate.i0).?, wire_states.get(gate.i1).?);
        try wires.append(.{.name = gate.o, .value = value});
      }
    }
  }

  // list the output
  // var iterator = wire_states.iterator();
  // while (iterator.next()) |entry| {
  //   try print("{s}: {}\n", .{ entry.key_ptr.*, entry.value_ptr.*});
  // }

  // compute the result
  var result: u64 = 0;
  var i: u8 = 0;
  var buf: [3]u8 = undefined;
  while(true) : (i+=1) {
    const name = try std.fmt.bufPrint(&buf, "z{:0>2}", .{i});
    // try print("{s}\n", .{name});

    if (wire_states.get(name)) |state| {
      const shiftee: u64 = @intFromBool(state);
      const shift: u6 = @intCast(i);
      result |= (shiftee << shift);
    } else {
      break;
    }
  }

  try print("{s}, result: {}\n", .{file_path, result});
}

pub fn main() !void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  const allocator = gpa.allocator();
  try day24("24-ex1.txt", allocator);
  try day24("24-ex2.txt", allocator);
  try day24("24.txt", allocator);
}