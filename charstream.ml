(*
 * Read character by character from a file
 * The file is openned as a channel
 *)

open Errors 
open Stream
open Str

(* return a character stream from an input_channel *)
let char_stream ic = 
	Stream.from 
		(fun _ -> 
			try Some (input_char ic) 
			with End_of_file -> None)

(* string to character list *)
let str_char_list str =
  let rec str_char_list_aux i l =
    if i < 0 then l else str_char_list_aux (i - 1) (str.[i] :: l) in
  str_char_list_aux (String.length str - 1) []

(* character stream from a string in memory *)
let char_stream_str str = 
	Stream.of_list (str_char_list str)

	
			
