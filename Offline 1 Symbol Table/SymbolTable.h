//
// Created by zeeon on 5/23/22.
//

#ifndef OFFLINE_1_SYMBOL_TABLE_SYMBOLTABLE_H
#define OFFLINE_1_SYMBOL_TABLE_SYMBOLTABLE_H

#include "ScopeTable.h"

class SymbolTable {
private:
    ScopeTable *currentScopeTable;
public:
    SymbolTable(int bucketSize) {
        currentScopeTable = new ScopeTable(bucketSize);
    }

    bool insert(string name, string type) {

        if (currentScopeTable->insert(const_cast<char *>(name.c_str()), type)) {
            return true;
        } else {
            return false;
        }
    }

    SymbolInfo* lookUp(string name) {

        return currentScopeTable->lookUp(name);
    }

    bool remove(string name) {
        if (lookUp(name) == nullptr) {
            return false;
        } else {
            return true;
        }
    }

    void printAllScopeTable() {
        cout << "All scope tables coming up" << endl;
    }

    void printCurrentScopeTable() {
        cout << "Current Scope table coming up" << endl;
        currentScopeTable->print();
    }

    void enterNewScope() {
        cout << "Entering into new Scope" << endl;
    }

    void exitCurrentScope() {
        cout << "Exit new scope" << endl;
    }

    virtual ~SymbolTable() {

    }
};


#endif //OFFLINE_1_SYMBOL_TABLE_SYMBOLTABLE_H
