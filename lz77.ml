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
	if (get_debug ()) then print_endline (filename);
	filename ^ ".lz77"

(* trim the search buffer *)
let trim_search_buffer b = 
	if (get_debug ()) then print_endline ("trim search buffer");
	let trim_b = Buffer.create default_buff_size in
	let trim_bytes = Bytes.create default_buff_size in Buffer.blit b ((Buffer.length b) - default_buff_size) trim_bytes 0 default_buff_size; Buffer.add_bytes trim_b trim_bytes; trim_b
	 
(* compress function 
 * 0: succeeded
 * 1: failed
 *)		 	
let compress filename = 
	let ic = open_in filename in 
	let chars = char_stream ic in 
	let comfilename = compress_filename filename in 
	if (get_debug ()) then print_endline (comfilename);
	let oc = open_out comfilename in   
	let search_buffer = Buffer.create default_buff_size in 
	current_match := ""; match_index := 0; 
	try
		while true do
			let next_char = Stream.next chars in 
			try 
			begin
				let r = Str.regexp (!current_match ^ (String.make 1 next_char)) in 
				(* look in our search buffer for a match *)
				let tmp_index = Str.search_forward r (Buffer.contents search_buffer) 0 in 
				(* if match then append next_char to current_match and update match index *)
				current_match := !current_match ^ (String.make 1 next_char); 
				match_index := tmp_index
			end
			with Not_found -> 
			begin
				(* found the longest match *)
				if (get_debug ()) then print_endline ("longest match: " ^ !current_match);
				let codedstr = "~" ^ (string_of_int !match_index) ^ "~" ^ (string_of_int (String.length !current_match)) ^ "~" ^ (String.make 1 next_char) in
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
				end
				else 
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
						let r1 = Str.regexp (!current_match) in 
						let tmp_index1 = Str.search_forward r1 (Buffer.contents search_buffer) 0 in
						match_index := tmp_index1
					with Not_found ->
						match_index := -1	
					end
					done
				end
			end;
			(* trim the search buffer *)
			if (Buffer.length search_buffer > default_buff_size) then let trim_buffer = trim_search_buffer search_buffer in Buffer.clear search_buffer; Buffer.add_buffer search_buffer trim_buffer
		done;
		true
	with 
		| Stream.Failure ->
			begin
			(* flush any thing in current_match *)
			if (!match_index <> -1) then 
				begin
				let codedstr = "~" ^ (string_of_int !match_index) ^ "~" ^ (string_of_int (String.length !current_match)) in 
				if ((String.length codedstr) <= (String.length !current_match)) then 
					output_string oc codedstr
				else output_string oc (!current_match)
				end;
			(* close any I/O channel *)
			close_in ic; close_out oc; true
			end
		| _ -> 
			begin
			(* close any I/O channel *)
			close_in ic; close_out oc; false
			end
	
(* uncompress function 
 * 0: succeeded
 * 1: failed
 *)	
let uncompress filename = 
	true
		
		