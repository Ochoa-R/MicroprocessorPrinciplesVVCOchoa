; ANTONIO OCHOA
; SWAP EQUIVALENT WITH ROR INSTRUCTION

.nolist
.include "m328pdef.inc"
.list

.def 	ROTATE = R17
.def 	TEMP = R16
.def 	COUNT = R18

MAIN:
	LDI		TEMP, 0x72
	MOV 	ROTATE, TEMP
	OUT 	PORTB, ROTATE
	RCALL 	swap_nib
	RJMP 	MAIN

swap_nib:
	LDI 	COUNT, 0x04
	LDI 	TEMP, 0x00
next:
	CLC
	ROR		ROTATE
	OUT 	PORTB, ROTATE
	ROR 	TEMP
	OUT 	PORTD, TEMP
	DEC 	COUNT
	BRNE 	next
	OR 		ROTATE, TEMP
	OUT 	PORTB, ROTATE
	RET 	
