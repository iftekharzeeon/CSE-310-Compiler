%option noyywrap

%x STRING_STATE
%x SINGLE_COMMENT_STATE
%x MULTI_COMMENT_STATE

%{
#include<stdio.h>
#include<cstring>
#include<bits/stdc++.h>
#include<string>

#include "headers/SymbolTable.h"

#define BUCKET_SIZE 7

using namespace std;

SymbolTable* symbolTable = new SymbolTable(BUCKET_SIZE);

int lineCount = 1;
int errorCount = 0;

int stringLineCount = 0;
int commentLineCount = 0;

FILE *logFile;
FILE *tokenFile;

string tokens = "";
string logFileText = "";

string stringLiterals = "";
string stringTokenValue = "";

string commentLiteral = "";

string originalString = "";

string to_upper(char *str) {
	char* temp = str;
    while(*temp) {
        *temp = toupper(*temp);
		temp++;
    }
	return str;
}

%}

WHITESPACE [ \t\v]+

KEYWORDS "if"|"for"|"do"|"int"|"float"|"void"|"switch"|"default"|"else"|"while"|"break"|"char"|"double"|"return"|"case"|"continue"

DIGIT [0-9]
DIGITS {DIGIT}+

ALPHABET [A-Za-z]
ALPHABET_ {ALPHABET}|_

FLOAT_NUMBER {DIGITS}?(\.{DIGITS})?([Ee][-]?{DIGITS})?

CHARACTER '[ -~]{-}[\\\']'

SPECIAL_CHARACTER '\\n'|'\\t'|'\\\\'|'\\\''|'\\a'|'\\f'|'\\r'|'\\b'|'\\v'|'\\0'

OPERATORS "+"|"-"|"="|"*"|"/"|"%"|"++"|"--"|"<"|"<="|">"|">="|"=="|"!="|"&&"|"||"|"!"|"("|")"|"{"|"}"|"["|"]"|","|";"

IDENTIFIERS {ALPHABET_}({DIGITS}|{ALPHABET_})*

NEW_LINE [\n]

MULTICHARACTER '([ -~][ -~]+)'

EMPTYCHARACTER ''

INVALIDIDENTIFIER ({DIGITS}+|{FLOAT_NUMBER}+){ALPHABET_}+

TOOMANYDECIMAL {FLOAT_NUMBER}(\.){FLOAT_NUMBER}(\.)({FLOAT_NUMBER})*

ILLFORMEDNUMBER {DIGITS}?E{DIGIT}*\.{DIGIT}*|{DIGITS}\.

UNFINISHEDCHARACTER '([ -~]{-}[\'])*|'\\'

%%

{WHITESPACE} {}

{KEYWORDS} {
	char* foundToken = new char[yyleng];
	strcpy(foundToken, yytext);
	
    string upperLetteredKeyword = to_upper(foundToken);
	string newToken = "<" + upperLetteredKeyword + "> ";
	tokens += newToken;
	logFileText += "Line no " + to_string(lineCount) + ":" + " Token " + newToken + "Lexeme " + yytext + " found\n\n";
}

{DIGITS} {
	//CONST_INT tokens

	string foundToken = yytext;

	string newToken = "<CONST_INT, " + foundToken + "> ";
	tokens += newToken;
	logFileText += "Line no " + to_string(lineCount) + ":" + " Token <CONST_INT> " + "Lexeme " + yytext + " found\n\n";

	if (symbolTable->insert(foundToken, "CONST_INT")) {
		logFileText += symbolTable->printAllScopeTable();
	} else {
		logFileText += foundToken + " already exists in current ScopeTable\n\n";
	}
}

{FLOAT_NUMBER} {
	//CONST_FLOAT tokens
	string foundToken = yytext;

	string newToken = "<CONST_FLOAT, " + foundToken + "> ";
	tokens += newToken;
	logFileText += "Line no " + to_string(lineCount) + ":" + " Token <CONST_FLOAT> " + "Lexeme " + yytext + " found\n\n";

	if (symbolTable->insert(foundToken, "CONST_FLOAT")) {
		logFileText += symbolTable->printAllScopeTable();
	} else {
		logFileText += foundToken + " already exists in current ScopeTable\n\n";
	}
}

