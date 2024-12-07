open System
open System.IO

type Equation = {
  result: int64
  numbers: int64 array
}

type Operation = Add | Mul | Con
module Operation =
  let compute op n1 n2 =
    match op with
    | Add -> n1 + n2
    | Mul -> n1 * n2
    | Con -> $"{n1}{n2}" |> int64
  let from (s: string) : Operation array =
    let parseOp c =
      match c with
      | '0' -> Add
      | '1' -> Mul
      | '2' -> Con
      | _ -> failwithf "wrong format: %c" c
    s.ToCharArray()
    |> Array.map (fun c -> parseOp c)

let solve (numbers: int64 array) (operations: Operation array) : int64 =
  let mutable res = numbers.[0]
  for i in 1..numbers.Length-1 do
    res <- Operation.compute operations.[i-1] res numbers.[i]
  res

let int2bases value (digits: char array) =
  let s = System.Text.StringBuilder()
  let b = digits.Length
  
  let mutable rem = value
  s.Insert(0, digits.[rem % b]) |> ignore
  rem <- rem / b

  while rem > 0 do
    s.Insert(0, digits.[rem % b]) |> ignore
    rem <- rem / b

  s.ToString()

let allOps (count: int) : Operation array seq =
  let digitsCount = 3
  let chars = 
    [|0..digitsCount-1|]
    |> Array.map string
    |> Array.map (fun s -> s.[0])

  let maxCount = (Math.Pow(digitsCount,count)|> int)-1

  seq {
    for i in 0..maxCount do
      yield
        int2bases i chars
        |> fun s -> s.PadLeft(count, chars.[0])
        |> Operation.from
  }

allOps 2 |> Seq.toArray

module Equation =
  let from (line: string) =
    line.Split(':')
    |> Array.splitAt 1
    |> fun (r, n) ->
      (r.[0] |> int64,
      n.[0].Split(' ', StringSplitOptions.RemoveEmptyEntries) |> Array.map int64)
    |> fun (r, n) -> { Equation.result = r; numbers = n }
  let isValid (eq: Equation) : bool =
    eq.numbers.Length-1
    |> allOps
    |> Seq.map (fun ops -> solve eq.numbers ops)
    |> Seq.exists(fun r -> r = eq.result)

let day7 file =
  File.ReadAllLines file
  |> Array.map Equation.from
  |> Array.filter Equation.isValid
  |> Array.sumBy (fun e -> e.result)

"07-ex.txt"
|> day7

"07.txt"
|> day7