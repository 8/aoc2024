open System
open System.IO

let example = """
3   4
4   3
2   5
1   3
3   9
3   3
"""

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

example
|> (fun s -> s.Split('\n', StringSplitOptions.RemoveEmptyEntries))
|> getGroups
|> getDistance

"01.txt"
|> File.ReadAllLines
|> getGroups
|> getDistance