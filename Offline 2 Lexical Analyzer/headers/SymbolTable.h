//
// Created by zeeon on 5/23/22.
//

#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include "ScopeTable.h"


class SymbolTable {
private:
    ScopeTable *currentScopeTable;
public:
    SymbolTable(int bucketSize) {
        //Initial Scope
        currentScopeTable = new ScopeTable(bucketSize);
        // cout << "ScopeTable #1 Initiated" << endl;
    }

    bool insert(string name, string type) {
        if (currentScopeTable->insert(name, type)) {
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

    string printAllScopeTable() {
        string outputMsg = "";
        // cout << endl;
        ScopeTable *temp = currentScopeTable;
        while (temp != nullptr) {
            outputMsg += temp->print();
            // cout << endl;
            temp = temp->getParentScope();
            outputMsg += "\n";
        }
        // outputMsg += "\n";
        return outputMsg;
    }

    void printCurrentScopeTable() {
        currentScopeTable->print();
    }

    void enterNewScope(int bucketSize) {
        //Initialize a new scope
        ScopeTable *newScopeTable;
        newScopeTable = new ScopeTable(bucketSize);

        newScopeTable->setParentScope(currentScopeTable);
        currentScopeTable->increaseNumberOfChild();
        int numberOfChildOfCurrentScope = currentScopeTable->getNumberOfChild();
        string nc = to_string(numberOfChildOfCurrentScope);
        string parentId = currentScopeTable->getId();
        string newId = parentId + "." + nc;
        newScopeTable->setId(newId);
        currentScopeTable = newScopeTable;

        // cout << "New ScopeTable with id " << currentScopeTable->getId() + " created" << endl;
    }

    void exitCurrentScope() {
        ScopeTable *scopeTable = currentScopeTable->getParentScope();
        // cout << "ScopeTable with id " << currentScopeTable->getId() << " removed" << endl;
        delete currentScopeTable;
        currentScopeTable = scopeTable;   
    }

    ~SymbolTable() {
        
    }
};


#endif
