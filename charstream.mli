(* character stream from input channel *)
val char_stream : in_channel -> char Stream.t

(* string to character list *)
val str_char_list : string -> char list

(* character stream from string in memory *)
val char_stream_str : string -> char Stream.t

