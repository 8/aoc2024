open System
open System.IO
open System.Text.RegularExpressions

let day3 file =
  let r = Regex(@"mul\((?<n1>\d+),(?<n2>\d+)\)")
  let s = File.ReadAllText(file)
  r.Matches(s)
  |> Seq.map (fun m -> m.Groups["n1"].Value |> int, m.Groups["n2"].Value |> int)
  |> Array.ofSeq
  |> Array.map (fun (n1, n2) -> n1*n2)
  |> Array.sum

"03-ex.txt"
|> day3

"03.txt"
|> day3