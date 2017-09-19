
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void yyerror(char *);

#include "y.tab.h"
%}



%%

([0-9]+[.][0-9]+) {
	  yylval.str = strdup(yytext);
	  return ESCALAR;
	}

[0-9]+  {
	  yylval.str = strdup(yytext);
	  return ESCALAR;
	}

\[	{
	  yylval.str = strdup(yytext);
	  return OPEN;	
	}

\]	{
	  yylval.str = strdup(yytext);
	  return CLOSE;	
	}

[a-z]  {
        yylval.ival = yytext[0] - 'a';
        return VAR;
       }


\" { return ASPA; }

[a-zA-Z0-9\.]+  {
        for (int i = 0; i < yyleng; i++ )
          yylval.strval[i] = yytext[i];

        yylval.strval[yyleng] = '\0';
        printf ("Achei nome: %s\n", yylval.strval);
        return STRING;
       }

[=]     {
          return IGUAL;
        }

[*/]     {
	  yylval.str = strdup(yytext);
          return OPERADOR;
        }


\n	{
         return EOL;
  	}

[ \t]+ ;

.     {printf("**%s**\n", yytext);
yyerror("Token nao reconhecido!\n");}

%%

int  yywrap() {
  return 1;
}
