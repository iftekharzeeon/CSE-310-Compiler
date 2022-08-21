%{
#include<iostream>
#include<bits/stdc++.h>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "headers/SymbolTable.h"
#include "util/AssemblyCode.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int lineCount;
extern int errorCount;
extern string logFileText;
extern string errorFileText;

SymbolTable *symbolTable = new SymbolTable(7);

FILE *fp;
FILE *logFile;
FILE *errorFile;
FILE *asmCodeFile;
FILE *asmCodeFileData;
FILE *asmCodeFileCode;
FILE *asmCodeFileProc;

vector<SymbolInfo*> parametersList;
vector<SymbolInfo*> argumentList;
vector<string> temporaryVariablesAsmList;

string typeName = "";
string asmCode = "";
string dataSegment = "";
string codeSegment = "";

int variableCount = 0;
int conditionCount = 0;

void yyerror(char *s)
{
	errorCount++;
	errorFileText += "Error at line " + to_string(lineCount) + ": syntax error " + "\n\n";
	logFileText += "Error at line " + to_string(lineCount) + ": syntax error " + "\n\n";
	cout << s << endl;

	return;
}


%}

%union {
	SymbolInfo *symbolInfo;
}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN
%token ADDOP INCOP DECOP MULOP RELOP ASSIGNOP LOGICOP NOTOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON NOT
%token ID CONST_INT CONST_FLOAT CONST_CHAR

%type <symbolInfo> ID
%type <symbolInfo> CONST_INT
%type <symbolInfo> CONST_FLOAT
%type <symbolInfo> CONST_CHAR
%type <symbolInfo> ADDOP
%type <symbolInfo> MULOP
%type <symbolInfo> RELOP
%type <symbolInfo> LOGICOP

%type <symbolInfo> start program unit var_declaration type_specifier declaration_list func_declaration
%type <symbolInfo> func_definition variable parameter_list error

%type <symbolInfo> expression_statement compound_statement statements unary_expression factor statement
%type <symbolInfo> expression logic_expression simple_expression rel_expression term arguments argument_list

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program 
	{
		logFileText += "Line " + to_string(lineCount) + ": start : program\n\n\n";
		$$ = $1;
		asmCode = $1->getAsmCode();

		printToCodeAsmFile(asmCodeFileCode, asmCode);
	}
	;



program : program unit {
			logFileText += "\nLine " + to_string(lineCount) + ": program : program unit\n\n" + $1->getName() + "\n" + $2->getName() + "\n\n\n";
			$$ = $1;
			$$->setName($1->getName() + "\n" + $2->getName());

			$$->setAsmCode($1->getAsmCode() + $2->getAsmCode());
		}
		| unit {
			logFileText += "\nLine " + to_string(lineCount) + ": program : unit\n\n" + $1->getName() + "\n\n\n";
			$$ = $1;
		}
		;
	
