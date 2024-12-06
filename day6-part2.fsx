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
    else if lines.[y].[x] = '#' || lines.[y].[x] = 'O' then
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

  let tour (guard: Guard option) lines = seq {
    let mutable g = guard
    yield g
    while g.IsSome do
      g <-
        match g with
        | Some(g) -> step g lines
        | None -> None
      yield g
  }

let day6 file =
  let lines =
    file |> File.ReadAllLines

  let guard =
    lines |> Guard.find

  let firstTour =
    Guard.tour guard lines
    |> Seq.takeWhile (Option.isSome)
    |> Seq.choose id
    |> Seq.toArray
    |> Array.map (fun g-> (g.x, g.y))

  // only consider positions for obstacles that are are actually on guards tour
  let setObstacle (x,y) (lines: string array) : string array =
    lines
    |> Array.mapi (fun i line ->
      if i = y then
        line |> String.mapi  (fun i  c -> if i = x then 'O' else c) |> String
      else
        line)

  let isLoop (tour: Guard option seq) : bool =
    let hash = System.Collections.Generic.HashSet<Guard>()
    let mutable isLoop = false
    tour
    |> Seq.takeWhile (fun g -> 
      match g with
      | Some(g) ->
        if (hash.Contains(g)) then 
          isLoop <- true
          false
        else
          hash.Add((g)) |> ignore
          true
      | None -> false
    )
    |> Seq.toArray
    |> ignore
    isLoop

  firstTour
  |> Array.skip 1
  |> Set.ofArray
  |> Set.toArray
  |> Array.map (fun p -> setObstacle p lines)
  |> Array.filter (fun lines -> isLoop (Guard.tour guard lines))
  |> Array.length

"06-ex.txt"
|> day6

"06.txt"
|> day6