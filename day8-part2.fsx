open System
open System.IO

module Array2D =
  let fromTextFile file =
    let lines =
      file
      |> File.ReadAllLines
    Array2D.init
      lines.Length
      lines.[0].Length
      (fun y x -> lines.[y].[x])
  let toSeq (array : 't array2d) =
    seq {
      for y in 0..array.GetLength(0)-1 do
        for x in 0..array.GetLength(1)-1 do
          yield y,x,array.[y,x]
    }

type Antenna = {
  Symbol: char
  Pos: int*int
}

module Antenna =
  let fromPos (y, x, c) =
    match c with
    | '.' -> None
    | c -> Some { Symbol = c; Pos = (y,x)}

  let fromGrid (grid : char array2d) =
    grid
    |> Array2D.toSeq
    |> Seq.choose fromPos

let inGrid (maxY: int, maxX) (y: int, x: int) =
  (y >= 0 && y < maxY && x >= 0 && x < maxX)

let antinodes (maxY: int, maxX: int) (a1: Antenna, a2: Antenna) : seq<int*int> =
  let a1 = a1.Pos
  let a2 = a2.Pos
  let d = (
    fst a2 - fst a1,
    snd a2 - snd a1
  )

  let points (start: int*int) (vec: int*int) =
    seq {
      let mutable p = start
      yield p
      while true do
        p <- fst p + fst vec, snd p + snd vec
        yield p
    }
    |> Seq.takeWhile (inGrid (maxY, maxX))
  
  seq {
    yield! points a1 (fst d * -1, snd d * -1)
    yield! points a2 d
  }

let day8 file =
  let grid =
    file
    |> Array2D.fromTextFile

  grid
  |> Antenna.fromGrid
  |> Array.ofSeq
  |> Array.groupBy _.Symbol
  |> Array.map (fun (_, antennas) ->
    antennas
    |> Array.allPairs antennas
    |> Array.filter (fun (a1,a2) -> a1 <> a2)
    )
  |> Array.collect id
  |> Array.map (antinodes (grid.GetLength(0), grid.GetLength(1)))
  |> Array.map Array.ofSeq
  |> Array.collect id
  |> Array.distinct
  |> Array.length

"08-ex.txt"
|> day8

"08.txt"
|> day8