%{
#include <stdio.h>
#include <stdlib.h>	
#include <string.h>
#include <time.h>

#define NUM_VARGLOB_MAX 100 	/* 100 variáveis globais possíveis */
#define NUM_VARTEMP_MAX 100 	/* 100 variáveis temporárias possíveis, para o LET */

extern int yylex( void );
extern FILE *yyin;




/* estrutura para guardarmos as variaveis; têm nome, tipo e valor */
typedef struct {
	char nome[32+1];
	int tipo; 		/* convençao: 0 para double, 1 para boolean */
	union {
		char c[3+1];	/* t ou nil*/
		double d;
	}
} variavel;


/* array das variáveis globais*/
variavel varsGlob[NUM_VARGLOB_MAX];


/* array para variáveis temporárias... não sei se será a melhor opção TODO*/
variavel varsTemp[NUM_VARTEMP_MAX];


/* contadores para sabermos onde estamos no array, como não há o conceito de apagar, vai funcionar*/
int varsGlobPreenchidas = 0;
int varsTempPreenchidas = 0;


int le_var( const char *nome );
int escreve_var( variavel v );
int encontra_var( const char *nome, int adicionar );
int inicializa_variaveis_iniciais();


/* novas funcoes */



/*	EscreveVariavel

recebe 
se é global ou temporária	global=1, temporária =0
nome
tipo


retorna
	-1 se a variável já existe
	-2 se a variável não pode ser gravada

*/


int putVar(char * varname);
void setVarValue(char * varname, float value);
int getVar(char * varname);
double getVarValue(int idx);




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
			char nome[32+1];
			char string[512];
		}

/* Os tokens sao uma enumeracao (enum do C) que cria automaticamente valores
   inteiros para cada um. Temos no entanto que os definir como "%token" no
   ficheiro ".y" do bison:
*/


%token <inteiro> 	NUM_INT
%token <real>    	NUM_DOUBLE
%token <string>		STRING
%token <nome>		VARIAVEL


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





%type <inteiro>  expressaoInteiros
%type <real> 	 expressaoReais
%type <string> 	 expressaoString

%type <inteiro>  listaSomaInteiros
%type <real> 	 listaSomaReais
%type <inteiro>  listaSubInteiros
%type <real> 	 listaSubReais
%type <inteiro>  listaMultInteiros
%type <real> 	 listaMultReais
%type <inteiro>  listaDivInteiros
%type <real> 	 listaDivReais
%type <string> 	 listaString

%type <inteiro>  exprCondicionalInteiros
%type <real> 	 exprCondicionalReais
%type <string>   condicao
%type <inteiro>  thenElseInteiros
%type <real> 	 thenElseReais


/* nao sei se necessario...*/
%type <string>   expr_zerop


%%



input:	/* vazio */
|	input linha
;

