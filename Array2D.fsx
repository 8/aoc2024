open System.IO

#if INTERACTIVE
#else
module Array2D
#endif

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
