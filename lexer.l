%option noyywrap
%{
#include "parser.tab.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int linenumber = 1;
int column = 1;
int token_start_column = 1;

char current_line[1024];
int current_line_pos = 0;

char last_token_text[256];

// Helper to get readable token type
const char* tokenTypeName(int token) {
    switch(token) {
        case INPUT:
        case ASSIGN:
        case TO:
        case PRINT:
        case IF:
        case ELSE:
        case WHILE:
            return "Keyword";
        case PLUS:
        case MINUS:
        case TIMES:
        case DIVIDE:
        case MOD:
        case GREATER:
        case LESS:
        case EQUAL:
            return "Operator";
        case IDENT: return "Identifier";
        case NUMBER: return "Number";
        case STRING: return "String";
        case FOR: return "Keyword";
        case TOLOWERCASE:
        case TOUPPERCASE:
        case STRINGLENGTH:
        case INDEXOF:
        case MERGESTRING:
        case CHARACTERAT:
            return "Keyword";
        case SEMICOLON:
        case LPAREN:
        case RPAREN:
        case LBRACE:
        case RBRACE:
            return "Punctuation";
        default: return "Unknown";
    }
}
%}

%%

\/\/[^\n]*            { /* skip single-line comments */ }

"/*"([^*]|\*+[^*/])*\*+"/"   { /* skip multi-line comments */ }

\"([^\\\"]|\\.)*\"    {
    token_start_column = column;
    strncpy(last_token_text, yytext, sizeof(last_token_text));
    last_token_text[sizeof(last_token_text)-1] = '\0';

    if (current_line_pos + yyleng < sizeof(current_line)) {
        memcpy(&current_line[current_line_pos], yytext, yyleng);
        current_line_pos += yyleng;
    }

    column += yyleng;
    yylval.id = strdup(yytext);

    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(STRING));
    return STRING;
}
"assign"          { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(ASSIGN)); return ASSIGN; 
    }
"input"           { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(INPUT)); return INPUT; 
    }
"to"              { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(TO)); return TO; 
    }
"print"           { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(PRINT)); return PRINT; 
    }
"if"              { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(IF)); return IF; 
    }
"else"            { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(ELSE)); return ELSE; 
    }
"while"           { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(WHILE)); return WHILE; 
    }
"for"  {
    token_start_column = column;
    strcpy(last_token_text, yytext);
    if (current_line_pos + yyleng < sizeof(current_line)) {
        memcpy(&current_line[current_line_pos], yytext, yyleng);
        current_line_pos += yyleng;
    }
    column += yyleng;
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(FOR));
    return FOR;
}
"plus"            { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(PLUS)); return PLUS; 
    }
"minus"           { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(MINUS)); return MINUS; 
    }
"times"           { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(TIMES)); return TIMES; 
    }
"divide"          { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(DIVIDE)); return DIVIDE; 
    }
"mod"             { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(MOD)); return MOD; 
    }
"greater than"    { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(GREATER)); return GREATER; 
    }
"less than"       { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(LESS)); return LESS; 
    }
"equal to"        { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    memcpy(&current_line[current_line_pos], yytext, yyleng); 
    current_line_pos += yyleng; 
    column += yyleng; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(EQUAL)); return EQUAL; 
    }

"tolowercase" {
    token_start_column = column;
    strcpy(last_token_text, yytext);
    if (current_line_pos + yyleng < sizeof(current_line))
        memcpy(&current_line[current_line_pos], yytext, yyleng);
    current_line_pos += yyleng;
    column += yyleng;
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(TOLOWERCASE));
    return TOLOWERCASE;
}

"touppercase" {
    token_start_column = column;
    strcpy(last_token_text, yytext);
    if (current_line_pos + yyleng < sizeof(current_line))
        memcpy(&current_line[current_line_pos], yytext, yyleng);
    current_line_pos += yyleng;
    column += yyleng;
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(TOUPPERCASE));
    return TOUPPERCASE;
}

