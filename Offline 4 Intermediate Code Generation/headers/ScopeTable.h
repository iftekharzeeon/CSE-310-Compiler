//
// Created by zeeon on 5/23/22.
//

#ifndef SCOPETABLE_H
#define SCOPETABLE_H

#include "SymbolInfo.h"

using namespace std;

class ScopeTable {
private:
    int bucketSize;
    SymbolInfo **scopeTable;
    ScopeTable *parentScope;
    string scopeTableId;
    int numberOfChild;
public:

    ScopeTable(int bucketSize)
    {
        this->bucketSize = bucketSize;

        //Initialize Array of Pointers
        scopeTable = new SymbolInfo*[bucketSize];
        for (int i = 0; i < bucketSize; i++) {
            scopeTable[i] = nullptr;
        }

        parentScope = nullptr;
        scopeTableId = "1";
        numberOfChild = 0;
    }

    //for Windows OS it needs to be unsigned long, for linux it is unsigned int
    unsigned int hashFunction(const char *str)
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

    bool insert(string name, string type) {
        int hashValueIndex = hashFunction(name.c_str());
        SymbolInfo *symbolInfo = existCheck(name); //Check for existence

        if (symbolInfo != nullptr) {
            //Already exists
            // cout << "<" + symbolInfo->getName() + " : " << symbolInfo->getType() + "> already exists in current ScopeTable" << endl;
            return false;
        } else {
            symbolInfo = scopeTable[hashValueIndex];
            if (symbolInfo == nullptr) {
                //Bucket is empty
                SymbolInfo *newSymbolInfo = new SymbolInfo(name, type);
                scopeTable[hashValueIndex] = newSymbolInfo;
                // cout << "Inserted in ScopeTable# " << getId() << " at position " << hashValueIndex << ", 0" << endl;
            } else {
                //Bucket is not empty
                int counter = 1;
                //Get to the last object of the linked list
                while (symbolInfo->getNextObj() != nullptr) {
                    symbolInfo = symbolInfo->getNextObj();
                    counter++;
                }
                SymbolInfo *newSymbolInfo;
                newSymbolInfo = new SymbolInfo(name, type);
                symbolInfo->setNextObj(newSymbolInfo);
                // cout << "Inserted into ScopeTable# " << getId() << " at position " << hashValueIndex << ", " << counter << endl;
            }
            return true;
        }
    }

    bool insert(string name, string type, string datType, int varType) {
        int hashValueIndex = hashFunction(name.c_str());
        SymbolInfo *symbolInfo = existCheck(name); //Check for existence

        if (symbolInfo != nullptr) {
            //Already exists
            // cout << "<" + symbolInfo->getName() + " : " << symbolInfo->getType() + "> already exists in current ScopeTable" << endl;
            return false;
        } else {
            symbolInfo = scopeTable[hashValueIndex];
            if (symbolInfo == nullptr) {
                //Bucket is empty
                SymbolInfo *newSymbolInfo = new SymbolInfo(name, type, datType, varType);
                scopeTable[hashValueIndex] = newSymbolInfo;
                // cout << "Inserted in ScopeTable# " << getId() << " at position " << hashValueIndex << ", 0" << endl;
            } else {
                //Bucket is not empty
                int counter = 1;
                //Get to the last object of the linked list
                while (symbolInfo->getNextObj() != nullptr) {
                    symbolInfo = symbolInfo->getNextObj();
                    counter++;
                }
                SymbolInfo *newSymbolInfo;
                newSymbolInfo = new SymbolInfo(name, type, datType);
                symbolInfo->setNextObj(newSymbolInfo);
                // cout << "Inserted into ScopeTable# " << getId() << " at position " << hashValueIndex << ", " << counter << endl;
            }
            return true;
        }
    }

