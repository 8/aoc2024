open System
open System.IO

let getGroups (lines: string array) =
  let numbers =
    lines
    |> Array.map (fun s -> s.Split(" ", StringSplitOptions.RemoveEmptyEntries))
  
  (numbers |> Array.map (fun a -> a.[0]) |> Array.map(int64) |> Array.sort,
   numbers |> Array.map (fun a -> a.[1]) |> Array.map(int64) |> Array.sort)

let getDistance (left, right) =
  Array.zip left right
  |> Array.map(fun (l, r) -> abs(l - r))
  |> Array.sum

"01-ex.txt"
|> File.ReadAllLines
|> getGroups
|> getDistance

"01.txt"
|> File.ReadAllLines
|> getGroups
|> getDistance