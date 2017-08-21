cd OUTPUT/stc
#cc -c parser.c
#ar -cvq libparser.a parser.o
#cc -c ut.c -DDEBUG
#cc -o a.out ut.c parser.c -DDEBUG
cc -o dbgrun ut.c parser.c -DDEBUG
cc -o run ut.c parser.c 
