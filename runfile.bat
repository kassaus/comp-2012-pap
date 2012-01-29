bison -d MiniLisp.y -o MiniLisp.tab.c
flex MiniLisp.l
gcc MiniLisp.tab.c lex.yy.c -Wall -o MiniLisp