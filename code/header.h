#ifndef HEADER_H
#define HEADER_H

#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>

typedef enum {
    blockN,
    decisionN,
    uncondjN
} Type;

struct Header{
    Type type; 
    char id[100];
    char data[10000];
    struct Header* ifTrue;
    struct Header* ifFalse;
};

extern struct Header buffer[20000];
extern int nodeCount;

void linkGraph(void);
void generateCode(void);

#endif
