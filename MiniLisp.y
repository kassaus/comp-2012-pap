%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <malloc.h>


#define MAXVARS 100

int DEBUG = 1;
int varsGlobaisPreenchidas = 0;	

void inicializaVariaveisIniciais();
char * leBooleanVariavel(char *nome);
double leValorVariavel(char *nome);
void gravaVariavel(char *nome, double valor, char * booleano, int tipo);
int procuraVariavel(char *nome);
void inicializaVariaveisIniciais();
void limpaListaVariaveis (int globais);







/*TODO... PROVAVELMENTE APAGAR*/
/* ver e altrerar se necessário */
void ShowCurrentVars();
/* char* itoa_simple(int n); */
char* ftoa_simple(double n);





struct s_vars {
	char nome[32+1];
	int tipo;			/* 0 para booleano, 1 para numero */
	double valor;		/* valor para numero, 0 para boolean nil, 1 para boolean t */
} vars[MAXVARS];



/* A funcao yyparse() gerada pelo bison vai automaticamente chamar a funcao
   yylex() do flex.
   A funcao yyparse() esta' definida no ficheiro ".tab.c" gerada por este
   ficheiro ".y" e a yylex() no ficheiro "lex.yy.c" gerada pelo ficheiro ".l".

   Como ambos os ficheiros sao compilados de forma independente para so'
   depois serem ligados (linked), o ficheiro ".y" precisa de ter definida a
   funcao yylex() para nao dar erro de compilacao.
   Infelizmente precisamos que o bison corra antes do flex (para gerar o
   ficheiro ".tab.h" com os %tokens e algumas outras definicoes). Entao
   declaramos essa funcao do flex como sendo "definida noutro ficheiro fonte",
   ou seja, "externa":
*/
extern int yylex( void );


int yyerror( char *s )
{
	fprintf( stderr, "Erro bison: %s\n", s );
	return 1;
}

%}

%union	{
		double		valor_double;
		char 		valor_boolean[3+1];
		char *		valor_string; 
		char 		nome_variavel[512+1];  /* se calhar não necessário, rever TODO */
}		




%token <valor_double> NUMERO
%token <valor_string> STRING
%token <nome_variavel> NOMEVAR

%token '+' '-' '*' '/' '>' '<' '='
%token LP RP
%token MAIOR_IGUAL MENOR_IGUAL DIFERENTE
%token NOT OR AND ZEROP
%token IF WHEN UNLESS
%token SETQ LET
%token NIL T
%token CONCATENATE

%type <valor_double> expr_double lista_numeros 
%type <valor_boolean> expr_booleana
%type <valor_string> expr_str expr_condicional expr_atribuicao expr_concatenate expressao




%%


/***************** terminado*/
input:	/* vazio */		{	if (DEBUG) puts("Bison consumiu: input de (vazio)\n"); }
|	input expressao		{	if (DEBUG) printf("Bison consumiu: input de input expressao\n"); }


;



/* em andamento */
expressao: 	 expr_atribuicao 	{										if (DEBUG) printf("Bison consumiu: expressao de var declaration: %s\n", $1 ); }
|	 expr_double 	{ printf("%f", $1);						if (DEBUG) printf("Bison consumiu: expressao de %f ;\n", $1 ); }
|	 expr_condicional 		{ printf("%s", $1);						if (DEBUG) printf("Bison consumiu: expressao de condition result: %s\n", $1 ); }
|	 expr_concatenate  			{ printf("%s", $1);						if (DEBUG) printf("Bison consumiu: expressao de \"%s\" ;\n", $1 ); }




;


/********  já não deve servir, apagar depois
expr_num:	NUMERO			{ $$ = $1;						if (DEBUG) printf("Bison consumiu: expr_num de %f\n", $$);  }
|	'+' expr_num			{ $$ = $2;						if (DEBUG) printf("Bison consumiu: expr_num (+)de %f\n", $$); }
|	'-' expr_num			{ $$ = -$2;						if (DEBUG) printf("Bison consumiu: expr_num (-)de %f\n", $$); }
|	NOMEVAR					{ $$ = leValorVariavel($1);			if (DEBUG) printf("Bison consumiu: expr_num (nome_variavel) de %f\n", $$);  }
;
************/


