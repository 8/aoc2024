open System
open System.IO
open System.Text.RegularExpressions

#r "nuget: Flips, 2.4.9"
open Flips
open Flips.Types

type Machine = {
  A: {| X: float; Y: float |}
  B: {| X : float; Y: float |}
  Prize: {| X: float; Y: float |}
}

module Machine =
  let from file = 
    file
    |> File.ReadAllLines
    |> Array.filter (fun s -> s.Length > 0)
    |> Array.chunkBySize 3
    |> Array.map (fun lines ->
      let xy (line: string) : {| X: float; Y: float |} =
        let r = Regex("X.(?<x>\\d+), Y.(?<y>\\d+)")
        let m  = r.Match line
        let x =  m.Groups.["x"].Value |> float
        let y =  m.Groups.["y"].Value |> float
        {| X = x; Y = y|}
      {
        A = xy lines.[0]
        B = xy lines.[1]
        Prize = xy lines.[2]
      }
    )

  let solve (machine: Machine) =
    let button_a_press_count = Decision.createInteger "A" 0 100
    let button_b_press_count = Decision.createInteger "B" 0 100
    let tokens = button_a_press_count * 3.0 + button_b_press_count
    let minimizeTokens = Objective.create "MinimizeTokens" Minimize tokens
    let equalPrizeX = Constraint.create "EqualPrizeX" (machine.Prize.X == (button_a_press_count * machine.A.X) + (button_b_press_count * machine.B.X))
    let equalPrizeY = Constraint.create "EqualPrizeY" (machine.Prize.Y == (button_a_press_count * machine.A.Y) + (button_b_press_count * machine.B.Y))
    let model =
      Model.create minimizeTokens
      |> Model.addConstraint equalPrizeX
      |> Model.addConstraint equalPrizeY

    let settings = {
      SolverType = SolverType.CBC
      MaxDuration = 10000L
      WriteLPFile = None
      WriteMPSFile = None
    }

    let result = Solver.solve settings model

    match result with
    | Optimal solution -> Objective.evaluate solution minimizeTokens |> Some
    | _ -> None


let day13 file =
  file
  |> Machine.from
  |> Array.map Machine.solve
  |> Array.choose id
  |> Array.sum

"13-ex1.txt"
|> day13

"13.txt"
|> day13