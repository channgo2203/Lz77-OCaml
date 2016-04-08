(*
 * Read character by character from a file
 * The file is openned as a channel
 *)
 
let char_stream ic = 
	Stream.from 
		(fun _ -> 
			try Some (input_char ic) with End_of_file -> None);;
			
