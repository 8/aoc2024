open System
open System.IO
open System.Collections.Generic

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

let getSimilarityScore (left, right) =
  
  let numberCount =
    let d = new Dictionary<int64, int64>()
    right  |> Array.iter (fun n -> d[n] <- d.TryGetValue(n) |> snd |> fun i -> i + 1L)
    d

  left
  |> Array.map (fun n -> (numberCount.TryGetValue(n) |> snd) * n)
  |> Array.sum

example
|> (fun s -> s.Split('\n', StringSplitOptions.RemoveEmptyEntries))
|> getGroups
|> getSimilarityScore

"01.txt"
|> File.ReadAllLines
|> getGroups
|> getSimilarityScore