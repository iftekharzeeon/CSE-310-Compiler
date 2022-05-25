#include <iostream>
#include <string>

#include "SymbolTable.h"

using namespace std;

int main() {
    freopen("input.txt",  "r", stdin);

    int numberOfBucket;
    cin >> numberOfBucket;

    SymbolTable *symbolTable = new SymbolTable(numberOfBucket);

    string input, name, type, secondInput, thirdInput;
    while (cin >> input) {
        if (input == "I") {
            //Insert name type
            cin >> name;
            cin >> type;
            symbolTable->insert(name, type);
        } else if(input == "L") {
            //Lookup name
            cin >> name;
            SymbolInfo *symbolInfo = symbolTable->lookUp(name);
            if (symbolInfo == nullptr) {
                cout << "Not found" << endl;
            }
        } else if (input == "D") {
            //Delete name
            cin >> name;
            symbolTable->remove(name);
        } else if (input == "P") {
            //Print All or Current
            cin >> secondInput;
            if (secondInput == "A") {
                //Print All
                symbolTable->printAllScopeTable();
            } else if (secondInput == "C") {
                //Print Current
                symbolTable->printCurrentScopeTable();
            }
        } else if (input == "S") {
            //EnterNewScope
            symbolTable->enterNewScope(numberOfBucket);
        } else if (input == "E") {
            //ExitCurrentScope
            symbolTable->exitCurrentScope();
        } else {
            //Invalid
            cout << "Invalid Command" << endl;
        }
    }
    delete symbolTable;
    return 0;
}