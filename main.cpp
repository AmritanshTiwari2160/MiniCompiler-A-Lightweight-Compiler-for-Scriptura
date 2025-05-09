#include <cstdio>
#include <cstdlib>
#include <map>
#include "ast.h"

// Define the global AST root pointer (remove the redundant extern)
ASTNode *root = nullptr;

extern int yyparse();
extern FILE *yyin;

int main(int argc, char **argv)
{
    // 1) Open input
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
        if (!yyin)
        {
            perror(argv[1]);
            return 1;
        }
    }
    else
    {
        yyin = stdin;
    }

    // 2) Parse
    int parseResult = yyparse();
    if (parseResult != 0)
    {
        std::fprintf(stderr, "Parsing failed with code %d\n", parseResult);
        if (yyin != stdin)
            fclose(yyin);
        return parseResult;
    }

    // 3) Execute AST
    if (root)
    {
        std::map<std::string, int> symTable;
        root->eval(symTable);
        delete root; // free the AST
    }

    // 4) Clean up
    if (yyin != stdin)
    {
        fclose(yyin);
    }
    return 0;
}