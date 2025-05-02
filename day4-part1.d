#!/usr/bin/rdmd
module day4part1;
import std;

void main() {
  solve_print("04-ex.txt");
  solve_print("04.txt");
}

void solve_print(string file_path) {
  writefln("result: %s", solve(file_path));
}

string[] read(string file_path) {
  auto file = File(file_path, "r");
  string[] lines;
  {
    string line;
    while ((line = file.readln()) != null) {
      lines ~= line;
    }
  }
  return lines;
}

ulong solve(string file_path) {
  auto lines = read(file_path);
  ulong sum = 0;
  string word = "XMAS";
  for (int y = 0; y < lines.length; y++)
    for (int x = 0; x < lines[y].length; x++) {
      sum += word_at_pos(word, lines, Pos(x, y));
    }
  return sum;
}

struct Pos { int x; int y; }
Pos add(Pos pos1, Pos pos2) {
  return Pos(pos1.x + pos2.x, pos1.y + pos2.y);
}
Pos mul(Pos pos, int scale) {
  return Pos(pos.x * scale, pos.y * scale);
}

ulong word_at_pos(string word, string[] lines, Pos pos) {
  auto len = word.length;
  Pos[] vecs = [
    Pos( 1, 0),
    Pos( 1,-1),
    Pos( 0,-1),
    Pos(-1,-1),
    Pos(-1, 0),
    Pos(-1, 1),
    Pos( 0, 1),
    Pos( 1, 1),
  ];
  return vecs.map!(v => get_string(lines, pos, v, len)).filter!(s => s == word).count();
}

Nullable!char getPos(string[] lines, Pos pos) {
  const is_valid =((pos.y >= 0 && pos.y < lines.length) && (pos.x >= 0 && pos.x < lines[pos.y].length));

  return is_valid
    ? Nullable!char(lines[pos.y][pos.x])
    : Nullable!char.init;
}

string get_string(string[] lines, Pos pos, Pos vec, ulong len) {

  string s = "";

  for (int i = 0; i < len; i++) {
    Pos p = pos.add(vec.mul(i));
    const c = getPos(lines, p);
    if (!c.isNull)
      s~=c.get();
    
  }

  return s;
}
