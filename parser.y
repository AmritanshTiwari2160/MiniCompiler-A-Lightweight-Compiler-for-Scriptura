%code requires {
#include <vector>
#include "ast.h"
extern ASTNode* root;
}

%{
#include 
#include 
extern int yylex();
void yyerror(const char* s);
%}

%union {
int                          num;
char*                        id;
ASTNode*                     node;
std::vector<ASTNode*>*       stmts;
}

%token     NUMBER
%token      IDENT
%token          ASSIGN TO PRINT IF ELSE WHILE
%token          PLUS MINUS TIMES DIVIDE GREATER LESS EQUAL
%token          LPAREN RPAREN LBRACE RBRACE SEMICOLON

%type     program stmt expr
%type    stmt_list

%%

program:
stmt_list {
// Build AST root from statement list
ASTNode* tree = new StmtList(*$1);
delete $1;
root = tree;
$$ = tree;
}
;

stmt_list:
stmt {
->push_back($1);
}
| stmt_list stmt {
->push_back($2);
}
;

stmt:
ASSIGN IDENT TO expr SEMICOLON {
 = new PrintNode($3);
}
| IF LPAREN expr RPAREN LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE {
 = new WhileNode($3, *$6);
delete $6;
}
;

expr:
expr PLUS expr    {  = new BinaryOpNode("-",  $1, $3); }
| expr TIMES expr   {  = new BinaryOpNode("/",  $1, $3); }
| expr GREATER expr {  = new BinaryOpNode("<",  $1, $3); }
| expr EQUAL expr   {  = $2; }
| NUMBER            {  = new VarNode($1); }
;

%%

void yyerror(const char* s) {
std::fprintf(stderr, "Parse error: %s\n", s);
}