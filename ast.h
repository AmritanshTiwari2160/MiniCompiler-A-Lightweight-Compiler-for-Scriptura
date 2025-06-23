#ifndef AST_H
#define AST_H

#include <vector>
#include <string>
#include <map>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <algorithm>
#include <fstream>
#include <sstream>
// Base AST node
class ASTNode {
public:
    virtual ~ASTNode() {}
    virtual int eval(std::map<std::string, int>&) { return 0; }
    virtual std::string eval_string(std::map<std::string, int>&) { return ""; }
};

// A list of statements
class StmtList : public ASTNode {
    std::vector<ASTNode*> stmts;

public:
    StmtList(const std::vector<ASTNode*>& s) : stmts(s) {}
    ~StmtList() {
        for (auto p : stmts)
            delete p;
    }

    int eval(std::map<std::string, int>& sym) override {
        for (auto p : stmts)
            p->eval(sym);
        return 0;
    }
};
class InputNode : public ASTNode {
    std::string id;

public:
    InputNode(const std::string& name) : id(name) {}

    int eval(std::map<std::string, int>& sym) override {
        int value;
        std::cout << "Input for " << id << ": ";
        std::cin >> value;
        sym[id] = value;
        return value;
    }
};

// Assignment
class AssignNode : public ASTNode {
    std::string id;
    ASTNode* expr;

public:
    AssignNode(const char* name, ASTNode* e) : id(name), expr(e) {}
    ~AssignNode() { delete expr; }

    int eval(std::map<std::string, int>& sym) override {
        std::string s = expr->eval_string(sym);

        if (!s.empty()) {
            stringSym[id] = s;   // store in string symbol table
            return 0;
        }

        int v = expr->eval(sym);
        sym[id] = v;
        return v;
    }

    static std::map<std::string, std::string> stringSym;  // static string symbol table
};


// String literal
class StringNode : public ASTNode {
    std::string value;

public:
    StringNode(const std::string& v) : value(v) {}

    int eval(std::map<std::string, int>&) override {
        return 0;
    }

    std::string eval_string(std::map<std::string, int>&) override {
        return value;
    }

    const std::string& getValue() const { return value; }
};

// Print
class PrintNode : public ASTNode {
    ASTNode* expr;

public:
    PrintNode(ASTNode* e) : expr(e) {}
    ~PrintNode() { delete expr; }

    int eval(std::map<std::string, int>& sym) override {
        std::string sval = expr->eval_string(sym);
        if (!sval.empty()) {
            std::cout << sval << std::endl;
            return 0;
        }
        int v = expr->eval(sym);
        std::cout << v << std::endl;
        return v;
    }
};


// If-else
class IfNode : public ASTNode {
    ASTNode* cond;
    std::vector<ASTNode*> thenStmts, elseStmts;

public:
    IfNode(ASTNode* c, const std::vector<ASTNode*>& t, const std::vector<ASTNode*>& e)
        : cond(c), thenStmts(t), elseStmts(e) {}
    ~IfNode() {
        delete cond;
        for (auto p : thenStmts) delete p;
        for (auto p : elseStmts) delete p;
    }

    int eval(std::map<std::string, int>& sym) override {
        if (cond->eval(sym)) {
            for (auto p : thenStmts) p->eval(sym);
        } else {
            for (auto p : elseStmts) p->eval(sym);
        }
        return 0;
    }
};

// While
class WhileNode : public ASTNode {
    ASTNode* cond;
    std::vector<ASTNode*> body;

public:
    WhileNode(ASTNode* c, const std::vector<ASTNode*>& b) : cond(c), body(b) {}
    ~WhileNode() {
        delete cond;
        for (auto p : body) delete p;
    }

    int eval(std::map<std::string, int>& sym) override {
        while (cond->eval(sym)) {
            for (auto p : body) p->eval(sym);
        }
        return 0;
    }
};

