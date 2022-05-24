//
// Created by zeeon on 5/23/22.
//

#ifndef OFFLINE_1_SYMBOL_TABLE_SYMBOLINFO_H
#define OFFLINE_1_SYMBOL_TABLE_SYMBOLINFO_H

#include <iostream>
#include <bits/stdc++.h>
#include <string>

using namespace std;

class SymbolInfo
{
private:
    string name;
    string type;
    SymbolInfo *next;
public:
    SymbolInfo(/* args */)
    {

    }

    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        this-> next = nullptr;
    }

    string getName()
    {
        return this-> name;
    }

    string getType()
    {
        return this->type;
    }

    void setName(string name)
    {
        this->name = name;
    }

    void setType(string type)
    {
        this->type = type;
    }

    SymbolInfo* getNextObj()
    {
        return this->next;
    }

    void setNextObj(SymbolInfo *nextObj)
    {
        this->next = nextObj;
    }

    ~SymbolInfo()
    {
        //this->name = "";
        //this->type = "";
        //delete this->next;
    }
};


#endif //OFFLINE_1_SYMBOL_TABLE_SYMBOLINFO_H