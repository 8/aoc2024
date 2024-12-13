open System
open System.IO

let numbersFromFile file =
  File.ReadAllText file
    |> _.ToCharArray()
    |> Array.map int
    |> Array.map (fun n->n-48)

let uncompressDiskmap (input: int seq) =
  let input =
    input
    |> Seq.indexed

  seq {
    for (i, n) in input do
      for _ in 0..n-1 do
        yield (if i%2=0 then Some(i/2) else None)
  }

let day9 file =
  let n = numbersFromFile file

  let diskmap =
    uncompressDiskmap n
    |> Seq.toArray

  let compacted  =
    seq {
      let mutable compactedBlockIndex = diskmap.Length
      for i in 0..diskmap.Length-1 do
        if i >= compactedBlockIndex then
          yield None
        else
          match diskmap.[i] with
          | Some(n) -> yield Some n
          | None ->
            let mutable b = None
            for c in compactedBlockIndex-1..-1..i do
              let item = diskmap.[c]
              if b.IsNone && item.IsSome then
                b <- item
                compactedBlockIndex <- c
            yield b
    }

  compacted
  |> Seq.indexed
  |> Seq.fold (fun s (i, n) ->
      s + int64(i * (n |> Option.defaultValue 0))
    ) 0L

"09-ex2.txt"
|> day9

"09-ex.txt"
|> day9

"09.txt"
|> day9