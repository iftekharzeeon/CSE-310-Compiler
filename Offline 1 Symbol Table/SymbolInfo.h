//
// Created by zeeon on 5/23/22.
//

#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

#include <iostream>
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
        this->name = "";
        this->type = "";
        this->next = nullptr;

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
        this->name = "";
        this->type = "";
        this->next = nullptr;
    }
};


#endif