// For loop
class ForNode : public ASTNode {
    ASTNode* init;
    ASTNode* cond;
    ASTNode* incr;
    std::vector<ASTNode*> body;

public:
    ForNode(ASTNode* i, ASTNode* c, ASTNode* inc, const std::vector<ASTNode*>& b)
        : init(i), cond(c), incr(inc), body(b) {}

    ~ForNode() {
        delete init;
        delete cond;
        delete incr;
        for (auto p : body) delete p;
    }

    int eval(std::map<std::string, int>& sym) override {
        for (init->eval(sym); cond->eval(sym); incr->eval(sym)) {
            for (auto p : body) p->eval(sym);
        }
        return 0;
    }
};

// Binary operations
class BinaryOpNode : public ASTNode {
    std::string op;
    ASTNode *left, *right;

public:
    BinaryOpNode(const char* o, ASTNode* l, ASTNode* r)
        : op(o), left(l), right(r) {}
    ~BinaryOpNode() {
        delete left;
        delete right;
    }

    int eval(std::map<std::string, int>& sym) override {
        int a = left->eval(sym);
        int b = right->eval(sym);

        if (op == "+") return a + b;
        if (op == "-") return a - b;
        if (op == "*") return a * b;
        if (op == "/") {
            if (b == 0) {
                std::cerr << "Runtime Error: Division by zero\n";
                std::exit(1);
            }
            return a / b;
        }
        if (op == "%") {
            if (b == 0) {
                std::cerr << "Runtime Error: Modulo by zero\n";
                std::exit(1);
            }
            return a % b;
        }
        if (op == ">") return a > b;
        if (op == "<") return a < b;
        return a == b;
    }
};

// Number literal
class NumberNode : public ASTNode {
    int value;

public:
    NumberNode(int v) : value(v) {}
    int eval(std::map<std::string, int>&) override {
        return value;
    }
};

// Variable reference
class VarNode : public ASTNode {
    std::string id;

public:
    VarNode(const char* name) : id(name) {}

    int eval(std::map<std::string, int>& sym) override {
        if (sym.find(id) != sym.end()) {
            return sym[id];
        }
        return 0;
    }

    std::string eval_string(std::map<std::string, int>& sym) override {
        if (AssignNode::stringSym.find(id) != AssignNode::stringSym.end()) {
            return AssignNode::stringSym[id];
        }
        if (sym.find(id) != sym.end()) {
            return std::to_string(sym[id]);
        }
        return id;  // fallback
    }
};



// Built-in String Functions

class ToLowerNode : public ASTNode {
    ASTNode* expr;
public:
    ToLowerNode(ASTNode* e) : expr(e) {}
    ~ToLowerNode() { delete expr; }

    std::string eval_string(std::map<std::string, int>& sym) override {
        std::string s = expr->eval_string(sym);
        std::transform(s.begin(), s.end(), s.begin(), ::tolower);
        return s;
    }
};

class ToUpperNode : public ASTNode {
    ASTNode* expr;
public:
    ToUpperNode(ASTNode* e) : expr(e) {}
    ~ToUpperNode() { delete expr; }

    std::string eval_string(std::map<std::string, int>& sym) override {
        std::string s = expr->eval_string(sym);
        std::transform(s.begin(), s.end(), s.begin(), ::toupper);
        return s;
    }
};

class StrLenNode : public ASTNode {
    ASTNode* expr;
public:
    StrLenNode(ASTNode* e) : expr(e) {}
    ~StrLenNode() { delete expr; }

    int eval(std::map<std::string, int>& sym) override {
        return expr->eval_string(sym).length();
    }
};

class IndexOfNode : public ASTNode {
    ASTNode *strExpr, *charExpr;
public:
    IndexOfNode(ASTNode* s, ASTNode* c) : strExpr(s), charExpr(c) {}
    ~IndexOfNode() {
        delete strExpr;
        delete charExpr;
    }

