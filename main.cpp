#include <cstdio>
#include <cstdlib>
#include <map>
#include "ast.h"

// Define the global AST root pointer
ASTNode *root = nullptr;

extern int yyparse();
extern FILE *yyin;
extern bool hasSyntaxError;

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

    // 2) Parse once
    int parseResult = yyparse();

    if (parseResult != 0)
    {
        fprintf(stderr, "Parsing failed with code %d\n", parseResult);
        if (yyin != stdin)
            fclose(yyin);
        return parseResult;
    }

    if (hasSyntaxError)
    {
        fprintf(stderr, "Compilation aborted due to syntax errors.\n");
        if (yyin != stdin)
            fclose(yyin);
        return 1;
    }

    // 3) Execute AST if no errors
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