/***************** terminado*/
expr_double:	NUMERO			{ $$ = $1;						if (DEBUG) printf("Bison consumiu: expr_double de %f\n", $1);  }
|	NOMEVAR						{ $$ = leValorVariavel($1);		if (DEBUG) printf("Bison consumiu: expr_double de %f\n", $$);  }
|	LP '+' lista_numeros RP 	{ $$ = $3;						if (DEBUG) printf("Bison consumiu: lista_numeros de %f\n", $3); }
|	LP '-' lista_numeros RP 	{ $$ = $3;						if (DEBUG) printf("Bison consumiu: lista_numeros de %f\n", $3); }
|	LP '*' lista_numeros RP 	{ $$ = $3;						if (DEBUG) printf("Bison consumiu: lista_numeros de %f\n", $3); }
|	LP '/' lista_numeros RP 	{ $$ = $3;						if (DEBUG) printf("Bison consumiu: lista_numeros de %f\n", $3); }
;

/***************** terminado*/
lista_numeros: 	expr_double		{ $$ = $1;			if (DEBUG) printf("Bison consumiu: expr_double de %f\n", $1);  }
|	lista_numeros expr_double	{ $$ = $1 + $2;		if (DEBUG) printf("Bison consumiu: lista numeros %f e expr_double de %f\n", $1, $2 );  }
;


/***********terminada*/
expr_concatenate: LP CONCATENATE expr_str RP	{ strcpy($$, $3); if (DEBUG) printf("Bison consumiu: expr_concatenate de %s\n", $3); }
;

/***********terminada*/
expr_str:	STRING	{ strcpy($$, $1);			if (DEBUG) printf("Bison consumiu: expr_str de %s\n", $1); }
|	expr_str STRING	{ strcpy($$, $1); strcat($$, $2);			if (DEBUG) printf("Bison consumiu: expr_str de %s e de %s\n", $1, $2); }

;



/***************** terminado*/
expr_atribuicao:	LP SETQ NOMEVAR expr_double RP	{ strcpy($$, $3); gravaVariavel($3, $4, "\0", 1);		if (DEBUG) ; }
|	LP SETQ NOMEVAR expr_booleana RP	{ strcpy($$, $3); gravaVariavel($3, 0, $4, 0);					if (DEBUG) ; }			



	/******TODO*********/
|	LP LET NOMEVAR expr_double	 RP	{ strcpy($$, $3); 				if (DEBUG) ; }
|	LP LET NOMEVAR expr_booleana RP	{ strcpy($$, $3); 				if (DEBUG) ; }

;





expr_condicional:	LP IF expr_booleana expressao expressao RP	{ if(strcmp($3, "t")==0) $$ = $4; else $$ = $5; if (DEBUG) printf("Bison consumiu: expr_condicional if, %s\n", $3); }

|	LP WHEN expr_booleana expressao  RP	{ if(strcmp($3, "t")==0) $$ = $4;  if (DEBUG) printf("Bison consumiu: expr_condicional when, %s\n", $3); }

|	LP UNLESS expr_booleana expressao  RP	{ if(strcmp($3, "nil")==0) $$ = $4;  if (DEBUG) printf("Bison consumiu: expr_condicional unless, %s\n", $3); }

;

/* mudar alguma coisa, o expr double da primeira linha*/
expr_booleana:	T	{ strcpy($$, "t");				if (DEBUG) printf("Bison consumiu: expr_booleana %s\n", $$); }
| 	NIL				{ strcpy($$, "nil");							if (DEBUG) printf("Bison consumiu: expr_booleana %s\n", $$); }
|	LP T RP			{ strcpy($$, "t");						if (DEBUG) printf("Bison consumiu: expr_booleana %s\n", $$); }
| 	LP NIL RP		{ strcpy($$, "nil");							if (DEBUG) printf("Bison consumiu: expr_booleana %s\n", $$); }
|	NUMERO			{ if ($1) strcpy($$, "t"); else strcpy($$, "nil ");	if (DEBUG) printf("Bison consumiu numero como booleano %s\n", $$); }
|	NOMEVAR			{ if ( strcmp( leBooleanVariavel($1), "t")  ) strcpy($$, "t"); else strcpy($$, "nil ");	if (DEBUG) printf("Bison consumiu variavel como booleano %s\n", $$); }
|	LP NUMERO RP			{ if ($2) strcpy($$, "t"); else strcpy($$, "nil ");	if (DEBUG) printf("Bison consumiu numero como booleano %s\n", $$); }
|	LP NOMEVAR RP			{ if ( strcmp( leBooleanVariavel($2), "t")  ) strcpy($$, "t"); else strcpy($$, "nil ");	if (DEBUG) printf("Bison consumiu variavel como booleano %s\n", $$); }



