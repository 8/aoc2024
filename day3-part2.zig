const std = @import("std");

const stdout =  std.io.getStdOut().writer();

pub fn print(comptime format: []const u8, args: anytype) void {
  stdout.print(format, args) catch {};
}

pub fn println(comptime format: []const u8, args: anytype) void {
  print(format ++ "\n", args);
}

const indexOf = std.mem.indexOf;
const isDigit = std.ascii.isDigit;
const parseInt = std.fmt.parseInt;
const startsWith = std.mem.startsWith;

const TokenTypeTag = enum {
  Mul,
  OpeningBracket,
  ClosingBracket,
  Number,
  Comma,
  Garbage,
  Do,
  Dont,
};

const TokenType = union(TokenTypeTag) {
  Mul: void,
  OpeningBracket: void,
  ClosingBracket: void,
  Number: u32,
  Comma: void,
  Garbage: void,
  Do: void,
  Dont: void,
};

fn tokenize(haystack: []const u8, tokens: *std.ArrayList(TokenType)) !void {
  var index : usize = 0;
  while (index < haystack.len) : (index += 1) {
    if (startsWith(u8, haystack[index..], "mul")) {
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
    } else if(startsWith(u8, haystack[index..], "don't")) {
      index += 4;
      try tokens.append(TokenTypeTag.Dont);
    } else if (startsWith(u8, haystack[index..], "do")) {
      index+=1;
      try tokens.append(TokenTypeTag.Do);
    }
    else {
      try tokens.append(TokenTypeTag.Garbage);
    }
  }
}

fn interpret(tokens: []const TokenType) u32 {
  var result : u32 = 0;
  var index : usize = 0;
  var enable = true;
  while (index < tokens.len) : (index+=1) {

    if (tokens[index] == .Do) {
      enable = true;
    } else if (tokens[index] == .Dont) {
      enable = false;
    }
    else if (enable
      and index + 5 < tokens.len
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

const day03_ex = @embedFile("03-ex-2.txt");
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