    SymbolInfo* existCheck(string name) {
        //Get the bucket
        int hashValueIndex = hashFunction(name.c_str());
        SymbolInfo *symbolInfo = scopeTable[hashValueIndex];

        int counter = 0;
        while (symbolInfo != nullptr) {
            //if nullptr, then no object exists
            if (symbolInfo->getName() == name) {
                return symbolInfo;
            }
            symbolInfo = symbolInfo->getNextObj();
            counter++;
        }
        return nullptr;
    }

    SymbolInfo* lookUp(string name) {
        //Get the bucket
        int hashValueIndex = hashFunction(name.c_str());
        SymbolInfo *symbolInfo = scopeTable[hashValueIndex];

        int counter = 0;
        while (symbolInfo != nullptr) {
            //if nullptr, then no object exists
            if (symbolInfo->getName() == name) {
                // cout << "Found in ScopeTable# " << scopeTableId << " at position " << hashValueIndex << ", " << counter << endl;
                return symbolInfo;
            }
            symbolInfo = symbolInfo->getNextObj();
            counter++;
        }
        return nullptr;
    }

    bool deleteEntry(string name) {
        //Look for existence
        int hashValueIndex = hashFunction(name.c_str());
        SymbolInfo *symbolToDelete = lookUp(name);

        if (symbolToDelete == nullptr) {
            //Not exist
            cout << "Not found" << endl;
            return false;
        } else {
            //Found
            SymbolInfo *firstSymbolInfo = scopeTable[hashValueIndex]; //Get the first object of the bucket
            int counter = 0;

            if (symbolToDelete == firstSymbolInfo) {
                //First object needs to be deleted
                if (symbolToDelete->getNextObj() == nullptr) {
                    //No sibling of first object
                    scopeTable[hashValueIndex]->setName("");
                    scopeTable[hashValueIndex]->setType("");
                    scopeTable[hashValueIndex] = nullptr;
                    delete symbolToDelete;
                } else {
                    //First object has siblings, first sibling will be the new first object now
                    scopeTable[hashValueIndex] = symbolToDelete->getNextObj();
                    symbolToDelete->setType("");
                    symbolToDelete->setName("");
                    symbolToDelete->setNextObj(nullptr);
                    delete symbolToDelete;
                }
            } else {
                //Any serial other than first object
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
            cout << "Deleted Entry " << hashValueIndex << " , " << counter << " from current ScopeTable" << endl;

            return true;
        }
    }

    string print() {
        string outputMsg = "";
        outputMsg += "ScopeTable# " + scopeTableId + "\n";
        // cout << "ScopeTable# " << scopeTableId << endl;
        for (int i = 0; i < bucketSize; i++) {
            SymbolInfo *symbolInfo = scopeTable[i];
            if (symbolInfo != nullptr) {
                outputMsg += to_string(i) + " --> ";
                outputMsg += "<" + symbolInfo->getName() + " : " + symbolInfo->getType() + "> "; 
                // cout << i << " --> ";
                // cout << "<" << symbolInfo->getName() << " : " << symbolInfo->getType() << "> ";
                while (symbolInfo->getNextObj() != nullptr) { //Get the siblings
                    symbolInfo = symbolInfo->getNextObj();
                    outputMsg += "<" + symbolInfo->getName() + " : " + symbolInfo->getType() + "> ";
                    // cout << "<" << symbolInfo->getName() << " : " << symbolInfo->getType() << "> ";
                }
                outputMsg += "\n";
            }
            // cout << endl;
        }
        return outputMsg;
    }

    ScopeTable *getParentScope() {
        return parentScope;
    }

    void setParentScope(ScopeTable *parentScope) {
        this->parentScope = parentScope;
    }

    void increaseNumberOfChild() {
        this->numberOfChild++;
    }

    int getNumberOfChild() {
        return numberOfChild;
    }

    ~ScopeTable()
    {
        //Called when delete calls
        numberOfChild = 0;
        for (int i = 0; i < bucketSize; i++) {
            if (scopeTable[i] != nullptr) {
                delete scopeTable[i];
            }
        }
        delete scopeTable;
    }
};


#endif
