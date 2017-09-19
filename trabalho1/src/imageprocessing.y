%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "imageprocessing.h"
#include <FreeImage.h>

void yyerror(char *c);
int yylex(void);

%}
%union {
  char    strval[50];
  char    *str;
  int     ival;
  float   fval;
}
%token <strval> STRING 
%token <str> IGUAL OPERADOR ESCALAR OPEN CLOSE
%token <ival> VAR EOL ASPA
%left SOMA

%%

PROGRAMA:
        PROGRAMA EXPRESSAO EOL
        |
        ;

EXPRESSAO:
    | STRING IGUAL STRING {
        printf("Copiando %s para %s\n", $<strval>3, $<strval>1);
        imagem I = abrir_imagem($<strval>3);
        printf("Li imagem %d por %d\n", I.width, I.height);
	int x1 = I.width;
	int y2 = I.height;

        salvar_imagem($<strval>1, &I);
      }
    | STRING IGUAL STRING OPERADOR ESCALAR {
	printf("Alterando o brilho da imagem %s por %s %s\n", $<strval>3, $<str>4, $<str>5);
	imagem I = abrir_imagem($<strval>3);

	int tam = strlen($<str>5), k1 = 0, k2 = 0, k3 = 0, flag = 0;
	float sum = 0, var = 0, esc = 0;
	
	//Função que retorna o número de dígitos antes e após o ponto
	for(int k=0;k<tam;k++){
		if($<str>5[k] == '.'){
			k1 = k;
			k2 = tam-k-1;	
			flag = 1;
		}
	}

	if(flag == 1){
	        //Função que reconhece o número antes do ponto
		for(int k=0;k<=(k1-1);k++){
			var = (float)($<str>5[k]-'0');
			for(int i=0;i<(k1-1-k);i++){
				var = var*10;
			}
			sum = sum+var;	
		}
	
	        //Função que reconhece o número após do ponto
		for(int k=k2-1;k>=0;k--){
			var = (float)($<str>5[k1+1+k]-'0');
			
			for(int i=k ;i>=0;i--){
				var = var*0.1;
			}
	
			sum = sum+var;
		}
		esc = sum;	//Escalar que altera o brilho da imagem
		printf("O escalar é %f\n", esc);
	}

	if(flag == 0){
		k3 = strlen($<str>5);
		sum = 0;

		for(int k=0;k<=(k3-1);k++){
			var = (float)($<str>5[k]-'0');
			for(int i=0;i<(k1-1-k);i++){
				var = var*10;
			}
			sum = sum+var;	
		}
		esc = sum;
		printf("O escalar é %f\n", esc);
	}	

	int x1 = I.width;
	int x2 = I.height;
	
	if($<str>4[0] == '*'){
		for(int k1=0; k1<x1; k1++){
			for(int k2=0; k2<x2;k2++){
				int idx;

				idx = k1 + (k2*x1);

			        I.r[idx] = I.r[idx]*esc;
      				I.g[idx] = I.g[idx]*esc;
				I.b[idx] = I.b[idx]*esc;
				
			}	
        	}
	}

	if($<str>4[0] == '/'){
		for(int k1=0; k1<x1; k1++){
			for(int k2=0; k2<x2;k2++){
				int idx;
	
				idx = k1 + (k2*x1);

			        I.r[idx] = I.r[idx]/esc;
      				I.g[idx] = I.g[idx]/esc;
				I.b[idx] = I.b[idx]/esc;
			}	
        	}
	}

	salvar_imagem($1, &I);
      }
      | OPEN STRING CLOSE{
	printf("Encontrei a expressao desejada! %s %s %s\n", $<str>1, $<strval>2,$<str>3);
	imagem I = abrir_imagem($<strval>2);

	int x1 = I.width;
	int x2 = I.height;
	int i = 0 ;
	float var = 0, aux = 0, max = 0;
	float maximos [x1];

	for(int k1 = 0; k1<x1; k1++){
		int id;

		id = k1 + (0*x1);
		var = I.r[id]+I.g[id]+I.b[id];
		
		for(int k2=1; k2<x2-1;k2++){
			int idx;

			idx = k1 + (k2*x1);

			aux = I.r[idx]+I.g[idx]+I.b[idx];
			if(aux > var){
				var = aux;
			}
		}

		id = k1 + ((x2-1)*x1);
		aux = I.r[id]+I.g[id]+I.b[id];

		if(aux > var){
			var = aux;
		}
		
		maximos[k1] = var;
		
	//	printf("%f\n", maximos[k1]);
        }

	max = maximos[0];
	for(int k1=1;k1<x1-1;k1++){
		if(maximos[k1+1] > max){
			max = maximos[k1+1];
		}			
	}

	printf("O brilho máximo é %f", max);  
    }
%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main() {
  FreeImage_Initialise(0);
  yyparse();
  return 0;

}