|	LP '>' expr_double expr_double RP		{ if($3 > $4) strcpy($$, "t"); else strcpy($$, "nil"); if (DEBUG) printf("Bison consumiu: expr_booleana > %s\n", $$); }
|	LP '<' expr_double expr_double RP		{ if($3 < $4) strcpy($$, "t"); else strcpy($$, "nil"); if (DEBUG) printf("Bison consumiu: expr_booleana < %s\n", $$); }
|	LP '=' expr_double expr_double RP		{ if($3 == $4) strcpy($$, "t"); else strcpy($$, "nil"); if (DEBUG) printf("Bison consumiu: expr_booleana = %s\n", $$); }
|	LP MAIOR_IGUAL expr_double expr_double RP	{ if($3 >= $4) strcpy($$, "t"); else strcpy($$, "nil"); if (DEBUG) printf("Bison consumiu: expr_booleana <= %s\n", $$); }
|	LP MENOR_IGUAL expr_double expr_double RP	{ if($3 <= $4) strcpy($$, "t"); else strcpy($$, "nil"); if (DEBUG) printf("Bison consumiu: expr_booleana <= %s\n", $$); }
|	LP DIFERENTE expr_double expr_double RP		{ if($3 != $4) strcpy($$, "t"); else strcpy($$, "nil"); if (DEBUG) printf("Bison consumiu: expr_booleana /= %s\n", $$); }

|	LP AND expr_booleana expr_booleana RP		{ if ( (strcmp($3, "t")==0) && (strcmp($4,"t")==0) ) strcpy($$, "t"); else strcpy($$, "nil"); if (DEBUG) printf("Bison consumiu: expr_booleana and %s\n", $$); }

|	LP OR expr_booleana expr_booleana RP		{ if ( (strcmp($3, "t")==0) || (strcmp($4,"t")==0) ) strcpy($$, "t"); else strcpy($$, "nil"); if (DEBUG) printf("Bison consumiu: expr_booleana or %s\n", $$); }

|	LP ZEROP expr_double RP 					{ if ($3==0) strcpy($$, "t"); else strcpy($$, "nil"); if (DEBUG) printf("Bison consumiu: expr_booleana zerop %s\n", $$); }

;


/* acho que não serve para nada TODO apagar
cond_res:	expr_double				{ strcpy($$, ftoa_simple($1)); 		if (DEBUG) printf("Bison consumiu: cond_res de \"%s\"\n", $$); }
|			expr_condicional					{ strcpy($$, $1);					if (DEBUG) printf("Bison consumiu: cond_res de \"%s\"\n", $1); }
;
*/




%%

int main( void ){

	inicializaVariaveisIniciais();

	if (DEBUG) ShowCurrentVars();
	
	return yyparse();
}


void limpaListaVariaveis (int globais){
		int i;
		
		if (globais==1){	/* limpa a lista das variaveis globais */
		
			for(i=0;i<100;i++){
				vars[i].nome[0] = '\0';
				vars[i].tipo = 0;
				vars[i].valor = 0;
			}
			if (DEBUG) printf("Lista das variaveis globais limpa");
		}
}


