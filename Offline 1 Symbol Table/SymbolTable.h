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
        while (currentScopeTable != nullptr) {
            SymbolInfo *symbolInfo = currentScopeTable->lookUp(name);
            if (symbolInfo == nullptr) {
                currentScopeTable = currentScopeTable->getParentScope();
            } else {
                return symbolInfo;
            }
        }
        return nullptr;
    }

    bool remove(string name) {
        if (lookUp(name) == nullptr) {
            return false;
        } else {
            return true;
        }
    }

    void printAllScopeTable() {

    }

    void printCurrentScopeTable() {
        currentScopeTable->print();
    }

    void enterNewScope(int bucketSize) {
        ScopeTable *newScopeTable;
        newScopeTable = new ScopeTable(bucketSize);
        newScopeTable->setParentScope(currentScopeTable);
        currentScopeTable->increaseNumberOfChld();
        int numberOfChildOfCurrentScope = currentScopeTable->getNumberOfChild();
        string nc = to_string(numberOfChildOfCurrentScope);
        string parentId = currentScopeTable->getId();
        string newId = parentId + "." + nc;
        newScopeTable->setId(newId);
        currentScopeTable = newScopeTable;

        cout << "New ScopeTable with scopeTableId " << currentScopeTable->getId() + " created" << endl;
    }

    void exitCurrentScope() {
        cout << "Exit new scope" << endl;
    }

    ~SymbolTable() {

    }
};


#endif //OFFLINE_1_SYMBOL_TABLE_SYMBOLTABLE_H
