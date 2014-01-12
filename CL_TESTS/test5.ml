let ff x y = match x, y with
  | a, b with c = 3 -> a + b

let gg = function
  | 0 with a = 1
    | a -> a

let _ =
  Format.fprintf Format.std_formatter "ff (1, 1) = %d\ngg 1 = %d\ngg 0 = %d\n"
    (ff 1 1) (gg 1) (gg 0)
