# Makefile para Windows com GCC

MiniLisp : MiniLisp.tab.c MiniLisp.tab.h lex.yy.c Makefile
	gcc MiniLisp.tab.c lex.yy.c -Wall -o MiniLisp

MiniLisp.tab.c MiniLisp.tab.h : MiniLisp.y Makefile
	bison -d MiniLisp.y -o MiniLisp.tab.c

lex.yy.c : MiniLisp.l MiniLisp.tab.h Makefile
	flex MiniLisp.l

clean:
	del MiniLisp.tab.c MiniLisp.tab.h MiniLisp.output lex.yy.c MiniLisp.exe MiniLisp
