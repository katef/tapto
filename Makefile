CC  ?= gcc

CFLAGS += -ansi -pedantic -Wall -Werror

all: tap

tap: main.o
	${CC} -o tap main.o

main.o: main.c
	${CC} ${CFLAGS} -c -o main.o main.c