"stringlength" {
    token_start_column = column;
    strcpy(last_token_text, yytext);
    if (current_line_pos + yyleng < sizeof(current_line))
        memcpy(&current_line[current_line_pos], yytext, yyleng);
    current_line_pos += yyleng;
    column += yyleng;
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(STRINGLENGTH));
    return STRINGLENGTH;
}

"indexof" {
    token_start_column = column;
    strcpy(last_token_text, yytext);
    if (current_line_pos + yyleng < sizeof(current_line))
        memcpy(&current_line[current_line_pos], yytext, yyleng);
    current_line_pos += yyleng;
    column += yyleng;
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(INDEXOF));
    return INDEXOF;
}
"mergestring" {
    token_start_column = column;
    strcpy(last_token_text, yytext);
    if (current_line_pos + yyleng < sizeof(current_line))
        memcpy(&current_line[current_line_pos], yytext, yyleng);
    current_line_pos += yyleng;
    column += yyleng;
    printf("Token: %-10s Type: Keyword\n", yytext);
    return MERGESTRING;
}
"characterat"  {
    token_start_column = column;
    strcpy(last_token_text, yytext);
    if (current_line_pos + yyleng < sizeof(current_line))
        memcpy(&current_line[current_line_pos], yytext, yyleng);
    current_line_pos += yyleng;
    column += yyleng;
    printf("Token: %-10s Type: Keyword\n", yytext);
    return CHARACTERAT;
}
"("               { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    current_line[current_line_pos++] = yytext[0]; 
    column++; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(LPAREN)); return LPAREN; 
    }
")"               { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    current_line[current_line_pos++] = yytext[0]; 
    column++; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(RPAREN)); return RPAREN; 
    }
"{"               { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    current_line[current_line_pos++] = yytext[0]; 
    column++; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(LBRACE)); return LBRACE; 
    }
"}"               { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    current_line[current_line_pos++] = yytext[0]; 
    column++; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(RBRACE)); return RBRACE; 
    }
";"               { 
    token_start_column = column; 
    strcpy(last_token_text, yytext); 
    current_line[current_line_pos++] = yytext[0]; 
    column++; 
    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(SEMICOLON)); return SEMICOLON; 
    }
"," {
    token_start_column = column;
    strcpy(last_token_text, yytext);
    if (current_line_pos < sizeof(current_line) - 1)
        current_line[current_line_pos++] = yytext[0];
    column++;
    printf("Token: %-10s Type: Punctuation\n", yytext);
    return COMMA;
}
[0-9]+ {
    token_start_column = column;
    strncpy(last_token_text, yytext, sizeof(last_token_text));
    last_token_text[sizeof(last_token_text)-1] = '\0';

    int len = yyleng;
    if (current_line_pos + len < sizeof(current_line)) {
        memcpy(&current_line[current_line_pos], yytext, len);
        current_line_pos += len;
    }

    column += yyleng;
    yylval.num = atoi(yytext);

    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(NUMBER));
    return NUMBER;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    token_start_column = column;
    strncpy(last_token_text, yytext, sizeof(last_token_text));
    last_token_text[sizeof(last_token_text)-1] = '\0';

    int len = yyleng;
    if (current_line_pos + len < sizeof(current_line)) {
        memcpy(&current_line[current_line_pos], yytext, len);
        current_line_pos += len;
    }

    column += yyleng;
    yylval.id = strdup(yytext);

    printf("Token: %-10s Type: %s\n", yytext, tokenTypeName(IDENT));
    return IDENT;
}

[ \t\r]+ {
    for (int i = 0; i < yyleng; i++) {
        if (current_line_pos < sizeof(current_line) - 1) {
            current_line[current_line_pos++] = yytext[i];
        }
    }
    column += yyleng;
}

\n {
    linenumber++;
    column = 1;
    current_line[current_line_pos] = '\0';
    current_line_pos = 0;
}

. {
    token_start_column = column;
    last_token_text[0] = yytext[0];
    last_token_text[1] = '\0';
    if (current_line_pos < sizeof(current_line) - 1)
        current_line[current_line_pos++] = yytext[0];
    column++;
    printf("Token: %-10s Type: Unknown\n", yytext);
    return yytext[0];
}

%%