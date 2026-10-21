%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "header.h"

int yylex();
void yyerror(const char *s);

int findNode(const char *name) {
    for (int i = 0; i < nodeCount; i++) {
        if (strcmp(buffer[i].id, name) == 0) return i;
    }
    return -1;
}
%}

%union {
    char *sval;
}

%token SYSTEM PROCESS PROCESSDEF BLOCK START END DECISION IF THEN ELSE GOTO UNCONDDEC
%token SEMICOLON COMMA
%token <sval> IDENTIFIER C_CODE COND_EXPR

%start program

%%

program:
    SYSTEM IDENTIFIER SEMICOLON process_list process_defs
    ;

process_list:
    PROCESS id_list SEMICOLON
    ;

id_list:
    IDENTIFIER
    | id_list COMMA IDENTIFIER
    ;

process_defs:
    process_def
    | process_defs process_def
    ;

process_def:
    PROCESSDEF IDENTIFIER START construct_list END
    ;

construct_list:
    construct
    | construct_list construct
    ;

construct:
    block_construct
    | decision_construct
    | uncond_construct
    ;

optional_semicolon:
    SEMICOLON
    | /* empty */
    ;

block_construct:
    BLOCK IDENTIFIER START C_CODE END GOTO IDENTIFIER optional_semicolon
    {
        buffer[nodeCount].type = blockN;
        strcpy(buffer[nodeCount].id, $2);
        strcpy(buffer[nodeCount].data, $4);
        buffer[nodeCount].ifTrue = (struct Header*)strdup($7);
        buffer[nodeCount].ifFalse = NULL;
        nodeCount++;
    }
    | BLOCK IDENTIFIER START C_CODE END
    {
        buffer[nodeCount].type = blockN;
        strcpy(buffer[nodeCount].id, $2);
        strcpy(buffer[nodeCount].data, $4);
        buffer[nodeCount].ifTrue = NULL;
        buffer[nodeCount].ifFalse = NULL;
        nodeCount++;
    }
    ;

decision_construct:
    DECISION IDENTIFIER IF COND_EXPR THEN GOTO IDENTIFIER optional_semicolon ELSE GOTO IDENTIFIER optional_semicolon
    {
        buffer[nodeCount].type = decisionN;
        strcpy(buffer[nodeCount].id, $2);
        strcpy(buffer[nodeCount].data, $4);
        buffer[nodeCount].ifTrue = (struct Header*)strdup($7);
        buffer[nodeCount].ifFalse = (struct Header*)strdup($11);
        nodeCount++;
    }
    | DECISION IDENTIFIER IF COND_EXPR THEN GOTO IDENTIFIER optional_semicolon
    {
        buffer[nodeCount].type = decisionN;
        strcpy(buffer[nodeCount].id, $2);
        strcpy(buffer[nodeCount].data, $4);
        buffer[nodeCount].ifTrue = (struct Header*)strdup($7);
        buffer[nodeCount].ifFalse = NULL;
        nodeCount++;
    }
    ;

uncond_construct:
    UNCONDDEC IDENTIFIER GOTO IDENTIFIER optional_semicolon
    {
        buffer[nodeCount].type = uncondjN;
        strcpy(buffer[nodeCount].id, $2);
        buffer[nodeCount].data[0] = '\0';
        buffer[nodeCount].ifTrue = (struct Header*)strdup($4);
        buffer[nodeCount].ifFalse = NULL;
        nodeCount++;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parser Error: %s\n", s);
}

void linkGraph() {
    for (int i = 0; i < nodeCount; i++) {
        if (buffer[i].type == blockN && buffer[i].ifTrue == NULL && (i + 1) < nodeCount) {
            buffer[i].ifTrue = &buffer[i + 1];
        } else if (buffer[i].ifTrue != NULL) {
            char *target = (char *)buffer[i].ifTrue;
            int idx = findNode(target);
            if (idx == -1) {
                fprintf(stderr, "Semantic Error: Block identifier '%s' not defined in process scope!\n", target);
            } else {
                buffer[i].ifTrue = &buffer[idx];
            }
            free(target);
        }

        if (buffer[i].ifFalse != NULL) {
            char *target = (char *)buffer[i].ifFalse;
            int idx = findNode(target);
            if (idx == -1) {
                fprintf(stderr, "Semantic Error: Block identifier '%s' not defined in process scope!\n", target);
            } else {
                buffer[i].ifFalse = &buffer[idx];
            }
            free(target);
        }
    }
}