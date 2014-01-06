(*
  Erreurs :

let f = function 
  | `A a with b = 0 and c = 0
  | `B (a, b) with c = 0 
  | `C (a, b, c) -> a + b + c

  => >2 or-patt avec deux with

let f = function x with b = 0 -> b  => Crash "full-match"

*)

let f = function `A with a = 0 -> a

let () = 
  assert (f `A = 0)

let f = function 
  | `A a with b = 0
  | `B (a, b) -> a + b

let () = begin
  assert (f (`A 1) = 1);
  assert (f (`B (1, 2)) = 3);
end

let f = function 
  | `A a with b = 0 and c = 0
  | `B (a, b) with c = 0 
  | `C (a, b, c) -> a + b + c

let () =
  begin
    assert (f (`A 1) = 1);
    assert (f (`B (1, 2)) = 3);
    assert (f (`C (1, 2, 3)) = 6);
  end

let f = function
  | `A (`Aa with n = 2 | `Ab n) -> n

let () =
  assert (f `A (`Aa ) = 3)
