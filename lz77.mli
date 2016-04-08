(* check compressed file extension *)
val check_extension : string -> bool

(* get filename without extension *)
val uncompress_filename : string -> string

(* get filename with extension *)
val compress_filename : string -> string

(* compress function 
 * 0: succeeded
 * 1: failed
 *)
val compress : string -> bool

(* uncompress function 
 * 0: succeeded
 * 1: failed
 *)
val uncompress : string -> bool

