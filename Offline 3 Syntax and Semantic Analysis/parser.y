%{
#include<iostream>
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

SymbolTable *symbolTable = new SymbolTable(7);

FILE *fp;
FILE *logFile;
FILE *fp3;

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

%type <symbolInfo> expression_statement
%type <symbolInfo> compound_statement statements unary_expression factor statement arguments
%type <symbolInfo> expression logic_expression simple_expression rel_expression term argument_list

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

				}
				| type_specifier ID LPAREN RPAREN SEMICOLON {
					logFileText += "Line " + to_string(lineCount) + ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n" + $1->getName() + " " + $2->getName() + "();\n\n";
					$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "();", "func_declaration");
				}
				;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
			string output = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $6->getName();
			logFileText += "Line " + to_string(lineCount) + ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" + output + "\n\n";
			$$ = new SymbolInfo($1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + $6->getName(), "func_definition");
			
		}
		| type_specifier ID LPAREN RPAREN compound_statement {
			string output = $1->getName() + " " + $2->getName() + "()" + $5->getName();
			logFileText += "Line " + to_string(lineCount) + ": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n" + output + "\n\n";
			$$ = new SymbolInfo(output, "func_definition");
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {
					logFileText += "Line " + to_string(lineCount) + ": parameter_list : parameter_list COMMA type_specifier ID\n\n" + $1->getName() + "," + $3->getName() + " " + $4->getName() + "\n\n";
					$$ = $1;
					$$->setName($1->getName() + "," + $3->getName() + " " + $4->getName());
				}
				| parameter_list COMMA type_specifier {

				}
				| type_specifier ID {
					logFileText += "Line " + to_string(lineCount) + ": parameter_list : type_specifier ID\n\n" + $1->getName() + " " + $2->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + " " + $2->getName(), "param_list");
				}
				| type_specifier {
					
				}
				;

 		
compound_statement : LCURL statements RCURL {
					logFileText += "Line " + to_string(lineCount) + ": compound_statement : LCURL statements RCURL\n\n" + "{\n" + $2->getName() + "\n}\n\n\n";
					
					logFileText += symbolTable->printAllScopeTable();

					symbolTable->exitCurrentScope();
					
					$$ = $2;
					$$->setName("{\n" + $2->getName() + "\n}\n");

					
				}
				| LCURL RCURL {

				}
				;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
					logFileText += "Line " + to_string(lineCount) + ": var_declaration : type_specifier declaration_list SEMICOLON\n\n" + $1->getName() + " " + $2->getName() + ";\n\n";
					
					$$ = new SymbolInfo($1->getName() + " " + $2->getName() + ";", "var_declaration");
				}
 				;
 		 
type_specifier	: INT {
					logFileText += "Line " + to_string(lineCount) + ": type_specifier : INT\n\nint\n\n"; 
					$$ = new SymbolInfo("int", "type_specifier");
				}
 				| FLOAT {
					logFileText += "Line " + to_string(lineCount) + ": type_specifier : FLOAT\n\nfloat\n\n";
					$$ = new SymbolInfo("float", "type_specifier");
				}
 				| VOID {
					logFileText += "Line " + to_string(lineCount) + ": type_specifier : VOID\n\nvoid\n\n";
					$$ = new SymbolInfo("void", "type_specifier");
				}
 				;
 		
declaration_list : declaration_list COMMA ID {

					logFileText += "Line " + to_string(lineCount) + ": declaration_list : declaration_list COMMA ID\n\n" + $1->getName() + "," + $3->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + "," + $3->getName(), "declaration_list");

				}
				| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
					
				}
 		  		| ID {
					$$ = $1;
					logFileText += "Line " + to_string(lineCount) + ": declaration_list : ID\n\n" + $1->getName() + "\n\n";


					symbolTable->insert($1->getName(), $1->getType());
				}
 		  		| ID LTHIRD CONST_INT RTHIRD {
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

		}
		| IF LPAREN expression RPAREN statement {


		}
		| IF LPAREN expression RPAREN statement ELSE statement {

		}
		| WHILE LPAREN expression RPAREN statement {

		}
		| PRINTLN LPAREN ID RPAREN SEMICOLON {

		}
		| RETURN expression SEMICOLON {
			logFileText += "Line " + to_string(lineCount) + ": statement : RETURN expression SEMICOLON\n\n" + "return " + $2->getName() + ";\n\n";
			$$ = $2;
			$$->setName("return " + $2->getName() + ";");
		}
		;
	  
