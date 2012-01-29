%{
#include <stdio.h>
#include <string.h> /* Comparação de Strings */
#include <time.h>
#include <sys/time.h>




/* A funcao yyparse() gerada pelo bison vai automaticamente chamar a funcao
   yylex() do flex.
   A funcao yyparse() esta' definida no ficheiro ".tab.c" gerada por este
   ficheiro ".y" e a yylex() no ficheiro "lex.yy.c" gerada pelo ficheiro ".l".

   Como ambos os ficheiros sao compilados de forma independente para so'
   depois serem ligados (linked), o ficheiro ".y" precisa de ter definida a
   funcao yylex() para nao dar erro de compilacao.
   Infelizmente precisamos que o bison corra antes do flex (para gerar o
   ficheiro ".tab.h" com os %tokens e algumas outras definicoes). Entao
   declaramos essafuncao do flex como sendo "definida noutro ficheiro fonte",
   ou seja, "externa":
*/
extern int yylex( void );
extern FILE *yyin;


/* Definição da estrutura de variaveis */

typedef union {
		double real;
		char	boolean[3+1];
	 	} valores;


typedef struct {
	char nome[32+1];
	int TipoValor; /* se For 0 então é double se 1 então é boolean */
	valores valor;
} var;

var vars[100];

int vars_preenchidas = 0;

int le_var( const char *nome );
int escreve_var( var v );
int encontra_var( const char *nome, int adicionar );
int Carregar_DateTime();



/* Finalmente, se o bison receber alguma combinacao de tokens para a qual nao
   ha' nenhuma regra, chama uma funcao yyerror() que devemos criar.
   A macro YYERROR_VERBOSE, se definida, pede ao bison para ser mais detalhado
   no erro que nos da', mas nao funciona bem em versoes antigas do bison.
*/
/* #define YYERROR_VERBOSE */
int yyerror( char *s )
{
	fprintf( stderr, "Erro bison: %s\n", s );
	return 1;
}

%}

%union	{
			int inteiro;
			double real;
			char string[1000+1];
		}

/* Os tokens sao uma enumeracao (enum do C) que cria automaticamente valores
   inteiros para cada um. Temos no entanto que os definir como "%token" no
   ficheiro ".y" do bison:
*/


%token <inteiro> NUM_INT
%token <real>    NUM_DOUBLE
%token <string>  STRING
%token <string>  VARIAVEL


%token CONCAT

%token AND
%token OR
%token NOT

%token IF
%token COND
%token WHEN
%token UNLESS


%token ZEROP

%token SETQ
%token LET

%token NIL
%token T




%token OP_SOMA
%token OP_SUB
%token OP_MULT
%token OP_DIV

%token OP_IGUAL
%token OP_DIFERENTE	/*ainda não feito, fazer TODO*/
%token OP_MENOR_IGUAL
%token OP_MAIOR_IGUAL
%token OP_MENOR
%token OP_MAIOR


%token LPAR
%token RPAR











%type <inteiro>  expr_num_int
%type <inteiro>  listaSoma_int
%type <inteiro>  listaSub_int
%type <inteiro>  listaMult_int
%type <inteiro>  listaDiv_int
%type <real> 	 expr_num_dbl
%type <real> 	 listaSoma_dbl
%type <real> 	 listaSub_dbl
%type <real> 	 listaMult_dbl
%type <real> 	 listaDiv_dbl
%type <inteiro>  expr_cond_int
%type <string>   condition
%type <inteiro>  action_int
%type <real> 	 expr_cond_dbl
%type <real> 	 action_dbl
%type <string> 	 expr_str
%type <string> 	 listaString
%type <string>   expr_zerop

%%


/* início do nosso*/



input:	/* vazio */
|	input linha
;

linha:  	expr_num_int							{ printf("%d\n", $1 ); }
|	expr_num_dbl							{ printf("%f\n", $1 ); }
|	expr_cond_int							{ printf("%d\n", $1 ); }
|	expr_cond_dbl							{ printf("%f\n", $1 ); }
|	expr_zerop							{ printf("%s\n", $1 ); } 
|	expr_str							{ printf("%s\n", $1 ); }
;

