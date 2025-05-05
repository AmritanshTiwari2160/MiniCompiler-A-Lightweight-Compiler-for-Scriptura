#ifndef AST_H
#define AST_H

#include <vector>
#include <string>
#include <map>
#include <cstdio>
#include <cstdlib>
#include <iostream> // for std::cout, std::cerr

// Base AST node
class ASTNode
{
public:
    virtual ~ASTNode() {}
    // Evaluate node, updating sym if needed. Return int for numeric nodes.
    virtual int eval(std::map<std::string, int> &) { return 0; }
};

// A list of statements
class StmtList : public ASTNode
{
    std::vector<ASTNode *> stmts;

public:
    StmtList(const std::vector<ASTNode *> &s) : stmts(s) {}
    ~StmtList()
    {
        for (auto p : stmts)
            delete p;
    }

    int eval(std::map<std::string, int> &sym) override
    {
        for (auto p : stmts)
            p->eval(sym);
        return 0;
    }
};

// Assignment: assign expr to variable
class AssignNode : public ASTNode
{
    std::string id;
    ASTNode *expr;

public:
    AssignNode(const char *name, ASTNode *e) : id(name), expr(e) {}
    ~AssignNode() { delete expr; }

    int eval(std::map<std::string, int> &sym) override
    {
        int v = expr->eval(sym);
        sym[id] = v;
        return v;
    }
};

// Runtime integer input: input var;
class InputNode : public ASTNode
{
    std::string id;

public:
    InputNode(const char *name) : id(name) {}

    int eval(std::map<std::string, int> &sym) override
    {
        int v = 0;
        // Always read from the terminal, even if stdin is redirected
        FILE *tty = fopen("/dev/tty", "r");
        if (!tty)
        {
            std::perror("fopen(/dev/tty)");
        }
        else
        {
            std::printf("Input for %s: ", id.c_str());
            std::fflush(stdout);
            if (fscanf(tty, "%d", &v) != 1)
            {
                std::fprintf(stderr, "Invalid integer input for %s\n", id.c_str());
                v = 0;
            }
            fclose(tty);
        }
        sym[id] = v;
        return v;
    }
};

// String literal node
class StringNode : public ASTNode
{
    std::string value;

public:
    StringNode(const std::string &v) : value(v) {}

    // eval not used directly for printing
    int eval(std::map<std::string, int> &) override
    {
        return 0;
    }

    const std::string &getValue() const { return value; }
};

// Print statement: print(expr);
class PrintNode : public ASTNode
{
    ASTNode *expr;

public:
    PrintNode(ASTNode *e) : expr(e) {}
    ~PrintNode() { delete expr; }

    int eval(std::map<std::string, int> &sym) override
    {
        // If it's a string literal, print it directly
        if (auto s = dynamic_cast<StringNode *>(expr))
        {
            std::cout << s->getValue() << std::endl;
            return 0;
        }
        // Otherwise, evaluate numeric expression
        int v = expr->eval(sym);
        std::printf("%d\n", v);
        return v;
    }
};

// If-else statement
class IfNode : public ASTNode
{
    ASTNode *cond;
    std::vector<ASTNode *> thenStmts, elseStmts;

public:
    IfNode(ASTNode *c,
           const std::vector<ASTNode *> &t,
           const std::vector<ASTNode *> &e)
        : cond(c), thenStmts(t), elseStmts(e) {}
    ~IfNode()
    {
        delete cond;
        for (auto p : thenStmts)
            delete p;
        for (auto p : elseStmts)
            delete p;
    }

    int eval(std::map<std::string, int> &sym) override
    {
        if (cond->eval(sym))
        {
            for (auto p : thenStmts)
                p->eval(sym);
        }
        else
        {
            for (auto p : elseStmts)
                p->eval(sym);
        }
        return 0;
    }
};

// While loop
class WhileNode : public ASTNode
{
    ASTNode *cond;
    std::vector<ASTNode *> body;

public:
    WhileNode(ASTNode *c, const std::vector<ASTNode *> &b)
        : cond(c), body(b) {}
    ~WhileNode()
    {
        delete cond;
        for (auto p : body)
            delete p;
    }

    int eval(std::map<std::string, int> &sym) override
    {
        while (cond->eval(sym))
        {
            for (auto p : body)
                p->eval(sym);
        }
        return 0;
    }
};

// Binary operations (+, -, *, /, %, >, <, ==)
class BinaryOpNode : public ASTNode
{
    std::string op;
    ASTNode *left, *right;

public:
    BinaryOpNode(const char *o, ASTNode *l, ASTNode *r)
        : op(o), left(l), right(r) {}
    ~BinaryOpNode()
    {
        delete left;
        delete right;
    }

    int eval(std::map<std::string, int> &sym) override
    {
        int a = left->eval(sym);
        int b = right->eval(sym);

        if (op == "+")
            return a + b;
        else if (op == "-")
            return a - b;
        else if (op == "*")
            return a * b;
        else if (op == "/")
        {
            if (b == 0)
            {
                std::cerr << "Runtime Error: Division by zero\n";
                std::exit(1);
            }
            return a / b;
        }
        else if (op == "%")
        {
            if (b == 0)
            {
                std::cerr << "Runtime Error: Modulo by zero\n";
                std::exit(1);
            }
            return a % b;
        }
        else if (op == ">")
            return a > b;
        else if (op == "<")
            return a < b;
        else
            return a == b;
    }
};

// Number literal
class NumberNode : public ASTNode
{
    int value;

public:
    NumberNode(int v) : value(v) {}
    int eval(std::map<std::string, int> &) override
    {
        return value;
    }
};

// Variable reference
class VarNode : public ASTNode
{
    std::string id;

public:
    VarNode(const char *name) : id(name) {}
    int eval(std::map<std::string, int> &sym) override
    {
        return sym[id]; // you may want to check existence
    }
};

#endif // AST_H