linha:  	expressaoInteiros							{ printf("%d\n", $1 ); }
|	expressaoReais							{ printf("%f\n", $1 ); }
|	exprCondicionalInteiros							{ printf("%d\n", $1 ); }
|	exprCondicionalReais							{ printf("%f\n", $1 ); }
|	expr_zerop							{ printf("%s\n", $1 ); } 
|	expressaoString							{ printf("%s\n", $1 ); 

;

exprCondicionalInteiros: LPAR IF condicao thenElseInteiros thenElseInteiros RPAR { if($3 == 1) $$ = $4; else $$ = $5; }
;

exprCondicionalReais: LPAR IF condicao thenElseReais thenElseReais RPAR { if($3 == 1) $$ = $4; else $$ = $5; }
;

condicao:	LPAR OP_IGUAL 		  expressaoInteiros expressaoInteiros RPAR	{ if($3 == $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR		  expressaoInteiros expressaoInteiros RPAR	{ if($3 < $4)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR		  expressaoInteiros expressaoInteiros RPAR	{ if($3 > $4)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR_IGUAL 	  expressaoInteiros expressaoInteiros RPAR	{ if($3 <= $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MAIOR_IGUAL 	  expressaoInteiros expressaoInteiros RPAR	{ if($3 >= $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_IGUAL		  expressaoReais expressaoReais RPAR 	{ if($3 == $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR MENOR		  expressaoReais expressaoReais RPAR 	{ if($3 < $4)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR MAIOR	 	  expressaoReais expressaoReais RPAR 	{ if($3 > $4)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR_IGUAL	  expressaoReais expressaoReais RPAR 	{ if($3 <= $4) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MAIOR_IGUAL	  expressaoReais expressaoReais RPAR 	{ if($3 >= $4) strcpy($$,"t"); else strcpy($$,"nil"); }
/* Comparação de Strings */
|		LPAR OP_IGUAL	          STRING   STRING   RPAR { if(strcmp($3, $4) == 0) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR MENOR		  STRING   STRING   RPAR { if(strcmp($3, $4) < 0)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR MAIOR		  STRING   STRING   RPAR { if(strcmp($3, $4) > 0)  strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MENOR_IGUAL	  STRING   STRING   RPAR { if(strcmp($3, $4) <= 0) strcpy($$,"t"); else strcpy($$,"nil"); }
|		LPAR OP_MAIOR_IGUAL	  STRING   STRING   RPAR { if(strcmp($3, $4) >= 0) strcpy($$,"t"); else strcpy($$,"nil"); }
/* Comparação Boolean */
		
;


expr_zerop:	LPAR ZEROP expressaoInteiros RPAR { if($3==0) strcpy($$,"t"); else strcpy($$,"nil");   }
|		LPAR ZEROP expressaoReais RPAR { if($3==0) strcpy($$,"t"); else strcpy($$,"nil");   }
;

thenElseInteiros:	expressaoInteiros		{ $$ = $1; }
|		exprCondicionalInteiros		{ $$ = $1; }
;

thenElseReais: 	expressaoReais		{ $$ = $1; }
|		exprCondicionalReais		{ $$ = $1; }
;

expressaoInteiros:	NUM_INT		{ $$ = $1; }
|		LPAR	OP_SOMA 	listaSomaInteiros 	RPAR	{ $$ = $3; }
|		LPAR 	OP_SUB 		listaSubInteiros 	RPAR 	{ $$ = $3; }
|		LPAR	OP_MULT		listaMultInteiros 	RPAR 	{ $$ = $3; }
|		LPAR 	OP_DIV		listaDivInteiros 	RPAR	{ $$ = $3; }
;

expressaoReais:	NUM_DOUBLE	{ $$ = $1; }
|		LPAR	OP_SOMA 	listaSomaReais 	RPAR	{ $$ = $3; }
|		LPAR 	OP_SUB 		listaSubReais 	RPAR 	{ $$ = $3; }
|		LPAR	OP_MULT 	listaMultReais 	RPAR 	{ $$ = $3; }
|		LPAR 	OP_DIV		listaDivReais 	RPAR	{ $$ = $3; }
;

expressaoString: 	LPAR		CONCAT		listaString 	RPAR	{ strcpy($$, $3); }
;

listaSomaInteiros: 		expressaoInteiros	{ $$ = $1; }
|			listaSomaInteiros 	expressaoInteiros	{ $$ = $1 + $2; }
;

listaSomaReais: 		expressaoReais	{ $$ = $1; }
|			listaSomaReais 	expressaoReais	{ $$ = $1 + $2; }
;

listaSubInteiros: 		expressaoInteiros	{ $$ = $1; }
|	  		listaSubInteiros 	expressaoInteiros	{ $$ = $1 - $2; }
;

listaSubReais: 		expressaoReais	{ $$ = $1; }
|			listaSubReais 	expressaoReais	{ $$ = $1 - $2; }
;

listaMultInteiros: 		expressaoInteiros	{ $$ = $1; }
|			listaMultInteiros 	expressaoInteiros	{ $$ = $1 * $2; }
;

listaMultReais: 		expressaoReais	{ $$ = $1; }
|			listaMultReais 	expressaoReais	{ $$ = $1 * $2; }
;

listaDivInteiros: 		expressaoInteiros	{ $$ = $1; }
|			listaDivInteiros 	expressaoInteiros	{ $$ = $1 / $2; }
;

listaDivReais: 		expressaoReais	{ $$ = $1; }
|			listaDivReais 	expressaoReais	{ $$ = $1 / $2; }
;

listaString: 	STRING				{ strcpy($$, $1);}
|		listaString STRING              { strcpy($$,$1); strcat($$, $2);}
;



%%


int main( int argc, char *argv[] )
{
	if(inicializa_variaveis_iniciais()==1){
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
		   if(vars[index].tipo == 0){
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




int escreve_var(variavel v )
{
	int i;

	i = encontra_var( v.nome, 1 );
	if( i < 0 )
		{
		fprintf( stderr, "Nao foi possivel criar a variavel: %s\n", v.nome );
		exit( 1 );
		}
	if(v.tipo==0){
		vars[i].valor.real = v.valor.real;
		vars[i].tipo = v.tipo;
		return 1;
	} else {
		strcpy(vars[i].valor.boolean,v.valor.boolean);
		vars[i].tipo = v.tipo;
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


int inicializa_variaveis_iniciais()
{

	time_t now;
    	struct tm* tm;
    	now = time(0);
    	tm = localtime(&now);	
	int hour = tm->tm_hour;
	//printf("hora: %d \n", hour);
	variavel Hora, Minutos, Segundos, Dia, Mes, Ano;

	// Hora
	strcpy (Hora.nome,"hour");
	Hora.tipo= 0;
	Hora.valor.real = tm->tm_hour; 

	//Minutos
	strcpy (Minutos.nome,"minute");
        Minutos.tipo= 0;
        Minutos.valor.real = tm->tm_min;	
	
	//Segundos
	strcpy (Segundos.nome,"second");
        Segundos.tipo= 0;
        Segundos.valor.real = tm->tm_sec;
	
	//Dia
	strcpy (Dia.nome,"day");
        Dia.tipo= 0;
        Dia.valor.real = tm->tm_mday;	
	
	//Mes
	strcpy (Mes.nome,"month");
        Mes.tipo= 0;
        Mes.valor.real = tm->tm_mon;
	
	//Ano
	strcpy (Ano.nome,"year");
        Ano.tipo= 0;
        Ano.valor.real = tm->tm_year;

	if(escreve_var(Hora) 	 != 1) return -1;
	if(escreve_var(Minutos)  != 1) return -1;
	if(escreve_var(Segundos) != 1) return -1;
	if(escreve_var(Dia) 	 != 1) return -1;
	if(escreve_var(Mes) 	 != 1) return -1;
	if(escreve_var(Ano) 	 != 1) return -1;

return 1;
}
