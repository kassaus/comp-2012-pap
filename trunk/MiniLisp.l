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


<LISP>"+"					{ if (DEBUG) printf("Flex consumiu: +");   return '+'; }
<LISP>"-"					{ if (DEBUG) printf("Flex consumiu: -");   return '-'; }
<LISP>"*"					{ if (DEBUG) printf("Flex consumiu: *");   return '*'; }
<LISP>"/"					{ if (DEBUG) printf("Flex consumiu: /");   return '/'; }

<LISP>"("					{ if (DEBUG) printf("Flex consumiu: (");   return LP; }
<LISP>")"					{ if (DEBUG) printf("Flex consumiu: )");   return RP; }


<LISP>">"					{ if (DEBUG) printf("Flex consumiu: >");   return '>'; }
<LISP>"<"					{ if (DEBUG) printf("Flex consumiu: <");   return '<'; }
<LISP>"="					{ if (DEBUG) printf("Flex consumiu: =");   return '='; }
<LISP>">="				{ if (DEBUG) printf("Flex consumiu: >=");  return MAIOR_IGUAL; }
<LISP>"<="				{ if (DEBUG) printf("Flex consumiu: <=");  return MENOR_IGUAL; }
<LISP>"/="				{ if (DEBUG) printf("Flex consumiu: /=");  return DIFERENTE; } 

<LISP>"not"				{ if (DEBUG) printf("Flex consumiu: not");  return NOT; }
<LISP>"or"				{ if (DEBUG) printf("Flex consumiu: or");  return OR; }
<LISP>"and"				{ if (DEBUG) printf("Flex consumiu: and");  return AND; }

<LISP>"if"				{ if (DEBUG) printf("Flex consumiu: if");  return IF; }
<LISP>"when"				{ if (DEBUG) printf("Flex consumiu: when");   return WHEN; }
<LISP>"unless"			{ if (DEBUG) printf("Flex consumiu: unless");   return UNLESS; }
<LISP>"zerop"				{ if (DEBUG) printf("Flex consumiu: zerop");   return ZEROP; }
<LISP>"setq"				{ if (DEBUG) printf("Flex consumiu: setq");  return SETQ; }
<LISP>"let"				{ if (DEBUG) printf("Flex consumiu: let");  return LET; }

<LISP>"nil"				{ if (DEBUG) printf("Flex consumiu: nil");  return NIL; }
<LISP>"t"					{ if (DEBUG) printf("Flex consumiu: t");  return T; }

<LISP>"concatenate"		{ if (DEBUG) printf("Flex consumiu: concatenate");  return CONCATENATE; }

<LISP>[ \t\n\r]			{ if (DEBUG) printf("Flex consumiu: espaco, tab ou newline"); }


<LISP>[+-]?[0-9]+([.,][0-9]+)?([Ee][+-]?[0-9]+)?					{ yylval.valor_double = atof(yytext);	if (DEBUG) printf("Flex consumiu: %f\n", yylval.valor_double); return NUMERO; }

<LISP>[a-zA-Z_]+([0-9a-zA-Z_]?)*				{ strcpy(yylval.nome_variavel, yytext);	if (DEBUG) printf("Flex consumiu: %s\n", yylval.nome_variavel); return NOMEVAR; }

<LISP>["]					BEGIN ( STR );	/* para apanhar as aspas no concatenate*/

<LISP>"?>"				BEGIN(INITIAL); 



<STR>([^\\"]|\\([^0-7xX]|0|[0-7]{3}|[xX][0-9a-fA-F]{2}))*{0,512}		{  strcpy(yylval.valor_string , yytext) ; if (DEBUG) printf("Flex consumiu string: %s\n" ,yylval.valor_string); return STRING; } 	/* limitada a 512 caracteres */
<STR>["]					BEGIN ( LISP );




