open System
open System.IO

module Stones =
  let from file =
    let line =
      file
      |> File.ReadAllLines
      |> Array.exactlyOne
    line.Split(' ')
    |> Array.map int64

  let blinks (count: int) (stones: int64 array) =

    let stoneList = new System.Collections.Generic.List<int64>(1024*1024)
    stoneList.AddRange(stones)

    let mutable ins = 0
    for c in 1..count do
      ins <- 0
      for i in 0..stoneList.Count do
        let ii = i+ins
        if ii < stoneList.Count then
          if stoneList.[ii] = 0 then
            stoneList.[ii] <- 1
          else
            let s = stoneList.[ii] |> string
            if s.Length % 2 = 0 then
              let n1 = s.[0..s.Length/2-1] |> int64
              let n2 = s.[s.Length/2..] |> int64
              stoneList.Insert(ii, n1)
              stoneList.[ii+1] <- n2
              ins<-ins+1
              ()
            else
              stoneList.[ii] <- stoneList.[ii]*2024L
        ()

      printfn "blink %i: %i " c stoneList.Count

    stoneList
    

  // let blinkStone (stone: int64) =
  //   match stone with
  //   | 0L -> [| 1L |]
  //   | n -> 
  //     let s = n |> string
  //     if s.Length % 2 = 0 then
  //       let s1 = s.[0..s.Length/2-1]
  //       let s2 = s.[s.Length/2..]
  //       [| s1|>int64; s2|>int64 |]
  //     else
  //       [| n * 2024L |]

  // let blinkStones (stones: int64 array) =
  //   stones
  //   |> Array.map blinkStone
  //   |> Array.collect id

  // let blinks count (stones: int64 array) =
  //   let mutable stones = stones
  //   for i in 1..count do
  //     stones <- blinkStones stones
  //   stones

let day11 file =
  let stones =
    file
    |> Stones.from

  stones
  |> Stones.blinks 75
  |> fun l -> l.Count

// "11-ex2.txt"
// |> day11

"11.txt"
|> day11