CC  ?= gcc

CFLAGS += -ansi -pedantic -Wall -Werror

all: tap

tap: main.o ast.o
	${CC} -o tap main.o ast.o

ast.o: ast.c
	${CC} ${CFLAGS} -c -o ast.o ast.c

main.o: main.c
	${CC} ${CFLAGS} -c -o main.o main.c

