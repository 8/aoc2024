open System
open System.IO

let day5 file =
  let lines = file |> File.ReadAllLines
  let rules = lines |> Array.takeWhile (String.IsNullOrWhiteSpace >> not)
  let updateLines = lines |> Array.skip (rules.Length+1)
  let middleFrom (numbers: int array) = numbers.[numbers.Length / 2]
  let numbersFrom (update:string) =
    update.Split (',')
    |> Array.map int
  let updates = updateLines |> Array.map numbersFrom

  let sortRules =
    rules
    |> Array.map (fun s -> s.Split('|') |> Array.map int)
    |> Array.map (fun a -> (a.[0], a.[1]))
    |> Array.groupBy (snd)
    |> Array.map (fun (key, a) -> (key, a |> Array.map(fst)))
    |> Map.ofArray
  
  let smaller n = n |> sortRules.TryFind |> Option.defaultValue Array.empty
  let isLessThan n1 n2 = smaller n2 |> Array.contains n1

  let isValid (numbers: int array) =
    let mutable ret = true
    // printfn "numbers: %A" numbers
    for i in 0..numbers.Length-1 do
      let remaining =  numbers.[i+1..]
      let forbidden = sortRules.TryFind numbers.[i] |> Option.defaultValue Array.empty
      if (ret) then
        ret <- remaining|> Array.exists (fun r -> Array.contains r forbidden) |> not
        // printfn "remaining: %A, forbidden: %A, ret: %b" remaining forbidden ret
    ret

  let sort (numbers: int array) =
    numbers
    |> Array.sortWith (fun i1 i2 ->
      if isLessThan i1 i2 then
        -1
      elif isLessThan i2 i1 then
        1
      else
        0
      )

  updates
  |> Array.filter (isValid >> not)
  |> Array.map sort
  |> Array.map middleFrom
  |> Array.sum

day5 "05-ex.txt"
day5 "05.txt"