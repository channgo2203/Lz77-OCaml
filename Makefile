###########################################################################
#                  Lz77OCaml Makefile
#                  Copyright (C) 2016  Chan Ngo
#
#
###########################################################################

OCAMLMAKEFILE = OCamlMakefile

SOURCES = errors.ml errors.mli \
		  exceptions.ml exceptions.mli \
          charstream.ml charstream.mli \
          lz77.ml lz77.mli \
          main.ml 

RESULT = lz77

# libs
LIBS = str unix

# includes
#LIBDIRS = lib/ocamlgraph

YFLAGS = -v

all: native-code

-include $(OCAMLMAKEFILE)
