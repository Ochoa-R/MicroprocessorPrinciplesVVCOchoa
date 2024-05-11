; TIMER 1 SERVO CONTROL

.nolist
.include "m328pdef.inc"
.list

.equ 	pulsePeriod = $4e20
.equ 	pMid = $05dc
.equ 	pMin = 0x03eb
.equ 	pMax = 0x07d0

.def 	TEMPL = R16
.def 	TEMPH = R17
.def 	posH = R15
.def  	posL = R14
.def 	maxH = R13
.def 	maxL = R12
.def 	midH = R11
.def 	midL = R10
.def 	minH = R9
.def  	minL = R8

.ORG $0000
	RJMP 	RESET
.ORG INT0addr
	RJMP 	servoLeft
.ORG INT1addr
	RJMP 	servoRight
.ORG 	INT_VECTORS_SIZE
RESET:
	LDI 	TEMPH, high(RAMEND)
	OUT 	SPH, TEMPH
	LDI 	TEMPL, low(RAMEND)
	OUT 	SPL, TEMPL

	SBI 	DDRB, 1 ; OC1A PIN OUTPUT
	LDI 	TEMPH, 0x0C ; PULL-UP ENABLE ON PD3 & PD2
	OUT 	PORTD, TEMPH

	LDI 	TEMPH, 0x0A ; DETECT FALLING EDGE 
	STS 	EICRA, TEMPH
	LDI 	TEMPH, 0x03 ; ENABLE EXTERNAL INTERRUPTS
	OUT 	EIMSK, TEMPH

	LDI 	TEMPH, high(pMax)
	LDI 	TEMPL, low(pMax)
	MOVW 	maxH:maxL, TEMPH:TEMPL

	LDI 	TEMPH, high(pMin)
	LDI 	TEMPL, low(pMin)
	MOVW 	minH:minL, TEMPH:TEMPL

	LDI 	TEMPH, high(pMid)
	LDI		TEMPL, low(pMid)
	MOVW 	midH:midL, TEMPH:TEMPL
	MOVW 	posH:posL, midH:midL

	LDI 	TEMPH, high(pulsePeriod)
	STS 	ICR1H, TEMPH
	LDI 	TEMPL, low(pulsePeriod)
	STS 	ICR1L, TEMPL
	
	STS 	OCR1AH, midH
	STS 	OCR1AL, midL

	LDI 	TEMPH, (1<<COM1A1)|(0<<COM1A0)|(1<<WGM11)|(0<<WGM10)
	STS 	TCCR1A, TEMPH

	LDI 	TEMPH, (1<<WGM13)|(1<<WGM12)|(0<<CS12)|(0<<CS11)|(1<<CS10)
	STS 	TCCR1B, TEMPH

	SEI

MAIN:
	NOP
	NOP
	NOP
	RJMP MAIN

servoLeft:
	STS 	OCR1AH, minH
	STS 	OCR1AL, minL
	RETI

servoRight:
	STS 	OCR1AH, maxH
	STS 	OCR1AL, maxL
	RETI
