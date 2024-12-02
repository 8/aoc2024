open System
open System.IO

let isValid (report : int array) =

  let isIncreasing1to3 report =
    report
    |> Array.pairwise
    |> Array.forall
      (fun (n1, n2) ->
        let d = n2-n1
        d >= 1 && d <= 3)

  let isDecreasing1to3 report = 
    report
    |> Array.pairwise
    |> Array.forall
      (fun (n1, n2) ->
        let d = n1-n2
        d >= 1 && d <= 3)

  isIncreasing1to3 report ||
  isDecreasing1to3 report

let day2 file =
  file
  |> File.ReadAllLines
  |> Array.map (fun s -> s.Split(" ") |> Array.map(int))
  |> Array.filter isValid
  |> Array.length

day2 "02-ex.txt"
day2 "02.txt"