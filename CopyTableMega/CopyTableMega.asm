; Copy a table from flash to SRAM
; Read SRAM table and output to PORTD
.nolist
.include "m328pdef.inc"
.list

.def 	TEMP = R16

.ORG 	$0000
		RJMP 	RESET
.ORG 	OVF0addr
		RJMP	READTABLE
.ORG 	INT_VECTORS_SIZE
RESET:
		LDI		TEMP, high(RAMEND)
		OUT		SPH, TEMP
		LDI 	TEMP, low(RAMEND)
		OUT 	SPL, TEMP

		LDI 	TEMP, 0xFF
		OUT 	DDRD, TEMP

		LDI 	XH, high(SRAM_START + $20)
		LDI 	XL, low(SRAM_START + $20)

		LDI 	ZH, high(Pattern<<1)
		LDI 	ZL, low(Pattern<<1)

		LDI 	YH, high(PatternEnd<<1)
		LDI 	YL, low(PatternEnd<<1)

CopyNext:
		LPM 	TEMP, Z+
		ST 		X+, TEMP
		CP 		ZL, YL
		CPC 	ZH, YH
		BRNE 	CopyNext

		LDI 	XH, high(SRAM_START + $20)
		LDI 	XL, low(SRAM_START + $20)

TimerConfigure:
		LDI 	TEMP, (1<<TOIE0)
		STS 	TIMSK0, TEMP

		LDI 	TEMP, (1<<CS02)|(0<<CS01)|(1<<CS00)
		//LDI 	TEMP, (0<<CS02)|(0<<CS01)|(1<<CS00) ; FOR SIMULATION
		OUT 	TCCR0B, TEMP

		SEI

MAIN:
		NOP
		NOP	
		NOP
		RJMP 	MAIN

READTABLE:
		LDI 	TEMP, $80
		OUT 	TCNT0, TEMP
		LD 		TEMP, X+
		OUT 	PORTD, TEMP
		CPI 	XL, low(SRAM_START + $2C)
		BRNE 	NORESET
		LDI 	XH, high(SRAM_START + $20)
		LDI 	XL, low(SRAM_START + $20)
NORESET:
		RETI



Pattern:
.db 	$18, $24, $42, $81, $C3, $E7, $FF, $E7, $C3, $81, $00

PatternEnd:







