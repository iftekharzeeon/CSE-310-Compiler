flex -o $1.c $1.l
g++ $1.c -lfl -o $1.o
./$1.o $2.txt
rm $1.o $1.c