unit : var_declaration {

		logFileText += "Line " + to_string(lineCount) + ": unit : var_declaration\n\n" + $1->getName() + "\n\n";
		
		$$ = $1;
	}
    | func_declaration {

		logFileText += "Line " + to_string(lineCount) + ": unit : func_declaration\n\n" + $1->getName() + "\n\n";

		$$ = $1;
	}
    | func_definition {
		logFileText += "Line " + to_string(lineCount) + ": unit : func_definition\n\n" + $1->getName() + "\n\n";

		$$ = $1;
	}
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
					logFileText += "Line " + to_string(lineCount) + ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n" + $1->getName() + " " + $2->getName() + "(" + $4->getName() + ");\n\n";
					$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "(" + $4->getName() + ");", "func_declaration");

					SymbolInfo *symbolInfo = symbolTable->lookUp($2->getName());
					if (symbolInfo == nullptr) {
						symbolTable->insert($2->getName(), $2->getType());
						symbolInfo = symbolTable->lookUp($2->getName());
						symbolInfo->setDatType($1->getName());	
						symbolInfo->setNumberOfParams(parametersList.size());					
					} else {
						// Error 
						errorCount++;
						errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $2->getName() + "\n\n";
						logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $2->getName() + "\n\n";
					}

					parametersList.clear();
				}
				| type_specifier ID LPAREN RPAREN SEMICOLON {
					logFileText += "Line " + to_string(lineCount) + ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n" + $1->getName() + " " + $2->getName() + "();\n\n";
					$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "();", "func_declaration");

					SymbolInfo *symbolInfo = symbolTable->lookUp($2->getName());
					if (symbolInfo == nullptr) {
						symbolTable->insert($2->getName(), $2->getType());
						symbolInfo = symbolTable->lookUp($2->getName());
						symbolInfo->setDatType($1->getName());
					} else {
						// Error 
						errorCount++;
						errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $2->getName() + "\n\n";
						logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $2->getName() + "\n\n";
					}
				}
				;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {
			asmCode = "";

			SymbolInfo *symbolInfo = symbolTable->lookUp($2->getName());
			if (symbolInfo == nullptr) {
				symbolTable->insert($2->getName(), $2->getType());
				symbolInfo = symbolTable->lookUp($2->getName());
				symbolInfo->setDatType($1->getName());
				symbolInfo->setNumberOfParams(parametersList.size());
			} else {

				int isDefined = symbolInfo->getIsDefined();
				int variableType = symbolInfo->getVarType();

				if (isDefined == 0 && variableType == 0) {
					symbolInfo->setIsDefined(1);
					if ($1->getName() != symbolInfo->getDatType()) {
						errorCount++;
						logFileText += "Error at line " + to_string(lineCount) + ": Return type mismatch with function declaration in function " + $2->getName() + "\n\n";
						errorFileText += "Error at line " + to_string(lineCount) + ": Return type mismatch with function declaration in function " + $2->getName() + "\n\n";
					}

					if (symbolInfo->getNumberOfParams() != parametersList.size()) {
						errorCount++;
						logFileText += "Error at line " + to_string(lineCount) + ": Total number of arguments mismatch with declaration in function " + $2->getName() + "\n\n";
						errorFileText += "Error at line " + to_string(lineCount) + ": Total number of arguments mismatch with declaration in function " + $2->getName() + "\n\n";
					}
					
				} else {
					// Error
					errorCount++;
					errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $2->getName() + "\n\n";
					logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $2->getName() + "\n\n";
				}
			}
			}
			compound_statement {
			
			string output = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $7->getName();
			logFileText += "Line " + to_string(lineCount) + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" + output + "\n\n";
			$$ = new SymbolInfo(output, "func_definition");

			int paramListSize = parametersList.size();
			int i = 0;
			while (i != paramListSize) {
				SymbolInfo *s1 = parametersList.at(i);
				SymbolInfo *t = symbolTable->lookUp($2->getName());
				t->addParameters(s1->getType());
				t->addParams(s1);
				i++;
				
			}

			asmCode = $4->getAsmCode();

			printToDataAsmFile(asmCodeFileData, asmCode);

			asmCode = "";
			string functionName = $2->getName();
			transform(functionName.begin(), functionName.end(), functionName.begin(), ::toupper);

			asmCode += functionName + " PROC NEAR\n\n";
			asmCode += "\tPOP CX\n";
			asmCode += $7->getAsmCode();
			asmCode += "\tPUSH CX\n";
			asmCode += "\n\tRET\n\n"
						"" + functionName + " ENDP\n";
			
			printToProcAsmFile(asmCodeFileProc, asmCode);

			parametersList.clear();
			
		}
		| type_specifier ID LPAREN RPAREN {
			SymbolInfo *symbolInfo = symbolTable->lookUp($2->getName());
			if (symbolInfo == nullptr) {
				symbolTable->insert($2->getName(), $2->getType());
				symbolInfo = symbolTable->lookUp($2->getName());
				symbolInfo->setDatType($1->getName());
			} else {
				
				int isDefined = symbolInfo->getIsDefined();

				if (isDefined == 0) {
					symbolInfo->setIsDefined(1);
				} else {
					// Error
					errorCount++;
					errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $2->getName() + "\n\n";
					logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $2->getName() + "\n\n";
				}
			}
		}
		compound_statement {
			asmCode = "";

			string output = $1->getName() + " " + $2->getName() + "()" + $6->getName();
			logFileText += "Line " + to_string(lineCount) + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n" + output + "\n\n";
			$$ = new SymbolInfo(output, "func_definition");
			
			if ($2->getName() == "main") {
				$$->setAsmCode($6->getAsmCode());
			} else {
				string functionName = $2->getName();
				transform(functionName.begin(), functionName.end(), functionName.begin(), ::toupper);

				asmCode += functionName + " PROC NEAR\n\n";
				asmCode += "\tPOP CX\n";
				asmCode += $6->getAsmCode();
				asmCode += "\tPUSH CX\n";
				asmCode += "\n\tRET\n\n"
							"" + functionName + " ENDP\n";
				
				printToProcAsmFile(asmCodeFileProc, asmCode);

			}

		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {
					asmCode = "";

					asmCode += $1->getAsmCode();

					logFileText += "Line " + to_string(lineCount) + ": parameter_list : parameter_list COMMA type_specifier ID\n\n";
					

					SymbolInfo *s1 = new SymbolInfo($4->getName(), $3->getName());

					for (vector<SymbolInfo*>::iterator it = parametersList.begin(); it != parametersList.end(); ++it) {
						if ((*it)->getName() == s1->getName()) {
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
						}
					}	

					logFileText += $1->getName() + "," + $3->getName() + " " + $4->getName() + "\n\n";
					$$ = $1;
					$$->setName($1->getName() + "," + $3->getName() + " " + $4->getName());

					//AssemblyCode
					string temporaryVariableName = "temp_" + s1->getName();

					if ( std::find(temporaryVariablesAsmList.begin(), temporaryVariablesAsmList.end(), temporaryVariableName) != temporaryVariablesAsmList.end() ) {
						s1->setAsmName(temporaryVariableName);
					} else {
						temporaryVariablesAsmList.push_back(temporaryVariableName);
						s1->setAsmName(temporaryVariableName);
						asmCode += "\t" + temporaryVariableName + " DW ?\n";	
					}

					$$->setAsmCode(asmCode);

					parametersList.push_back(s1);


				}
				| parameter_list COMMA type_specifier {
					logFileText += "Line " + to_string(lineCount) + ": parameter_list : parameter_list COMMA type_specifier\n\n";

					SymbolInfo *s1 = new SymbolInfo("", $3->getName());

					for (vector<SymbolInfo*>::iterator it = parametersList.begin(); it != parametersList.end(); ++it) {
						if ((*it)->getName() == s1->getName()) {
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
						}
					}

					logFileText += $1->getName() + "," + $3->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + "," + $3->getName(), "PARAM_LIST");

					parametersList.push_back(s1);
				}
				| type_specifier ID {
					asmCode = "";

					logFileText += "Line " + to_string(lineCount) + ": parameter_list : type_specifier ID\n\n";

					SymbolInfo *s1 = new SymbolInfo($2->getName(), $1->getName());

					for (vector<SymbolInfo*>::iterator it = parametersList.begin(); it != parametersList.end(); ++it) {
						if ((*it)->getName() == s1->getName()) {
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
						}
					}

					logFileText += $1->getName() + " " + $2->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + " " + $2->getName(), "PARAM_LIST");

					//AssemblyCode
					string temporaryVariableName = "temp_" + s1->getName();

					if ( std::find(temporaryVariablesAsmList.begin(), temporaryVariablesAsmList.end(), temporaryVariableName) != temporaryVariablesAsmList.end() ) {
						s1->setAsmName(temporaryVariableName);
					} else {
						temporaryVariablesAsmList.push_back(temporaryVariableName);
						s1->setAsmName(temporaryVariableName);
						asmCode += "\t" + temporaryVariableName + " DW ?\n";
					}

					$$->setAsmCode(asmCode);

					parametersList.push_back(s1);

				}
				| type_specifier {
					logFileText += "Line " + to_string(lineCount) + ": parameter_list : type_specifier\n\n";
					$$ = new SymbolInfo($1->getName(), "PARAM_LIST");

					SymbolInfo *s1 = new SymbolInfo("", $1->getName());

					for (vector<SymbolInfo*>::iterator it = parametersList.begin(); it != parametersList.end(); ++it) {
						if ((*it)->getName() == s1->getName()) {
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
						}
					}

					logFileText += $1->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName(), "PARAM_LIST");

					parametersList.push_back(s1);
				} 
				| type_specifier error {
					cout << $2->getName() << endl;
					logFileText += "Line " + to_string(lineCount) + ": parameter_list : type_specifier\n\n";
					$$ = new SymbolInfo($1->getName(), "PARAM_LIST");

					SymbolInfo *s1 = new SymbolInfo("", $1->getName());

					for (vector<SymbolInfo*>::iterator it = parametersList.begin(); it != parametersList.end(); ++it) {
						if ((*it)->getName() == s1->getName()) {
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
						}
					}

					logFileText += $1->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName(), "PARAM_LIST");

					parametersList.push_back(s1);
				}
				;

 		
