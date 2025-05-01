#!/usr/bin/rdmd
import std;
import std.range;
import std.stdio;

bool isSafe(int[] numbers) {
  enum Direction { none, asc, desc }
  auto direction = Direction.none;

  foreach(n; numbers.slide(2)) {
    auto diff = n[0]-n[1];
    auto dir = diff < 0 ? Direction.asc : Direction.desc;

    if (direction == Direction.none)
      direction = dir;
    else if (direction != dir)
      return false;
    
    auto a = abs(diff);

    if (!(a >=1 && a <= 3))
      return false;
  }
  return true;
}

void main() {
  auto file = File("02.txt", "r");

  int safe = 0;
  string line;
  while ((line = file.readln()) !is null) {
    int[] numbers = split(line).map!(s => to!int(s)).array;

    for (int i; i < numbers.length; i++) {

      auto modNumbers = numbers.dup.remove(i);
      if (isSafe(modNumbers)) {
        safe++;
        break;
      }
    }
  }

  writefln("result: %s", safe);
}
