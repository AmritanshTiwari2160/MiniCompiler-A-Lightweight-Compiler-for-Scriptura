#ifndef AST_H
#define AST_H

#include <vector>
#include <string>
#include <map>
#include <cstdio>

// Base class
class ASTNode
{
public:
    virtual ~ASTNode() {}
    virtual int eval(std::map<std::string, int> &) { return 0; }
};

// Statement list
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

// Assignment
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

// Input
class InputNode : public ASTNode
{
    std::string id;

public:
    InputNode(const char *name) : id(name) {}
    int eval(std::map<std::string, int> &sym) override
    {
        int v = 0;
        // Open the terminal directly
        FILE *tty = fopen("/dev/tty", "r");
        if (!tty)
        {
            std::perror("fopen /dev/tty");
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
// Print
class PrintNode : public ASTNode
{
    ASTNode *expr;

public:
    PrintNode(ASTNode *e) : expr(e) {}
    ~PrintNode() { delete expr; }
    int eval(std::map<std::string, int> &sym) override
    {
        int v = expr->eval(sym);
        std::printf("%d\n", v);
        return v;
    }
};

// If-Else
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
            for (auto p : thenStmts)
                p->eval(sym);
        else
            for (auto p : elseStmts)
                p->eval(sym);
        return 0;
    }
};

// While
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
            for (auto p : body)
                p->eval(sym);
        return 0;
    }
};

// Binary operations
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
        int a = left->eval(sym), b = right->eval(sym);
        if (op == "+")
            return a + b;
        else if (op == "-")
            return a - b;
        else if (op == "*")
            return a * b;
        else if (op == "/")
            return a / b;
        else if (op == ">")
            return a > b;
        else if (op == "<")
            return a < b;
        else /*==*/
            return a == b;
    }
};

// Number literal
class NumberNode : public ASTNode
{
    int value;

public:
    NumberNode(int v) : value(v) {}
    int eval(std::map<std::string, int> &) override { return value; }
};

// Variable reference
class VarNode : public ASTNode
{
    std::string id;

public:
    VarNode(const char *name) : id(name) {}
    int eval(std::map<std::string, int> &sym) override
    {
        return sym[id];
    }
};

#endif // AST_H
