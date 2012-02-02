%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "MiniLisp.tab.h"
%}



%x LISP
%x STR



%%
	int DEBUG = 0;

	
"<?ml"				BEGIN(LISP);
.|\n|\r				ECHO;

<LISP>{

"+"					{ if (DEBUG) printf("Flex consumiu: +");   return SOMA; }
"-"					{ if (DEBUG) printf("Flex consumiu: -");   return SUB; }
"*"					{ if (DEBUG) printf("Flex consumiu: *");   return MUL; }
"/"					{ if (DEBUG) printf("Flex consumiu: /");   return DIV; }

"("					{ if (DEBUG) printf("Flex consumiu: (");   return LP; }
")"					{ if (DEBUG) printf("Flex consumiu: )");   return RP; }

">"					{ if (DEBUG) printf("Flex consumiu: >");   return MAIOR; }
"<"					{ if (DEBUG) printf("Flex consumiu: <");   return MENOR; }
"="					{ if (DEBUG) printf("Flex consumiu: =");   return IGUAL; }
">="				{ if (DEBUG) printf("Flex consumiu: >=");  return MAIOR_IGUAL; }
"<="				{ if (DEBUG) printf("Flex consumiu: <=");  return MENOR_IGUAL; }
"/="				{ if (DEBUG) printf("Flex consumiu: /=");  return DIFERENTE; } 

"not"				{ if (DEBUG) printf("Flex consumiu: not");  return NOT; }
"or"				{ if (DEBUG) printf("Flex consumiu: or");  return OR; }
"and"				{ if (DEBUG) printf("Flex consumiu: and");  return AND; }

"if"				{ if (DEBUG) printf("Flex consumiu: if");  return IF; }
"when"				{ if (DEBUG) printf("Flex consumiu: when");   return WHEN; }
"unless"			{ if (DEBUG) printf("Flex consumiu: unless");   return UNLESS; }
"zerop"				{ if (DEBUG) printf("Flex consumiu: zerop");   return ZEROP; }
"setq"				{ if (DEBUG) printf("Flex consumiu: setq");  return SETQ; }

"let"				{ if (DEBUG) printf("Flex consumiu: let");  return LET; }

"nil"				{ if (DEBUG) printf("Flex consumiu: nil");  return NIL; }
"t"					{ if (DEBUG) printf("Flex consumiu: t");  return T; }

"concatenate"		{ if (DEBUG) printf("Flex consumiu: concatenate");  return CONCATENATE; }

[ \t\n\r]			{ if (DEBUG) printf("Flex consumiu: espaco, tab ou newline"); }


[+-]?[0-9]+([.,][0-9]+)?([Ee][+-]?[0-9]+)?					{ yylval.real = atof(yytext);	if (DEBUG) printf("Flex consumiu: %f\n", yylval.real); return NUMERO; }

[a-zA-Z_]+([0-9a-zA-Z_]?)*				{ strcpy(yylval.string, yytext);	if (DEBUG) printf("Flex consumiu: %s\n", yylval.string ); return NOMEVAR; }

["]					BEGIN ( STR );	/* para apanhar as aspas no concatenate*/

"?>"				BEGIN(INITIAL); 
}

<STR>{
([^\\"]|\\([^0-7xX]|0|[0-7]{3}|[xX][0-9a-fA-F]{2}))*{0,512}		{  strcpy(yylval.string , yytext) ; if (DEBUG) printf("Flex consumiu string: %s\n" ,yylval.string); return STRING; } 	/* limitada a 512 caracteres */

["]					BEGIN ( LISP );
}

