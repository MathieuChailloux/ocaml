(* A -ppx rewriter which evaluates expressions at compile-time,
   using the OCaml toplevel interpreter.

   The following extensions are supported:

   [%eval e] in expression context: the expression e will be evaluated
   at compile time, and the resulting value will be inserted as a
   constant literal.

   [%%eval.start] as a structure item: forthcoming structure items
   until the next [%%eval.stop] will be evaluated at compile time (the
   result is ignored) only.

   [%%eval.start both] as a structure item: forthcoming structure
   items until the next [%%eval.stop] will be evaluated at compile
   time (the result is ignored), but also kept in the compiled unit.

   [%%eval.load "..."] as a structure item: load the specified
   .cmo unit or .cma library, so that it can be used in the forthcoming
   compile-time components.
*)


module Main : sig end = struct

  open Location
  open Longident
  open Asttypes
  open Parsetree
  open Ast_helper
  open Outcometree

(* Convenience AST builders, to be moved to Ast_helper at some point *)
  let may_tuple tup = function
    | [] -> None
    | [x] -> Some x
    | l -> Some (tup l)

  let lid s = mknoloc (Longident.parse s)
  let constr s args = Exp.construct (lid s) (may_tuple Exp.tuple args) false
  let nil = constr "[]" []
  let cons hd tl = constr "::" [hd; tl]
  let list l = List.fold_right cons l nil
  let str s = Exp.constant (Const_string (s, None))
  let int x = Exp.constant (Const_int x)
  let char x = Exp.constant (Const_char x)
  let float x = Exp.constant (Const_float (string_of_float x))

  let get_str = function
    | {pexp_desc=Pexp_constant (Const_string (s, _)); _} -> s
    | e ->
        Location.print_error Format.err_formatter e.pexp_loc;
        Format.eprintf "string literal expected";
        exit 2

  let rec lid_of_out_ident = function
    | Oide_apply _ -> assert false
    | Oide_dot (x, s) -> lid_of_out_ident x ^ "." ^ s
    | Oide_ident s -> s

  let rec exp_of_out_value = function
    | Oval_string x -> str x
    | Oval_int x -> int x
    | Oval_char x -> char x
    | Oval_float x -> float x
    | Oval_list l -> list (List.map exp_of_out_value l)
    | Oval_array l -> Exp.array (List.map exp_of_out_value l)
    | Oval_constr (c, args) -> constr (lid_of_out_ident c) (List.map exp_of_out_value args)
    | Oval_record l ->
        Exp.record
          (List.map (fun (s, v) -> (lid (lid_of_out_ident s),
                                    exp_of_out_value v)) l)
          None
    | v ->
        Format.eprintf "[%%eval] cannot map value to expression:@.%a@."
          !Toploop.print_out_value
          v;
        exit 2

  let set_loc loc = object
    inherit Ast_mapper.mapper
    method! location _ = loc
  end

  let empty_str_item = Str.include_ (Mod.structure [])

  let run phr =
    try Toploop.execute_phrase true Format.err_formatter phr
    with exn ->
      Errors.report_error Format.err_formatter exn;
      exit 2

  let eval = object
    inherit Ast_mapper.mapper as super

    val mutable eval_str_items = None

    method! structure_item i =
      match i.pstr_desc with
      | Pstr_extension(("eval.load", e0), _) ->
          let s = get_str e0 in
          if not (Topdirs.load_file Format.err_formatter s) then begin
            Location.print Format.err_formatter e0.pexp_loc;
            exit 2;
          end;
          empty_str_item
      | Pstr_extension(("eval.start", {pexp_desc=Pexp_ident{txt=Lident"both";_};_}), _) ->
          eval_str_items <- Some true;
          empty_str_item
      | Pstr_extension(("eval.start", _), _) ->
          eval_str_items <- Some false;
          empty_str_item
      | Pstr_extension(("eval.stop", _), _) ->
          eval_str_items <- None;
          empty_str_item
      | _ ->
          let s = super # structure_item i in
          match eval_str_items with
          | None -> s
          | Some both ->
              if not (run (Ptop_def [s])) then begin
                Location.print_error Format.err_formatter s.pstr_loc;
                Format.eprintf "this structure item raised an exception@.";
                exit 2
              end;
              if both then s else empty_str_item

    method! expr e =
      match e.pexp_desc with
      | Pexp_extension("eval", e0) ->
          let last_result = ref None in
          let pop = !Toploop.print_out_phrase in
          Toploop.print_out_phrase := begin fun _ppf -> function
            | Ophr_eval (v, _) -> last_result := Some v
            | r ->
                Location.print_error Format.err_formatter e.pexp_loc;
                Format.eprintf "error while evaluating expression:@.%a@."
                  pop
                  r;
                exit 2
          end;
          run (Ptop_def [Str.eval e0]);
          Toploop.print_out_phrase := pop;
          begin match !last_result with
          | None -> assert false
          | Some v -> (set_loc e0.pexp_loc) # expr (exp_of_out_value v)
          end
      | _ ->
          super # expr e

    initializer Toploop.initialize_toplevel_env ()
  end


  let () = Ast_mapper.main eval
end