open Exceptions

let check_extension filename = 
	let len = String.length filename in 
	if (len < 5) then false
	else
		begin
			let extension = String.sub filename (len - 5) 5 in 
			let uppercaseext = String.uppercase extension in 
			if (String.compare uppercaseext ".LZ77" <> 0) then false
			else true
		end

let uncompress_filename filename = 
	let len = String.length filename in 
	if (len < 5) then raise (Ext)
	else 
		String.sub filename (0) (len - 5)

let compress_filename filename = 
	String.concat filename [".lz77"]
			 	
let compress ic = 
	true
	
let uncompress ic = 
	true
