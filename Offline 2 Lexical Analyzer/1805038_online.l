%option noyywrap

%{
    #include<stdio.h>
    #include<cstring>
    #include<bits/stdc++.h>
    #include<string>

    using namespace std;


%}

ALPHABET [A-Za-z]
DIGIT [0-9]

NUMBER {DIGIT}+(.{DIGIT}+)?([Ee][-]?{DIGIT}+)?

DEFINE_KEYWORD "#define "

SPACE [ ]

ALL_CHARACTERS [ -~]

QUOTE [\"]

INT_MACRO {DEFINE_KEYWORD}{ALPHABET}+{SPACE}{NUMBER}

STRING_MACRO {DEFINE_KEYWORD}{ALPHABET}+{SPACE}{QUOTE}{ALPHABET}+{QUOTE}



%%
{INT_MACRO} { 
    cout << "MACRO " << yytext << " (MACRO WITH VALUE) DETECTED" << endl; 
}

{STRING_MACRO} {
    cout << "MACRO " << yytext << " (MACRO WITH VALUE) DETECTED" << endl; 
}
. {
    
}

%%

int main(int argc, char *argv[]) {
    if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	yyin = fin;
	yylex();

	fclose(yyin);

	return 0;
}