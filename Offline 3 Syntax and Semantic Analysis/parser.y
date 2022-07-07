%{
#include<iostream>
#include<bits/stdc++.h>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "headers/SymbolTable.h"

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

vector<SymbolInfo*> parametersList;
vector<SymbolInfo*> argumentList;

string typeName = "";

void yyerror(char *s)
{
	//write your code
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
%type <symbolInfo> func_definition variable parameter_list

%type <symbolInfo> expression_statement compound_statement statements unary_expression factor statement
%type <symbolInfo> expression logic_expression simple_expression rel_expression term arguments argument_list

%left 
%right

%nonassoc 


%%

start : program 
	{
		logFileText += "Line " + to_string(lineCount) + ": start : program\n\n\n";
		$$ = $1;
	}
	;



program : program unit {
			logFileText += "\nLine " + to_string(lineCount) + ": program : program unit\n\n" + $1->getName() + "\n" + $2->getName() + "\n\n\n";
			$$ = $1;
			$$->setName($1->getName() + "\n" + $2->getName());
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
				symbolTable->lookUp($2->getName())->addParameters(s1->getType());
				i++;
				
			}

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
			string output = $1->getName() + " " + $2->getName() + "()" + $6->getName();
			logFileText += "Line " + to_string(lineCount) + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n" + output + "\n\n";
			$$ = new SymbolInfo(output, "func_definition");

		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {
					logFileText += "Line " + to_string(lineCount) + ": parameter_list : parameter_list COMMA type_specifier ID\n\n" + $1->getName() + "," + $3->getName() + " " + $4->getName() + "\n\n";
					$$ = $1;
					$$->setName($1->getName() + "," + $3->getName() + " " + $4->getName());

					SymbolInfo *s1 = new SymbolInfo($4->getName(), $3->getName());
					parametersList.push_back(s1);

				}
				| parameter_list COMMA type_specifier {
					logFileText += "Line " + to_string(lineCount) + ": parameter_list : parameter_list COMMA type_specifier\n\n" + $1->getName() + "," + $3->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + "," + $3->getName(), "PARAM_LIST");

					SymbolInfo *s1 = new SymbolInfo("", $3->getName());
					parametersList.push_back(s1);
				}
				| type_specifier ID {
					logFileText += "Line " + to_string(lineCount) + ": parameter_list : type_specifier ID\n\n" + $1->getName() + " " + $2->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + " " + $2->getName(), "PARAM_LIST");

					SymbolInfo *s1 = new SymbolInfo($2->getName(), $1->getName());
					parametersList.push_back(s1);
				}
				| type_specifier {
					logFileText += "Line " + to_string(lineCount) + ": parameter_list : type_specifier\n\n" + $1->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName(), "PARAM_LIST");

					SymbolInfo *s1 = new SymbolInfo("", $1->getName());
					parametersList.push_back(s1);
				}
				;

 		
compound_statement : LCURL {
						symbolTable->enterNewScope(7);

						int paramListSize = parametersList.size();
						int i = 0;
						while (i != paramListSize) {
							SymbolInfo *s1 = parametersList.at(i);
							if (!symbolTable->insert(s1->getName(), "ID")) {
								// Error 
								errorCount++;
								logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
								errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + s1->getName() + " in parameter\n\n";
							}
							i++;
							
						}
					}
					statements RCURL {
					logFileText += "Line " + to_string(lineCount) + ": compound_statement : LCURL statements RCURL\n\n" + "{\n" + $3->getName() + "\n}\n\n\n";
					
					logFileText += symbolTable->printAllScopeTable();

					symbolTable->exitCurrentScope();
					
					$$ = $3;
					$$->setName("{\n" + $3->getName() + "\n}\n");
					
				}
				| LCURL {
					symbolTable->enterNewScope(7);
				}
				RCURL {
					logFileText += "Line " + to_string(lineCount) + ": compound_statement : LCURL RCURL\n\n{}\n\n";
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
					typeName = "INT";
				}
 				| FLOAT {
					logFileText += "Line " + to_string(lineCount) + ": type_specifier : FLOAT\n\nfloat\n\n";
					$$ = new SymbolInfo("float", "type_specifier");
					typeName = "FLOAT";
				}
 				| VOID {
					logFileText += "Line " + to_string(lineCount) + ": type_specifier : VOID\n\nvoid\n\n";
					$$ = new SymbolInfo("void", "type_specifier");
					typeName = "VOID";
				}
 				;
 		
