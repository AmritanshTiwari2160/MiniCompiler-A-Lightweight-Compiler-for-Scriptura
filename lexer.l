%option noyywrap
%{
#include "parser.tab.h"
%}

%%

"assign"          { return ASSIGN; }
"input"           { return INPUT; }
"to"              { return TO; }
"print"           { return PRINT; }
"if"              { return IF; }
"else"            { return ELSE; }
"while"           { return WHILE; }
"plus"            { return PLUS; }
"minus"           { return MINUS; }
"times"           { return TIMES; }
"divide"          { return DIVIDE; }
"greater"         { return GREATER; }
"less"            { return LESS; }
"equal"           { return EQUAL; }

"("               { return LPAREN; }
")"               { return RPAREN; }
"{"               { return LBRACE; }
"}"               { return RBRACE; }
";"               { return SEMICOLON; }

[0-9]+            { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return IDENT; }

[ \t\r\n]+        { /* skip whitespace */ }
.                 { return yytext[0]; }
%%