{CHARACTER} {
	string foundToken = yytext;

	char characterFound = yytext[1];

	string newToken = "<CONST_CHAR, ";
	newToken += characterFound;
	newToken += "> ";
	tokens += newToken;
	logFileText += "Line no " + to_string(lineCount) + ":" + " Token <CONST_CHAR> " + "Lexeme " + yytext + " found --> " + newToken + "\n\n";

	if (symbolTable->insert(foundToken, "CONST_CHAR")) {
		logFileText += symbolTable->printAllScopeTable();
	} else {
		logFileText += foundToken + " already exists in current ScopeTable\n\n";
	}
}

{SPECIAL_CHARACTER} {
	string foundToken = yytext;

	string specialSymbol = 	foundToken.substr(1, 2);

	string newToken = "";

	char characterFound1 = yytext[1];
	char characterFound2 = yytext[2];

	if (characterFound2 == 't') {
		newToken = "<CONST_CHAR,\t > ";
	} else if (characterFound2 == 'n') {
		newToken = "<CONST_CHAR, \n > ";
	} else if (characterFound2 == '\\') {
		newToken = "<CONST_CHAR,\\ > ";
	} else if (characterFound2 == '\'') {
		newToken = "<CONST_CHAR,' > ";
	} else if (characterFound2 == 'a') {
		newToken = "<CONST_CHAR,\a > ";
	} else if (characterFound2 == 'f') {
		newToken = "<CONST_CHAR,\f > ";
	} else if (characterFound2 == 'r') {
		newToken = "<CONST_CHAR,\r > ";
	} else if (characterFound2 == 'b') {
		newToken = "<CONST_CHAR,\b > ";
	} else if (characterFound2 == 'v') {
		newToken = "<CONST_CHAR,\v > ";
	} else if (characterFound2 == '0') {
		newToken = "<CONST_CHAR,\0 > ";
	}

	tokens += newToken;
	logFileText += "Line no " + to_string(lineCount) + ":" + " Token <CONST_CHAR> " + "Lexeme " + yytext + " found --> " + newToken + "\n\n";

	if (symbolTable->insert(foundToken, "CONST_CHAR")) {
		logFileText += symbolTable->printAllScopeTable();
	} else {
		logFileText += foundToken + " already exists in current ScopeTable\n\n";
	}
}

{OPERATORS} {
	string foundToken = yytext;

	string newToken;
	string tokenType;

	if (foundToken == "+" || foundToken == "-") {
		newToken = "<ADDOP, " + foundToken + "> ";
		tokenType = "<ADDOP> ";

	} else if (foundToken == "++" || foundToken == "--") {
		newToken = "<INCOP, " + foundToken + "> ";
		tokenType = "<INCOP> ";
	} else if (foundToken == "*" || foundToken == "/" || foundToken == "%") {
		newToken = "<MULOP, " + foundToken + "> ";
		tokenType = "<MULOP> ";

	} else if (foundToken == "<" || foundToken == "<=" || foundToken == ">" || foundToken == ">=" || foundToken == "==" || foundToken == "!=") {
		newToken = "<RELOP, " + foundToken + "> ";
		tokenType = "<RELOP> ";

	} else if (foundToken == "=") {
		newToken = "<ASSIGNOP, " + foundToken + "> ";
		tokenType = "<ASSIGNOP> ";

	} else if (foundToken == "&&" || foundToken == "||") {
		newToken = "<LOGICOP, " + foundToken + "> ";
		tokenType = "<LOGICOP> ";

	} else if (foundToken == "!") {
		newToken = "<NOTOP, " + foundToken + "> ";
		tokenType = "<NOTOP> ";

	} else if (foundToken == "(") {
		newToken = "<LPAREN, " + foundToken + "> ";
		tokenType = "<LPAREN> ";
		
	} else if (foundToken == ")") {
		newToken = "<RPAREN, " + foundToken + "> ";
		tokenType = "<RPAREN> ";

	} else if (foundToken == "{") {
		symbolTable->enterNewScope(BUCKET_SIZE);
		newToken = "<LCURL, " + foundToken + "> ";
		tokenType = "<LCURL> ";
		
	} else if (foundToken == "}") {
		symbolTable->exitCurrentScope();
		newToken = "<RCURL, " + foundToken + "> ";
		tokenType = "<RCURL> ";

	} else if (foundToken == "[") {
		newToken = "<LTHIRD, " + foundToken + "> ";
		tokenType = "<LTHIRD> ";

	} else if (foundToken == "]") {
		newToken = "<RTHIRD, " + foundToken + "> ";
		tokenType = "<RTHIRD> ";

	} else if (foundToken == ",") {
		newToken = "<COMMA, " + foundToken + "> ";
		tokenType = "<COMMA> ";

	} else if (foundToken == ";") {
		newToken = "<SEMICOLON, " + foundToken + "> ";
		tokenType = "<SEMICOLON> ";

	}

	tokens += newToken;

	logFileText += "Line no " + to_string(lineCount) + ":" + " Token " + tokenType + "Lexeme " + yytext + " found\n\n";

}

