type bidon = A of int | B of string

let f =
  function
  | A n -> string_of_int n
  | B s with res = "titi" -> s ^ res

let _ =
  Printf.printf "f (A 1) = %s\nf (B \"tata\") = %s\n\n" (f (A 1)) (f (B "tata"))
