#include <stdio.h>
#include <stdlib.h>
#include "header.h"

extern int yyparse();
extern FILE *yyin;

struct Header buffer[20000];
int nodeCount = 0;

void generateStructuredCode() {
    printf("#include <stdio.h>\n\n");
    printf("int main() {\n");
    
    if (nodeCount == 0) {
        printf("    return 0;\n}\n");
        return;
    }

    if (buffer[0].type == blockN) {
        printf("%s\n", buffer[0].data);
    }

    long startState = -1;
    if (buffer[0].ifTrue != NULL) {
        startState = buffer[0].ifTrue - buffer;
    }

    printf("\n    int _state = %ld;\n", startState);
    printf("    while (_state != -1) {\n");
    printf("        switch (_state) {\n");

    for (int i = 1; i < nodeCount; i++) {
        printf("\n            case %d:\n", i);
        
        if (buffer[i].type == blockN) {
            printf("                {\n%s\n                }\n", buffer[i].data);
            
            if (buffer[i].ifTrue != NULL) {
                printf("                _state = %ld;\n", buffer[i].ifTrue - buffer);
            } else {
                printf("                _state = -1;\n");
            }
            printf("                break;\n");
            
        } else if (buffer[i].type == decisionN) {
            printf("                if (%s) {\n", buffer[i].data);
            if (buffer[i].ifTrue != NULL) {
                printf("                    _state = %ld;\n", buffer[i].ifTrue - buffer);
            } else {
                printf("                    _state = -1;\n");
            }
            printf("                } else {\n");
            if (buffer[i].ifFalse != NULL) {
                printf("                    _state = %ld;\n", buffer[i].ifFalse - buffer);
            } else {
                printf("                    _state = -1;\n");
            }
            printf("                }\n");
            printf("                break;\n");
            
        } else if (buffer[i].type == uncondjN) {
            if (buffer[i].ifTrue != NULL) {
                printf("                _state = %ld;\n", buffer[i].ifTrue - buffer);
            } else {
                printf("                _state = -1;\n");
            }
            printf("                break;\n");
        }
    }

    printf("\n            default:\n");
    printf("                _state = -1;\n");
    printf("                break;\n");
    printf("        }\n");
    printf("    }\n\n");
    
    printf("    return 0;\n");
    printf("}\n");
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) {
            perror("Error opening file");
            return 1;
        }
        yyin = fp;
    }

    if (yyparse() == 0) {
        linkGraph();
        generateStructuredCode();
    } else {
        fprintf(stderr, "Parsing failed.\n");
        return 1;
    }

    return 0;
}