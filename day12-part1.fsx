open System
open System.IO
open System.Collections.Generic

type List<'T> = System.Collections.Generic.List<'T>
let trd (_,_,c) = c

#load "Array2D.fsx"

type Position = (int*int*char)

module Position =
  let from (map: char array2d) (y,x) : Position option =
    if y >= 0 && y < (map.GetLength(0)) &&
       x >= 0 && x < (map.GetLength(1)) then
      Some (y,x,map.[y,x])
    else
      None

type Region = {
  positions: Position array
}

module Region =
  let area (region: Region) = region.positions.Length
  let perimeter (region: Region) =
    let neighbours (points: (int*int*char) array)(y: int,x: int,_) : int =
      let find p = points |> Array.tryFind p
      let top = find (fun (py,px,_) -> py-1=y && px=x)
      let left = find (fun (py, px,_) -> py=y && px-1=x)
      let right = find (fun (py, px,_) -> py=y && px+1=x)
      let bottom = find (fun (py, px,_) -> py+1=y && px=x)
      [ top; left; right; bottom ]
      |> List.choose id
      |> List.length

    region.positions
    |> Array.map (neighbours region.positions)
    |> Array.map (fun n -> 4-n)
    |> Array.sum

  let cost (region: Region) = area region * perimeter region

  let from (map: char array2d) (p: Position) : Region =
    let pos = Position.from map
    let rec region (p: Position) (visited: HashSet<(int*int)>) : Position seq =
      let (y,x,r) = p
      let adj =
        [
          pos (y  ,x-1)
          pos (y-1,x  )
          pos (y  ,x+1)
          pos (y+1,x  )
        ]
      |> Seq.choose id
      |> Seq.filter (fun (_,_,c) -> c = r)
      |> Seq.filter(fun (y,x,_ ) -> visited.Add(y,x))
      |> Seq.toArray
      
      seq {
        yield! adj
        for p in adj do
          yield! region p visited
      }

    let (y,x,r) = p
    let visited = new HashSet<(int*int)>()
    visited.Add(y,x) |> ignore

    let positions = 
      [|p|] 
      |> Array.append (region p visited |> Seq.toArray)

    { positions = positions }

  let allFrom (map: char array2d) : Region array =
    let pos2Region = new Dictionary<(int*int), Region>()

    for y in 0..map.GetLength(0)-1 do
      for x in 0..map.GetLength(1)-1 do
        let r = map.[y,x]

        if not (pos2Region.ContainsKey(y,x)) then
          let region = from map (y,x,r)
          region.positions
          |> Array.iter (fun (y,x,_) -> pos2Region.Add ((y,x),region) |> ignore)

    pos2Region
    |> Seq.map (fun kv -> kv.Value)
    |> Seq.distinct
    |> Seq.toArray

let day12 file =
  file
  |> Array2D.fromTextFile
  |> Region.allFrom
  // |> Array.map (fun r -> r |> Region.area, r |> Region.perimeter)
  |> Array.map (Region.cost)
  |> Array.sum

"12-ex1.txt"
|> day12

"12-ex2.txt"
|> day12

"12.txt"
|> day12
