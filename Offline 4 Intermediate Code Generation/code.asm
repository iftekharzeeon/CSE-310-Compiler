.MODEL SMALL
.STACK 100H

.DATA
	CR EQU 0DH
	LF EQU 0AH
	VAR_TO_PRINT DW ?
	COUNT DW ?

	k_1 DW ?
	temp_a DW ?

	x_2 DW ?
	i_3 DW ?
	temp_b DW ?

	a_4 DW ?
	b_5 DW ?
	i_6 DW ?

.CODE
MAIN PROC
	;DATA INIT
	MOV AX, @DATA
	MOV DS, AX


	PUSH 1
	;a = 1
	POP BX
	MOV a_4, BX
	PUSH 2
	;b = 2
	POP BX
	MOV b_5, BX
	;Call Proc g
	PUSH a_4
	PUSH b_5
	POP temp_b
	POP temp_a
	CALL G
	;a = g(a,b)
	POP BX
	MOV a_4, BX
	;println(a)
	MOV CX, a_4
	MOV VAR_TO_PRINT, CX
	CALL NEW_LINE
	CALL PRINT_VAR
	CALL NEW_LINE
	;for(i=0;i<4;i++)
	PUSH 0
	;i = 0
	POP BX
	MOV i_6, BX
label_23:
	PUSH 4
	;Check i < 4
	MOV AX, i_6
	POP BX
	CMP AX, BX
	JL label_16
	PUSH 0
	JMP label_17

label_16:
	PUSH 1

label_17:

	POP AX
	CMP AX, 1
	JGE label_24
	JMP label_25
label_24:
	PUSH 3
	;a = 3
	POP BX
	MOV a_4, BX
label_20:
	PUSH 0
	;Check a > 0
	MOV AX, a_4
	POP BX
	CMP AX, BX
	JG label_18
	PUSH 0
	JMP label_19

label_18:
	PUSH 1

label_19:

	POP AX
	CMP AX, 1
	JGE label_21
	JMP label_22
label_21:
	;b++
	MOV AX, b_5
	ADD AX, 1
	MOV b_5, AX
	;a--
	MOV AX, a_4
	SUB AX, 1
	MOV a_4, AX
	PUSH AX
	JMP label_20
label_22:
	;i++
	MOV AX, i_6
	ADD AX, 1
	MOV i_6, AX
	JMP label_23
label_25:
	;println(a)
	MOV CX, a_4
	MOV VAR_TO_PRINT, CX
	CALL NEW_LINE
	CALL PRINT_VAR
	CALL NEW_LINE
	;println(b)
	MOV CX, b_5
	MOV VAR_TO_PRINT, CX
	CALL NEW_LINE
	CALL PRINT_VAR
	CALL NEW_LINE
	;println(i)
	MOV CX, i_6
	MOV VAR_TO_PRINT, CX
	CALL NEW_LINE
	CALL PRINT_VAR
	CALL NEW_LINE
	POP BP
	PUSH 0
	PUSH BP

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
	MOV CX, AX

	;PRINT MINUS SIGN
	MOV DL, '-'
	MOV AH, 2
	INT 21H

	MOV AX, CX
	NEG AX
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


F PROC NEAR

	PUSH 5
	;k = 5
	POP BX
	MOV k_1, BX
label_3:
	PUSH 0
	;Check k > 0
	MOV AX, k_1
	POP BX
	CMP AX, BX
	JG label_1
	PUSH 0
	JMP label_2

label_1:
	PUSH 1

label_2:

	POP AX
	CMP AX, 1
	JGE label_4
	JMP label_5
label_4:
	;a++
	MOV AX, temp_a
	ADD AX, 1
	MOV temp_a, AX
	;k--
	MOV AX, k_1
	SUB AX, 1
	MOV k_1, AX
	PUSH AX
	JMP label_3
label_5:
	POP BP
	PUSH 3
	;3*a
	POP AX
	MOV BX, temp_a
	MUL BX
	PUSH AX
	PUSH 7
	;3*a-7
	POP BX
	POP AX
	SUB AX, BX
	PUSH AX
	PUSH BP

	RET

F ENDP

G PROC NEAR

	;Call Proc f
	PUSH temp_a
	POP temp_a
	CALL F
	;f(a)+a
	POP BX
	MOV AX, temp_a
	ADD AX, BX
	PUSH AX
	;f(a)+a+b
	POP BX
	MOV AX, temp_b
	ADD AX, BX
	PUSH AX
	;x = f(a)+a+b
	POP BX
	MOV x_2, BX
	;for(i=0;i<7;i++)
	PUSH 0
	;i = 0
	POP BX
	MOV i_3, BX
label_13:
	PUSH 7
	;Check i < 7
	MOV AX, i_3
	POP BX
	CMP AX, BX
	JL label_6
	PUSH 0
	JMP label_7

label_6:
	PUSH 1

label_7:

	POP AX
	CMP AX, 1
	JGE label_14
	JMP label_15
label_14:
	PUSH 3
	;i%3
	MOV AX, i_3
	POP BX
	MOV DX, 0
	DIV BX
	PUSH DX
	PUSH 0
	;Check i%3 == 0
	POP AX
	POP BX
	CMP AX, BX
	JE label_8
	PUSH 0
	JMP label_9

label_8:
	PUSH 1

label_9:

	;if (i%3==0) else
	POP AX
	CMP AX, 1
	JNE label_10
	PUSH 5
	;x+5
	MOV BX, x_2
	POP AX
	ADD AX, BX
	PUSH AX
	;x = x+5
	POP BX
	MOV x_2, BX

	JMP label_12

label_10:
	PUSH 1
	;x-1
	MOV BX, x_2
	POP AX
	SUB AX, BX
	PUSH AX
	;x = x-1
	POP BX
	MOV x_2, BX


label_12:
	;i++
	MOV AX, i_3
	ADD AX, 1
	MOV i_3, AX
	JMP label_13
label_15:
	POP BP
	PUSH x_2
	PUSH BP

	RET

G ENDP

END MAIN
