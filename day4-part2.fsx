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
  let isMiddle = lines.[y].[x] = term.[(term.Length-1)/2]
  if isMiddle then
    let getString = getString term.Length lines
    [|
      getString (x-1,y-1) ( 1, 1)
      getString (x+1,y-1) (-1, 1)
      getString (x+1,y+1) (-1,-1)
      getString (x-1,y+1) ( 1,-1)
    |]
    |> Array.filter (fun s -> s = term)
    |> Array.length = 2
  else
    false

let day4 file =
  let lines = File.ReadAllLines file
  let term = "MAS"

  seq {
    for y in 0..lines.Length-1 do
      for x in 0..lines.[y].Length-1 do
        yield xmasAtPos lines x y term
  }
  |> Seq.filter id
  |> Seq.length

"04-ex-2.txt"
|> day4

"04.txt"
|> day4