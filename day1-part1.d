#!/usr/bin/rdmd
module day1;

import std;

void main() {
  auto file = File("01.txt", "r");
  int[] left;
  int[] right;
  string line;
  while ((line = file.readln()) !is null) {
    auto numbers = split(line);
    left ~= to!int(numbers[0]);
    right ~= to!int(numbers[1]);
  }

  sort(left);
  sort(right);

  int sum = 0;
  foreach (l, r; zip(left,right)) {
    sum += abs(l-r);
  }
  writeln(sum);
}