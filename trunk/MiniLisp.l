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



<LISP>["]				BEGIN ( STRING_CONCATENATE );	/* para apanhar as aspas no concatenate*/
<STRING_CONCATENATE>([^\\"]|\\["])*{0,512}		{ strcpy(yylval.string, yytext) ; return STRING; } 	/* limitada a 512 caracteres */
<STRING_CONCATENATE>["]	BEGIN ( LISP ); 				/* quando encontrarmos o outro " voltamos ao LISP normal*/


<LISP>concatenate  { return CONCAT;    }		/* este flex não aceita o ?i e temos de fazer todos os caracteres minusculos e maiusculos.... :-(*/

<LISP>and          { return AND;       }
<LISP>or           { return OR;        }
<LISP>not          { return NOT;       }

<LISP>if       	{ return IF;        }
<LISP>cond			{ return COND;		} /*FAZER DEPOIS SE POSSÍVEL*/
<LISP>when         { return WHEN;     	}
<LISP>unless      { return UNLESS;   	}

<LISP>zerop		{ return ZEROP;		}

<LISP>setq			{ return SETQ;		}
<LISP>let			{ return LET;		}

<LISP>nil			{ return NIL;		}
<LISP>t			{ return T;			}


<LISP>"-"               { return OP_SUB;    }	/* poderíamos não fazer a distinçao aqui, mas dá-nos mais jeito enviar ao bison logo os tokens separados*/
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
<LISP>([[:alpha:]]|_)([[:alnum:]]|_)*{0,31}			{ int i; for (i=0;i<strlen(yytext);i++) strcpy(yylval.nome, yytext); return VARIAVEL;  }	/* a variável pode começar por letra ou underscore, e depois ter qualquer letra, número ou underscore, até 32 caracteres (31 repetições máximo depois da primeira letra)*/ /*VER COMO SERÁ MELHOR FAZER A VARIAVEL - A REVER*/






<LISP>[ \t\n\r]			;		/* limpar os espaços, tabs e newlines dentro do Lisp*/ /*será necessário testar isto? VERIFICAR COM TESTES*/



<LISP>"?>"              BEGIN( INITIAL );

.|\n|\r|\t				ECHO;
