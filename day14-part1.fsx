open System
open System.IO
open System.Text.RegularExpressions

type Pos = {
  X: int
  Y: int
}

type Robot = {
  Position: Pos
  Velocity: Pos
}

module Robot =
  let from line =
    let r = Regex "^p=(?<px>\\d+),(?<py>\\d+)\\sv=(?<vx>-?\\d+),(?<vy>-?\\d+)$"
    let m = r.Match line
    let n (name: string) = m.Groups.[name].Value |> int
    {
      Position = { X = n "px"; Y = n "py" }
      Velocity = { X = n "vx"; Y = n "vy" }
    }
  let move (width: int, height: int) (robot: Robot) : Robot =
    let x = robot.Position.X + robot.Velocity.X
    let y = robot.Position.Y + robot.Velocity.Y
    let r =
      {
        Velocity = robot.Velocity
        Position = {
          X = if x < 0 then width-(abs(x)%width) else x % width
          Y = if y < 0 then height-(abs(y)%height) else y % height
        }
      }
    // printfn "%A -> %A" robot r
    r

let getTile2RobotsCount robots =
  robots
  |> Array.groupBy (fun r -> r.Position)
  |> Array.map (fun (p,robots) -> ((p.X,p.Y), robots.Length))
  |> Map


let print (width, height) robots =
  let tile2RobotsCount = getTile2RobotsCount robots
  for y in 0..height-1 do
    for x in 0..width-1 do
      match tile2RobotsCount.TryFind (x,y) with
      | Some count -> printf "%i" count
      | None -> printf "."
    printfn ""
  ()
    
let tick robots count (width, height) =
  let mutable r = robots
  for i in 0..count-1 do
    r <- (r |> Array.map (Robot.move (width, height)))
  r

let score (width, height) (robots: Robot array) : int =
  let quads =
    robots
    |> Array.fold (fun (s: int array) r ->
      
        let middleX = (width-1)/2
        let middleY = (height-1)/2

        let i =
          if r.Position.X = middleX then
            None
          else if r.Position.Y = middleY then
            None
          else if r.Position.X < middleX && r.Position.Y < middleY then
            Some 0
          else if r.Position.X > middleX && r.Position.Y < middleY then
            Some 1
          else if r.Position.X < middleX && r.Position.Y > middleY then
            Some 2
          else
            Some 3
        match i with
        | Some i -> (s.[i] <- s.[i]+1)
        | None -> ()
        s
      )
      [| 0; 0; 0; 0|]

  printfn "%A" quads
  quads
  |> Array.reduce (*)

let day14 (width,height) seconds file = 
  let robotsNow =
    file
    |> File.ReadAllLines
    |> Array.map Robot.from

  let robotsThen = tick robotsNow seconds (width, height)

  robotsThen
  |> print (width,height)

  robotsThen
  |> score (width, height)

"14-ex.txt"
|> day14 (11,7) 100


"14.txt"
|> day14 (101,103) 100
 