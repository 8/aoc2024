const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

const Input = struct {
  allocator: Allocator,
  a: u64,
  b: u64,
  c: u64,
  program: []u8 = &.{},

  pub fn init(file_path: []const u8, allocator: Allocator) !Input {

    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var a : u64 = undefined;
    var b : u64 = undefined;
    var c : u64 = undefined;
    var program : []u8= &.{};

    const reader = file.reader();
    var buffer: [1024]u8 = undefined;
    var i : i8 = 0;
    while (reader.readUntilDelimiter(&buffer, '\n')) |read| : (i=i+1) {
      switch (i) {
        0 => a = try std.fmt.parseInt(u64, read[12..], 10),
        1 => b = try std.fmt.parseInt(u64, read[12..], 10),
        2 => c = try std.fmt.parseInt(u64, read[12..], 10),
        3 => {},
        4 => {
          const content = read[9..];
          var byte_list = std.ArrayList(u8).init(allocator);
          defer byte_list.deinit();

          var stream = std.io.fixedBufferStream(content);
          var reader2 = stream.reader();
          var buf: [2]u8 = undefined;
          while (reader2.readUntilDelimiterOrEof(&buf,',')) |read2|{
            if (read2 == null) {
              break;
            }
            const num = try std.fmt.parseInt(u8, read2.?, 10);
            try byte_list.append(num);
          } else |err| {
            if (err != error.EndOfStream) {
              return err;
            }
          }
          program = try byte_list.toOwnedSlice();
          errdefer allocator.free(program);
        },
        else => {},
      }
    } else |err| {
      if (err != error.EndOfStream) {
        return err;
      }
    }

    return Input {
      .allocator = allocator,
      .a = a,
      .b = b,
      .c = c,
      .program = program,
    };
  }

  pub fn deinit(self: @This()) void {
    if (self.program.len > 0) {
      self.allocator.free(self.program);
    }
  }
};

test "Input init & deinit" {
  const allocator = std.testing.allocator;
  const input = try Input.init("17-ex1.txt", allocator);
  defer input.deinit();
  print("input: {}\n", .{input});
  try std.testing.expect(input.a == 729);
  try std.testing.expect(input.b == 0);
  try std.testing.expect(input.c == 0);
  try std.testing.expect(input.program.len == 6);
}

const OpCode = enum(u8) {
  adv,
  bxl,
  bst,
  jnz,
  bxc,
  out,
  bdv,
  cdv,
};

test "enums" {
  try std.testing.expect(@intFromEnum(OpCode.adv) == 0);
  try std.testing.expect(@intFromEnum(OpCode.cdv) == 7);
}

fn run(input: Input) !void{

  var a : u64 = input.a;
  var b : u64 = input.b;
  var c : u64 = input.c;
  var ip: u64 = 0;

  while (ip < input.program.len) {

    const opcode : OpCode  = @enumFromInt(input.program[ip]);
    const operand : u8 = input.program[ip+1];

    const combo = switch (operand) {
      0 => 0,
      1 => 1,
      2 => 2,
      3 => 3,
      4 => a,
      5 => b,
      6 => c,
      else => error.InvalidComboOperand,
    };
    
    switch (opcode) {
      OpCode.adv => {
        const denominator: u64 = (@as(u64, 1)<<|try combo);
        const numerator = a;
        a = @divTrunc(numerator, denominator);
      },
      OpCode.bxl => {
        b = b ^ operand;
      },
      OpCode.bst => {
        b = try combo % 8;
      },
      OpCode.jnz => {
        if (a != 0) {
          ip = operand;
        } else {
          ip = ip + 2;
        }
      },
      OpCode.bxc => {
        b = b ^ c;
      },
      OpCode.out => {
        const value = try combo % 8;
        print("{},", .{value});
      },
      OpCode.bdv => {
        const denominator: u64 = (@as(u64, 1)<<|try combo);
        const numerator = a;
        b = @divTrunc(numerator, denominator);
      },
      OpCode.cdv => {
        const denominator: u64 = (@as(u64, 1)<<|try combo);
        const numerator = a;
        c = @divTrunc(numerator, denominator);
      },
    }
    
    ip = switch (opcode) {
      OpCode.jnz => ip,
      else => ip + 2
    };
  }
  print("\n",.{});
}

fn day17(file_path: [] const u8, allocator: Allocator) !void {

  var input = try Input.init(file_path, allocator);
  defer input.deinit();

  try run(input);

  const result = 0;
  print("file_path: {s}, result: {}\n", .{file_path, result});
}

pub fn main() !void {
  var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
  defer arena_allocator.deinit();
  const allocator = arena_allocator.allocator();
 
  try day17("17-ex1.txt", allocator);
  try day17("17.txt", allocator);
}