compound_statement : LCURL {
						symbolTable->enterNewScope(7);

						int paramListSize = parametersList.size();
						int i = 0;
						while (i != paramListSize) {
							SymbolInfo *s1 = parametersList.at(i);
							symbolTable->insert(s1->getName(), "ID");
							i++;
							
						}
					}
					statements RCURL {
					asmCode = "";
					
					asmCode += $3->getAsmCode();

					logFileText += "Line " + to_string(lineCount) + ": compound_statement : LCURL statements RCURL\n\n" + "{\n" + $3->getName() + "\n}\n\n\n";
					
					logFileText += symbolTable->printAllScopeTable();

					symbolTable->exitCurrentScope();
					
					$$ = $3;
					$$->setName("{\n" + $3->getName() + "\n}\n");
					$$->setAsmCode(asmCode);

					
				}
				| LCURL {
					symbolTable->enterNewScope(7);
				}
				RCURL {
					logFileText += "Line " + to_string(lineCount) + ": compound_statement : LCURL RCURL\n\n{}\n\n";
					$$ = new SymbolInfo("{}", "COMP_STATEMENT");
					logFileText += symbolTable->printAllScopeTable();
					symbolTable->exitCurrentScope();
				}
				;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
					logFileText += "Line " + to_string(lineCount) + ": var_declaration : type_specifier declaration_list SEMICOLON\n\n";
					
					if ($1->getName() == "void") {
						errorCount++;
						logFileText += "Error at line " + to_string(lineCount) + ": Variable type cannot be void\n\n";
						errorFileText += "Error at line " + to_string(lineCount) + ": Variable type cannot be void\n\n";
					}
					logFileText += $1->getName() + " " + $2->getName() + ";\n\n";
					$$ = new SymbolInfo($1->getName() + " " + $2->getName() + ";", "var_declaration");
					typeName = "";

				}
 				;
 		 
type_specifier	: INT {
					logFileText += "Line " + to_string(lineCount) + ": type_specifier : INT\n\nint\n\n"; 
					$$ = new SymbolInfo("int", "type_specifier");
					typeName = "int";
				}
 				| FLOAT {
					logFileText += "Line " + to_string(lineCount) + ": type_specifier : FLOAT\n\nfloat\n\n";
					$$ = new SymbolInfo("float", "type_specifier");
					typeName = "float";
				}
 				| VOID {
					logFileText += "Line " + to_string(lineCount) + ": type_specifier : VOID\n\nvoid\n\n";
					$$ = new SymbolInfo("void", "type_specifier");
					typeName = "void";
				}
 				;
 		
declaration_list : declaration_list COMMA ID {

					asmCode = "";

					asmCode += $1->getAsmCode();

					if (!symbolTable->insert($3->getName(), $3->getType(), typeName, 1)) {
						errorCount++;
						errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $3->getName() + "\n\n";
						logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $3->getName() + "\n\n";
					}

					logFileText += "Line " + to_string(lineCount) + ": declaration_list : declaration_list COMMA ID\n\n" + $1->getName() + "," + $3->getName() + "\n\n";
					$$ = $1;
					$$ = new SymbolInfo($1->getName() + "," + $3->getName(), "declaration_list");

					//AssemblyCode
					variableCount++;
					string variableNameForAsm = $3->getName() + "_" + to_string(variableCount);

					$$->setAsmName(variableNameForAsm);
					symbolTable->lookUp($3->getName())->setAsmName(variableNameForAsm);
					asmCode += "\t" + variableNameForAsm + " DW ?";
					printToDataAsmFile(asmCodeFileData, asmCode);

					// $$->setAsmCode(asmCode);

				}
				| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
					if (!symbolTable->insert($3->getName(), $3->getType(), typeName, 2)) {
						errorCount++;
						errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $3->getName() + "\n\n";
						logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $3->getName() + "\n\n";
					}

					logFileText += "Line " + to_string(lineCount) + ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n" + $1->getName() + "," + $3->getName() + "[" + $5->getName() + "]" + "\n\n";
					$$ = $1;
					$$ = new SymbolInfo($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]", "declaration_list");
				}
 		  		| ID {
					asmCode = "";

					if (!symbolTable->insert($1->getName(), $1->getType(), typeName, 1)) {
						errorCount++;
						errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $1->getName() + "\n\n";
						logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $1->getName() + "\n\n";
					}

					$$ = $1;
					logFileText += "Line " + to_string(lineCount) + ": declaration_list : ID\n\n" + $1->getName() + "\n\n";


					//AssemblyCode
					variableCount++;
					string variableNameForAsm = $1->getName() + "_" + to_string(variableCount);

					$$->setAsmName(variableNameForAsm);
					symbolTable->lookUp($1->getName())->setAsmName(variableNameForAsm);
					asmCode += "\t" + variableNameForAsm + " DW ?";
					printToDataAsmFile(asmCodeFileData, asmCode);

					// $$->setAsmCode(asmCode);


				} 
				| ID error {
					if (!symbolTable->insert($1->getName(), $1->getType(), typeName, 1)) {
						errorCount++;
						errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $1->getName() + "\n\n";
						logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $1->getName() + "\n\n";
					}

					$$ = $1;
					logFileText += "Line " + to_string(lineCount) + ": declaration_list : ID\n\n" + $1->getName() + "\n\n";
				}
 		  		| ID LTHIRD CONST_INT RTHIRD {

					if (!symbolTable->insert($1->getName(), $1->getType(), typeName, 2)) {
						errorCount++;
						errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $1->getName() + "\n\n";
						logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $1->getName() + "\n\n";
					}

					logFileText += "Line " + to_string(lineCount) + ": declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n" + $1->getName() + "[" + $3->getName() + "]" + "\n\n";
					$$ = new SymbolInfo($1->getName() + "[" + $3->getName() + "]", "declaration_list");
				}
 		  		;
 		  
statements : statement {
				logFileText += "Line " + to_string(lineCount) + ": statements : statement\n\n" + $1->getName() + "\n\n";
				$$ = $1;
			}
			| statements statement {
				asmCode = "";
				asmCode += $1->getAsmCode() + $2->getAsmCode();
				logFileText += "Line " + to_string(lineCount) + ": statements : statements statement\n\n" + $1->getName() + "\n" + $2->getName() + "\n\n";
				$$ = $1;
				$$->setName($1->getName() + "\n" + $2->getName());

				$$->setAsmCode(asmCode);
			}
	   		;
	   
