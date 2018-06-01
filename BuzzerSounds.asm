   
        ABSENTRY Entry        ; for absolute assembly: mark this as application entry point
    
; Include derivative-specific definitions 
		INCLUDE 'mc9s12dp256.inc'     ;CPU used by Dragon12+ board
 
 
;----------------------USE $1000-$2FFF for Scratch Pad 
R1      EQU     $1001
R2      EQU     $1002
R3      EQU     $1003
;COUNT	DC.B	$FF
BUZZ_R3	EQU	$1004

;code section
        ORG   $4000     ;Flash ROM address for Dragon12+
Entry:
	      LDS     #$4000    ;Stack
        BSET    DDRT,%00100000     ;PTT5 as Output pin for buzzer
   
MAIN	LDAA	#1
	STAA	BUZZ_R3	
	JSR	BUZZ

;-------Sound the Buzzer at PTT5

BUZZ    LDAA	#$FF
BACK	BSET	PTT, %00100000
	MOVB	BUZZ_R3, R3
	JSR	DELAY
	BCLR	PTT, %00100000
	MOVB	BUZZ_R3, R3
	JSR	DELAY
	BNE	BACK
	RTS 
  