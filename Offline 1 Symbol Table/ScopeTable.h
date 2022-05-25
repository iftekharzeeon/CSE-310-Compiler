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
    SymbolInfo **scopeTable;
    ScopeTable* parentScope;
    string scopeTableId;
    int numberOfChild;
public:

    ScopeTable(int bucketSize)
    {
        this->bucketSize = bucketSize;

        scopeTable = new SymbolInfo*[bucketSize];
        for (int i = 0; i < bucketSize; i++) {
            SymbolInfo *symbolInfo = new SymbolInfo();
            scopeTable[i] = symbolInfo;
        }
        parentScope = nullptr;
        scopeTableId = "1";
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
            symbolInfo = scopeTable[hashValueIndex];
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
        SymbolInfo *symbolInfo = scopeTable[hashValueIndex];
        int counter = 0;
        while (symbolInfo != nullptr && !symbolInfo->getName().empty()) {
            if (symbolInfo->getName() == name) {
                cout << "Found in ScopeTable# " << scopeTableId << " at position " << hashValueIndex << ", " << counter << endl;
                return symbolInfo;
            }
            symbolInfo = symbolInfo->getNextObj();
            counter++;
        }
        return nullptr;
    }

    bool deleteEntry(string name) {
        int hashValueIndex = hashFunction(const_cast<char *>(name.c_str()));
        SymbolInfo *symbolToDelete = lookUp(name);
        if (symbolToDelete == nullptr) {
            cout << "Not found" << endl;
            return false;
        } else {
            SymbolInfo *firstSymbolInfo = scopeTable[hashValueIndex];
            int counter = 0;
            if (symbolToDelete == firstSymbolInfo) {
                if (symbolToDelete->getNextObj() == nullptr) {
                    scopeTable[hashValueIndex]->setName("");
                    scopeTable[hashValueIndex]->setType("");
                } else {
                    scopeTable[hashValueIndex] = symbolToDelete->getNextObj();
                    symbolToDelete->setType("");
                    symbolToDelete->setName("");
                    symbolToDelete->setNextObj(nullptr);
                    delete symbolToDelete;
                }
            } else {
                while (firstSymbolInfo->getNextObj() != symbolToDelete) {
                    firstSymbolInfo = firstSymbolInfo->getNextObj();
                    counter++;
                }
                counter++;
                firstSymbolInfo->setNextObj(symbolToDelete->getNextObj());
                symbolToDelete->setType("");
                symbolToDelete->setName("");
                symbolToDelete->setNextObj(nullptr);
                delete symbolToDelete;
            }
            cout << "Deleted Entry " << hashValueIndex << " , " << counter << " from current ScopeTable";

            return true;
        }
    }

    void print() {
        cout << "ScopeTable# " << scopeTableId << endl;
        for (int i = 0; i < bucketSize; i++) {
            SymbolInfo *symbolInfo = scopeTable[i];
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
        numberOfChild = 0;
        for (int i = 0; i < bucketSize; i++) {
            delete scopeTable[i];
        }
        delete scopeTable;
        cout << "ScopeTable with id " << scopeTableId << " removed" << endl;
        scopeTableId = "";
    }
};


#endif //OFFLINE_1_SYMBOL_TABLE_SCOPETABLE_H