statement : var_declaration {
			logFileText += "Line " + to_string(lineCount) + ": statement : var_declaration\n\n" + $1->getName() + "\n\n";
			$$ = $1;
		}
		| expression_statement {
			logFileText += "Line " + to_string(lineCount) + ": statement : expression_statement\n\n" + $1->getName() + "\n\n";
			$$ = $1;
		}
		| compound_statement {
			logFileText += "Line " + to_string(lineCount) + ": statement : compound_statement\n\n" + $1->getName() + "\n\n";
			$$ = $1;

		}
		| FOR LPAREN expression_statement expression_statement expression RPAREN statement {
			asmCode = "";

			string output = "for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName(); 
			logFileText += "Line " + to_string(lineCount) + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n" + output + "\n\n";
			$$ = $7;

			$$->setName(output);

			string newLabel1 = newLabel();
			string newLabel2 = newLabel();
			string newLabel3 = newLabel();

			//AssemblyCode

			string initializationPart = $3->getAsmCode();
			string checkingPart = $4->getAsmCode();
			string incDecPart = $5->getAsmCode();
			string statement = $7->getAsmCode();

			asmCode += "\t;for(" + $3->getName() + $4->getName() + $5->getName() + ")\n";

			asmCode += initializationPart;
			asmCode += newLabel1 + ":\n";
			asmCode += checkingPart;
			asmCode += "\tPOP AX\n"
						"\tCMP AX, 1\n"
						"\tJGE " + newLabel2 + "\n"
						"\tJMP " + newLabel3 + "\n"
						"" + newLabel2 + ":\n";
			asmCode += statement;
			asmCode += incDecPart;
			asmCode += "\tJMP " + newLabel1 + "\n";
			asmCode += newLabel3 + ":\n";

			$$->setAsmCode(asmCode);
		}
		| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
			asmCode = "";

			asmCode += $3->getAsmCode();

			string output = "if (" + $3->getName() + ")" + $5->getName(); 
			logFileText += "Line " + to_string(lineCount) + ": statement : IF LPAREN expression RPAREN statement\n\n" + output + "\n\n";
			$$ = $5;

			$$->setName(output);

			string newLabel1 = newLabel();

			//AssemblyCode

			asmCode += "\t;if (" + $3->getName() + ")\n";

			asmCode += "\tPOP AX\n"
						"\tCMP AX, 1\n"
						"\tJNE " + newLabel1 + "\n"
						"" + $5->getAsmCode() + "\n"
						"" + newLabel1 + ":\n";
			
			$$->setAsmCode(asmCode);
			$$->setAsmName("");
		}
		| IF LPAREN expression RPAREN statement ELSE statement {
			asmCode = "";

			asmCode += $3->getAsmCode();

			string output = "if (" + $3->getName() + ")" + $5->getName() + "else\n" + $7->getName(); 
			logFileText += "Line " + to_string(lineCount) + ": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n" + output + "\n\n";
			$$ = $7;

			$$->setName(output);

			string newLabel1 = newLabel();
			string newLabel2 = newLabel();
			string newLabel3 = newLabel();

			//AssemblyCode

			asmCode += "\t;if (" + $3->getName() + ") else\n";

			asmCode += "\tPOP AX\n"
						"\tCMP AX, 1\n"
						"\tJNE " + newLabel1 + "\n"
						"" + $5->getAsmCode() + "\n"
						"\tJMP " + newLabel3 + "\n\n"
						"" + newLabel1 + ":\n"
						"" + $7->getAsmCode() + "\n\n"
						"" + newLabel3 + ":\n";
			
			$$->setAsmCode(asmCode);
			$$->setAsmName("");
		}
		| WHILE LPAREN expression RPAREN statement {
			asmCode = "";

			string output = "while (" + $3->getName() + ")" + $5->getName(); 
			logFileText += "Line " + to_string(lineCount) + ": statement : WHILE LPAREN expression RPAREN statement\n\n" + output + "\n\n";
			$$ = $5;

			$$->setName(output);

			//AssemblyCode

			string newLabel1 = newLabel();
			string newLabel2 = newLabel();
			string newLabel3 = newLabel();

			string checkingPart = $3->getAsmCode();
			string statement = $5->getAsmCode();

			asmCode += newLabel1 + ":\n";
			asmCode += checkingPart;
			asmCode += "\tPOP AX\n"
						"\tCMP AX, 1\n"
						"\tJGE " + newLabel2 + "\n"
						"\tJMP " + newLabel3 + "\n"
						"" + newLabel2 + ":\n";
			
			asmCode += statement;
			asmCode += "\tJMP " + newLabel1 + "\n";
			asmCode += newLabel3 + ":\n";

			$$->setAsmCode(asmCode);

		}
		| PRINTLN LPAREN ID RPAREN SEMICOLON {

			asmCode = "";

			string asmVariableName = "";

			logFileText += "Line " + to_string(lineCount) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";

			string output = "printf(" + $3->getName() + ");"; 
			if (symbolTable->lookUp($3->getName()) == nullptr) {
				errorCount++;
				logFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $3->getName() + "\n\n";
				errorFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $3->getName() + "\n\n";
			} else {
				asmVariableName = symbolTable->lookUp($3->getName())->getAsmName();
			}

			logFileText += output + "\n\n";
			$$ = new SymbolInfo(output, "STATEMENT");

			//AssemblyCode
			asmCode += "\t;println(" + $3->getName() + ")\n"
					"\tMOV CX, " + asmVariableName + "\n"
					"\tMOV VAR_TO_PRINT, CX\n"
					"\tCALL NEW_LINE\n"
					"\tCALL PRINT_VAR\n"
					"\tCALL NEW_LINE\n";
			
			//printToCodeAsmFile(asmCodeFileCode, asmCode);
			$$->setAsmCode(asmCode);

		}
		| RETURN expression SEMICOLON {
			asmCode = "";

			asmCode += $2->getAsmCode();

			logFileText += "Line " + to_string(lineCount) + ": statement : RETURN expression SEMICOLON\n\n" + "return " + $2->getName() + ";\n\n";
			$$ = $2;
			$$->setName("return " + $2->getName() + ";");

			//AssemblyCode
			if ($2->getAsmName() != "") {
				asmCode += "\tPUSH " + $2->getAsmName() + "\n";
			}

			$$->setAsmCode(asmCode);
		}
		;
	  
expression_statement : SEMICOLON {
						logFileText += "Line " + to_string(lineCount) + ": expression_statement : SEMICOLON\n\n;\n\n";
						$$->setName(";");
					}			
					| expression SEMICOLON {
						logFileText += "Line " + to_string(lineCount) + ": expression_statement : expression SEMICOLON\n\n" + $1->getName() + ";\n\n";
						$$ = $1;
						$$->setName($1->getName() + ";");
					}
					;
	  
