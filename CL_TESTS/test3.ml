let _ =
  match 3 with
  | 1 with x = "tu" -> print_endline ("tu craques" ^ x)
  | 3 with y = "win" -> print_endline ("gagné" ^ y)
  | _ -> print_endline "bof"
