(* Lz77 implementation 
 * in OCaml
 *)

open Errors
open Printf
open Exceptions
open Lz77

(* text file *)
let text_file = ref ""

(* compressed file *)
let comp_file = ref ""

(* working mode *)
let mode = ref (-1)

(* version information *)
let print_copyright () = 
	print_string (
		"\nLz77Ocaml\n"
		^"* Copyright (c) 2016 by Chan Ngo.\n"
		^"* All rights reserved.\n"
		^"* \n")

(* usage message *)
let usage_msg = "Lz77 compression and decompression.\nUsage: lz77 [-c|-d] text_file [-debug]\n"

(* main function *)
let main text_file comp_file = 
	begin
		match !mode with 
		| 0 ->  
			if (String.compare text_file "" <> 0) then
				let res = compress text_file in
				if (res) then
					print_string ("\nCompression succeeded!\n")
				else print_string ("\nCompression failed!\n")
			else
				print_string ("\nNo input file\n")
		| 1 -> 
			if (String.compare comp_file "" <> 0) then
				try 
					if (check_extension comp_file) then 
						let res = uncompress comp_file in
						if (res) then
							print_string ("\nUncompression succeeded!\n")
						else print_string ("\nUncompression failed!\n")
					else print_string ("\nFile invalid!\n")
				with Invalid_file_ext ->
					print_string ("\nFile invalid!\n")
			else
				print_string ("\nNo input file\n")
		| _ -> print_string (usage_msg)
			
	end;
	exit 0
	
(* entry point *)
let _ = let speclist = [
						("-c", 
							Arg.String (fun s -> mode := 0; text_file := s),
							": Compression");
						("-d",
							Arg.String (fun s -> mode := 1; comp_file := s),
							": Decompression");
						("-debug",
							Arg.Unit (fun () -> set_debug true),
							": The debug mode");
						("-version", 
							Arg.Unit (fun () -> print_copyright(); exit 0),
							": Print version information")
					] in
		Arg.parse speclist (fun args -> raise (Arg.Bad ("Bad argument : " ^ args))) usage_msg;
		main !text_file !comp_file

						