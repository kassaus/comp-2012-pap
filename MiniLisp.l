%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "MiniLisp.tab.h"
%}
%option noyywrap

%x LISP
%x STRING_CONCATENATE

%%

"<?ml"                  BEGIN ( LISP );



<LISP>["]				BEGIN ( STRING_CONCATENATE );	/* para apanhar os " no concatenate*/
<STRING_CONCATENATE>([^\\"]|\\([^0-7xX]|0|[0-7]{3}|[xX][0-9a-fA-F]{2}))*{0,512}	{ strcpy(yyval.string, yytext) ; return STRING; } 	/* limitada a 512 caracteres */
<STRING_CONCATENATE>["]	BEGIN ( LISP ); 				/* quando encontrarmos o outro " voltamos ao LISP normal*/


<LISP>(?i:concatenate)  { return CONCAT;    }

<LISP>(?i:and)          { return AND;       }
<LISP>(?i:or)           { return OR;        }
<LISP>(?i:not)          { return NOT;       }

<LISP>(?i:if)         	{ return IF;        }
<LISP>(?i:cond)			{ return COND;		} /*FAZER DEPOIS SE POSS�VEL*/
<LISP>(?i:when)         { return WHEN;     	}
<LISP>(?i:unless)       { return UNLESS;   	}

<LISP>(?i:zerop)		{ return ZEROP;		}

<LISP>(?i:setq)			{ return SETQ;		}
<LISP>(?i:let)			{ return LET;		}

<LISP>(?i:nil)			{ return NIL;		}
<LISP>(?i:t)			{ return T;			}


<LISP>"-"               { return OP_SUB;    }	/* poder�amos n�o fazer a distin�ao aqui, mas d�-nos mais jeito enviar ao bison logo os tokens separados*/
<LISP>"+"               { return OP_SOMA;   }
<LISP>"*"				{ return OP_MULT;   }
<LISP>"/"				{ return OP_DIV;    }

<LISP>"="				{ return OP_IGUAL;  	}
<LISP>"/="				{ return OP_DIFERENTE;	}
<LISP>"<="            	{ return OP_MENOR_IGUAL;}
<LISP>">="            	{ return OP_MAIOR_IGUAL;}
<LISP>"<"             	{ return OP_MENOR;    	}
<LISP>">"             	{ return OP_MAIOR;    	}


<LISP>"("               { return LPAR; 			}
<LISP>")"               { return RPAR; 			}


<LISP>[+-]?[0-9]+ 									{ yylval.inteiro = atoi(yytext); 	return NUM_INT;   	}
<LISP>[+-]?[0-9]+([.,][0-9]+)?([Ee][+-]?[0-9]+)? 	{ yylval.real = atoi(yytext); 	return NUM_DOUBLE;   }
<LISP>([[:alpha:]]|_)([[:alnum:]]|_)*{0,31}			{ int i; for (i=0;i<strlen(yytext) strcpy(yylval.nome, yytext); return VARIAVEL;  }	/* a vari�vel pode come�ar por letra ou underscore, e depois ter qualquer letra, n�mero ou underscore, at� 32 caracteres (31 repeti��es m�ximo depois da primeira letra)*/ /*VER COMO SER� MELHOR FAZER A VARIAVEL - A REVER*/






<LISP>[ \t\n\r]			;		/* limpar os espa�os, tabs e newlines dentro do Lisp*/ /*ser� necess�rio testar isto? VERIFICAR COM TESTES*/



<LISP>"?>"              BEGIN( INITIAL );

.|\n|\r|\t				ECHO;