%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <malloc.h>


#define MAXVARS 100
#define MAXNOME 33
#define MAXBOOL	4
#define MAXSTRING 513

int DEBUG = 0;
int varsGlobaisPreenchidas = 0;	

extern int yylex( void );
extern FILE *yyin;

typedef struct {
	char nome[MAXNOME];
	double real;
	char booleano [MAXBOOL];
	int tipo; /* 0 real, 1 booleano */
} var;

var arrayVarGlobais[MAXVARS];


/* prototipo funcoes*/
void limpaListaVariaveis (int globais);
int verificaTipo( double num );
void inicializaVariaveisIniciais();
void actualizaVariavel( char nome[MAXNOME], double real, char booleano[MAXBOOL], int tipo, int index );
void adicionaVariavel( char nome[MAXNOME], double real, char booleano[MAXBOOL], int tipo );
int verificaVariavel( const char *name );



int yyerror( char *s )
{
	fprintf( stderr, "Erro bison: %s\n", s );
	return 1;
}

%}

	
%union {
	double real;
	char string[513];   /* não aceitava o MAXSTRING....*/
}


%token <real> NUMERO
%token <string> STRING
%token <string> NOMEVAR
%token <string> NIL
%token <string> T

%token SOMA SUB	MUL	DIV
%token WHEN UNLESS IF
%token ZEROP
%token AND OR NOT
%token IGUAL MENOR MAIOR MENOR_IGUAL MAIOR_IGUAL DIFERENTE /* falta fazer o diferente  TODO*/
%token CONCATENATE
%token SETQ
%token LET
%token LP
%token RP

%type <real> expr_double lista_numeros_soma lista_numeros_sub lista_numeros_mul lista_numeros_div
%type <real> expr_condicional expr_then_else
%type <string> condicao expr_condicional_booleana expr_logica_booleana
%type <string> lista_logica_and lista_logica_or
%type <string> expr_str lista_string lista_logica_not
%type <string> expr_variavel


%%



input:		/* vazio */
|	input expressao
;



expressao:	expr_double				{ if( verificaTipo($1) ) printf("%f ", $1 ); else printf("%d", (int)$1); }

|	expr_condicional				{ if( verificaTipo($1) ) printf("%f ", $1 ); else printf("%d", (int)$1); }

|	expr_condicional_booleana		{ printf("%s ", $1 ); }

|	expr_str						{ printf("%s ", $1 ); }

|	expr_logica_booleana			{ printf("%s ", $1 ); }

|	expr_setq						/* não escreve nada, cria variavel*/

;




expr_setq: LP SETQ expr_variavel RP 	/* não escreve nada, cria variavel*/
;





expr_variavel: NOMEVAR expr_double		{ 	int i = verificaVariavel($1);
											if(i == -1) 
												adicionaVariavel($1, $2, NULL, 0); 
											else 
												actualizaVariavel($1, $2, NULL, 0, i); 
										}

|	expr_variavel NOMEVAR expr_double	{ 	int i = verificaVariavel($1);
											if(i == -1) 
												adicionaVariavel($2, $3, NULL, 0); 
											else 
												actualizaVariavel($2, $3, NULL, 0, i); 
										}

|	NOMEVAR T							{ 	int i = verificaVariavel($1);
											if(i == -1) 
												adicionaVariavel($1, 0, $2, 1); 
											else 
												actualizaVariavel($1, 0, $2, 1, i); 
										}

|	expr_variavel NOMEVAR T				{ 	int i = verificaVariavel($1);
											if(i == -1) 
												adicionaVariavel($2, 0, $3, 1); 
											else 
												actualizaVariavel($2, 0, $3, 1, i); 
										}



|	NOMEVAR NIL							{ 	int i = verificaVariavel($1);
											if(i == -1) 
												adicionaVariavel($1, 0, $2, 1); 
											else 
												actualizaVariavel($1, 0, $2, 1, i); 
										}

|	expr_variavel NOMEVAR NIL			{ 	int i = verificaVariavel($1);
											if(i == -1) 
												adicionaVariavel($2, 0, $3, 1); 
											else 
												actualizaVariavel($2, 0, $3, 1, i); 
										}
											
|	NOMEVAR condicao					{ 	int i = verificaVariavel($1);
											if(i == -1) 
												adicionaVariavel($1, 0, $2, 1); 
											else 
												actualizaVariavel($1, 0, $2, 1, i); 
										}
																	
