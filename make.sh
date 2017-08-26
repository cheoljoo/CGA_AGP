cd OUTPUT/stc
#cc -c parser.c
#ar -cvq libparser.a parser.o
#cc -c ut.c -DDEBUG
#cc -o a.out ut.c parser.c -DDEBUG
cc -o unittestdbg ut.c parser.c -DDEBUG -Wimplicit-function-declaration
cc -o unittest ut.c parser.c 
