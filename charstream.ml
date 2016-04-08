(*
 * Read character by character from a file
 * The file is openned as a channel
 *)
 

(* return a character stream from an input_channel *)
let char_stream ic = 
	Stream.from 
		(fun _ -> 
			try Some (input_char ic) 
			with End_of_file -> None)

(* character stream from a string in memory *)
let 
			
