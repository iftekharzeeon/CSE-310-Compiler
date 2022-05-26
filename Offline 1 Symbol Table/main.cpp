#include <iostream>
#include <string>

#include "SymbolTable.h"

using namespace std;

int main() {
    freopen("input.txt",  "r", stdin);
    freopen("output.txt", "w", stdout);

    int numberOfBucket;
    cin >> numberOfBucket;

    SymbolTable *symbolTable = new SymbolTable(numberOfBucket);
    int activeScopeTableCount = 1;

    string input, name, type, secondInput, thirdInput;
    while (cin >> input) {
        if (input == "I") {
            //Insert name type
            cin >> name;
            cin >> type;
            if (activeScopeTableCount == 0) {
                cout << "No active scope table found" << endl;
                continue;
            }
            symbolTable->insert(name, type);
        } else if(input == "L") {
            //Lookup name
            cin >> name;
            if (activeScopeTableCount == 0) {
                cout << "No active scope table found" << endl;
                continue;
            }
            SymbolInfo *symbolInfo = symbolTable->lookUp(name);
            if (symbolInfo == nullptr) {
                cout << "Not found" << endl;
            }
        } else if (input == "D") {
            //Delete name
            cin >> name;
            if (activeScopeTableCount == 0) {
                cout << "No active scope table found" << endl;
                continue;
            }
            symbolTable->remove(name);
        } else if (input == "P") {
            //Print All or Current
            cin >> secondInput;
            if (secondInput == "A") {
                //Print All
                if (activeScopeTableCount == 0) {
                    cout << "No active scope table found" << endl;
                    continue;
                }
                symbolTable->printAllScopeTable();
            } else if (secondInput == "C") {
                //Print Current
                if (activeScopeTableCount == 0) {
                    cout << "No active scope table found" << endl;
                    continue;
                }
                symbolTable->printCurrentScopeTable();
            }
        } else if (input == "S") {
            //EnterNewScope
            activeScopeTableCount++;
            symbolTable->enterNewScope(numberOfBucket);
        } else if (input == "E") {
            //ExitCurrentScope
            if (activeScopeTableCount == 0) {
                cout << "No active scope table found" << endl;
                continue;
            }
            activeScopeTableCount--;
            symbolTable->exitCurrentScope();
        } else {
            //Invalid
            cout << "Invalid Command" << endl;
        }
    }

    cout << "Exiting program" << endl;

    for (int i = 1; i <= activeScopeTableCount; i++) {
        symbolTable->exitCurrentScope();
    }
    return 0;
}