variable : ID {

			asmCode = "";

			string variableNameForAsm = "";
			logFileText += "Line " + to_string(lineCount) + ": variable : ID\n\n";

			SymbolInfo *tempSymbolInfo = symbolTable->lookUp($1->getName());

			if (tempSymbolInfo == nullptr) {
				errorCount++;
				logFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $1->getName() + "\n\n";
				errorFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $1->getName() + "\n\n";

			} else {
				if (tempSymbolInfo->getAsmName() == "") {
					tempSymbolInfo->setAsmName("temp_" + tempSymbolInfo->getName());
				} 
				variableNameForAsm = tempSymbolInfo->getAsmName();
				int variableType = tempSymbolInfo->getVarType();
				// cout << tempSymbolInfo->getName() << tempSymbolInfo->getVarType() << endl;

				if (variableType == 2) {
					errorCount++;
					logFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch, " + $1->getName() + " is an array\n\n";
					errorFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch, " + $1->getName() + " is an array\n\n";
				}
			}

			logFileText += $1->getName() + "\n\n";

			//AssemblyCode
			$$ = $1;
			$$->setAsmName(variableNameForAsm);
			
		}
		| ID LTHIRD expression RTHIRD 
		{
			logFileText += "Line " + to_string(lineCount) + ": variable : ID LTHIRD expression RTHIRD\n\n";

			if ($3->getType() != "CONST_INT") {
				errorCount++;
				logFileText += "Error at line " + to_string(lineCount) + ": Expression inside third brackets not an integer\n\n";
				errorFileText += "Error at line " + to_string(lineCount) + ": Expression inside third brackets not an integer\n\n";
			} else {
				SymbolInfo *tempSymbolInfo = symbolTable->lookUp($1->getName());
				if (tempSymbolInfo == nullptr) {
					errorCount++;
					logFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $1->getName() + "\n\n";
					errorFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $1->getName() + "\n\n";

				} else {
					int variableType = tempSymbolInfo->getVarType();

					if (variableType != 2) {
						errorCount++;
						logFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch, " + $1->getName() + " is not an array\n\n";
						errorFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch, " + $1->getName() + " is not an array\n\n";
						}
				}

			}

			logFileText += $1->getName() + "[" + $3->getName() + "]" + "\n\n";

			$$ = new SymbolInfo($1->getName() + "[" + $3->getName() + "]", "ARRAY_VAR");
		}
		;
	 
expression : logic_expression {
					logFileText += "Line " + to_string(lineCount) + ": expression : logic_expression\n\n" + $1->getName() + "\n\n";
					$$ = $1;
 			}
			| variable ASSIGNOP logic_expression {
				asmCode = "";

				asmCode += $1->getAsmCode() + $3->getAsmCode();

				string variableName;
				string functionName;

				logFileText += "Line " + to_string(lineCount) + ": expression : variable ASSIGNOP logic_expression\n\n";

				if ($1->getType() == "ARRAY_VAR") {
					int position = $1->getName().find('[');
					variableName = $1->getName().substr(0,position);
				} else if($1->getType() == "ID") {
					variableName = $1->getName();
				}

				SymbolInfo *tempSymbolInfo = symbolTable->lookUp(variableName);

				if (tempSymbolInfo != nullptr) {

					typeName = tempSymbolInfo->getDatType();

					if ($3->getType() == "CONST_INT" || $3->getType() == "CONST_FLOAT") {
						if (typeName == "int" && $3->getType() != "CONST_INT") {
							// cout << $3->getName() << " " << variableName << " " << $3->getType() << endl;
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch\n\n";
						}
					} else if ($3->getType() == "FUNCTION") {
						// cout << $3->getName() << endl;
						int position = $3->getName().find('(');
						functionName = $3->getName().substr(0,position);
						SymbolInfo *temp = symbolTable->lookUp(functionName);

						if (temp != nullptr && temp->getDatType() == "void") {
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Void function used in expression\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Void function used in expression\n\n";
						} else if (temp != nullptr && (temp->getDatType() != tempSymbolInfo->getDatType())) {
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch\n\n";
						}


					} else if ($3->getType() == "LOGIC_EXPRESSION" || $3->getType() == "RELOP_EXPRESSION") {
						if (tempSymbolInfo->getDatType() != "int") {
							cout << tempSymbolInfo->getDatType() << endl;
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Result of LOGICOP and RELOP must be an int\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Result of LOGICOP and RELOP must be an int\n\n";
						}
					}
				}

				logFileText += $1->getName() + "=" + $3->getName() + "\n\n";
				typeName = "";
				$$ = new SymbolInfo($1->getName() + "=" + $3->getName(), "expression");
				

				//AssemblyCode
				asmCode += "\t;" + $1->getName() + " = " + $3->getName() + "\n"
						"\tPOP BX\n"
						"\tMOV " + $1->getAsmName() + ", BX\n";
				
				//printToCodeAsmFile(asmCodeFileCode, asmCode);
				$$->setAsmCode(asmCode);

			}	
			;
			
logic_expression : rel_expression {
					logFileText += "Line " + to_string(lineCount) + ": logic_expression : rel_expression\n\n" + $1->getName() + "\n\n";
					$$ = $1;
				}
				| rel_expression LOGICOP rel_expression {
					asmCode = "";

					asmCode += $1->getAsmCode() + $3->getAsmCode();

					logFileText += "Line " + to_string(lineCount) + ": logic_expression : rel_expression LOGICOP rel_expression\n\n" + $1->getName() + $2->getName() + $3->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "LOGIC_EXPRESSION");

					//AssemblyCode

					asmCode += "\t;" + $1->getName() + " " + $2->getName() + " " + $3->getName() + "\n";

					if ($1->getAsmName() == "") {
						asmCode += "\tPOP AX\n";
					} else {
						asmCode += "\tMOV AX, " + $1->getAsmName() + "\n";
					}
					if ($3->getAsmName() == "") {
						asmCode += "\tPOP BX\n";
					} else {
						asmCode += "\tMOV BX, " + $3->getAsmName() + "\n";
					}

					if ($2->getName() == "||") {
						asmCode += "\tOR AX, BX\n";

					} else if ($2->getName() == "&&") {
						asmCode += "\tAND AX, BX\n";
					}
					
					asmCode += "\tPUSH AX\n";
					$$->setAsmName("");
					$$->setAsmCode(asmCode);
					//printToCodeAsmFile(asmCodeFileCode, asmCode);
				} 	
				;
			
