%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "MiniLisp.tab.h"
%}

/* vari�veis */
VAR_CHARS	{CHARS}([0-9a-zA-Z_]?)*

/* Define caracteres v�lidos dentro de uma STRING */
STR_CHARS	([^\\"\n\r]|\\([^0-7xX]|0|[0-7]{3}|[xX][0-9a-fA-F]{2}))*

/* Define n�meros */
/*	DECIMAL PARA NUM ALTERADO				*/
DIGIT	[0-9]
NUM		({DIGIT}+("."{DIGIT}*)?|"."{DIGIT}+)([Ee][+-][0-9]+)?


/* MINIC PARA LISP  ALTERADO*/
%x LISP
%x STR

	int DEBUG = 0;
	int STR_Caller;


%%
	int DEBUG = 0

	

"<?ml"				BEGIN(LISP);
.|\n|\r				ECHO;

<LISP>{

"+"					{ if (DEBUG) printf("Flex consumiu: +");   return '+'; }
"-"					{ if (DEBUG) printf("Flex consumiu: -");   return '-'; }
"*"					{ if (DEBUG) printf("Flex consumiu: *");   return '*'; }
"/"					{ if (DEBUG) printf("Flex consumiu: /");   return '/'; }




"("					{ if (DEBUG) printf("Flex consumiu: (");   return LP; }
")"					{ if (DEBUG) printf("Flex consumiu: )");   return RP; }


">"					{ if (DEBUG) printf("Flex consumiu: >");   return '>'; }
"<"					{ if (DEBUG) printf("Flex consumiu: <");   return '<'; }
"="					{ if (DEBUG) printf("Flex consumiu: =");   return '='; }
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


[+-]?[0-9]+([.,][0-9]+)?([Ee][+-]?[0-9]+)?					{ yylval.valor_double = atof(yytext);	if (DEBUG) printf("Flex consumiu: %f\n", yylval.valor_double); return NUMERO; }

[a-zA-Z_]+([0-9a-zA-Z_]?)*				{ strcpy(yylval.nome_variavel, yytext);	if (DEBUG) printf("Flex consumiu: %s\n", yylval.nome_variavel); return NOMEVAR; }

["]					BEGIN ( STR );	/* para apanhar as aspas no concatenate*/

"?>"				BEGIN(INITIAL); 
}

<STR>{
([^\\"]|\\([^0-7xX]|0|[0-7]{3}|[xX][0-9a-fA-F]{2}))*{0,512}		{  strcpy(yylval.string , yytext) ; if (DEBUG) printf("Flex consumiu string: %s\n" ,yylval.string); return STRING; } 	/* limitada a 512 caracteres */

["]					BEGIN ( LISP );
}


