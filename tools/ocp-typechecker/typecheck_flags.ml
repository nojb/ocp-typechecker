(**************************************************************************)
(*                                                                        *)
(*   Typerex Tools                                                        *)
(*                                                                        *)
(*   Copyright 2011-2017 OCamlPro SAS                                     *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU General Public License version 3 described in the file       *)
(*   LICENSE.                                                             *)
(*                                                                        *)
(**************************************************************************)

let tool_name = "typecheck"

let print_annotated = ref false
let print_dtypedtree = ref false
let typecheck = ref true
let output : string option ref = ref None
let warn_mode = ref false
let print_annotations = ref false

let files : string list ref = ref []
let push_file f = files := f :: !files

let exprs : Typedtree.expression list ref = ref []

let debug = ref false
let backtrace = ref false
let raw_print = ref false

let print_debug s =
  if !debug then
    Format.fprintf Format.err_formatter "%s\n%!" s

let print_warning loc msg =
  if !warn_mode then
    Format.eprintf "%aWarning: %s\n%!"
      Location.print loc msg

let print_type fmt ty=
  if !raw_print then Printtyp.raw_type_expr fmt ty
  else Printtyp.type_expr fmt ty

let mode ?expr attr f =
  match attr with
  | "debug" ->
    let prev_debug = !debug in
    debug := true;
    fun () -> f (); debug := prev_debug
  | "nodebug" ->
    let prev_debug = !debug in
    debug := false;
    fun () -> f (); debug := prev_debug
  | "warning" ->
    let prev_warn = !warn_mode in
    warn_mode := true;
    fun () -> f (); warn_mode := prev_warn
  | "no_warning" ->
    let prev_warn = !warn_mode in
    warn_mode := false;
    fun () -> f (); warn_mode := prev_warn
  | "debug_annot" ->
    begin
      match expr with
        Some expr -> exprs := expr :: !exprs
      | None -> ()
    end; f
  | _ -> f

let debug_mode ?expr l =
  List.fold_left (fun acc (s, _) ->
      mode ?expr s.Location.txt acc) (fun _ -> ()) l