rel_expression	: simple_expression {
				logFileText += "Line " + to_string(lineCount) + ": rel_expression : simple_expression\n\n" + $1->getName() + "\n\n";
				$$ = $1;
				}
				| simple_expression RELOP simple_expression	{
					
					asmCode = "";

					asmCode += $1->getAsmCode() + $3->getAsmCode();

					logFileText += "Line " + to_string(lineCount) + ": rel_expression : simple_expression RELOP simple_expression\n\n" + $1->getName() + $2->getName() + $3->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(),"RELOP_EXPRESSION");

					//AssemblyCode
					conditionCount++;

					string newLabel1 = newLabel();
					string newLabel2 = newLabel();
					
					asmCode += "\t;Check " + $1->getName() + " " + $2->getName() + " " + $3->getName() + "\n";

					if ($1->getAsmName() == "") {
						asmCode += "\tPOP AX\n";
					} else {
						asmCode += "\tMOV AX, " + $1->getAsmName() + "\n";
					}
					if ($3->getAsmName() == "") {
						asmCode += "\tPOP BX\n";
					} else {
						asmCode += "\tMOV BX, " + $3->getAsmName() + "\n";
					}
					
					if ($2->getName() == "<") {
						asmCode += "\tCMP AX, BX\n"
									"\tJL " + newLabel1 + "\n"
									"\tPUSH 0\n"
									"\tJMP " + newLabel2 + "\n\n"
									"" + newLabel1 + ":\n"
									"\tPUSH 1\n\n"
									"" + newLabel2 + ":\n\n";
					} else if ($2->getName() == "<=") {
						asmCode += "\tCMP AX, BX\n"
									"\tJLE " + newLabel1 + "\n"
									"\tPUSH 0\n"
									"\tJMP " + newLabel2 + "\n\n"
									"" + newLabel1 + ":\n"
									"\tPUSH 1\n\n"
									"" + newLabel2 + ":\n\n";
					} else if ($2->getName() == ">") {
						asmCode += "\tCMP AX, BX\n"
									"\tJG " + newLabel1 + "\n"
									"\tPUSH 0\n"
									"\tJMP " + newLabel2 + "\n\n"
									"" + newLabel1 + ":\n"
									"\tPUSH 1\n\n"
									"" + newLabel2 + ":\n\n";
					} else if ($2->getName() == ">=") {
						asmCode += "\tCMP AX, BX\n"
									"\tJGE " + newLabel1 + "\n"
									"\tPUSH 0\n"
									"\tJMP " + newLabel2 + "\n\n"
									"" + newLabel1 + ":\n"
									"\tPUSH 1\n\n"
									"" + newLabel2 + ":\n\n";
					} else if ($2->getName() == "==") {
						asmCode += "\tCMP AX, BX\n"
									"\tJE " + newLabel1 + "\n"
									"\tPUSH 0\n"
									"\tJMP " + newLabel2 + "\n\n"
									"" + newLabel1 + ":\n"
									"\tPUSH 1\n\n"
									"" + newLabel2 + ":\n\n";
					} else if ($2->getName() == "!=") {
						asmCode += "\tCMP AX, BX\n"
									"\tJNE " + newLabel1 + "\n"
									"\tPUSH 0\n"
									"\tJMP " + newLabel2 + "\n\n"
									"" + newLabel1 + ":\n"
									"\tPUSH 1\n\n"
									"" + newLabel2 + ":\n\n";
					}

					$$->setAsmName("");
					$$->setAsmCode(asmCode);
					//printToCodeAsmFile(asmCodeFileCode, asmCode);

				}
				;
				
simple_expression : term {
					logFileText += "Line " + to_string(lineCount) + ": simple_expression : term\n\n" + $1->getName() + "\n\n";
					$$ = $1;
				}
				| simple_expression ADDOP term {
					asmCode = "";

					asmCode += $1->getAsmCode() + $3->getAsmCode();

					string asmComment = "\t;" + $1->getName() + $2->getName() + $3->getName() + "\n";
					
					logFileText += "Line " + to_string(lineCount) + ": simple_expression : simple_expression ADDOP term\n\n" + $1->getName() + $2->getName() + $3->getName() + "\n\n";
					$$ = $1;
					$$->setName($1->getName() + $2->getName() + $3->getName());
					$$->setType("SIMPLE_EXPRESSION");

					//AssemblyCode
					asmCode += asmComment;
					if ($1->getAsmName() != "") {
						asmCode += "\tMOV BX, " + $1->getAsmName() + "\n";
					} else {
						asmCode += "\tPOP BX\n";
					}
					if ($3->getAsmName() != "") {
						asmCode += "\tMOV AX, " + $3->getAsmName() + "\n";
					} else {
						asmCode += "\tPOP AX\n";
					}

					if ($2->getName() == "+") {
						asmCode += "\tADD AX, BX\n"
							"\tPUSH AX\n";
					} else if ($2->getName() == "-") {
						asmCode += "\tSUB AX, BX\n"
							"\tPUSH AX\n";
					}

					//printToCodeAsmFile(asmCodeFileCode, asmCode);
					$$->setAsmName("");
					$$->setAsmCode(asmCode);

				} 
				| simple_expression ADDOP error term {
					logFileText += "Line " + to_string(lineCount) + ": simple_expression : simple_expression ADDOP term\n\n" + $1->getName() + $2->getName() + $4->getName() + "\n\n";
					$$ = $1;
					$$->setName($1->getName() + $2->getName() + $4->getName());
					$$->setType("SIMPLE_EXPRESSION");
				} 
				;
					
