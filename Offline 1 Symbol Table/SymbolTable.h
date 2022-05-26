//
// Created by zeeon on 5/23/22.
//

#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include "ScopeTable.h"

class SymbolTable {
private:
    ScopeTable *currentScopeTable;
    int rootScope;
public:
    SymbolTable(int bucketSize) {
        //Initial Scope
        currentScopeTable = new ScopeTable(bucketSize);
        rootScope = 1;
    }

    bool insert(string name, string type) {
        if (currentScopeTable->insert(const_cast<char *>(name.c_str()), type)) {
            return true;
        } else {
            return false;
        }
    }

    SymbolInfo* lookUp(string name) {
        ScopeTable *temp = currentScopeTable;
        while (temp != nullptr) {
            SymbolInfo *symbolInfo = temp->lookUp(name);
            if (symbolInfo == nullptr) {
                temp = temp->getParentScope();
            } else {
                return symbolInfo;
            }
        }
        return nullptr;
    }

    bool remove(string name) {
        return currentScopeTable->deleteEntry(name);
    }

    void printAllScopeTable() {
        cout << endl;
        ScopeTable *temp = currentScopeTable;
        while (temp != nullptr) {
            temp->print();
            cout << endl;
            temp = temp->getParentScope();
        }
    }

    void printCurrentScopeTable() {
        currentScopeTable->print();
    }

    void enterNewScope(int bucketSize) {
        //Initialize a new scope
        ScopeTable *newScopeTable;
        newScopeTable = new ScopeTable(bucketSize);

        if (currentScopeTable == nullptr) {
            rootScope++;
            string newId = to_string(rootScope);
            newScopeTable->setId(newId);
            currentScopeTable = newScopeTable;
        } else {
            newScopeTable->setParentScope(currentScopeTable);
            currentScopeTable->increaseNumberOfChild();
            int numberOfChildOfCurrentScope = currentScopeTable->getNumberOfChild();
            string nc = to_string(numberOfChildOfCurrentScope);
            string parentId = currentScopeTable->getId();
            string newId = parentId + "." + nc;
            newScopeTable->setId(newId);
            currentScopeTable = newScopeTable;
        }

        cout << "New ScopeTable with id " << currentScopeTable->getId() + " created" << endl;
    }

    void exitCurrentScope() {
        ScopeTable* temp = currentScopeTable;
        currentScopeTable = temp->getParentScope();
        delete temp;
    }

    ~SymbolTable() {
        delete currentScopeTable;
    }
};


#endif
