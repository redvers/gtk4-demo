all:
	corral run -- ponyc --files -d .
	./gtk4-demo

c:
	gcc -c `pkg-config gtk4 --cflags` foo.c
	rm -f libfoo.a
	ar -cvq libfoo.a foo.o