declaration_list : declaration_list COMMA ID {

					if (!symbolTable->insert($3->getName(), $3->getType(), typeName, 1)) {
						errorCount++;
						errorFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $3->getName() + "\n\n";
						logFileText += "Error at line " + to_string(lineCount) + ": Multiple declaration of " + $3->getName() + "\n\n";
					}

					logFileText += "Line " + to_string(lineCount) + ": declaration_list : declaration_list COMMA ID\n\n" + $1->getName() + "," + $3->getName() + "\n\n";
					$$ = $1;
					$$ = new SymbolInfo($1->getName() + "," + $3->getName(), "declaration_list");

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
				logFileText += "Line " + to_string(lineCount) + ": statements : statements statement\n\n" + $1->getName() + "\n" + $2->getName() + "\n\n";
				$$ = $1;
				$$->setName($1->getName() + "\n" + $2->getName());
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
			string output = "for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName(); 
			logFileText += "Line " + to_string(lineCount) + ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n" + output + "\n\n";
			$$ = $7;

			$$->setName(output);
		}
		| IF LPAREN expression RPAREN statement {
			string output = "if (" + $3->getName() + ")" + $5->getName(); 
			logFileText += "Line " + to_string(lineCount) + ": statement : IF LPAREN expression RPAREN statement\n\n" + output + "\n\n";
			$$ = $5;

			$$->setName(output);
		}
		| IF LPAREN expression RPAREN statement ELSE statement {
			string output = "if (" + $3->getName() + ")" + $5->getName() + "else\n" + $7->getName(); 
			logFileText += "Line " + to_string(lineCount) + ": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n" + output + "\n\n";
			$$ = $7;

			$$->setName(output);
		}
		| WHILE LPAREN expression RPAREN statement {
			string output = "while (" + $3->getName() + ")" + $5->getName(); 
			logFileText += "Line " + to_string(lineCount) + ": statement : WHILE LPAREN expression RPAREN statement\n\n" + output + "\n\n";
			$$ = $5;

			$$->setName(output);
		}
		| PRINTLN LPAREN ID RPAREN SEMICOLON {
			string output = "printf(" + $3->getName() + ");"; 
			if (symbolTable->lookUp($3->getName()) == nullptr) {
				errorCount++;
				logFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $3->getName() + "\n\n";
				errorFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $3->getName() + "\n\n";
			}
			logFileText += "Line " + to_string(lineCount) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";

			logFileText += output + "\n\n";
			$$ = new SymbolInfo(output, "STATEMENT");

		}
		| RETURN expression SEMICOLON {
			logFileText += "Line " + to_string(lineCount) + ": statement : RETURN expression SEMICOLON\n\n" + "return " + $2->getName() + ";\n\n";
			$$ = $2;
			$$->setName("return " + $2->getName() + ";");
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
			logFileText += "Line " + to_string(lineCount) + ": variable : ID\n\n";

			SymbolInfo *tempSymbolInfo = symbolTable->lookUp($1->getName());

			if (tempSymbolInfo == nullptr) {
				errorCount++;
				logFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $1->getName() + "\n\n";
				errorFileText += "Error at line " + to_string(lineCount) + ": Undeclared variable " + $1->getName() + "\n\n";

			} else {
				int variableType = tempSymbolInfo->getVarType();
				// cout << tempSymbolInfo->getName() << tempSymbolInfo->getVarType() << endl;

				if (variableType == 2) {
					errorCount++;
					logFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch, " + $1->getName() + " is an array\n\n";
					errorFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch, " + $1->getName() + " is an array\n\n";
				}
			}

			logFileText += $1->getName() + "\n\n";
			
			$$ = $1;
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
						logFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch, " + $1->getName() + " is an array\n\n";
						errorFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch, " + $1->getName() + " is an array\n\n";
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
					typeName = "CONST_" + typeName;

					if ($3->getType() == "CONST_INT" || $3->getType() == "CONST_FLOAT") {
						if (typeName == "CONST_INT" && typeName != $3->getType()) {
							// cout << $3->getName() << " " << variableName << " " << $3->getType() << endl;
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Type Mismatch\n\n";
						}
					} else if ($3->getType() == "FUNCTION") {
						int position = $3->getName().find('(');
						functionName = $3->getName().substr(0,position);
						SymbolInfo *temp = symbolTable->lookUp(functionName);

						if (temp != nullptr && temp->getDatType() == "void") {
							errorCount++;
							logFileText += "Error at line " + to_string(lineCount) + ": Void function used in expression\n\n";
							errorFileText += "Error at line " + to_string(lineCount) + ": Void function used in expression\n\n";
						}
					}
				}

				logFileText += $1->getName() + "=" + $3->getName() + "\n\n";
				typeName = "";
				$$ = new SymbolInfo($1->getName() + "=" + $3->getName(), "expression");
			}	
			;
			
