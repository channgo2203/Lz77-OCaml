(* debug flag *)
type debug = bool ref

let debug = ref false

(* set debug *)
let set_debug b = debug := b


(* get current debug setting *)
let get_debug () = !debug