    int eval(std::map<std::string, int>& sym) override {
        std::string s = strExpr->eval_string(sym);
        std::string c = charExpr->eval_string(sym);
        if (c.empty()) return -1;
        size_t pos = s.find(c);
        return (pos == std::string::npos) ? -1 : static_cast<int>(pos);
    }
};
// String Concatenation: concatenate("hello", "world") => "helloworld"
class MergeStringNode : public ASTNode {
    ASTNode *left, *right;

public:
    MergeStringNode(ASTNode* l, ASTNode* r) : left(l), right(r) {}
    ~MergeStringNode() {
        delete left;
        delete right;
    }

    std::string eval_string(std::map<std::string, int>& sym) override {
        return left->eval_string(sym) + right->eval_string(sym);
    }
};

// Character At: charat("hello", 1) => "e"
class CharAtNode : public ASTNode {
    ASTNode *strExpr, *indexExpr;

public:
    CharAtNode(ASTNode* s, ASTNode* i) : strExpr(s), indexExpr(i) {}
    ~CharAtNode() {
        delete strExpr;
        delete indexExpr;
    }

    std::string eval_string(std::map<std::string, int>& sym) override {
        std::string s = strExpr->eval_string(sym);
        int idx = indexExpr->eval(sym);
        if (idx < 0 || idx >= static_cast<int>(s.length())) {
            std::cerr << "Runtime Error: Index " << idx << " out of bounds for string \"" << s << "\"\n";
            std::exit(1);
        }
        return std::string(1, s[idx]);  // return a single character as a string
    }
};

//file handling
// class FileReadNode : public ASTNode {
//     std::string filename;

// public:
//     FileReadNode(const char* fname) : filename(fname) {}

//     std::string eval_string(std::map<std::string, int>&) override {
//         std::ifstream file(filename);
//         if (!file.is_open()) {
//             std::cerr << "Could not open file: " << filename << std::endl;
//             return "";
//         }
//         std::stringstream buffer;
//         buffer << file.rdbuf();
//         return buffer.str();
//     }
// };
// class FileWriteNode : public ASTNode {
//     std::string filename;
//     ASTNode* content;

// public:
//     FileWriteNode(const char* fname, ASTNode* c) : filename(fname), content(c) {}
//     ~FileWriteNode() { delete content; }

//     int eval(std::map<std::string, int>& sym) override {
//         std::ofstream file(filename);
//         if (!file.is_open()) {
//             std::cerr << "Could not open file: " << filename << std::endl;
//             return 0;
//         }
//         file << content->eval_string(sym);
//         return 0;
//     }
// };
// class FileDeleteNode : public ASTNode {
//     std::string filename;

// public:
//     FileDeleteNode(const char* fname) : filename(fname) {}

//     int eval(std::map<std::string, int>&) override {
//         if (std::remove(filename.c_str()) != 0) {
//             std::cerr << "Could not delete file: " << filename << std::endl;
//             return 0;
//         }
//         return 1;
//     }
// };
// class FileAppendNode : public ASTNode {
//     std::string filename;
//     ASTNode* content;

// public:
//     FileAppendNode(const char* fname, ASTNode* c) : filename(fname), content(c) {}
//     ~FileAppendNode() { delete content; }

//     int eval(std::map<std::string, int>& sym) override {
//         std::ofstream file(filename, std::ios::app);
//         if (!file.is_open()) {
//             std::cerr << "Could not open file for appending: " << filename << std::endl;
//             return 0;
//         }
//         file << content->eval_string(sym);
//         return 1;
//     }
// };
// class FileExistsNode : public ASTNode {
//     std::string filename;

// public:
//     FileExistsNode(const char* fname) : filename(fname) {}

//     int eval(std::map<std::string, int>&) override {
//         std::ifstream file(filename);
//         return file.good() ? 1 : 0;
//     }
// };

#endif // AST_H
