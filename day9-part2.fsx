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

let checksum compacted =
  compacted
  |> Seq.indexed
  |> Seq.fold (fun s (i, n) ->
      s + int64(i * (n |> Option.defaultValue 0))
    ) 0L

let blocks (diskmap: int option array) =
  diskmap
  |> Array.indexed
  |> Array.choose (fun (i, n) -> n |> Option.map (fun n -> i,n))
  |> Array.groupBy (fun (i,  n) -> n)
  |> Array.map (fun (n, a) -> n, a |> Array.map fst)
  |> Array.map (fun (n, a) ->
    let Start = a |> Array.min
    let End = a |> Array.max
    {|Id = n;
      Start = Start
      Length = (End-Start)+1|})
  |> Array.sortBy (fun i -> i.Id)
  |> Array.rev

let holes (diskmap: int option array) =
  seq {
    let mutable start = None
    for i in 0..diskmap.Length-1 do
      if diskmap.[i].IsNone && start.IsNone then
        start <- Some i
      else if diskmap.[i].IsSome then
        match start with
        | Some(s) ->
          yield {| Start = s; Length = (i-s) |}
          start <- None
        | None -> ()
  }


"09-ex.txt"
|> numbersFromFile
|> uncompressDiskmap
|> Seq.toArray
|> holes

let compact (diskmap: int option array) : int option seq =
  let mutable disk =
    diskmap
    |> Array.copy

  let blocks = blocks disk |> Array.toSeq

  for block in blocks do
    let holes = holes disk
    let hole =
      holes
      |> Seq.tryFind (fun h -> 
        block.Length <= h.Length && block.Start > h.Start
        )
    
    match hole with
    | None -> ()
    | Some(hole) ->
      printfn "found hole %A for block %A" hole block
      // printfn "block: %i" block.Id
      for bi in 0..block.Length-1 do
        disk.[hole.Start+bi] <- Some block.Id
        disk.[block.Start+bi] <- None
  disk

let day9 file =
  file
  |> numbersFromFile
  |> uncompressDiskmap
  |> Seq.toArray
  |> compact
  |> checksum

"09-ex.txt"
|> day9

"09-ex2.txt"
|> day9

"09.txt"
|> day9