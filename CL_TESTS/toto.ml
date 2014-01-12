type triplet = Un of int | Deux of int * int | Trois of int * int * int

let f x =
  match x with
  | Un a -> a
  | Deux (a, b) -> a + b
  | Trois (a,b,c) -> a + b + c

let g x =
  match x with
  | Un a -> a
  | Deux (a, b) -> a * b
  | Trois (a,b,c) -> a * b * c

let _ =
  Printf.printf "f 1 = %d\ng (2, 1) = %d\n"
    (f (Un 1))
    (g (Deux (2, 1)))
