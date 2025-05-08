const std = @import("std");

const stdout =  std.io.getStdOut().writer();

pub fn print(comptime format: []const u8, args: anytype) void {
  stdout.print(format, args) catch {};
}

pub fn println(comptime format: []const u8, args: anytype) void {
  print(format ++ "\n", args);
}

const Mul = struct {
  index: usize,
  length: usize,
  factor1: u32,
  factor2: u32,
};

const indexOf = std.mem.indexOf;
const isDigit = std.ascii.isDigit;
const parseInt = std.fmt.parseInt;

const TokenTypeTag = enum {
  Mul,
  OpeningBracket,
  ClosingBracket,
  Number,
  Comma,
  Garbage,
};

const TokenType = union(TokenTypeTag) {
  Mul: void,
  OpeningBracket: void,
  ClosingBracket: void,
  Number: u32,
  Comma: void,
  Garbage: void,
};

fn tokenize(haystack: []const u8, tokens: *std.ArrayList(TokenType)) !void {
  var index : usize = 0;
  while (index < haystack.len) : (index += 1) {
    if (index+2 < haystack.len
    and haystack[index+0] == 'm'
    and haystack[index+1] == 'u'
    and haystack[index+2] == 'l'){
      index += 2;
      try tokens.append(TokenTypeTag.Mul);
    } else if (haystack[index] == ',') {
      try tokens.append(TokenTypeTag.Comma);
    } else if (haystack[index] == '(') {
      try tokens.append(TokenTypeTag.OpeningBracket);
    } else if (haystack[index] == ')') {
      try tokens.append(TokenTypeTag.ClosingBracket);
    } else if (isDigit(haystack[index])) {
      var num_length : usize = 1;
      for (haystack[index+1..]) |d| {
        if (isDigit(d)) {
          num_length += 1;
        } else { break; }
      }
      const number = TokenType {
        .Number = try parseInt(u32, haystack[index..index+num_length], 10)};
      try tokens.append(number);
      index += num_length-1;
    } else {
      try tokens.append(TokenTypeTag.Garbage);
    }
  }
}

fn interpret(tokens: []const TokenType) u32 {
  var result : u32 = 0;
  var index : usize = 0;
  while (index < tokens.len) : (index+=1) {

    if (index + 5 < tokens.len
      and tokens[index+0] == .Mul
      and tokens[index+1] == .OpeningBracket
      and tokens[index+2] == .Number
      and tokens[index+3] == .Comma
      and tokens[index+4] == .Number
      and tokens[index+5] == .ClosingBracket)
     {
      result += tokens[index+2].Number * tokens[index+4].Number;
    }
  }

  return result;
}

const day03_ex = @embedFile("03-ex.txt");
const day03 = @embedFile("03.txt");

pub fn main() !void {

  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();

  var tokens = std.ArrayList(TokenType).init(gpa.allocator());
  defer tokens.deinit();

  try tokenize(day03, &tokens);
  const result = interpret(tokens.items);
  println("result: {}", .{result});
}