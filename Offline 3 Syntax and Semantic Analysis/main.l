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
#include "y.tab.h"

using namespace std;

int lineCount = 1;
int errorCount = 0;

int stringLineCount = 0;
int commentLineCount = 0;

string logFileText = "";
string errorFileText = "";

string stringLiterals = "";
string stringTokenValue = "";

string commentLiteral = "";

string originalString = "";

extern SymbolTable *symbolTable;
void yyerror(char *s);

string to_upper(char *str) {
	char* temp = str;
    while(*temp) {
        *temp = toupper(*temp);
		temp++;
    }
	return str;
}

%}

WHITESPACE [ \t\r\f\v]+

KEYWORDS "if"|"for"|"do"|"int"|"float"|"void"|"switch"|"default"|"else"|"while"|"break"|"char"|"double"|"return"|"case"|"continue"|"printf"

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

	if (upperLetteredKeyword == "IF") {
		return IF;
	} else if (upperLetteredKeyword == "ELSE") {
		return ELSE;
	} else if (upperLetteredKeyword == "FOR") {
		return FOR;
	} else if (upperLetteredKeyword == "WHILE") {
		return WHILE;
	} else if (upperLetteredKeyword == "DO") {
		return DO;
	} else if (upperLetteredKeyword == "BREAK") {
		return BREAK;
	} else if (upperLetteredKeyword == "INT") {
		return INT;
	} else if (upperLetteredKeyword == "CHAR") {
		return CHAR;
	} else if (upperLetteredKeyword == "FLOAT") {
		return FLOAT;
	} else if (upperLetteredKeyword == "DOUBLE") {
		return DOUBLE;
	} else if (upperLetteredKeyword == "VOID") {
		return VOID;
	} else if (upperLetteredKeyword == "RETURN") {
		return RETURN;
	} else if (upperLetteredKeyword == "SWITCH") {
		return CASE;
	} else if (upperLetteredKeyword == "CASE") {
		return DOUBLE;
	} else if (upperLetteredKeyword == "BREAK") {
		return BREAK;
	} else if (upperLetteredKeyword == "CONTINUE") {
		return CONTINUE;
	} else if (upperLetteredKeyword == "PRINTF") {
		return PRINTLN;
	}
	
}

{DIGITS} {

	string foundToken = yytext;

	SymbolInfo *newSymbolInfo = new SymbolInfo(foundToken, "CONST_INT");
	yylval.symbolInfo = newSymbolInfo;
	return CONST_INT;

}

{FLOAT_NUMBER} {
	string foundToken = yytext;

	SymbolInfo *newSymbolInfo = new SymbolInfo(foundToken, "CONST_FLOAT");
	yylval.symbolInfo = newSymbolInfo;
	return CONST_FLOAT; 

}

{CHARACTER} {
	string foundToken = yytext;

	char characterFound = yytext[1];

	SymbolInfo *newSymbolInfo = new SymbolInfo(foundToken, "CONST_CHAR");
	yylval.symbolInfo = newSymbolInfo;
	return CONST_CHAR; 

}

{SPECIAL_CHARACTER} {
	string foundToken = yytext;

	string specialSymbol = 	foundToken.substr(1, 2);

	string newToken = "";

	char characterFound1 = yytext[1];
	char characterFound2 = yytext[2];

	SymbolInfo *newSymbolInfo = new  SymbolInfo(foundToken, "CONST_CHAR");
	yylval.symbolInfo = newSymbolInfo;
	return CONST_CHAR;

}

{OPERATORS} {
	string foundToken = yytext;

	string newToken;
	string tokenType;

	if (foundToken == "+" || foundToken == "-") {
		SymbolInfo *newSymbolInfo = new  SymbolInfo(foundToken, "ADDOP");
		yylval.symbolInfo = newSymbolInfo;
		return ADDOP;

	} else if (foundToken == "++") {

		return INCOP;
	} else if (foundToken == "--") {

		return DECOP;
	} else if (foundToken == "*" || foundToken == "/" || foundToken == "%") {
		SymbolInfo *newSymbolInfo = new  SymbolInfo(foundToken, "MULOP");
		yylval.symbolInfo = newSymbolInfo;
		return MULOP;

	} else if (foundToken == "<" || foundToken == "<=" || foundToken == ">" || foundToken == ">=" || foundToken == "==" || foundToken == "!=") {
		SymbolInfo *newSymbolInfo = new  SymbolInfo(foundToken, "RELOP");
		yylval.symbolInfo = newSymbolInfo;
		return RELOP;

	} else if (foundToken == "=") {

		return ASSIGNOP;

	} else if (foundToken == "&&" || foundToken == "||") {
		SymbolInfo *newSymbolInfo = new SymbolInfo(foundToken, "LOGICOP");
		yylval.symbolInfo = newSymbolInfo;
		return LOGICOP;

	} else if (foundToken == "!") {

		return NOT;

	} else if (foundToken == "(") {

		return LPAREN;
		
	} else if (foundToken == ")") {

		return RPAREN;

	} else if (foundToken == "{") {

		return LCURL;
		
	} else if (foundToken == "}") {

		return RCURL;

	} else if (foundToken == "[") {

		return LTHIRD;

	} else if (foundToken == "]") {

		return RTHIRD;

	} else if (foundToken == ",") {

		return COMMA;

	} else if (foundToken == ";") {

		return SEMICOLON;
	}

}

{IDENTIFIERS} {
	string foundToken = yytext;
	
	SymbolInfo *newSymbolInfo = new SymbolInfo(foundToken, "ID");
	yylval.symbolInfo = newSymbolInfo;
	return ID;
}

\" {
	BEGIN STRING_STATE;
	cout << "Starting string" << endl;

	string foundToken = yytext;
	stringLiterals += foundToken;
	originalString += foundToken;
}

"//" {
	
	commentLiteral += yytext;
	BEGIN SINGLE_COMMENT_STATE;
}

\/\* {
	cout << "Multi line comment started" << endl;
	commentLiteral += yytext;
	BEGIN MULTI_COMMENT_STATE;
}

{MULTICHARACTER} {
	string foundToken = yytext;

	errorCount++;
}

{EMPTYCHARACTER} {
	string foundToken = yytext;

	errorCount++;
}

{INVALIDIDENTIFIER} {
	string foundToken = yytext;

	errorCount++;
}

{TOOMANYDECIMAL} {
	string foundToken = yytext;

	errorCount++;
}

{ILLFORMEDNUMBER} {
	string foundToken = yytext;

	errorCount++;
}

{UNFINISHEDCHARACTER} {
	string foundToken = yytext;

	errorCount++;
}

<SINGLE_COMMENT_STATE>{
	\n {
		commentLineCount++;

		BEGIN INITIAL;
		commentLiteral = "";
		lineCount += commentLineCount;
		commentLineCount = 0;
	}
	\\\n {
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

		string foundToken = yytext;
		commentLiteral += foundToken;

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

		string foundToken = yytext;
		stringLiterals += foundToken;
		originalString += foundToken;

		SymbolInfo *newSymbolInfo = new SymbolInfo(foundToken, "STRING");
		yylval.symbolInfo = newSymbolInfo;
		

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
	errorFileText += "Error at line no " + to_string(lineCount) + ": Unrecognized character " + foundToken + "\n\n";

	errorCount++;
}

%% 