\" {
	BEGIN STRING_STATE;
	cout << "Starting string" << endl;

	string foundToken = yytext;
	stringLiterals += foundToken;
	originalString += foundToken;
}

"//" {
	cout << "Comment found" << endl;
	commentLiteral += yytext;
	BEGIN SINGLE_COMMENT_STATE;
}

\/\* {
	cout << "Multi line comment started" << endl;
	commentLiteral += yytext;
	BEGIN MULTI_COMMENT_STATE;
}

{IDENTIFIERS} {
	string foundToken = yytext;

	string newToken = "<ID, " + foundToken + "> ";
	tokens += newToken;
	logFileText += "Line no " + to_string(lineCount) + ":" + " Token <ID> " + "Lexeme " + yytext + " found\n\n";

	if (symbolTable->insert(foundToken, "ID")) {
		logFileText += symbolTable->printAllScopeTable();
	} else {
		logFileText += foundToken + " already exists in current ScopeTable\n\n";
	}
}

{MULTICHARACTER} {
	string foundToken = yytext;

	logFileText += "Error at line no " + to_string(lineCount) + ": Multi character constant error " + foundToken + "\n\n";

	errorCount++;
}

{EMPTYCHARACTER} {
	string foundToken = yytext;

	logFileText += "Error at line no " + to_string(lineCount) + ": Empty character constant error " + foundToken + "\n\n";

	errorCount++;
}

{INVALIDIDENTIFIER} {
	string foundToken = yytext;

	logFileText += "Error at line no " + to_string(lineCount) + ": Invalid prefix on ID or invalid suffix on Number " + foundToken + "\n\n";

	errorCount++;
}

{TOOMANYDECIMAL} {
	string foundToken = yytext;

	logFileText += "Error at line no " + to_string(lineCount) + ": Too many decimal points " + foundToken + "\n\n";

	errorCount++;
}

{ILLFORMEDNUMBER} {
	string foundToken = yytext;

	logFileText += "Error at line no " + to_string(lineCount) + ": Ill formed number " + foundToken + "\n\n";

	errorCount++;
}

{UNFINISHEDCHARACTER} {
	string foundToken = yytext;

	logFileText += "Error at line no " + to_string(lineCount) + ": Unterminated character " + foundToken + "\n\n";

	errorCount++;
}

<SINGLE_COMMENT_STATE>{
	\n {
		cout << "Comment end" << endl;
		commentLineCount++;

		logFileText += "Line no " + to_string(lineCount) + ":" + " Token <COMMENT> " + "Lexeme " + commentLiteral + " found\n\n";

		BEGIN INITIAL;
		commentLiteral = "";
		lineCount += commentLineCount;
		commentLineCount = 0;
	}
	\\\n {
		cout << "New line in comment" << endl;
		commentLineCount++;
		string foundToken = yytext;
		commentLiteral += foundToken;
	}
	. {
		string foundToken = yytext;
		commentLiteral += foundToken;
	}
}

