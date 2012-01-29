# Makefile para Windows com GCC

calc : calc.tab.c calc.tab.h lex.yy.c Makefile
	gcc calc.tab.c lex.yy.c -Wall -o calc

calc.tab.c calc.tab.h : calc.y Makefile
	bison -d calc.y -o calc.tab.c

lex.yy.c : calc.l calc.tab.h Makefile
	flex calc.l

clean:
	del calc.tab.c calc.tab.h calc.output lex.yy.c calc.exe calc
