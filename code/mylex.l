%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "header.h"
#include "y.tab.h"

char code_buf[10000];
int inside_block = 0;
%}

%option noyywrap
%option nounput
%option noinput

%x IN_C_CODE
%x IN_IF_COND

%%

[ \t\r\n]+              ; /* Ignore whitespace */
"//".*                  ; /* Ignore comments */

"SYSTEM"                { return SYSTEM; }
"PROCESS"               { return PROCESS; }
"PROCESSDEF"            { return PROCESSDEF; }
"DECISION"              { return DECISION; }
"UNCONDDEC"             { return UNCONDDEC; }
"ELSE"                  { return ELSE; }
"GOTO"                  { return GOTO; }
"END"                   { return END; }
"THEN"                  { return THEN; }

"BLOCK"                 { 
                            inside_block = 1; 
                            return BLOCK; 
                        }

"START"                 {
                            if (inside_block) {
                                inside_block = 0;
                                code_buf[0] = '\0';
                                BEGIN(IN_C_CODE);
                            }
                            return START;
                        }

"IF"                    {
                            code_buf[0] = '\0';
                            BEGIN(IN_IF_COND);
                            return IF;
                        }

";"                     { return SEMICOLON; }
","                     { return COMMA; }

[a-zA-Z_][a-zA-Z0-9_]*  {
                            yylval.sval = strdup(yytext);
                            return IDENTIFIER;
                        }

<IN_C_CODE>"END"        {
                            BEGIN(INITIAL);
                            yylval.sval = strdup(code_buf);
                            /* Put 'END' back into the input stream so Yacc can match it */
                            yyless(0);
                            return C_CODE;
                        }

<IN_C_CODE>.|\n         {
                            strcat(code_buf, yytext);
                        }

<IN_IF_COND>"THEN"      {
                            BEGIN(INITIAL);
                            yylval.sval = strdup(code_buf);
                            yyless(0);
                            return COND_EXPR;
                        }

<IN_IF_COND>.|\n        {
                            strcat(code_buf, yytext);
                        }

.                       { return yytext[0]; }

%%