expression_statement : SEMICOLON {

					}			
					| expression SEMICOLON {
						logFileText += "Line " + to_string(lineCount) + ": expression_statement : expression SEMICOLON\n\n" + $1->getName() + ";\n\n";
						$$ = $1;
						$$->setName($1->getName() + ";");
					}
					;
	  
variable : ID {
			logFileText += "Line " + to_string(lineCount) + ": variable : ID\n\n" + $1->getName() + "\n\n";
			$$ = $1;

			symbolTable->insert($1->getName(), $1->getType());
		}
		| ID LTHIRD expression RTHIRD 
		{
			logFileText += "Line " + to_string(lineCount) + ": variable : ID LTHIRD expression RTHIRD\n\n" + $1->getName() + "[" + $3->getName() + "]" + "\n\n";
			$$ = new SymbolInfo($1->getName() + "[" + $3->getName() + "]", "variable");
		}
		;
	 
expression : logic_expression	{
					logFileText += "Line " + to_string(lineCount) + ": expression : logic_expression\n\n" + $1->getName() + "\n\n";
					$$ = $1;
 			}
			| variable ASSIGNOP logic_expression {
				logFileText += "Line " + to_string(lineCount) + ": expression : variable ASSIGNOP logic_expression\n\n" + $1->getName() + "=" + $3->getName() + "\n\n";
				$$ = new SymbolInfo($1->getName() + "=" + $3->getName(), "expression");
			}	
			;
			
logic_expression : rel_expression {
					logFileText += "Line " + to_string(lineCount) + ": logic_expression : rel_expression\n\n" + $1->getName() + "\n\n";
					$$ = $1;
				}
				| rel_expression LOGICOP rel_expression {
					logFileText += "Line " + to_string(lineCount) + ": logic_expression : rel_expression LOGICOP rel_expression\n\n" + $1->getName() + $2->getName() + $3->getName() + "\n\n";
					$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(), "logic_expression");
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
		logFileText += "Line " + to_string(lineCount) + ": term : term MULOP unary_expression\n\n" + $1->getName() + $2->getName() + $3->getName() + "\n\n";
		$$ = $1;
		$$->setName($1->getName() + $2->getName() + $3->getName());
	}
    ;

unary_expression : ADDOP unary_expression {

		}  
		| NOT unary_expression {

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
			logFileText += "Line " + to_string(lineCount) + ": factor : ID LPAREN argument_list RPAREN\n\n" + $1->getName() + "(" + $3->getName() + ")" + "\n\n";
			$$ = new SymbolInfo($1->getName() + "(" + $3->getName() + ")", "factor");
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
		}
	    | logic_expression {
			logFileText += "Line " + to_string(lineCount) + ": arguments : logic_expression\n\n" + $1->getName() + "\n\n";
			$$ = $1;
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
	// fp3= fopen(argv[3],"w");
	// fclose(fp3);
	
	// fp2= fopen(argv[2],"a");
	// fp3= fopen(argv[3],"a");
	

	yyin=fp;
	yyparse();

	logFileText += symbolTable->printAllScopeTable();

	string lineCountText = "Total lines: " + to_string(lineCount) + "\n";
	string errorCountText = "Total errors: " + to_string(errorCount) + "\n";

	fprintf(logFile, "%s", logFileText.c_str());

	fprintf(logFile, "%s", lineCountText.c_str());
	fprintf(logFile, "%s", errorCountText.c_str());
	

	fclose(logFile);
	
	return 0;
}