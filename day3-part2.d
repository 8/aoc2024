#!/usr/bin/rdmd
module day3part2;
import std;
import std.regex;

void solve(string file_path) {
  auto file = File(file_path, "r");
  int sum = 0;
  auto r = regex("mul\\((?P<n1>\\d+),(?P<n2>\\d+)\\)|(?P<do>do\\(\\))|(?P<dont>don't\\(\\))");
  string line;
  bool active = true;
  while ((line = file.readln()) != null) {
    auto matches = matchAll(line, r);
    foreach (m; matches) {
      auto c1 = m.captures["n1"];
      auto c2 = m.captures["n2"];
      if (c1 && c2){
        if (active) 
          sum += to!int(c1) * to!int(c2);
      }
      else if (m.captures["do"])
        active = true;
      else if (m.captures["dont"])
        active = false;
    }
  }
  writefln("result: %s", sum);
}

void main() {
  solve("03-ex-2.txt");
  solve("03.txt");
}