(* search buffer size *)
type default_buff_size = int

(* current match string *)
type current_match = string ref

(* match index *)
type match_index = int ref

(* check compressed file extension *)
val check_extension : string -> bool

(* get filename without extension *)
val uncompress_filename : string -> string

(* get filename with extension *)
val compress_filename : string -> string

(* trim the search buffer *)
val trim_search_buffer : Buffer.t -> Buffer.t

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