logic_expression : rel_expression {
					logFileText += "Line " + to_string(lineCount) + ": logic_expression : rel_expression\n\n" + $1->getName() + "\n\n";
					$$ = $1;
				}
				| rel_expression LOGICOP rel_expression {
					logFileText += "Line " + to_string(lineCount) + ": logic_expression : rel_expression LOGICOP rel_expression\n\n" + $1->getName() + $2->getName() + $3->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "LOGIC_EXPRESSION");
				} 	
				;
			
rel_expression	: simple_expression {
				logFileText += "Line " + to_string(lineCount) + ": rel_expression : simple_expression\n\n" + $1->getName() + "\n\n";
				$$ = $1;
				}
				| simple_expression RELOP simple_expression	{
					logFileText += "Line " + to_string(lineCount) + ": rel_expression : simple_expression RELOP simple_expression\n\n" + $1->getName() + $2->getName() + $3->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(),"rel_expression");
				}
				;
				
simple_expression : term {
					logFileText += "Line " + to_string(lineCount) + ": simple_expression : term\n\n" + $1->getName() + "\n\n";
					$$ = $1;
				}
				| simple_expression ADDOP term {
					logFileText += "Line " + to_string(lineCount) + ": simple_expression : simple_expression ADDOP term\n\n" + $1->getName() + $2->getName() + $3->getName() + "\n\n";
					$$ = $1;
					$$->setName($1->getName() + $2->getName() + $3->getName());
				} 
				;
					
