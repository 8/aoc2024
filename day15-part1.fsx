#load "Pos.fsx"
#load "Array2D.fsx"

open System
open System.IO
open Pos

type Move =
  | Up
  | Down
  | Left
  | Right

module Move =
  let from c =
    match c with
    | '<' -> Some Left
    | '>' -> Some Right
    | '^' -> Some Up
    | 'v' -> Some Down
    | _ -> None
  
  let toPos (move: Move) : Pos =
    match move with
    | Up    -> { Y = -1; X =  0 }
    | Down  -> { Y =  1; X =  0 }
    | Right -> { Y =  0; X =  1 }
    | Left  -> { Y =  0; X = -1 }

let robotFrom (map: char array2d): (Pos*char) option =
  let r = '@'
  map
  |> Array2D.toSeq
  |> Seq.tryFind (fun (_,_,c) -> c = r)
  |> Option.map (fun (y,x,_) -> Pos.ofTuple (y,x),r)

let nextPos (map: char array2d) (pos: Pos) (move: Move) : (Pos*char) option =
  let next =
    move
    |> Move.toPos
    |> Pos.add pos

  Array2D.tryGet map next.Y next.X
  |> Option.map(fun c -> next, c)

let push (map: char array2d) ((pos,r): (Pos*char)) (move: Move) : char array2d =

  let nextPositions = 
    seq {
      let mutable p : (Pos*char) option = None
      let mutable more = true
      while more do
        p <- nextPos map (match p with Some (p,_) -> p | None -> pos) move
        match p with
        | Some p -> yield p
        | None -> more <- false
    }
    |> Seq.toArray
  
  // find the next free spot in the direction
  let index =
    nextPositions
    |> Array.takeWhile (fun (_, c) -> c <> '#')
    |> Array.tryFindIndex (fun (_, c) -> c = '.')

  // move all in reverse order
  match index with
  | Some index ->

    let positions =
      nextPositions
      |> Array.append [| pos,r |]
      |> Array.take (index+2)
      |> Array.rev

    positions
    |> Array.pairwise
    |> Array.iter (fun ((p1,c1),(p2,c2)) ->
      map.[p1.Y,p1.X] <- c2
      map.[p2.Y,p2.X] <- '.'
      )

    ()
  | None -> ()

  map

let moveRobot (map: char array2d) (move: Move) : (char array2d) =
  let robot = robotFrom map |> Option.get
  let map = push map robot move
  map

let day15 file = 

  let lines =
    file
    |> File.ReadAllLines
  
  let emptyLineIndex =
    lines
    |> Array.findIndex (fun l -> l = "")
  
  let mapLines, instructionLines =
    lines
    |> Array.splitAt emptyLineIndex

  let map = Array2D.fromLines mapLines

  let moves =
    instructionLines
    |> Array.map Array.ofSeq
    |> Array.collect id
    |> Array.choose Move.from

  let mutable map = map
  for move in moves do
    map <- moveRobot map move

  let sum =
    map
    |> Array2D.toSeq
    |> Seq.filter (fun (_,_,c) -> c = 'O')
    |> Seq.map (fun (y,x,_) -> y*100+x)
    |> Seq.sum

  sum

"15-ex2.txt"
|> day15

"15-ex.txt"
|> day15

"15.txt"
|> day15