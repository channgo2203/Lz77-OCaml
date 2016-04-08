(* debug flag *)
type debug = bool ref

(* set debug *)
val set_debug : bool -> unit

(* get current debug setting *)
val get_debug : unit -> bool

