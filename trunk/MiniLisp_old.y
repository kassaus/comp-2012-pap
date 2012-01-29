/* Compiladores Projeto Minilisp 2011/2012
   a20090122-Paulo Fernandes  a20095167-Paulo Luis  a20091565-António Lourenço */
   
/*========================================================================
C Libraries, Symbol Table, Code Generator & other C code
========================================================================*/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

extern int yylex( void );

/* valores possíveis de variáveis, double ou boolean */
typedef union {
	double _double;
	char _bool[3+1]
} val_variaveis;

/* variáveis: nome, tipo e valor */
typedef struct {
	char nome[32+1];
	int tipo; /* 0 para double, 1 para boolean*/
	val_variaveis valor;
} variaveis;

/* array de variáveis */
variaveis vars[100];


int vars_preenchidas = 0;

int le_var( const char *nome );
int escreve_var( const char *nome, int valor );
int encontra_var( const char *nome, int adicionar );
int insere_var_iniciais();

int yyerror( char *s )
{
    fprintf( stderr, "Erro bison: %s\n", s );
    return 1;
}


/* exemplo de error recovery!!!!!!!!!!!
 *
     line:     '\n'
             | exp '\n'   { printf ("\t%.10g\n", $1); }
             | error '\n' { yyerrok;                  }
     ;
*
exemplo de erro de divisão por zero

| exp '/' exp
                 {
                   if ($3)
                     $$ = $1 / $3;
                   else
                     {
                       $$ = 1;
                       fprintf (stderr, "%d.%d-%d.%d: division by zero",
                                @3.first_line, @3.first_column,
                                @3.last_line, @3.last_column);
                     }
                 }

*/

%}


/*****************************/

%union    {
	int num_int;
    double num_double;
    char string[];
    }




%%

input:				{ }
|	input linha		{ }
;

linha:	EOL			{ }
|	expr EOL		{ printf( "%0.2f\n", $1 );}
|   strvar EOL      { printf( "%s\n", $1 );}
;

expr: NUMERO                  { $$ = $1;         }
|   LP expr RP                { $$ = $2;        }
|   OP_SOMA expr expr         { $$ = $2 + $3;    }
|   OP_SUB expr expr          { $$ = $2 - $3;    }
|   OP_MULT expr expr         { $$ = $2 * $3;    }
|   OP_DIV expr expr          { if ($3==0) printf("ERROR: Divide %0.2f by zero\n", $2);   
                                    else  $$ = $2 / $3;   }
|   LP expr RP                { $$ = $2;         } 
|   VARIAVEL '=' expr         { $$ = $3;         }
|   OP_MENOR expr expr        { if (($2 < $3) == 1) printf(" true "); 
                                    else printf(" false ");  }
|   OP_MAIOR expr expr        { if (($2 > $3) == 1) printf(" true "); 
                                    else printf(" false ");  }
;

strvar: CONCAT strvar   {} 
;
%%

int main( void )
{
    return yyparse();
}


int le_var( const char *nome )
{
    int i;

    i = encontra_var( nome, 0 );
    if( i < 0 )
        {
        fprintf( stderr, "Referencia a variavel inexistente: %s\n", nome );
        /* exit( 1 ); */
        }
    return vars[i].valor;
}


int escreve_var( const char *nome, int valor )
{
    int i;

    i = encontra_var( nome, 1 );
    if( i < 0 )
        {
        fprintf( stderr, "Nao foi possivel criar a variavel: %s\n", nome );
        exit( 1 );
        }
    vars[i].valor = valor;
    return valor;
}


int encontra_var( const char *nome, int adicionar )
{
    int i;

    for( i=0;  i < vars_preenchidas;  i++ )
        {
        if( strcmp(vars[i].nome, nome) == 0 )
            return i;
        }
    if( adicionar  &&  i < 100 )
        {
        strcpy( vars[i].nome, nome );
        vars_preenchidas++;
        return i;
        }
    return -1;
}
