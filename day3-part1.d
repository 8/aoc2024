#!/usr/bin/rdmd
module day3part1;
import std;
import std.regex;

void solve(string file_path) {
  auto file = File(file_path, "r");
  int sum = 0;
  auto r = std.regex.regex("mul\\((?P<n1>\\d+),(?P<n2>\\d+)\\)");
  string line;
  while ((line = file.readln()) != null) {
    auto matches = matchAll(line, r);
    foreach (m; matches) {
      sum += to!int(m.captures["n1"]) * to!int(m.captures["n2"]);
    }
  }
  writefln("result: %s", sum);
}

void main() {
  solve("03-ex.txt");
  solve("03.txt");
}