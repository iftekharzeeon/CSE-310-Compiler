#include "bits/stdc++.h"
using namespace std;

#ifndef ASSEMBLYCODE_H
#define ASSEMBLYCODE_H

string initCode = ".MODEL SMALL\n"
                ".STACK 100H\n\n"
                ".DATA\n"
                "\tCR EQU 0DH\n"
                "\tLF EQU 0AH\n"
                "\tVAR_TO_PRINT DW ?\n"
                "\tCOUNT DW ?\n";

string printProc = "PRINT_VAR PROC\n\n"
                    "\tPUSH AX\n"
                    "\tPUSH BX\n"
                    "\tPUSH CX\n"
                    "\tPUSH DX\n\n"
                    "\tMOV COUNT, 0\n\n"
                    "\tMOV AX, VAR_TO_PRINT\n"
                    "\tCMP AX, 0\n"
                    "\tJL NEGATIVE_PRINT\n\n"
                    "START_DIVISION:\n"
                    "\tMOV DX, 0\n"
                    "\tMOV CX, 10\n"
                    "\tDIV CX\n"
                    "\tPUSH DX\n"
                    "\tADD COUNT, 1\n"
                    "\tCMP AX, 0\n"
                    "\tJE POP_STACK\n"    
                    "\tJMP START_DIVISION\n\n"
                    "NEGATIVE_PRINT:\n"
                    "\tMOV CX, AX\n\n"
                    "\t;PRINT MINUS SIGN\n"
                    "\tMOV DL, '-'\n"
                    "\tMOV AH, 2\n"
                    "\tINT 21H\n\n"
                    "\tMOV AX, CX\n"
                    "\tNEG AX\n"
                    "\tJMP START_DIVISION\n\n"
                    "POP_STACK:\n"
                    "\tPOP DX\n"
                    "\tADD DL, '0'\n"
                    "\tMOV AH, 2\n"
                    "\tINT 21H\n\n"
                    "\tSUB COUNT, 1\n"
                    "\tMOV CX, COUNT\n"
                    "\tCMP CX, 0\n"
                    "\tJNE POP_STACK\n\n"
                    "\tPOP DX\n"
                    "\tPOP CX\n"
                    "\tPOP BX\n"
                    "\tPOP AX\n\n"
                    "\tRET\n\n"
                    "\tPRINT_VAR ENDP\n\n";

string newLineProc = "NEW_LINE PROC\n\n"
                    "\tMOV AH, 2\n"
                    "\tMOV DL, CR\n"
                    "\tINT 21H\n"
                    "\tMOV AH, 2\n"
                    "\tMOV DL, LF\n"
                    "\tINT 21H\n\n"
                    "\tRET\n\n"
                    "\tNEW_LINE ENDP\n\n";

string codeSegmentInit = "\n.CODE\n"
                        "MAIN PROC\n"
                        "\t;DATA INIT\n"
                        "\tMOV AX, @DATA\n"
                        "\tMOV DS, AX\n\n";

string codeSegmentEnd = "\t;EXIT PROGRAM\n"
                        "\tMOV AH, 4CH\n"
                        "\tINT 21H\n\n"
                        "\tMAIN ENDP\n";

int numberOfLabel = 0;



void printToAsmFile(FILE *asmCodeFile, string codeLine) {
    fprintf(asmCodeFile, "%s\n", codeLine.c_str());
}

void printToDataAsmFile(FILE *asmCodeFileData, string codeLine) {
    fprintf(asmCodeFileData, "%s\n", codeLine.c_str());
}

void printToCodeAsmFile(FILE *asmCodeFileCode, string codeLine) {
    fprintf(asmCodeFileCode, "%s\n", codeLine.c_str());
}

void printToProcAsmFile(FILE *asmCodeFileProc, string codeLine) {
    fprintf(asmCodeFileProc, "%s\n", codeLine.c_str());
}

void initAsmFile(FILE *asmCodeFile) {
    fprintf(asmCodeFile, "%s\n", initCode.c_str());
}

void initAsmProcFile(FILE *asmCodeFileProc) {
    fprintf(asmCodeFileProc, "%s\n", printProc.c_str());
    fprintf(asmCodeFileProc, "%s\n", newLineProc.c_str());
}

void initAsmCodeFile(FILE *asmCodeFileCode) {
    fprintf(asmCodeFileCode, "%s\n", codeSegmentInit.c_str());
}

void mergeFiles(FILE *asmCodeFile, FILE *asmCodeFileData, FILE *asmCodeFileCode, FILE *asmCodeFileProc) {
    char * line = NULL;
    size_t len = 0;

    rewind(asmCodeFileData);
    rewind(asmCodeFileCode);
    rewind(asmCodeFileProc);

    while ((getline(&line, &len, asmCodeFileData)) != -1) {
        fprintf(asmCodeFile, "%s", line);
    }

    while ((getline(&line, &len, asmCodeFileCode)) != -1) {
        fprintf(asmCodeFile, "%s", line);
    }

    fprintf(asmCodeFile, "%s\n", codeSegmentEnd.c_str());

    while ((getline(&line, &len, asmCodeFileProc)) != -1) {
        fprintf(asmCodeFile, "%s", line);
    }

    fprintf(asmCodeFile, "%s\n", "END MAIN");

    if (line) free(line);

}

string newLabel() {
    numberOfLabel++;
    return "label_" + to_string(numberOfLabel);
}

string newTemp(string variableName) {
    return "temp_" + variableName;
}

#endif