term :	unary_expression {
		logFileText += "Line " + to_string(lineCount) + ": term : unary_expression\n\n" + $1->getName() + "\n\n";
		$$ = $1;
	}
    |  term MULOP unary_expression {

		asmCode = "";

		asmCode += $1->getAsmCode() + $3->getAsmCode();

		string asmComment = "\t;" + $1->getName() + $2->getName() + $3->getName() + "\n";

		logFileText += "Line " + to_string(lineCount) + ": term : term MULOP unary_expression\n\n";
		// cout << $2->getName() << $3->getName() << endl;
		if ($2->getName() == "%" && ($3->getType() == "CONST_FLOAT" || $1->getType() == "CONST_FLOAT")) {
			errorCount++;
			logFileText += "Error at line " + to_string(lineCount) + ": Non-Integer operand on modulus operator\n\n";
			errorFileText += "Error at line " + to_string(lineCount) + ": Non-Integer operand on modulus operator\n\n";
		} else if (($2->getName() == "/" || $2->getName() == "%") && ($3->getType() == "CONST_FLOAT" || $3->getType() == "CONST_INT")) {
			if($3->getName() == "0" || $3->getName() == "0.0") {
				errorCount++;
				if ($2->getName() == "/") {
					logFileText += "Error at line " + to_string(lineCount) + ": Divide by Zero\n\n";
					errorFileText += "Error at line " + to_string(lineCount) + ": Divide by Zero\n\n";
				} else {
					logFileText += "Error at line " + to_string(lineCount) + ": Modulus by Zero\n\n";
					errorFileText += "Error at line " + to_string(lineCount) + ": Modulus by Zero\n\n";
				}
			}
		}

		if ($3->getType() == "FUNCTION") {
			int position = $3->getName().find('(');
			string functionName = $3->getName().substr(0,position);

			SymbolInfo *tempSymbolInfo = symbolTable->lookUp(functionName);

			if (tempSymbolInfo != nullptr && tempSymbolInfo->getDatType() == "void") {
				errorCount++;
				logFileText += "Error at line " + to_string(lineCount) + ": Void function used in expression\n\n";
				errorFileText += "Error at line " + to_string(lineCount) + ": Void function used in expression\n\n";
			}			
		}
		
		logFileText += $1->getName() + $2->getName() + $3->getName() + "\n\n";
		$$ = $1;
		$$->setName($1->getName() + $2->getName() + $3->getName());

		//AssemblyCode
		asmCode += asmComment;

		if ($1->getAsmName() != "") {
			asmCode += "\tMOV AX, " + $1->getAsmName() + "\n";
		} else {
			asmCode += "\tPOP AX\n";
		}
		if ($3->getAsmName() != "") {
			asmCode += "\tMOV BX, " + $3->getAsmName() + "\n";
		} else {
			asmCode += "\tPOP BX\n";
		}
		if ($2->getName() == "%") {
			asmCode += "\tMOV DX, 0\n" 
					"\tDIV BX\n"
					"\tPUSH DX\n";
		} else if ($2->getName() == "*") {
			asmCode += "\tMUL BX\n"
					"\tPUSH AX\n";
		}


		//printToCodeAsmFile(asmCodeFileCode, asmCode);
		$$->setAsmName("");
		$$->setAsmCode(asmCode);

	}
    ;

unary_expression : ADDOP unary_expression {
			asmCode = "";
			asmCode += $2->getAsmCode();

			logFileText += "Line " + to_string(lineCount) + ": unary_expression : ADDOP unary_expression\n\n" + $1->getName() + $2->getName() + "\n\n";
			$$ = $2;
			$$->setName($1->getName() + $2->getName());

			//AssemblyCode
			asmCode += "\t;" + $$->getName() + "\n";

			if ($2->getAsmName() == "") {
				asmCode += "\tPOP AX\n";
			} else {
				asmCode += "\tMOV AX, " + $2->getAsmName() + "\n";
			}

			if ($1->getName() == "+") {
				//Do nothing
			} else if ($1->getName() == "-") {
				asmCode += "\tNEG AX\n"
							"\tPUSH AX\n";
			}

			//printToCodeAsmFile(asmCodeFileCode, asmCode);
			$$->setAsmName("");
			$$->setAsmCode(asmCode);

		}  
		| NOT unary_expression {
			logFileText += "Line " + to_string(lineCount) + ": unary_expression : NOT unary_expression\n\n" + "!" + $2->getName() + "\n\n";
			$$ = $2;
			$$->setName("!" + $2->getName());
		}
		| factor {
			logFileText += "Line " + to_string(lineCount) + ": unary_expression : factor\n\n" + $1->getName() + "\n\n";
			$$ = $1;
		} 
		;
	
