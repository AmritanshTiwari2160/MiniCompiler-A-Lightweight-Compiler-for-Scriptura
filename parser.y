%code requires {
    #include <vector>
    #include <string>
    #include "ast.h"
    extern ASTNode* root;
}

%{
    #include <cstdio>
    #include <cstdlib>
    #include <cstring>
    #include "ast.h"
    extern int yylex();
    void yyerror(const char* s);
%}

%union {
    int                          num;
    char*                        id;
    ASTNode*                     node;
    std::vector<ASTNode*>*       stmts;
}

%token <num>   NUMBER
%token <id>    IDENT
%token <id> STRING
%token         ASSIGN INPUT TO PRINT IF ELSE WHILE
%token         PLUS MINUS TIMES DIVIDE MOD GREATER LESS EQUAL
%token         LPAREN RPAREN LBRACE RBRACE SEMICOLON

%type  <node>  program stmt expr
%type  <stmts> stmt_list

%%

program:
    stmt_list {
        ASTNode* tree = new StmtList(*$1);
        delete $1;
        root = tree;
        $$ = tree;
    }
;

stmt_list:
    stmt {
        $$ = new std::vector<ASTNode*>();
        $$->push_back($1);
    }
  | stmt_list stmt {
        $$ = $1;
        $$->push_back($2);
    }
;

stmt:
    INPUT IDENT SEMICOLON {
        $$ = new InputNode($2);
        free($2);
    }
  | ASSIGN expr TO IDENT SEMICOLON {
        $$ = new AssignNode($4, $2);
        free($4);
    }
  | ASSIGN LPAREN expr RPAREN TO IDENT SEMICOLON {
        $$ = new AssignNode($6, $3);
        free($6);
    }
  | PRINT expr SEMICOLON {
        $$ = new PrintNode($2);
    }
  | WHILE LPAREN expr RPAREN LBRACE stmt_list RBRACE {
        $$ = new WhileNode($3, *$6);
        delete $6;
    }
  | IF LPAREN expr RPAREN LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE {
        $$ = new IfNode($3, *$6, *$10);
        delete $6;
        delete $10;
    }
;

expr:
    expr PLUS expr       { $$ = new BinaryOpNode("+",  $1, $3); }
  | expr MINUS expr      { $$ = new BinaryOpNode("-",  $1, $3); }
  | expr TIMES expr      { $$ = new BinaryOpNode("*",  $1, $3); }
  | expr DIVIDE expr     { $$ = new BinaryOpNode("/",  $1, $3); }
  | expr MOD expr        { $$ = new BinaryOpNode("%",  $1, $3); }  /* new modulo */
  | expr GREATER expr    { $$ = new BinaryOpNode(">",  $1, $3); }
  | expr LESS expr       { $$ = new BinaryOpNode("<",  $1, $3); }
  | expr EQUAL expr      { $$ = new BinaryOpNode("==", $1, $3); }
  | IDENT                { $$ = new VarNode($1); free($1); }
  | NUMBER               { $$ = new NumberNode($1); }
  | STRING {
        std::string raw($1);
        $$ = new StringNode(raw.substr(1, raw.size() - 2));
        free($1);
    }
;

%%

void yyerror(const char* s) {
    std::fprintf(stderr, "Parse error: %s\n", s);
}