term :	unary_expression {
		logFileText += "Line " + to_string(lineCount) + ": term : unary_expression\n\n" + $1->getName() + "\n\n";
		$$ = $1;
	}
    |  term MULOP unary_expression {
		logFileText += "Line " + to_string(lineCount) + ": term : term MULOP unary_expression\n\n";
		// cout << $2->getName() << $3->getName() << endl;
		if ($2->getName() == "%" && $3->getType() == "CONST_FLOAT") {
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
	}
    ;

unary_expression : ADDOP unary_expression {
			logFileText += "Line " + to_string(lineCount) + ": unary_expression : ADDOP unary_expression\n\n" + $1->getName() + $2->getName() + "\n\n";
			$$ = $2;
			$$->setName($1->getName() + $2->getName());
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
			logFileText += "Line " + to_string(lineCount) + ": factor : ID LPAREN argument_list RPAREN\n\n";

			SymbolInfo *s1 = symbolTable->lookUp($1->getName());
			if (s1 == nullptr) {
				errorCount++;
				logFileText += "Error at line " + to_string(lineCount) + ": Undeclared function " + $1->getName() + "\n\n";
				errorFileText += "Error at line " + to_string(lineCount) + ": Undeclared function " + $1->getName() + "\n\n";
			} else { 
				cout << argumentList.size() << endl;
				vector<string> pList = s1->getParamList();
				int pListSize = pList.size();
				int i = 0;
				if (pListSize != argumentList.size()) {
					errorCount++;
				} else {
					while(i != pListSize) {
					cout << argumentList.at(i)->getName() + " " << argumentList.at(i)->getType() + " " << pList.at(i) << endl;
					i++;
					}
				}
			}

			argumentList.clear();

			logFileText += $1->getName() + "(" + $3->getName() + ")" + "\n\n";
			$$ = new SymbolInfo($1->getName() + "(" + $3->getName() + ")", "FUNCTION");
		}
		| LPAREN expression RPAREN {
			logFileText += "Line " + to_string(lineCount) + ": factor : LPAREN expression RPAREN\n\n" + "(" + $2->getName() + ")" + "\n\n";
			$$ = new SymbolInfo("(" + $2->getName() + ")", "factor");
		}
		| CONST_INT {
			logFileText += "Line " + to_string(lineCount) + ": factor : CONST_INT\n\n" + $1->getName() + "\n\n";
			$$ = $1;
		}
		| CONST_FLOAT {
			logFileText += "Line " + to_string(lineCount) + ": factor : CONST_FLOAT\n\n" + $1->getName() + "\n\n";
			$$ = $1;
		}
		| variable INCOP {
			logFileText += "Line " + to_string(lineCount) + ": factor : variable INCOP\n\n" + $1->getName() + "++" + "\n\n";
			$$ = new SymbolInfo($1->getName() + "++", "factor");
		}
		| variable DECOP {
			logFileText += "Line " + to_string(lineCount) + ": factor : variable DECOP\n\n" + $1->getName() + "--" + "\n\n";
			$$ = new SymbolInfo($1->getName() + "--", "factor");
		}
		;
	
argument_list : arguments {
				logFileText += "Line " + to_string(lineCount) + ": argument_list : arguments\n\n" + $1->getName() + "\n\n";
				$$ = $1;
			}
			| {}
			;
	
arguments : arguments COMMA logic_expression {
			logFileText += "Line " + to_string(lineCount) + ": arguments : arguments COMMA logic_expression\n\n" + $1->getName() + "," + $3->getName() + "\n\n";
			$$ = $1;
			$$->setName($1->getName() + "," + $3->getName());
			SymbolInfo *tempSymbolInfo = new SymbolInfo($3->getName(), $3->getType());
			argumentList.push_back(tempSymbolInfo);
		}
	    | logic_expression {
			logFileText += "Line " + to_string(lineCount) + ": arguments : logic_expression\n\n" + $1->getName() + "\n\n";
			$$ = $1;
			
			SymbolInfo *tempSymbolInfo = new SymbolInfo($1->getName(), $1->getType());
			argumentList.push_back(tempSymbolInfo);
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
	
	// fp2= fopen(argv[2],"a");
	// fp3= fopen(argv[3],"a");
	

	yyin=fp;
	yyparse();

	logFileText += symbolTable->printAllScopeTable();

	string lineCountText = "Total lines: " + to_string(lineCount) + "\n";
	string errorCountText = "Total errors: " + to_string(errorCount) + "\n";

	fprintf(logFile, "%s", logFileText.c_str());
	fprintf(errorFile, "%s", errorFileText.c_str());

	fprintf(logFile, "%s", lineCountText.c_str());
	fprintf(logFile, "%s", errorCountText.c_str());
	

	fclose(logFile);
	fclose(errorFile);
	
	return 0;
}