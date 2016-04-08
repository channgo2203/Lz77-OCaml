open Errors
open Exceptions
open Charstream
open Str
open Printf

(* check compressed file extension *)
let check_extension filename = 
	let len = String.length filename in 
	if (len < 5) then raise (Invalid_file_ext)
	else
		begin
			let extension = String.sub filename (len - 5) 5 in 
			let uppercaseext = String.uppercase extension in 
			if (String.compare uppercaseext ".LZ77" <> 0) then false
			else true
		end

(* get filename without extension *)
let uncompress_filename filename = 
	let len = String.length filename in 
	if (len < 5) then raise (Invalid_file_ext)
	else 
		String.sub filename (0) (len - 5)

(* get filename with extension *)
let compress_filename filename = 
	String.concat filename [".lz77"]

(* compress function 
 * 0: succeeded
 * 1: failed
 *)		 	
let compress filename = 
	let ic = open_in filename in 
	let chars = char_stream ic in 
	try
		while true do
			let c = Stream.next chars in 
			if (get_debug ()) then print_char c
		done;
		true
	with Stream.Failure ->
		close_in ic; true
	
(* uncompress function 
 * 0: succeeded
 * 1: failed
 *)	
let uncompress filename = 
	true
		
		