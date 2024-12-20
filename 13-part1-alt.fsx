open System.IO
open System.Text.RegularExpressions

type Machine = {
  A: {| X: int; Y: int |}
  B: {| X : int; Y: int |}
  Prize: {| X: int; Y: int |}
}

module Machine =
  let from file = 
    file
    |> File.ReadAllLines
    |> Array.filter (fun s -> s.Length > 0)
    |> Array.chunkBySize 3
    |> Array.map (fun lines ->
      let xy (line: string) : {| X: int; Y: int |} =
        let r = Regex("X.(?<x>\\d+), Y.(?<y>\\d+)")
        let m  = r.Match line
        let x =  m.Groups.["x"].Value |> int
        let y =  m.Groups.["y"].Value |> int
        {| X = x; Y = y|}
      {
        A = xy lines.[0]
        B = xy lines.[1]
        Prize = xy lines.[2]
      }
    )

  let solve (machine: Machine) =
    let a_count =
      ((machine.B.X * machine.Prize.Y) - (machine.B.Y * machine.Prize.X))
      /
      ((machine.B.X * machine.A.Y) - (machine.B.Y * machine.A.X))

    let b_count =
      ((machine.A.X * machine.Prize.Y) - (machine.A.Y * machine.Prize.X))
      /
      ((machine.A.X * machine.B.Y) - (machine.A.Y * machine.B.X))

    let x = (a_count * machine.A.X) + (b_count * machine.B.X)
    let y = (a_count * machine.A.Y) + (b_count * machine.B.Y)

    if  x = machine.Prize.X &&
        y = machine.Prize.Y then
        Some ((a_count*3)+(b_count))
      else
        None

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
