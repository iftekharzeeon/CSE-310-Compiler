//
// Created by zeeon on 5/23/22.
//

#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

#include <iostream>
#include <string>
#include <vector>

using namespace std;

class SymbolInfo
{
private:
    string name;
    string type;
    SymbolInfo *next;
    string datType;
    int isDefined;
    int varType; //0-> Function 1-> Variable 2->Array
    int numberOfParams;
    string asmName;
    string asmCode;

    vector<string> parametersList;
    vector<SymbolInfo*> paramList;


public:
    SymbolInfo()
    {
        this->name = "";
        this->type = "";
        this->next = nullptr;
        this->isDefined = 0; // The symbol is not defined yet
        this->datType = "";
        this->varType = 0;
        this->numberOfParams = 0;
        this->asmCode = "";
        this->asmName = "";

    }

    SymbolInfo(string name, string type)
    {
        this->name = name;
        this->type = type;
        this-> next = nullptr;
        this->isDefined = 0;
        this->datType = "";
        this->varType = 0;
        this->numberOfParams = 0;
    }

    SymbolInfo(string name, string type, string datType)
    {
        this->name = name;
        this->type = type;
        this-> next = nullptr;
        this->isDefined = 0;
        this->datType = datType;
        this->varType = 0;
        this->numberOfParams = 0;
    }

    SymbolInfo(string name, string type, string datType, int varType)
    {
        this->name = name;
        this->type = type;
        this-> next = nullptr;
        this->isDefined = 0;
        this->datType = datType;
        this->varType = varType;
        this->numberOfParams = 0;
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

    int getIsDefined() {
        return this->isDefined;
    }

    void setIsDefined(int isDefined) {
        this->isDefined = isDefined;
    }

    string getDatType() {
        return this->datType;
    }

    void setDatType(string dataType) {
        this->datType = dataType;
    }

    int getVarType() {
        return this->varType;
    }

    void setVarType(int varType) {
        this->varType = varType;
    }

    int getNumberOfParams() {
        return this->numberOfParams;
    }

    void setNumberOfParams(int numberOfParams) {
        this->numberOfParams = numberOfParams;
    }

    void addParameters(string type) {
        this->parametersList.push_back(type);
    }

    void addParams(SymbolInfo* param) {
        this->paramList.push_back(param);
    }

    vector<string> getParamList() {
        return this->parametersList;
    }

    vector<SymbolInfo*> getParamArgList() {
        return this->paramList;
    }

    string getAsmName() {
        return this->asmName;
    }

    void setAsmName(string asmName) {
        this->asmName = asmName;
    }

    string getAsmCode() {
        return this->asmCode;
    }

    void setAsmCode(string asmCode) {
        this->asmCode = asmCode;
    }

    ~SymbolInfo()
    {
        this->name = "";
        this->type = "";
        this->next = nullptr;
    }
};


#endif
