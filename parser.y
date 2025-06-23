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
    #include <set>
    #include "ast.h"
    extern int yylex();
    extern int linenumber;
    bool hasSyntaxError = false;
    void yyerror(const char* s);
    std::set<int> errorLines;
    extern int token_start_column;
    extern char current_line[];
    extern char last_token_text[];
%}

%union {
    int                          num;
    char*                        id;
    ASTNode*                     node;
    std::vector<ASTNode*>*       stmts;
}

%define parse.error verbose

%token <num>   NUMBER
%token <id>    IDENT
%token <id>    STRING
%token         ASSIGN INPUT TO PRINT IF ELSE WHILE
%token         PLUS MINUS TIMES DIVIDE MOD GREATER LESS EQUAL
%token         LPAREN RPAREN LBRACE RBRACE SEMICOLON
%token         FOR
%token         TOLOWERCASE TOUPPERCASE STRINGLENGTH INDEXOF CHARACTERAT MERGESTRING
%token         COMMA
/* %token         FILEWRITE FILEAPPEND FILEDELETE FILEEXISTS FILEREAD */

%type  <node>  program stmt expr init_stmt update_stmt
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
        if ($1) $$->push_back($1);
    }
  | stmt_list stmt {
        $$ = $1;
        if ($2) $$->push_back($2);
    }
  | stmt_list error SEMICOLON {
        $$ = $1;
        yyerrok;
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
  | PRINT expr SEMICOLON {
        $$ = new PrintNode($2);
    }
  | PRINT LPAREN expr RPAREN SEMICOLON {
        $$ = new PrintNode($3);
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
  | FOR LPAREN init_stmt SEMICOLON expr SEMICOLON update_stmt RPAREN LBRACE stmt_list RBRACE {
        $$ = new ForNode($3, $5, $7, *$10);
        delete $10;
    }
  | error SEMICOLON {
        $$ = nullptr;
        yyerrok;
    }
;

init_stmt:
    ASSIGN expr TO IDENT {
        $$ = new AssignNode($4, $2);
        free($4);
    }
  | /* empty */ {
        $$ = nullptr;
    }
;

update_stmt:
    ASSIGN expr TO IDENT {
        $$ = new AssignNode($4, $2);
        free($4);
    }
  | /* empty */ {
        $$ = nullptr;
    }
;

expr:
    expr PLUS expr       { $$ = new BinaryOpNode("+",  $1, $3); }
  | expr MINUS expr      { $$ = new BinaryOpNode("-",  $1, $3); }
  | expr TIMES expr      { $$ = new BinaryOpNode("*",  $1, $3); }
  | expr DIVIDE expr     { $$ = new BinaryOpNode("/",  $1, $3); }
  | expr MOD expr        { $$ = new BinaryOpNode("%",  $1, $3); }
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
  | TOLOWERCASE LPAREN expr RPAREN {
        $$ = new ToLowerNode($3);
    }
  | TOUPPERCASE LPAREN expr RPAREN {
        $$ = new ToUpperNode($3);
    }
  | STRINGLENGTH LPAREN expr RPAREN {
        $$ = new StrLenNode($3);
    }
  | INDEXOF LPAREN expr COMMA expr RPAREN {
        $$ = new IndexOfNode($3, $5);
    }
  | CHARACTERAT LPAREN expr COMMA expr RPAREN {
        $$ = new CharAtNode($3, $5);
    }
  | MERGESTRING LPAREN expr COMMA expr RPAREN {
        $$ = new MergeStringNode($3, $5);
    }

  | LPAREN expr RPAREN {
        $$ = $2;
    }
;

%%

void yyerror(const char *s) {
    hasSyntaxError = true;
    fprintf(stderr, "Syntax error at line %d, column %d: %s\n", linenumber, token_start_column, s);
    fprintf(stderr, "%s\n", current_line);
    for (int i = 1; i < token_start_column; i++) {
        fprintf(stderr, " ");
    }
    int len = strlen(last_token_text);
    for (int i = 0; i < len; i++) {
        fprintf(stderr, "^");
    }
    fprintf(stderr, "\n");
    fprintf(stderr, "Unexpected token: '%s'\n", last_token_text);
}
