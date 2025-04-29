#!/usr/bin/rdmd
module day1;

import std;

void main() {
  auto file = File("01.txt", "r");

  int[] left;
  int[int] right;
  string line;
  while ((line = file.readln()) !is null) {
    int[] numbers = split(line).map!(s => to!int(s)).array;
    left ~= numbers[0];
    right[numbers[1]]++;
  }

  int sum = 0;
  foreach (l; left) {
    sum += l * right.get(l,0);
  }

  writefln("result: %s", sum);
}
