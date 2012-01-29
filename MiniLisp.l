/* Compiladores Projeto Minilisp 2011/2012
   a20090122-Paulo Fernandes  a20095167-Paulo Luis  a20091565-António Lourenço */

%option noyywrap
  #include <stdlib.h>
  #include <string.h>
  #include "MiniLisp.tab.h"
  /* Nota que foi removido o #define YYSTYPE! */

%x LISP
%x STRING_CONCATENATE



%%



"<?ml"                  BEGIN ( LISP );


/* para apanhar os " no concatenate*/
<LISP>["]				BEGIN ( STRING_CONCATENATE );	
/* limitada a 1000 caracteres */
<STRING_CONCATENATE>([^\\"]|\\([^0-7xX]|0|[0-7]{3}|[xX][0-9a-fA-F]{2}))*{0,1000}	{ strcpy(yyval.string, yytext) ; return STRING } 
/* quando encontrarmos o outro " voltamos ao LISP normal*/
<STRING_CONCATENATE>["]	BEGIN ( LISP );


<LISP>(?i:concatenate)  { return CONCAT;    }

<LISP>(?i:and)          { return AND;       }
<LISP>(?i:or)           { return OR;        }
<LISP>(?i:not)          { return NOT;       }

<LISP>(?i:if)         	{ return IF;        }
<LISP>(?i:cond)			{ return COND)		} /*FAZER DEPOIS SE POSSÍVEL*/
<LISP>(?i:when)         { return WHEN;     	}
<LISP>(?i:unless)       { return UNLESS;   	}

<LISP>(?i:zerop)		{ return ZEROP;		}

<LISP>(?i:setq)			{ return SETQ;		}
<LISP>(?i:let)			{ return LET;		}

<LISP>(?i:nil)			{ return NIL;		}
<LISP>(?i:t)			{ return T;			}


<LISP>"-"               { return OP_SUB;    }
<LISP>"+"               { return OP_SOMA;   }
<LISP>"*"				{ return OP_MULT;   }
<LISP>"/"				{ return OP_DIV;    }
<LISP>"="				{ return OP_IGUAL;  }

<LISP>"<="            	{ return OP_MENOR_IGUAL;}
<LISP>">="            	{ return OP_MAIOR_IGUAL;}
<LISP>"<"             	{ return OP_MENOR;    	}
<LISP>">"             	{ return OP_MAIOR;    	}
<LISP>"("               { return LP; 			}
<LISP>")"               { return RP; 			}


<LISP>[+-]?[0-9]+ 									{ yylval.integer = atoi(yytext); 	return NUMERO_INT;   	}
<LISP>[+-]?[0-9]+([.,][0-9]+)?([Ee][+-]?[0-9]+)? 	{ yylval.double = atoi(yytext); 	return NUMERO_DOUBLE;   }

<LISP>([[:alpha:]]|_)([[:alnum:]]|_)*{0,31}			{ int i; for (i=0;i<strlen(yytext); strcpy(yylval.string, yytext); return VARIAVEL; }
/* a variável pode começar por letra ou underscore, e depois ter qualquer letra, número ou underscore, até 32 caracteres (31 repetições máximo depois da primeira letra)*/
/*VER COMO SERÁ MELHOR FAZER A VARIAVEL - A REVER*/


/*será necessário testar isto? VERIFICAR COM TESTES*/
<LISP>[ \t\n\r]			;



<LISP>"?>"              BEGIN( INITIAL );

.|\n|\r|\t				ECHO;



/*
[\r\n]          		{ return EOL;      } ???????????????????
<LISP>(i:fnct)                  { return OP_FNCT;   }	/*?????*/
<LISP>" "						;	/*para limpar os espaços que vão aparecendo*/

*/