|	expr_variavel NOMEVAR condicao		{ 	int i = verificaVariavel($1);
											if(i == -1) 
												adicionaVariavel($2, 0, $3, 1); 
											else 
												actualizaVariavel($2, 0, $3, 1, i); 
										}											
;


/*
expr_do: 	expr_double					{ if ( verificaTipo($1) ) sprintf($$, "%f", $1); else sprintf($$, "%d", (int)$1); }

|	expr_do expr_double					{ if ( verificaTipo($2) ) sprintf($$, "%f", $2); else sprintf($$, "%d", (int)$2); }

|	expr_condicional					{ if ( verificaTipo($1) ) sprintf($$, "%f", $1); else sprintf($$, "%d", (int)$1); }

|	expr_do expr_condicional			{ if ( verificaTipo($2) ) sprintf($$, "%f", $2); else sprintf($$, "%d", (int)$2); }

;
*/


expr_condicional:	LP IF condicao expr_then_else expr_then_else RP { if(strcmp($3, "t") == 0) $$ = $4; else $$ = $5; 	}
																	   
| LP WHEN condicao expr_then_else RP			{ if(strcmp($3, "t") == 0) {$$ = $4;} } /* TODO verificar se é necessário sprintf*/

| LP UNLESS condicao expr_then_else RP			{ if(strcmp($3, "nil") == 0) {$$ = $4;} }																   
;


expr_condicional_booleana: LP ZEROP expr_double RP { if($3 == 0) strcpy($$, "t"); else strcpy($$, "nil"); }
;


expr_logica_booleana: LP AND lista_logica_and RP 	{ strcpy($$, $3); }

|	LP OR lista_logica_or RP 						{ strcpy($$, $3); }

|	LP NOT lista_logica_not RP 						{ strcpy($$, $3); }

;



lista_logica_and: condicao				{ strcpy($$, $1); }

|	lista_logica_and	condicao		{ if( strcmp($1, "nil") == 0) strcpy($$, $1); else strcpy($$, $2); }

|	expr_logica_booleana				{ strcpy($$, $1); }

|	lista_logica_and expr_logica_booleana	{ if( strcmp($1, "nil") == 0) strcpy($$, $1); else strcpy($$, $2); }

|	expr_double							{ if ( verificaTipo($1) ) sprintf($$, "%f", $1); else sprintf($$, "%d", (int)$1); }

|	lista_logica_and expr_double		{ 	if( strcmp($1, "nil") == 0) 
													strcpy($$, $1); 
												else {
													if ( verificaTipo($2) ) 
														sprintf($$, "%f", $2); 
													else 
														sprintf($$, "%d", (int)$2);
												} 
										}

|	NIL									{ strcpy($$, "nil"); }

|	lista_logica_and NIL				{ if( strcmp($1, "nil") == 0) strcpy($$, $1); else strcpy($$, "nil"); }

|	T									{ strcpy($$, "t"); }

|	lista_logica_and T					{ if( strcmp($1, "nil") == 0) strcpy($$, $1); else strcpy($$, "t"); }

;



lista_logica_or: condicao				{ strcpy($$, $1); }

|	lista_logica_or	condicao			{ if( strcmp($1, "nil") != 0) strcpy($$, $1); else strcpy($$, $2); }

|	expr_logica_booleana				{ strcpy($$, $1); }

|	lista_logica_or expr_logica_booleana	{ if( strcmp($1, "nil") != 0) strcpy($$, $1); else strcpy($$, $2); }

|	expr_double							{ if ( verificaTipo($1) ) sprintf($$, "%f", $1); else sprintf($$, "%d", (int)$1); }

|	lista_logica_or expr_double 		{ 	if( strcmp($1, "nil") != 0) {
												strcpy($$, $1); 
											} else {	
												if ( verificaTipo($2) ) 
													sprintf($$, "%f", $2); 
												else 
													sprintf($$, "%d", (int)$2);
											} 
										}

|	NIL									{ strcpy($$, "nil"); }

|	lista_logica_or NIL					{ if( strcmp($1, "nil") != 0) strcpy($$, $1); else strcpy($$, "nil"); }

|	T									{ strcpy($$, "t"); }

|	lista_logica_or T					{ if( strcmp($1, "nil") != 0) strcpy($$, $1); else strcpy($$, "t"); }

