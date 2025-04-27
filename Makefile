all:
	flex lexer.l
	bison -d parser.y
	g++ -std=c++11 parser.tab.c lex.yy.c ast.cpp main.cpp -o mini_compiler

clean:
	rm -f lex.yy.c parser.tab.* mini_compiler
