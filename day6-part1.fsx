open System
open System.IO

type Direction = N | E | S | W
module Direction =
  let from (c: char) : Direction option =
    match c with
    | '<' -> Direction.W |> Some
    | '>' -> Direction.E |> Some
    | 'v' -> Direction.S |> Some
    | '^' -> Direction.N |> Some
    | _ -> None
  let toVec dir =
      match dir with
      | Direction.N -> ( 0,-1)
      | Direction.E -> ( 1, 0)
      | Direction.S -> ( 0, 1)
      | Direction.W -> (-1, 0)
  let rotate dir =
    match dir with
    | Direction.N -> Direction.E
    | Direction.E -> Direction.S
    | Direction.S -> Direction.W
    | Direction.W -> Direction.N

type Guard = {
  x: int
  y: int
  dir: Direction
}

type Field = Empty | Obstacle | Exit

module Field =
  let from (x,y) (lines: string array) =
    if (y < 0 || x < 0 || y >= lines.Length || x >= lines.[y].Length) then
      Exit
    else if lines.[y].[x] = '#' then
      Obstacle
    else
      Empty

module Guard =
  let find (lines: string array) : Guard option =
    seq {
      for y in 0..lines.Length-1 do
        for x in 0..lines.[y].Length-1 do
          yield x,y,lines.[y].[x]
    }
    |> Seq.pick (fun (x,y,c) ->
      c 
      |> Direction.from
      |> Option.map (fun d -> Some { x = x;  y = y; dir = d})
    )

  let rec step (guard: Guard) (lines : string array) : Guard option =

    let newPos =
      let (vx, vy) = guard.dir |> Direction.toVec 
      (guard.x + vx, guard.y + vy)

    let field = Field.from newPos lines
    
    if field = Field.Obstacle then
      (step { x = guard.x; y = guard.y; dir = Direction.rotate guard.dir} lines)
    else if field = Field.Empty then
      { x = fst newPos; y = snd newPos; dir = guard.dir } |> Some
    else
      None

let day6 file =
  let lines =
    file |> File.ReadAllLines

  let mutable guard =
    lines |> Guard.find

  let tour = seq {
    yield guard
    while guard.IsSome do
      guard <-
        match guard with
        | Some(guard) -> Guard.step guard lines
        | None -> None
      yield guard
  }

  tour
  |> Seq.takeWhile (Option.isSome)
  |> Seq.choose id
  |> Seq.toArray
  |> Array.map (fun g-> (g.x, g.y))
  |> Set.ofArray
  |> fun s -> s.Count

"06-ex.txt"
|> day6

"06.txt"
|> day6