;



lista_logica_not: condicao				{ if( strcmp($1, "t") == 0) strcpy($$, "nil"); else strcpy($$, "t"); }

|	expr_logica_booleana				{ if( strcmp($1, "t") == 0) strcpy($$, "nil"); else strcpy($$, "t"); }

;



condicao:	LP IGUAL expr_double expr_double RP 	{ if($3 == $4) strcpy($$, "t"); else strcpy($$, "nil"); }

|	LP MENOR expr_double expr_double RP 			{ if($3 < $4) strcpy($$, "t"); else strcpy($$, "nil"); }

|	LP MAIOR expr_double expr_double RP 			{ if($3 > $4) strcpy($$, "t"); else strcpy($$, "nil"); }

|	LP MENOR_IGUAL expr_double expr_double RP 		{ if($3 <= $4) strcpy($$, "t"); else strcpy($$, "nil"); }

|	LP MAIOR_IGUAL expr_double expr_double RP 		{ if($3 >= $4) strcpy($$, "t"); else strcpy($$, "nil"); }

|	LP IGUAL STRING STRING RP 						{ if(strcmp($3, $4) == 0) strcpy($$, "t"); else strcpy($$, "nil"); }

|	LP MENOR STRING STRING RP 						{ if(strcmp($3, $4) < 0) strcpy($$, "t"); else strcpy($$, "nil"); }

|	LP MAIOR STRING STRING RP 						{ if(strcmp($3, $4) > 0) strcpy($$, "t"); else strcpy($$, "nil"); }

|	LP MENOR_IGUAL STRING STRING RP 				{ if(strcmp($3, $4) <= 0) strcpy($$, "t"); else strcpy($$, "nil"); }

|	LP MAIOR_IGUAL STRING STRING RP 				{ if(strcmp($3, $4) >= 0) strcpy($$, "t"); else strcpy($$, "nil"); }

;



expr_then_else: expr_double				{ $$ = $1; }

|	expr_condicional					{ $$ = $1; }
;



expr_double:	NUMERO					{ $$ = $1; }

|	NOMEVAR								{ 		int i = verificaVariavel($1); 
												
												if ( i== -1 ) {
													printf("Variavel inexistente\n"); 
													exit(-1);
												}
												
												if( arrayVarGlobais[i].tipo == 0) 
													 $$ = arrayVarGlobais[i].real; 
												else {	
													printf("Erro: Esperado termo numérico, recebido booleano\n");
													exit(-1);
												}
										}
											
|	LP SOMA lista_numeros_soma  RP		{ $$ = $3; }

|	LP SUB lista_numeros_sub RP 		{ $$ = $3; }

|	LP MUL lista_numeros_mul RP 		{ $$ = $3; }

|	LP DIV lista_numeros_div RP			{ $$ = $3; }

;


lista_numeros_soma: 	expr_double		{ $$ = $1; }

|	lista_numeros_soma 	expr_double		{ $$ = $1 + $2; }

;



lista_numeros_sub: 		expr_double	{ $$ = $1; }

|	lista_numeros_sub 	expr_double	{ $$ = $1 - $2; }
;



lista_numeros_mul: 		expr_double	{ $$ = $1; }

|	lista_numeros_mul 	expr_double	{ $$ = $1 * $2; }
;



lista_numeros_div: 		expr_double	{ $$ = $1; }

|	lista_numeros_div 	expr_double	{ $$ = $1 / $2; }
;




expr_str: LP CONCATENATE lista_string RP	{ strcpy($$, $3); }
;


lista_string: 	STRING				{ strcpy($$, $1);}

|	lista_string STRING	 			{ strcpy($$, $1); strcat($$, $2);}

|	NOMEVAR							{ 	int i = verificaVariavel($1);

										if ( i ==-1 ) {		/* se a var não existe*/
											printf("Variavel inexistente\n"); 
											exit(-1);
										}

										if(arrayVarGlobais[i].tipo == 0) 	/*numero*/
											sprintf($$, "%f", arrayVarGlobais[i].real); 
										else								/*booleano*/	
											sprintf($$, "%s", arrayVarGlobais[i].booleano);

									}
									  
								
