open System
open System.IO
open System.Text.RegularExpressions

type Mul = { n1: int; n2: int }

type Instruction = Mul of Mul | Do | Dont

module Instruction =
  let from (m: Match) =
    if m.Groups.["do"].Value <> "" then
      Instruction.Do
    else if m.Groups.["dont"].Value <> "" then
      Instruction.Dont
    else
      Instruction.Mul({
        n1 = m.Groups.["n1"].Value |> int
        n2 = m.Groups.["n2"].Value |> int
      })

let day3 file =
  let r = Regex(@"(?<op>(?<mul>(mul\((?<n1>\d+),(?<n2>\d+)\)))|(?<do>do\(\))|(?<dont>don't\(\)))")
  let s = File.ReadAllText(file)
  r.Matches(s)
  |> Array.ofSeq
  |> Array.map Instruction.from
  |> Array.fold 
    (fun (d, s) instruction ->
      match instruction with
      | Do -> (true, s)
      | Dont -> (false, s)
      | Mul(mul) -> (d, if d then s + mul.n1 * mul.n2 else s)
      )
    (true, 0)
  |> fun (_, s) -> s
  
"03-ex-2.txt"
|> day3

"03.txt"
|> day3