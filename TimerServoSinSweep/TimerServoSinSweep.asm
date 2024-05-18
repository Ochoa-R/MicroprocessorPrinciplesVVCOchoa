; ANTONIO OCHOA
; FOR ATmega328P
; Sinusoidal Movement Tables from harrimand on github
; need to figure out how exactly to add contents of program memory to pwmH:pwmL

; Sweep a servo motor in a sinusoidal motion by reading a table of values to 
;     add to the Output Compare Register.  
; Use Timer 2 output compare interrupt to trigger an interrupt every 20 mS to update servo position.
; Use Timer 1 OCR1A for PWM pulse width and the OC1A pin to servo motor.
; Use Timer 1 ICR1 register to set PWM period to 20 mS.

; ICR1 Counter TOP set to 20000 for 20 mS PWM Period
; OCR1A starts at 1500 for servo mid position 1.5 mS PWM pulse
; TCCR1B Clock Select 001 for 1 MHz MCUclk / 1 

; OCR2A  Counter TOP set to 156 for 20 mS Interrupt
; TIMSK2 Output Compare A interrupt enabled
; TCCR2B Clock Select CS22..0 for 1 MHz MCUclk / 128.

; Interrupt Service Routine for Timer 2 OCR2A match 
;    Read next Table Value
;    Add to PWMH and PWML register
;    Update OCR1A with new PWM values.
;    Reset Z address register when reaching end of table.

.nolist
.include "m328pdef.inc"
.list

.equ pulsePeriod = 20000
.equ pulseMid = 1500
.equ servoDelay = 156

.def TEMPL = r16
.def TEMP = r16
.def TEMPH = r17
.def pwmH = r15
.def pwmL = r14

.ORG $0000
	RJMP 	RESET
.ORG OC2Aaddr
	RJMP 	moveServo
.ORG INT_VECTORS_SIZE

RESET:
	LDI 	TEMP, high(RAMEND)
	OUT 	SPH, TEMP
	LDI 	TEMP, low(RAMEND)
	OUT 	SPL, TEMP

	SBI 	DDRB, 1 
	; PORTB PIN 1 OUTPUT

	LDI 	ZH, high(TABLEaddr<<1)
	LDI 	ZL, low(TABLEaddr<<1)
	; LOAD START OF TABLE TO INDEX Z

	LDI 	YH, high(TABLEend<<1)
	LDI 	YL, low(TABLEend<<1)
	; LOAD END OF TABLE TO INDEX Y

	LDI 	TEMPH, high(pulseMid)
	LDI 	TEMPL, low(pulseMid)
	MOVW 	pwmH:pwmL, TEMPH:TEMPL	
	STS 	OCR1AH, pwmH
	STS 	OCR1AL, pwmL
	; SET DUTY CYCLE TO 1500us

	LDI 	TEMPH, high(pulsePeriod)
	STS 	ICR1H, TEMPH
	LDI 	TEMPL, low(pulsePeriod)
	STS 	ICR1L, TEMPL
	; SET TOP OF TIMER 1 TO 20000us
	
	LDI 	TEMP, $82
	STS 	TCCR1A, TEMP 
	; SET OCR1A TO BOTTOM WHEN COMPARE MATCH
	; SET PART OF WGM FOR FAST PWM, TOP SET TO IRC1

	LDI 	TEMP, servoDelay
	STS 	OCR2A, TEMP
	; SET TOP OF TIMER 2 TO 156

	LDI 	TEMP, 0x02
	STS 	TIMSK2, TEMP
	; OUTPUT COMPARE A INTERRUPT ENABLE

	LDI 	TEMP, 0x82
	STS 	TCCR2A, TEMP
	; CLEAR TIMER ON COMPARE MATCH

	LDI 	TEMP, $19
	STS 	TCCR1B, TEMP 
	; TIMER 1 START / PRESCALER AT 1,
	; WGM BITS SET TO FAST PWM, TOP SET TO IRC1

	LDI 	TEMP, 0x05
	STS 	TCCR2B, TEMP 
	; TIMER 2 START / PRESCALER AT 128

	SEI
	;GLOBAL INTERRUPT ENABLE

HERE:
	NOP 
	RJMP 	HERE

moveServo:
	LPM 	TEMPL, Z+
	CLR 	TEMPH
	SBRC 	TEMPL, 7
	SER 	TEMPH
	ADD 	pwmL, TEMPL
	ADC 	pwmH, TEMPH
	STS	OCR1AH, pwmH
	STS 	OCR1AL, pwmL
	CP	ZL, YL
	CPC 	ZH, YH
	BRNE 	goBack
	LDI 	ZH, high(TABLEaddr<<1)
	LDI 	ZL, low(TABLEaddr<<1)
goBack:
	RETI

; 1.5 Second Sweep Time 
TABLEaddr:
.db	$27,	$28,	$27,	$26,	$25,	$23,	$22,	$21
.db	$1E,	$1B,	$1A,	$17,	$13,	$11,	$0E,	$0B
.db	$07,	$05,	$00,	$FE,	$FA,	$F7,	$F4,	$F0
.db	$EE,	$EB,	$E7,	$E6,	$E3,	$E1,	$DF,	$DD
.db	$DB,	$DB,	$D9,	$D9,	$D8,	$D9,	$D8,	$D9
.db	$D9,	$DB,	$DB,	$DD,	$DF,	$E1,	$E3,	$E6
.db	$E7,	$EB,	$EE,	$F0,	$F4,	$F7,	$FA,	$FE
.db	$00,	$05,	$07,	$0B,	$0E,	$11,	$13,	$17
.db	$1A,	$1B,	$1E,	$21,	$22,	$23,	$25,	$26
.db	$27,	$28,	$28
TABLEend:
	
; 2.5 Second Sweep Time 
/*TABLEaddr:
.db	$17,	$18,	$18,	$17,	$18,	$17,	$16,	$16
.db	$16,	$15,	$15,	$14,	$13,	$13,	$12,	$11
.db	$10,	$0F,	$0E,	$0E,	$0C,	$0B,	$0A,	$09
.db	$08,	$07,	$06,	$04,	$03,	$03,	$00,	$00
.db	$FF,	$FD,	$FC,	$FB,	$FA,	$F8,	$F8,	$F6
.db	$F6,	$F4,	$F3,	$F2,	$F1,	$F1,	$EF,	$EF
.db	$EE,	$ED,	$EC,	$EC,	$EB,	$EA,	$EA,	$EA
.db	$E9,	$E9,	$E9,	$E8,	$E8,	$E8,	$E9,	$E8
.db	$E8,	$E8,	$E9,	$E9,	$E9,	$EA,	$EA,	$EA
.db	$EB,	$EC,	$EC,	$ED,	$EE,	$EF,	$EF,	$F1
.db	$F1,	$F2,	$F3,	$F4,	$F6,	$F6,	$F8,	$F8
.db	$FA,	$FB,	$FC,	$FD,	$FF,	$00,	$00,	$03
.db	$03,	$04,	$06,	$07,	$08,	$09,	$0A,	$0B
.db	$0C,	$0E,	$0E,	$0F,	$10,	$11,	$12,	$13
.db	$13,	$14,	$15,	$15,	$16,	$16,	$16,	$17
.db	$18,	$17,	$18,	$18,	$18
TABLEend:*/