|	lista_string NOMEVAR			{ 	int i = verificaVariavel($2);

										if ( i ==-1 ) {		/* se a var não existe*/
											printf("Variavel inexistente\n"); 
											exit(-1);
										}

										if(arrayVarGlobais[i].tipo == 0) 	/*numero*/
											sprintf($$, "%f", arrayVarGlobais[i].real); 
										else								/*booleano*/	
											sprintf($$, "%s", arrayVarGlobais[i].booleano);

									}
									  
;



%%


int main( int argc, char *argv[] )
{
	inicializaVariaveisIniciais();
	
	if (argc == 2) {
		yyin = fopen(argv[1], "r");
		yyparse();
	}
	else
		printf("ERRO: Faltam argumentos,  Uso: ./MiniLisp <inputFile>\n");
		
	fclose(yyin);
	return -1;
}


/**/
int verificaVariavel( const char *name ){
	int i;
	if (varsGlobaisPreenchidas >= MAXVARS)
		exit (-1);		/* se já não existir memória livre, sai do programa*/
		
	for(i=0; i<varsGlobaisPreenchidas; i++) {
		if (strncasecmp(arrayVarGlobais[i].nome, name, sizeof(name)) == 0)
			return i;	/* se a variavel existe*/
	}
	return (-1); 	/* se ainda não existe */
}


/* adiciona variavel

recebe
	nome 	nome da variavel
	real 	valor real
	booleano valor booleano
	tipo	0 para real, 1 para booleano	
*/
void adicionaVariavel( char nome[MAXNOME], double real, char booleano[MAXBOOL], int tipo ) {
	strcpy(arrayVarGlobais[varsGlobaisPreenchidas].nome, nome);

	if( tipo )	/*booleano*/
		strcpy(arrayVarGlobais[varsGlobaisPreenchidas].booleano, booleano);
	else 		/*real*/
		arrayVarGlobais[varsGlobaisPreenchidas].real = real;
		
	arrayVarGlobais[varsGlobaisPreenchidas].tipo = tipo;
	
	varsGlobaisPreenchidas++;	
}


/* actualiza variavel

recebe
	nome 	nome da variavel
	real 	valor real
	booleano valor booleano
	tipo	0 para real, 1 para booleano	
	index 	onde vamos gravar
*/
void actualizaVariavel( char nome[MAXNOME], double real, char booleano[MAXBOOL], int tipo, int index ) {
	strcpy(arrayVarGlobais[index].nome, nome);

	if( tipo )	/*booleano*/
		strcpy(arrayVarGlobais[index].booleano, booleano);
	else 		/*real*/
		arrayVarGlobais[index].real = real;
		
	arrayVarGlobais[index].tipo = tipo;	
}



void inicializaVariaveisIniciais() {

	/* obtém hora do sistema*/
	time_t now;
	struct tm* tm;
	now = time(0);
	tm = localtime(&now);
	
	/* limpa a lista das variaveis globais*/
	limpaListaVariaveis(1);
	
	/* adiciona as variáveis iniciais*/
	adicionaVariavel("year", 1900 + tm->tm_year, NULL, 0);
	adicionaVariavel("month", 1 + tm->tm_mon, NULL, 0);
	adicionaVariavel("day", tm->tm_mday, NULL, 0);
	adicionaVariavel("hour", tm->tm_hour, NULL, 0);
	adicionaVariavel("minute", tm->tm_min, NULL, 0);
	adicionaVariavel("second", tm->tm_sec, NULL, 0);
	
	return;
}



/* verifica tipo

devolve
	0 se for um numero inteiro
	1 se for um numero real

 */
int verificaTipo( double num ){
	/* converter o double para string*/
	char numString[MAXVARS]; 
	sprintf(numString, "%f", num);

	int i;
	for ( i=0; i<MAXVARS; i++) {
		if (numString[i]=='\0')
			return 0;	/* chegou ao fim da string sem encontrar '.'*/	
			
		if (numString[i]=='.')
			return 1;	/* é um numero double */	
	}	
	return 0;
}




void limpaListaVariaveis (int globais){
		int i;
		
		if (globais==1){	/* limpa a lista das variaveis globais */	
			for(i=0;i<MAXVARS;i++){
				arrayVarGlobais[i].nome[0] = '\0';
				arrayVarGlobais[i].tipo = 0;
				arrayVarGlobais[i].real = 0;
				
			}
			if (DEBUG) printf("Lista das variaveis globais limpa");
		}
		
		return;
}



