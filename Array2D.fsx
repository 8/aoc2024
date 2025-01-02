open System.IO

#if INTERACTIVE
#else
module Array2D
#endif

let fromLines (lines: string array) =
  Array2D.init
    lines.Length
    lines.[0].Length
    (fun y x -> lines.[y].[x])

let fromTextFile file =
  file
  |> File.ReadAllLines
  |> fromLines

let toSeq<'t> (array : 't array2d) =
  seq {
    for y in 0..array.GetLength(0)-1 do
      for x in 0..array.GetLength(1)-1 do
        yield y,x,array.[y,x]
  }

let tryGet<'t> (array: 't array2d) (index1: int) (index2:int) : 't option =
  if index1 < 0 || index1 >= (Array2D.length1 array) then
    None
  elif index2 < 0 ||index2 >= (Array2D.length2 array) then
    None
  else
    Array2D.get array index1 index2 |> Some