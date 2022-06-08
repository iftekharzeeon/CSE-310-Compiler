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

IDENTIFIER [A-Za-z]

NEW_LINE [\n]

%%
{KEYWORDS} {
	char* foundToken = new char[strlen(yytext)];
	strcpy(foundToken, yytext);
	
    string upperLetteredKeyword = to_upper(foundToken);
	string newToken = "<" + upperLetteredKeyword + "> ";
	tokens += newToken;
	string logFileText = "Line no " + to_string(lineCount) + ":" + " Token " + newToken + "Lexeme " + yytext + " found\n\n";

	fprintf(tokenFile, "%s", tokens.c_str());
	fprintf(logFile, "%s", logFileText.c_str());
}

{IDENTIFIER}* {}

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
	fclose(yyin);
	fclose(logFile);
	fclose(tokenFile);
	return 0;
}
