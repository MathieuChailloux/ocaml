let (>>) h f = f h
let print_sep () = print_endline "---------------------------------"

let test1 = function _ with y = 0 -> y

let () = 
  test1 () >> Printf.printf "Test1 %d\n" 

let () = print_sep ()

let f x =
  match x with
  | `Un a with b = 1 -> a + b
  | `Deux (a, b) -> a + b
  | `Trois _ -> 3
      
let f' x =
  match x with
  | `Deux (a, b) -> b
  | `Un a with b = 1
  | `Trois (a,b,_) -> 3 + b

let f'' x =
  match x with
  | `Un a with b = 1 and c = 0
  | `Deux (a, c) with b = 0
  | `Trois (a, b, c) -> a + b + c

let () =
  let cpt = ref 0 in
  [`Un 1; `Deux (2, 1); `Trois (1,2,3)]
  >> List.iter 
    (fun e -> incr cpt;
      Printf.printf "Test2(%d) %d\n" !cpt (f e))

let () = print_sep ()

let () =
  let cpt = ref 0 in
  [`Un 1; `Deux (2, 1); `Trois (1,2,3)]
  >> List.iter 
    (fun e -> incr cpt;
      Printf.printf "Test3(%d) %d\n" !cpt (f' e))

let () = print_sep ()

let () =
  let cpt = ref 0 in
  [`Un 1; `Deux (2, 1); `Trois (1,2,3)]
  >> List.iter 
    (fun e -> incr cpt;
      Printf.printf "Test4(%d) %d\n" !cpt (f'' e))
