open Errors
open Exceptions
open Charstream
open Str
open Printf

type default_buff_size = int
type current_match = string ref
type match_index = int ref

let default_buff_size = 1024
let current_match = ref ""
let match_index = ref 0

(* check compressed file extension *)
let check_extension filename = 
	let len = String.length filename in 
	if (len < 5) then 
		begin
			false
		end else
		begin
			let extension = String.sub filename (len - 5) 5 in 
			let uppercaseext = String.uppercase extension in 
			if (String.compare uppercaseext ".LZ77" <> 0) then false
			else true
		end

(* get filename without extension *)
let uncompress_filename filename = 
	let len = String.length filename in 
	if (check_extension filename) then String.sub filename (0) (len - 5)
	else raise (Invalid_file_ext)

(* get filename with extension *)
let compress_filename filename = 
	filename ^ ".lz77"

(* trim the search buffer *)
let trim_search_buffer b = 
	let _ = if (get_debug ()) then print_endline ("trim search buffer") in
	
	let trim_b = Buffer.create default_buff_size in
	let trim_bytes = Bytes.create default_buff_size in 
	let _ = Buffer.blit b ((Buffer.length b) - default_buff_size) 
		trim_bytes 0 default_buff_size in
		Buffer.add_bytes trim_b trim_bytes; trim_b
	 
(* compress function 
 * 0: succeeded
 * 1: failed
 *)		 	
let compress filename = 
	(* debug *)
	let _ = if (get_debug ()) then print_endline ("Text file: " ^ filename) in
	
	try 
		let ic = open_in filename in 
		let chars = char_stream ic in 
		let comfilename = compress_filename filename in 
	
		(* debug *)
		let _ = if (get_debug ()) then print_endline ("Compressed file: " ^ comfilename) in
	
		let oc = open_out comfilename in   
		let search_buffer = Buffer.create default_buff_size in 
		current_match := ""; match_index := 0; 
		try
			while true do
				(* get the next char from text file *)
				let next_char = Stream.next chars in 
				try 
					let r = Str.regexp_string (!current_match ^ (String.make 1 next_char)) in 
					(* look in our search buffer for a match *)
					let tmp_index = Str.search_forward r (Buffer.contents search_buffer) 0 in 
					(* if match then append next_char to current_match and update match index *)
					current_match := !current_match ^ (String.make 1 next_char); 
					match_index := tmp_index
				
				with Not_found -> 
					(* found the longest match *)
					let _ = if (get_debug ()) then print_endline ("longest match: " ^ !current_match) in 
					(* coded string of the current match *)
					let codedstr = "~" ^ (string_of_int !match_index) ^ "~" 
						^ (string_of_int (String.length !current_match)) ^ "~" 
						^ (String.make 1 next_char) in
					let concat = !current_match ^ (String.make 1 next_char) in 
					if ((String.length codedstr) <= (String.length concat)) then 
						begin
							(* output codedstr *)
							output_string oc codedstr;
							(* append concat to search buffer *)
							Buffer.add_string search_buffer concat;
							(* reset current_match and match_index *)
							current_match := "";
							match_index := 0
					end else 
						begin
							(* otherwise, output chars one at a time *)
							current_match := !current_match ^ (String.make 1 next_char); 
							match_index := -1;
							while ((String.length !current_match) > 1 && !match_index = -1) do
								begin
									output_char oc (String.get !current_match 0);
									Buffer.add_char search_buffer (String.get !current_match 0);
									current_match := String.sub !current_match 1 (String.length !current_match - 1);
									try
										let r1 = Str.regexp_string (!current_match) in 
										let tmp_index1 = Str.search_forward r1 (Buffer.contents search_buffer) 0 in
										match_index := tmp_index1
									with Not_found ->
										match_index := -1	
								end
							done
						end;
					
				(* trim the search buffer *)
				if (Buffer.length search_buffer > default_buff_size) then 
					let trim_buffer = trim_search_buffer search_buffer in 
					Buffer.clear search_buffer; 
					Buffer.add_buffer search_buffer trim_buffer
			done; 
			true
		with 
			| Stream.Failure ->
				(* flush any thing in current_match *)
				if (!match_index <> -1) then 
					begin
						let codedstr = "~" ^ (string_of_int !match_index) ^ "~" ^ (string_of_int (String.length !current_match)) in 
						if ((String.length codedstr) <= (String.length !current_match)) then 
							output_string oc codedstr
						else output_string oc (!current_match)
					end;
				(* close any I/O channel *)
				close_in ic; flush oc; close_out oc; 
				true
	with Sys_error e -> 
		(* file invalid *)
		print_endline e; 
		false
	
(* uncompress function 
 * 0: succeeded
 * 1: failed
 *)	
let uncompress filename = 
	(* debug *)
	let _ = if (get_debug ()) then print_endline ("Compressed file: " ^ filename) in
	try 
		let ic = open_in filename in
		try 
			let uncomfilename = uncompress_filename filename in
			(* debug *)
			let _ = if (get_debug ()) then print_endline ("Uncompressed file: " ^ uncomfilename) in
			(* uncompressed file *)
			let oc = open_out uncomfilename in  
			true
		with 
			| Invalid_file_ext ->
				(* invalid compressed file extension *)
				print_endline ("Invalid compressed file"); 
				(* close any open channel *)
				close_in ic;
				false
			| Sys_error e -> 
				(* file invalid *)
				print_endline e; 
				(* close open channel *)
				close_in ic;
				false
	with Sys_error e -> 
			(* file invalid *)
			print_endline e; 
			false
		
	