factor	: variable {
			logFileText += "Line " + to_string(lineCount) + ": factor : variable\n\n" + $1->getName() + "\n\n";
			$$ = $1;
		}
		| ID LPAREN argument_list RPAREN {
			asmCode = "";

			string procName = $1->getName();
			asmCode += "\t;Call Proc " + procName + "\n";
			asmCode += $3->getAsmCode();

			int argumentLength = 0;

			logFileText += "Line " + to_string(lineCount) + ": factor : ID LPAREN argument_list RPAREN\n\n";

			SymbolInfo *s1 = symbolTable->lookUp($1->getName());
			if (s1 == nullptr) {
				errorCount++;
				logFileText += "Error at line " + to_string(lineCount) + ": Undeclared function " + $1->getName() + "\n\n";
				errorFileText += "Error at line " + to_string(lineCount) + ": Undeclared function " + $1->getName() + "\n\n";
			} else { 
				if (s1->getVarType() != 0) {
					errorCount++;
					logFileText += "Error at line " + to_string(lineCount) + ": " +  $1->getName() + " is not a function " + "\n\n";
					errorFileText += "Error at line " + to_string(lineCount) + ": " +  $1->getName() + " is not a function " + "\n\n";
				} else {
					vector<string> pList = s1->getParamList();
					vector<SymbolInfo*> pListForAsm = s1->getParamArgList();

					int pListSize = pList.size();

					int i = 0;
					if (pListSize != argumentList.size()) {
						errorCount++;
						logFileText += "Error at line " + to_string(lineCount) + ": Total number of arguments mismatch in function " + $1->getName() + "\n\n";
						errorFileText += "Error at line " + to_string(lineCount) + ": Total number of arguments mismatch in function " + $1->getName() + "\n\n";
					} else {
						string asmNamesForArgs[pListSize];
						argumentLength = pListSize;

						while(i != pListSize) {
							
							string variableName = argumentList.at(i)->getName();
							string variableType = argumentList.at(i)->getType();
							string argumentType = pList.at(i);

							asmNamesForArgs[i] = pListForAsm.at(i)->getAsmName();

							if (variableType == "CONST_INT" || "CONST_FLOAT") {
								if (variableType == "CONST_INT" && argumentType != "int") {
									errorCount++;
									logFileText += "Error at line " + to_string(lineCount) + ": " + to_string(i+1) + "th argument mismatch in function " + $1->getName() + "\n\n";
									errorFileText += "Error at line " + to_string(lineCount) + ": " + to_string(i+1) + "th argument mismatch in function " + $1->getName() + "\n\n";
									break;
								}
								if (variableType == "CONST_FLOAT" && argumentType != "float") {
									errorCount++;
									logFileText += "Error at line " + to_string(lineCount) + ": " + to_string(i+1) + "th argument mismatch in function " + $1->getName() + "\n\n";
									errorFileText += "Error at line " + to_string(lineCount) + ": " + to_string(i+1) + "th argument mismatch in function " + $1->getName() + "\n\n";
									break;
								}
							} else if (variableType == "ID") {
								SymbolInfo *tempSymbolInfo = symbolTable->lookUp(variableName);
								if (tempSymbolInfo != nullptr) {
									if (tempSymbolInfo->getVarType() == 1) {
										if (tempSymbolInfo->getDatType() != argumentType) {
											errorCount++;
											logFileText += "Error at line " + to_string(lineCount) + ": " + to_string(i+1) + "th argument mismatch in function " + $1->getName() + "\n\n";
											errorFileText += "Error at line " + to_string(lineCount) + ": " + to_string(i+1) + "th argument mismatch in function " + $1->getName() + "\n\n";
											break;
										}
									}
								}
							}

							// cout << argumentList.at(i)->getName() + " " << argumentList.at(i)->getType() + " " << pList.at(i) << endl;
							i++;
						}

						//AssemblyCode
						for (int k = argumentLength-1; k>=0; k--) {
							asmCode += "\tPOP " + asmNamesForArgs[k] + "\n";
						}
					}
				}	
			}
			argumentList.clear();

			logFileText += $1->getName() + "(" + $3->getName() + ")" + "\n\n";
			$$ = new SymbolInfo($1->getName() + "(" + $3->getName() + ")", "FUNCTION");

			//AssemblyCode
			// cout << $3->getAsmCode() << endl;
			// cout << $3->getAsmName() << endl;

			transform(procName.begin(), procName.end(), procName.begin(), ::toupper);

			asmCode += "\tCALL " + procName + "\n";

			$$->setAsmCode(asmCode);
		}
		| LPAREN expression RPAREN {
			logFileText += "Line " + to_string(lineCount) + ": factor : LPAREN expression RPAREN\n\n" + "(" + $2->getName() + ")" + "\n\n";
			$$ = new SymbolInfo("(" + $2->getName() + ")", "factor");
		}
		| CONST_INT {
			asmCode = "";

			logFileText += "Line " + to_string(lineCount) + ": factor : CONST_INT\n\n" + $1->getName() + "\n\n";
			$$ = $1;

			asmCode += "\tPUSH " + $1->getName() + "\n";
			$$->setAsmCode(asmCode);
			//printToCodeAsmFile(asmCodeFileCode, asmCode);

		}
		| CONST_FLOAT {
			logFileText += "Line " + to_string(lineCount) + ": factor : CONST_FLOAT\n\n" + $1->getName() + "\n\n";
			$$ = $1;
		}
		| variable INCOP {
			asmCode = "";

			logFileText += "Line " + to_string(lineCount) + ": factor : variable INCOP\n\n" + $1->getName() + "++" + "\n\n";
			$$ = new SymbolInfo($1->getName() + "++", "factor");

			//AssemblyCode
			asmCode += "\t;" + $1->getName() + "++\n";

			asmCode += "\tMOV AX, " + $1->getAsmName() + "\n"
						"\tADD AX, 1\n"
						"\tMOV " + $1->getAsmName() + ", AX\n";
			
			//printToCodeAsmFile(asmCodeFileCode, asmCode);
			$$->setAsmName($1->getAsmName());
			$$->setAsmCode(asmCode);
		}
		| variable DECOP {
			asmCode = "";


			logFileText += "Line " + to_string(lineCount) + ": factor : variable DECOP\n\n" + $1->getName() + "--" + "\n\n";
			$$ = new SymbolInfo($1->getName() + "--", "factor");

			//AssemblyCode
			asmCode += "\t;" + $1->getName() + "--\n";

			asmCode += "\tMOV AX, " + $1->getAsmName() + "\n"
						"\tSUB AX, 1\n"
						"\tMOV " + $1->getAsmName() + ", AX\n"
						"\tPUSH AX\n";
			
			//printToCodeAsmFile(asmCodeFileCode, asmCode);
			$$->setAsmName($1->getAsmName());
			$$->setAsmCode(asmCode);
		}
		;
	
argument_list : arguments {
				logFileText += "Line " + to_string(lineCount) + ": argument_list : arguments\n\n" + $1->getName() + "\n\n";
				$$ = $1;
			}
			| {
				$$ = new SymbolInfo("", "BLANK_ARGUMENT_LIST");
			}
			;
	
arguments : arguments COMMA logic_expression {
			asmCode = "";

			asmCode += $1->getAsmCode();

			logFileText += "Line " + to_string(lineCount) + ": arguments : arguments COMMA logic_expression\n\n" + $1->getName() + "," + $3->getName() + "\n\n";
			$$ = $1;
			$$->setName($1->getName() + "," + $3->getName());
			SymbolInfo *tempSymbolInfo = new SymbolInfo($3->getName(), $3->getType());
			argumentList.push_back(tempSymbolInfo);

			//AssemblyCode
			if ($3->getAsmName() != "") {
				asmCode += "\tPUSH " + $3->getAsmName() + "\n";
			}
			$$->setAsmCode(asmCode);

		}
	    | logic_expression {
			asmCode = "";

			logFileText += "Line " + to_string(lineCount) + ": arguments : logic_expression\n\n" + $1->getName() + "\n\n";
			$$ = $1;
			
			SymbolInfo *tempSymbolInfo = new SymbolInfo($1->getName(), $1->getType());
			argumentList.push_back(tempSymbolInfo);

			//AssemblyCode
			if ($1->getAsmName() != "") {
				asmCode += "\tPUSH " + $1->getAsmName() + "\n";
			}
			$$->setAsmCode(asmCode);
		}
	    ;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	

	logFile= fopen("log.txt","w");
	errorFile= fopen("error.txt","w");	

	asmCodeFile = fopen("code.asm", "w");
	asmCodeFileData = fopen("dataCode.asm", "w+");
	asmCodeFileCode = fopen("codeCode.asm", "w+");
	asmCodeFileProc = fopen("procCode.asm", "w+");

	initAsmFile(asmCodeFile);
	initAsmProcFile(asmCodeFileProc);
	initAsmCodeFile(asmCodeFileCode);

	yyin=fp;
	yyparse();

	mergeFiles(asmCodeFile, asmCodeFileData, asmCodeFileCode, asmCodeFileProc); 

	logFileText += symbolTable->printAllScopeTable();

	string lineCountText = "Total lines: " + to_string(lineCount) + "\n";
	string errorCountText = "Total errors: " + to_string(errorCount) + "\n";

	fprintf(logFile, "%s", logFileText.c_str());
	fprintf(errorFile, "%s", errorFileText.c_str());

	fprintf(logFile, "%s", lineCountText.c_str());
	fprintf(logFile, "%s", errorCountText.c_str());
	

	fclose(logFile);
	fclose(errorFile);
	fclose(asmCodeFile);
	fclose(asmCodeFileData);
	fclose(asmCodeFileCode);
	fclose(asmCodeFileProc);

	remove("codeCode.asm");
	remove("dataCode.asm");
	remove("procCode.asm");
	
	return 0;
}