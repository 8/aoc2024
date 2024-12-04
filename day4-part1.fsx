open System
open System.IO

let getString length (lines: string array) (x,y) (vx, vy) =
  seq {
    for i in 0..length-1 do
      let py = y+i*vy
      let px = x+i*vx
      if (py >= 0 && py < lines.Length && px >= 0 && px < lines.[py].Length) then
        yield lines.[py].[px]
  }
  |> Seq.toArray
  |> String

let xmasAtPos (lines: string array) x y (term: string) =
  let isStart = lines.[y].[x] = term.[0]
  if isStart then
    let getString = getString term.Length lines (x,y)
    [|
      getString( 1, 0)
      getString( 1, 1)
      getString( 0, 1)
      getString(-1, 1)
      getString(-1, 0)
      getString(-1,-1)
      getString( 0,-1)
      getString( 1,-1)
    |]
    |> Array.filter (fun s -> s = term)
    |> Array.length
  else
    0

let day4 file =

  let lines = File.ReadAllLines file
  let term = "XMAS"

  let counts = 
    seq {
      for y in 0..lines.Length-1 do
        for x in 0..lines.[y].Length-1 do
          yield xmasAtPos lines x y term
    }

  counts
  |> Seq.sum

day4 "04-ex.txt"
day4 "04.txt"