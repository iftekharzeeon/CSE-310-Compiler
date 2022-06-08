%option noyywrap

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

FILE *logFile;
FILE *tokenFile;

string tokens = "";
string logFileText = "";

string to_upper(char *str) {
	char* temp = str;
    while(*temp) {
        *temp = toupper(*temp);
		temp++;
    }
	return str;
}

%}

KEYWORDS "if"|"for"|"do"|"int"|"float"|"void"|"switch"|"default"|"else"|"while"|"break"|"char"|"double"|"return"|"case"|"continue"

DIGIT [0-9]
DIGITS {DIGIT}+

ALPHABET [A-Za-z]
ALPHABET_ [{ALPHABET}_]

FLOAT_NUMBER {DIGITS}?(\.{DIGITS})(E[+-]?{DIGITS})?

CHARACTER '{ALPHABET}'

NEW_LINE [\n]

%%
{KEYWORDS} {
	char* foundToken = new char[yyleng];
	strcpy(foundToken, yytext);
	
    string upperLetteredKeyword = to_upper(foundToken);
	string newToken = "<" + upperLetteredKeyword + "> ";
	tokens += newToken;
	string logFileText = "Line no " + to_string(lineCount) + ":" + " Token " + newToken + "Lexeme " + yytext + " found\n\n";

	fprintf(tokenFile, "%s", tokens.c_str());
	fprintf(logFile, "%s", logFileText.c_str());
}

{DIGITS} {
	//CONST_INT tokens

	string foundToken = yytext;

	string newToken = "<CONST_INT," + foundToken + "> ";
	tokens += newToken;
	string logFileText = "Line no " + to_string(lineCount) + ":" + " Token <CONST_INT> " + "Lexeme " + yytext + " found\n\n";

	fprintf(tokenFile, "%s", tokens.c_str());
	fprintf(logFile, "%s", logFileText.c_str());

	symbolTable->insert(foundToken, "CONST_INT");
	symbolTable->printAllScopeTable();
}

{FLOAT_NUMBER} {
	//CONST_FLOAT tokens
	string foundToken = yytext;

	string newToken = "<CONST_FLOAT," + foundToken + "> ";
	tokens += newToken;
	string logFileText = "Line no " + to_string(lineCount) + ":" + " Token <CONST_FLOAT> " + "Lexeme " + yytext + " found\n\n";

	fprintf(tokenFile, "%s", tokens.c_str());
	fprintf(logFile, "%s", logFileText.c_str());

	symbolTable->insert(foundToken, "CONST_FLOAT");
	symbolTable->printAllScopeTable();
}

{CHARACTER} {
	string foundToken = yytext;

	char characterFound = yytext[1];

	string newToken = "<CONST_CHAR,";
	newToken += characterFound;
	newToken += "> ";
	tokens += newToken;
	string logFileText = "Line no " + to_string(lineCount) + ":" + " Token <CONST_CHAR> " + "Lexeme " + yytext + " found --> " + newToken + "\n\n";

	fprintf(tokenFile, "%s", tokens.c_str());
	fprintf(logFile, "%s", logFileText.c_str());

	symbolTable->insert(foundToken, "CONST_CHAR");
	symbolTable->printAllScopeTable();
}

{NEW_LINE} {
	lineCount++;
}

. {}
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

	fprintf(logFile, "%s", lineCountText.c_str());
	fprintf(logFile, "%s", errorCountText.c_str());
	fclose(yyin);
	fclose(logFile);
	fclose(tokenFile);

	return 0;
}