expr_cond_int: LPAR IF condition action_int action_int RPAR { if($3 == 1) $$ = $4; else $$ = $5; }
;

expr_cond_dbl: LPAR IF condition action_dbl action_dbl RPAR { if($3 == 1) $$ = $4; else $$ = $5; }
;

condition:	LPAR OP_IGUAL 		  expr_num_int expr_num_int RPAR	{ if($3 == $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR		  expr_num_int expr_num_int RPAR	{ if($3 < $4)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR		  expr_num_int expr_num_int RPAR	{ if($3 > $4)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR_IGUAL 	  expr_num_int expr_num_int RPAR	{ if($3 <= $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MAIOR_IGUAL 	  expr_num_int expr_num_int RPAR	{ if($3 >= $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_IGUAL		  expr_num_dbl expr_num_dbl RPAR 	{ if($3 == $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR MENOR		  expr_num_dbl expr_num_dbl RPAR 	{ if($3 < $4)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR MAIOR	 	  expr_num_dbl expr_num_dbl RPAR 	{ if($3 > $4)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR_IGUAL	  expr_num_dbl expr_num_dbl RPAR 	{ if($3 <= $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MAIOR_IGUAL	  expr_num_dbl expr_num_dbl RPAR 	{ if($3 >= $4) strcpy($$,"t"); else strcpy($$,"nil"); }
/* Comparação de Strings */
|		LPAR OP_IGUAL	          STRING   STRING   RPAR { if(strcmp($3, $4) == 0) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR MENOR		  STRING   STRING   RPAR { if(strcmp($3, $4) < 0)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR MAIOR		  STRING   STRING   RPAR { if(strcmp($3, $4) > 0)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR_IGUAL	  STRING   STRING   RPAR { if(strcmp($3, $4) <= 0) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MAIOR_IGUAL	  STRING   STRING   RPAR { if(strcmp($3, $4) >= 0) strcpy($$,"t"); else strcpy($$,"nil"); }
/* Comparação Boolean */
		
;


expr_zerop:	LPAR ZEROP expr_num_int RPAR { if($3==0) strcpy($$,"t"); else strcpy($$,"nil");   }
|		LPAR ZEROP expr_num_dbl RPAR { if($3==0) strcpy($$,"t"); else strcpy($$,"nil");   }
;

action_int:	expr_num_int		{ $$ = $1; }
|		expr_cond_int		{ $$ = $1; }
;

action_dbl: 	expr_num_dbl		{ $$ = $1; }
|		expr_cond_dbl		{ $$ = $1; }
;

expr_num_int:	NUM_INT		{ $$ = $1; }
|		LPAR	OP_SOMA 	listaSoma_int 	RPAR	{ $$ = $3; }
|		LPAR 	OP_SUB 		listaSub_int 	RPAR 	{ $$ = $3; }
|		LPAR	OP_MULT		listaMult_int 	RPAR 	{ $$ = $3; }
|		LPAR 	OP_DIV		listaDiv_int 	RPAR	{ $$ = $3; }
;

expr_num_dbl:	NUM_DOUBLE	{ $$ = $1; }
|		LPAR	OP_SOMA 	listaSoma_dbl 	RPAR	{ $$ = $3; }
|		LPAR 	OP_SUB 		listaSub_dbl 	RPAR 	{ $$ = $3; }
|		LPAR	OP_MULT 	listaMult_dbl 	RPAR 	{ $$ = $3; }
|		LPAR 	OP_DIV		listaDiv_dbl 	RPAR	{ $$ = $3; }
;

expr_str: 	LPAR		CONCAT		listaString 	RPAR	{ strcpy($$, $3); }
;

listaSoma_int: 		expr_num_int	{ $$ = $1; }
|			listaSoma_int 	expr_num_int	{ $$ = $1 + $2; }
;

listaSoma_dbl: 		expr_num_dbl	{ $$ = $1; }
|			listaSoma_dbl 	expr_num_dbl	{ $$ = $1 + $2; }
;

listaSub_int: 		expr_num_int	{ $$ = $1; }
|	  		listaSub_int 	expr_num_int	{ $$ = $1 - $2; }
;

listaSub_dbl: 		expr_num_dbl	{ $$ = $1; }
|			listaSub_dbl 	expr_num_dbl	{ $$ = $1 - $2; }
;

listaMult_int: 		expr_num_int	{ $$ = $1; }
|			listaMult_int 	expr_num_int	{ $$ = $1 * $2; }
;

listaMult_dbl: 		expr_num_dbl	{ $$ = $1; }
|			listaMult_dbl 	expr_num_dbl	{ $$ = $1 * $2; }
;

listaDiv_int: 		expr_num_int	{ $$ = $1; }
|			listaDiv_int 	expr_num_int	{ $$ = $1 / $2; }
;

listaDiv_dbl: 		expr_num_dbl	{ $$ = $1; }
|			listaDiv_dbl 	expr_num_dbl	{ $$ = $1 / $2; }
;

listaString: 	STRING				{ strcpy($$, $1);}
|		listaString STRING              { strcpy($$,$1); strcat($$, $2);}
;



%%


int main( int argc, char *argv[] )
{
	if(Carregar_DateTime()==1){
		if (argc == 2)
		{
			yyin = fopen(argv[1], "r");
			yyparse();
		}
		else{
			printf("Args err: execute-> ./rpn <inputFile>\n");
			fclose(yyin);
			
		}
		int index = le_var("hour");
		if (index >= 0)
		{
		   if(vars[index].TipoValor == 0){
				printf("Variavel %s com o valor = %f",vars[index].nome,vars[index].valor.real);
		   }
		    else 
                   {
 				printf("Variavel %s com o valor = %s",vars[index].nome,vars[index].valor.boolean);
		    }	
		}

	} 
	else 
	{
		printf("TEste Falhado\n");
		
	}
	return 0;
}


int le_var( const char *nome )
{
	int i;
	i = encontra_var( nome, 0 );
	if( i < 0 )
		{
		fprintf( stderr, "Referencia a variavel inexistente: %s\n", nome );
		exit( 1 );
		}
	return i;
}




int escreve_var(var v )
{
	int i;

	i = encontra_var( v.nome, 1 );
	if( i < 0 )
		{
		fprintf( stderr, "Nao foi possivel criar a variavel: %s\n", v.nome );
		exit( 1 );
		}
	if(v.TipoValor==0){
		vars[i].valor.real = v.valor.real;
		vars[i].TipoValor = v.TipoValor;
		return 1;
	} else {
		strcpy(vars[i].valor.boolean,v.valor.boolean);
		vars[i].TipoValor = v.TipoValor;
		return 1;
	}
	return -1;
}


int encontra_var( const char *nome, int adicionar  )
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


int Carregar_DateTime()
{

	time_t now;
    	struct tm* tm;
    	now = time(0);
    	tm = localtime(&now);	
	int hour = tm->tm_hour;
	//printf("hora: %d \n", hour);
	var Hora, Minutos, Segundos, Dia, Mes, Ano;

	// Hora
	strcpy (Hora.nome,"hour");
	Hora.TipoValor= 0;
	Hora.valor.real = tm->tm_hour; 

	//Minutos
	strcpy (Minutos.nome,"minute");
        Minutos.TipoValor= 0;
        Minutos.valor.real = tm->tm_min;	
	
	//Segundos
	strcpy (Segundos.nome,"second");
        Segundos.TipoValor= 0;
        Segundos.valor.real = tm->tm_sec;
	
	//Dia
	strcpy (Dia.nome,"day");
        Dia.TipoValor= 0;
        Dia.valor.real = tm->tm_mday;	
	
	//Mes
	strcpy (Mes.nome,"month");
        Mes.TipoValor= 0;
        Mes.valor.real = tm->tm_mon;
	
	//Ano
	strcpy (Ano.nome,"year");
        Ano.TipoValor= 0;
        Ano.valor.real = tm->tm_year;

	if(escreve_var(Hora) 	 != 1) return -1;
	if(escreve_var(Minutos)  != 1) return -1;
	if(escreve_var(Segundos) != 1) return -1;
	if(escreve_var(Dia) 	 != 1) return -1;
	if(escreve_var(Mes) 	 != 1) return -1;
	if(escreve_var(Ano) 	 != 1) return -1;

return 1;
}
