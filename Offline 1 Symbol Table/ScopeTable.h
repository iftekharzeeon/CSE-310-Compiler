//
// Created by zeeon on 5/23/22.
//

#ifndef OFFLINE_1_SYMBOL_TABLE_SCOPETABLE_H
#define OFFLINE_1_SYMBOL_TABLE_SCOPETABLE_H

#include <iostream>
#include <bits/stdc++.h>

#include "SymbolInfo.h"

using namespace std;

class ScopeTable {
private:
    int bucketSize;
    SymbolInfo *scopeTable;
    ScopeTable* parentScope;
    string scopeTableId;
    int numberOfChild;
public:

    ScopeTable(int bucketSize)
    {
        this->bucketSize = bucketSize;
        scopeTable = new SymbolInfo[bucketSize];
        parentScope = nullptr;
        numberOfChild = 0;
    }

    unsigned int hashFunction(char *str)
    {
        unsigned int hash = 0;
        int c;

        while (c = *str++)
            hash = c + (hash << 6) + (hash << 16) - hash;

        return (hash % bucketSize);
    }

    string getId() {
        return this->scopeTableId;
    }

    void setId(string _id)
    {
        this->scopeTableId = _id;
    }

    bool insert(char *name, string type) {
        int hashValueIndex = hashFunction(name);
        SymbolInfo *symbolInfo = lookUp(name);

        if (symbolInfo != nullptr) {
            return false;
        } else {
            symbolInfo = &scopeTable[hashValueIndex];
            if (symbolInfo->getName() == "") {
                symbolInfo->setName(name);
                symbolInfo->setType(type);
                cout << "Inserted into ScopeTable# " << getId() << " at position " << hashValueIndex << ", 0" << endl;
            } else {
                int counter = 1;
                while (symbolInfo->getNextObj() != nullptr) {
                    symbolInfo = symbolInfo->getNextObj();
                    counter++;
                }
                SymbolInfo *newSymbolInfo;
                newSymbolInfo = new SymbolInfo(name, type);
                symbolInfo->setNextObj(newSymbolInfo);
                cout << "Inserted into ScopeTable " << getId() << " at position " << hashValueIndex << ", " << counter << endl;
            }
            return true;
        }
    }

    SymbolInfo* lookUp(string name) {
        int hashValueIndex = hashFunction(const_cast<char *>(name.c_str()));
        SymbolInfo *symbolInfo = &scopeTable[hashValueIndex];
        while (symbolInfo != nullptr && !symbolInfo->getName().empty()) {
            if (symbolInfo->getName() == name) {
                return symbolInfo;
            }
            symbolInfo = symbolInfo->getNextObj();
        }
        return nullptr;
    }

    void print() {
        for (int i = 0; i < bucketSize; i++) {
            SymbolInfo *symbolInfo = &scopeTable[i];
            cout << i << " --> ";
            if (!symbolInfo->getName().empty()) {
                cout << "<" << symbolInfo->getName() << " : " << symbolInfo->getType() << "> ";
                while (symbolInfo->getNextObj() != nullptr) {
                    symbolInfo = symbolInfo->getNextObj();
                    cout << "<" << symbolInfo->getName() << " : " << symbolInfo->getType() << "> ";
                }
            }
            cout << endl;
        }
    }

    ScopeTable *getParentScope() {
        return parentScope;
    }

    void setParentScope(ScopeTable *parentScope) {
        this->parentScope = parentScope;
    }

    void increaseNumberOfChld() {
        this->numberOfChild++;
    }

    int getNumberOfChild() {
        return numberOfChild;
    }

    ~ScopeTable()
    {

    }
};


#endif //OFFLINE_1_SYMBOL_TABLE_SCOPETABLE_H
