type triplet = Un of int | Deux of int * int | Trois of int * int * int

let f x =
  match x with
  | Deux (a, b) -> a + b
  | Un a avec b = 1 -> a + b
    | Trois _ -> 3
      
let f' x =
  match x with
  | Deux (a, b) -> b
  | Un a avec b = 1
    | Trois (a,b,_) -> 3 + b

let g x =
  match x with
  | Un a avec b = 1 and c = 0
    | Deux (a, c) avec b = 0
      | Trois (a, b, c) -> a + b + c

let _ =
  Printf.printf "f 1 = %d\nf (2, 1) = %d\nf (Trois (1,2,3)) = %d\n"
    (f (Un 1))
    (f (Deux (2, 1)))
    (f (Trois (1,2,3)))


let _ =
  Printf.printf "f' 1 = %d\nf' (2, 1) = %d\nf' (Trois (1,2,3)) = %d\n"
    (f' (Un 1))
    (f' (Deux (2, 1)))
    (f' (Trois (1,2,3)))

let _ =
  Printf.printf "g 1 = %d\ng (2, 1) = %d\ng (Trois (1,2,3)) = %d\n"
    (g (Un 1))
    (g (Deux (2, 1)))
    (g (Trois (1,2,3)))

