#if INTERACTIVE
#else
module Pos
#endif

type Pos = {
  X: int
  Y: int
}

module Pos =
  let add (p1: Pos) (p2: Pos) : Pos = 
    {
      X = p1.X + p2.X
      Y = p1.Y + p2.Y
    }
  let mul (pos: Pos) (times : int) : Pos =
    {
      X = pos.X * times
      Y = pos.Y * times
    }
  let ofTuple ((y,x) : int*int) : Pos = 
    {
      Y = y
      X = x
    }
  let toTuple (pos: Pos) : (int*int) = 
    pos.Y, pos.X
