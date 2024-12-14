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

type Map = int array2d

module Map =
  let from file =
    Array2D.fromTextFile file
    |> Array2D.map (fun c -> c |> int |> fun n -> n-48)

type Point = (int*int*int)

module Point =
  let from (map: Map) (y,x) : Point option =
    if y >= 0 && y < (map.GetLength(0)) &&
       x >= 0 && x < (map.GetLength(1)) then
      Some (y,x,map.[y,x])
    else
      None

  let ascent (map: Map) ((y,x,h): Point) : Point seq =
    let from = from map
    seq {
      from (y-1, x+0)
      from (y+1, x+0)
      from (y+0, x+1)
      from (y+0, x-1)
    }
    |> Seq.choose id
    |> Seq.filter (fun (_,_,height) -> height = h+1)

  let rec getPeaks (map: Map) (p: Point) : Point seq = 
    let points = ascent map p

    let peaks, points =
      points
      |> Array.ofSeq
      |> Array.partition (fun (_,_,h) -> h = 9)

    seq {
      yield! peaks
      yield!
        points
        |> Seq.map (getPeaks map)
        |> Seq.collect id
    }
    |> Seq.distinct


module Trailhead =
  let from (map: Map) : Point seq =
    map
    |> Array2D.toSeq
    |> Seq.filter (fun (y,x,n) -> n = 0)

  /// calculate the number of different peaks that the point reach
  let score (map: Map) (trailhead: Point) : int =
    Point.getPeaks map trailhead
    |> Seq.toArray
    |> Array.length

let day10 file = 
  let map =
    file
    |> Map.from

  map
  |> Trailhead.from
  |> Seq.map (Trailhead.score map)
  |> Seq.sum

"10-1.txt"
|> day10

"10-2.txt"
|> day10

"10.txt"
|> day10