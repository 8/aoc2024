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

  let isValid (numbers: int array) =
    let mutable ret = true
    printfn "numbers: %A" numbers
    for i in 0..numbers.Length-1 do
      let remaining =  numbers.[i+1..]
      let forbidden = sortRules.TryFind numbers.[i] |> Option.defaultValue Array.empty
      if (ret) then
        ret <- remaining|> Array.exists (fun r -> Array.contains r forbidden) |> not
        // printfn "remaining: %A, forbidden: %A, ret: %b" remaining forbidden ret
    ret

  updates
  |> Array.filter isValid
  |> Array.map middleFrom
  |> Array.sum

day5 "05-ex.txt"

day5 "05.txt"