open System
open System.IO

module Stone =
  let blink (stone: int64) =
    match stone with
    | 0L -> [| 1L |]
    | n -> 
      let s = n |> string
      if s.Length % 2 = 0 then
        let s1 = s.[0..s.Length/2-1]
        let s2 = s.[s.Length/2..]
        [| s1|>int64; s2|>int64 |]
      else
        [| n * 2024L |]

module Stones =
  let from file =
    let line =
      file
      |> File.ReadAllLines
      |> Array.exactlyOne
    line.Split(' ')
    |> Array.map int64

  let blink (stones: int64 array) =
    stones
    |> Array.map Stone.blink
    |> Array.collect id

  let blinks count (stones: int64 array) =
    let mutable stones = stones
    for i in 1..count do
      stones <- blink stones
    stones

let day11 file =
  let stones =
    file
    |> Stones.from

  stones
  |> Stones.blinks 25
  |> Array.length

"11-ex2.txt"
|> day11

"11.txt"
|> day11