void inicializaVariaveisIniciais() {

	/* obtém hora do sistema*/
	time_t sec = time(&sec);
	struct tm t = *localtime(&sec);
	
	/* limpa a lista das variaveis globais*/
	limpaListaVariaveis(1);
	
	/* adiciona as variáveis iniciais*/
	gravaVariavel("year", 1900 + t.tm_year, "\0", 1);
	gravaVariavel("month", 1 + t.tm_mon, "\0", 1);
	gravaVariavel("day", t.tm_mday, "\0", 1);
	gravaVariavel("hour", t.tm_hour, "\0", 1);
	gravaVariavel("minute", t.tm_min, "\0", 1);
	gravaVariavel("second", t.tm_sec, "\0", 1);
}


/*
procura variavel e retorna o index onde existe, senão -1
*/
int procuraVariavel(char *nome){
		int i;
		for(i=0;i<100;i++){
			if (stricmp(vars[i].nome, nome) == 0){	/*comparacao case insensitive*/
				return i;
				if (DEBUG) printf("Variavel %s encontrada na posicao %d\n", nome, i);
			}
		}
		return -1;
		if (DEBUG) printf("Variavel %s nao encontrada\n", nome);
}



/* Função que adiciona ou actualiza uma variável à pilha de variáveis */
void gravaVariavel(char *nome, double valor, char * booleano, int tipo) {
	int i;

	if (varsGlobaisPreenchidas >= MAXVARS){
		printf("Erro: Não é possível alocar mais memória\n");
		exit (-1);
		
	} else {
		i = procuraVariavel(nome);
		
		if (i==-1){	/*ainda não existe*/
			i=varsGlobaisPreenchidas;
			varsGlobaisPreenchidas++;	
			if (DEBUG) printf("Variavel vai ser adicionada, nome %s\n", nome);
		} 
					
		/* já existe */
		strcpy(vars[i].nome, nome);
		vars[i].tipo = tipo;
		
		if (tipo)	{	/*numero*/
			vars[i].valor = valor;
			
		} else	{		/*boolean*/
			if (stricmp(booleano, "t")) 
				vars[i].valor = 1;
			else 
				vars[i].valor = 0;
		}	
	
		if (DEBUG) printf("Variavel actualizada, nome %s, valor %f, tipo %d, index %d\n", nome, valor, tipo, i);
		
	}	
}






/* 
devolve o valor da variável apenas se for um numero
em caso de ser boolean, dá erro pois há um conflito de tipos em comparações
*/
double leValorVariavel(char *nome) {
	int i;
	i = procuraVariavel(nome);
	
	if (i==-1)	{	/* não existe */
		printf("Erro: Variavel não existe, nome %s\n", nome);
		exit (-2);
		
	} else {		/* tipo errado */
		if (vars[i].tipo == 0) {
			printf("Erro: Conflito de tipos, nome %s\n", nome);
			exit (-3);	
		} else {	
			return vars[i].valor;
		}
	}
}


/* 
devolve o valor da variáviel apenas se for um booleano
em caso de ser numero, dá erro pois há um conflito de tipos em comparações
*/
char * leBooleanVariavel(char *nome) {
	int i;
	
	i = procuraVariavel(nome);
	
	if (i==-1)	{	/* não existe */
		printf("Erro: Variavel não existe, nome %s\n", nome);
		exit (-2);
		
	} else {		/* tipo errado */
		if (vars[i].tipo == 1) {
			printf("Erro: Conflito de tipos, nome %s\n", nome);
			exit (-3);	
		} else {
			if (vars[i].valor==0){
				return "nil";
				if (DEBUG) printf("Vai ser retornado o valor nil à variável %s\n", nome );			
			} else {
				return "t";
				if (DEBUG) printf("Vai ser retornado o valor nil à variável %s\n", nome );	
			}
				

		}
	}
}





/* função simplificada da função C itoa (integer to array of char) 
char* itoa_simple(int n)
{
	char strNum[1023+1];
	
	_itoa(n, strNum, 10);
	return strNum;
}
*/

/* forma simplificada de converter um double num char* */
char* ftoa_simple(double n){
	char strNum[1023+1];

	sprintf(strNum, "%f", n);
	return strNum;
}




void ShowCurrentVars(){
	int i;

	printf("Conteudo actual da lista de variavies\n");

	for(i=0;i<100;i++)
		if (vars[i].nome[0] == '\0')
			break;
		else
			printf("%s:\t\t%f\n", vars[i].nome, vars[i].valor);
}