<MULTI_COMMENT_STATE>{
	\*\/ {
		cout << "Multi line comment end" << endl;

		string foundToken = yytext;
		commentLiteral += foundToken;

		logFileText += "Line no " + to_string(lineCount) + ":" + " Token <COMMENT> " + "Lexeme " + commentLiteral + " found\n\n";

		BEGIN INITIAL;
		commentLiteral = "";
		lineCount += commentLineCount;
		commentLineCount = 0;
	}

	\n {
		commentLineCount++;
		string foundToken = yytext;
		commentLiteral += foundToken;
	}

	<<EOF>> {
		cout << "Unfinished " << endl;

		logFileText += "Error at line no " + to_string(lineCount) + ": Unterminated Comment " + commentLiteral + "\n\n";
		
		errorCount++;

		BEGIN INITIAL;
		commentLiteral = "";
		lineCount += commentLineCount;
		commentLineCount = 0;
	}

	. {
		string foundToken = yytext;
		commentLiteral += foundToken;
	}
}

<STRING_STATE>{
	\" {
		cout << "Ending string" << endl;

		string foundToken = yytext;
		stringLiterals += foundToken;
		originalString += foundToken;

		string newToken = "<STRING, " + originalString + "> ";
		tokens += newToken;
		logFileText += "Line no " + to_string(lineCount) + ":" + " Token <STRING> " + "Lexeme " + stringLiterals + " found --> " + newToken + "\n\n";

		BEGIN INITIAL;
		stringLiterals = "";
		originalString = "";
		lineCount += stringLineCount;
		stringLineCount = 0;
	}

	\\\" {
		cout << "\" occured inside string" << endl;
		originalString += yytext[1];
		stringLiterals += yytext;

	}
	\\\n {
		cout << "New Line with \\ found" << endl;
		stringLineCount++;
		string foundToken = yytext;
		stringLiterals += foundToken;
	}

	\\{ALPHABET} {
		cout << "Spcial character found" << endl;
		string foundToken = yytext;
		stringLiterals += foundToken;

		char c = yytext[1];
		if (c == 't') {
			originalString += "\t";
		} else if (c == 'n') {
			originalString += "\n";
		} else if (c == 'v') {
			originalString += "\v";
		} else if (c == 'r') {
			originalString += "\r";
		} else if (c == 'b') {
			originalString += "\b";
		} else if (c == 'f') {
			originalString += "\f";
		} else if (c == '\\') {
			originalString += "\\";
		} else if (c == '0') {
			originalString += '\0';
		} else {
			originalString += foundToken;
		}
	}
	{NEW_LINE} {
		
		stringLineCount++;
		errorCount++;
		logFileText += "Error at line no " + to_string(lineCount) + ": Unterminated String " + stringLiterals + "\n\n";

		BEGIN INITIAL;
		stringLiterals = "";
		originalString = "";
		lineCount += stringLineCount;
		stringLineCount = 0;
	}
	. {
		stringLiterals += yytext;
		originalString += yytext;
	}
}


{NEW_LINE} {
	lineCount++;
}


. {
	string foundToken = yytext;

	logFileText += "Error at line no " + to_string(lineCount) + ": Unrecognized character " + foundToken + "\n\n";

	errorCount++;
}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logFile = fopen("log.txt","w");
	tokenFile = fopen("token.txt","w");

	yyin = fin;
	yylex();

	string lineCountText = "Total lines: " + to_string(lineCount) + "\n";
	string errorCountText = "Total errors: " + to_string(errorCount) + "\n";

	logFileText += symbolTable->printAllScopeTable();

	fprintf(tokenFile, "%s", tokens.c_str());
	fprintf(logFile, "%s", logFileText.c_str());

	fprintf(logFile, "%s", lineCountText.c_str());
	fprintf(logFile, "%s", errorCountText.c_str());
	fclose(yyin);
	fclose(logFile);
	fclose(tokenFile);

	return 0;
}
