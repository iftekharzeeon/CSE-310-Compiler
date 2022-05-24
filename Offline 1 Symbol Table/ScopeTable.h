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
    string id;
    int numberOfChild;
public:

    ScopeTable(int bucketSize)
    {
        this->bucketSize = bucketSize;
        scopeTable = new SymbolInfo[bucketSize];
        parentScope = nullptr;

        cout << sizeof(scopeTable) << endl;

        numberOfChild = 0;
    }

    unsigned long hashFunction(char *str, int bucketSize)
    {
        unsigned long hash = 0;
        int c;

        while (c = *str++)
            hash = c + (hash << 6) + (hash << 16) - hash;

        return (hash % bucketSize);
    }

    string getId()
    {
        if (parentScope == nullptr) {
            return "1";
        } else {
            string current_id = to_string(parentScope->getNumberOfChild()) + to_string(1);
            return parentScope->id + "." + current_id;
        }
    }

    void setId(string _id)
    {
        this->id = _id;
    }

    bool insert(char *name, string type) {
        int hashValueIndex = hashFunction(name, bucketSize);
        SymbolInfo *symbolInfo = lookUp(name);

        if (symbolInfo != nullptr) {
            return false;
        } else {
            symbolInfo = &scopeTable[hashValueIndex];
            if (symbolInfo->getName() == "") {
                symbolInfo->setName(name);
                symbolInfo->setType(type);
                cout << "Inserted into ScopeTable " << getId() << endl;
            } else {
                while (symbolInfo->getNextObj() != nullptr) {
                    symbolInfo = symbolInfo->getNextObj();
                }
                SymbolInfo *newSymbolInfo;
                newSymbolInfo = new SymbolInfo(name, type);
                symbolInfo->setNextObj(newSymbolInfo);
                cout << "Inserted into ScopeTable " << getId() << endl;
            }
            return true;
        }
    }

    SymbolInfo* lookUp(string name) {
        int hashValueIndex = hashFunction(const_cast<char *>(name.c_str()), bucketSize);
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

    int getNumberOfChild() {
        return numberOfChild;
    }

    ~ScopeTable()
    {

    }
};


#endif //OFFLINE_1_SYMBOL_TABLE_SCOPETABLE_H
