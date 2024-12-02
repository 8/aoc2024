open System
open System.IO

let getReports file =
  file
  |> File.ReadAllLines
  |> Array.map (fun s -> s.Split(" ") |> Array.map(int))

let isIncreasing1to3 (n1, n2) =
  let d = n2-n1
  d >= 1 && d <= 3

let isDecreasing1to3 (n1, n2) =
  let d = n1-n2
  d >= 1 && d <= 3

let isIncreasingOrDecreasing1to3 report =
  let areAllIncreasing1to3 report =
    report
    |> Array.pairwise
    |> Array.forall isIncreasing1to3

  let areAllDecreasing1to3 report = 
    report
    |> Array.pairwise
    |> Array.forall isDecreasing1to3

  areAllIncreasing1to3 report || areAllDecreasing1to3 report

let isValid (report : int array) =
  // check which reports are valid -> valid
  if isIncreasingOrDecreasing1to3 report then
    true
  else
    // remove items and try again
    let mutable valid  = false
    for i in 0..report.Length-1 do
      let v =
        report
        |> Array.removeAt i
        |> isIncreasingOrDecreasing1to3
      if v then valid <- true
    valid

let day2 file =
  file
  |> getReports
  |> Array.filter isValid
  |> Array.length

day2 "02-ex.txt"
day2 "02.txt"