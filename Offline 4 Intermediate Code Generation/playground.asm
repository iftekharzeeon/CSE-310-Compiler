.MODEL SMALL
.STACK 100H

.DATA         
CR EQU 0DH
LF EQU 0AH
VAR_TO_PRINT DW ?
COUNT DW ?

.CODE 
MAIN PROC 
    ;DATA INIT
    MOV AX, @DATA
    MOV DS, AX 

    MOV VAR_TO_PRINT, -45

    ;LINE BREAK
    CALL NEW_LINE
    CALL PRINT_VAR        
    
    ;EXIT PROGRAM        
    MOV AH, 4CH
    INT 21H

    MAIN ENDP 

PRINT_VAR PROC 

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV COUNT, 0

    MOV AX, VAR_TO_PRINT   
    CMP AX, 0 
    JL NEGATIVE_PRINT

START_DIVISION:     
    MOV DX, 0
    MOV CX, 10
    DIV CX
    PUSH DX
    ADD COUNT, 1
    CMP AX, 0
    JE POP_STACK    
    JMP START_DIVISION

NEGATIVE_PRINT:
    MOV CX, AX                           ;STORE AX TEMPORALILY IN CX
    ;PRINT MINUS SIGN
    MOV DL, '-'
    MOV AH, 2
    INT 21H
    
    MOV AX, CX
    NEG AX                               ;NEGATE THE NUMBER TO GET THE POSITIVE NUMBER
    JMP START_DIVISION

POP_STACK:  
    POP DX 
    ADD DL, '0'
    MOV AH, 2
    INT 21H
    
    SUB COUNT, 1
    MOV CX, COUNT   
    CMP CX, 0
    JNE POP_STACK 
               
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET

    PRINT_VAR ENDP

NEW_LINE PROC  

    MOV AH, 2
    MOV DL, CR
    INT 21H
    MOV AH, 2
    MOV DL, LF
    INT 21H  
    
    RET
NEW_LINE ENDP               
           

END MAIN