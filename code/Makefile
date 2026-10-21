CC = gcc
CFLAGS = -Wall

all: parser

parser: lex.yy.c y.tab.c main.c
	$(CC) $(CFLAGS) lex.yy.c y.tab.c main.c -o parser

y.tab.c y.tab.h: myyacc.y
	yacc -d myyacc.y

lex.yy.c: mylex.l y.tab.h
	lex mylex.l

clean:
	rm -f lex.yy.c y.tab.c y.tab.h parser