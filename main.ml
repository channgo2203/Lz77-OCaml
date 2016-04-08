(* Lz77 implementation 
 * in OCaml
 *)

open Printf
open Exceptions
open Lz77

(* debug flag *)
let debug = ref false

(* text file *)
let text_file = ref ""

(* compressed file *)
let comp_file = ref ""

(* version information *)
let print_copyright () = 
	print_string (
		"\nLz77Ocaml\n"
		^"* Copyright (c) 2016 by Chan Ngo.\n"
		^"* All rights reserved.\n"
		^"* \n")

(* main function *)
let main text_file comp_file = 
	begin
		if (String.compare text_file "" <> 0) then
			begin
				let ic = open_in text_file in 
				let res = compress ic in
				if (res == 0) then
					print_string ("\nCompression completed!\n")
				else print_string ("\nCompression failed!\n")
			end
		else
			print_string ("\nCannot find text file\n")
	end;
	begin
		if (String.compare comp_file "" <> 0) then
			begin
				let ic = open_in comp_file in 
				let res = decompress ic in
				if (res == 0) then
					print_string ("\nUncompression completed!\n")
				else print_string ("\nUncompression failed!\n")
			end
		else
			print_string ("\nCannot find compressed file\n")
	end;
	exit 0
	
(* entry point *)
let _ = let usage_msg = "Lz77 compression and decompression.\nUsage: lz77 [-c|-d] text_file [options]" in
	let speclist = [
						("-c", 
							Arg.String (fun s -> text_file := s),
							": Compression");
						("-d",
							Arg.String (fun s -> comp_file := s),
							": Decompression");
						("-debug",
							Arg.Unit (fun () -> debug := true),
							": The debug mode");
						("-version", 
							Arg.Unit (fun () -> print_copyright(); exit 0),
							": Print version information")
					] in
		Arg.parse speclist (fun args -> raise (Arg.Bad ("Bad argument : " ^ args))) usage_msg;
		main !text_file !comp_file

						