 
        ABSENTRY Entry        ; for absolute assembly: mark this as application entry point
    
; Include derivative-specific definitions 
		INCLUDE 'mc9s12dp256.inc'     ;CPU used by Dragon12+ board
 
 
;----------------------USE $1000-$2FFF for Scratch Pad 
R1      EQU     $1001
R2      EQU     $1002
R3      EQU     $1003
COUNT	DC.B	$FF
;code section
        ORG   $4000     ;Flash ROM address for Dragon12+
Entry:
	      LDS     #$4000    ;Stack
        BSET    DDRT,%00100000     ;PTT5 as Output pin for buzzer
   
MAIN	JSR	BUZZ	
	BRA	$

;-------Sound the Buzzer at PTT5

BUZZ    LDAA #COUNT
LP1	BSET PTT,%00100000     ;PTT5=1
    	JSR DELAY        
    	BCLR PTT,%00100000     ;PTT5=0
    	JSR DELAY        
      	DECA  
	BNE LP1             ;Keep toggling buzzer    
  
;----------DELAY
DELAY

        PSHA		;Save Reg A on Stack
        LDAA    #1		;Change this value to hear  
        STAA    R3		;different Buzzer sounds 
;--1 msec delay. The Serial Monitor works at speed of 48MHz with XTAL=8MHz on Dragon12+ board
;Freq. for Instruction Clock Cycle is 24MHz (1/2 of 48Mhz). 
;(1/24MHz) x 10 Clk x240x10=1 msec. Overheads are excluded in this calculation.         
L3      LDAA    #10
        STAA    R2
L2      LDAA    #240
        STAA    R1
L1      NOP         ;1 Intruction Clk Cycle
        NOP         ;1
        NOP         ;1
        DEC     R1  ;4
        BNE     L1  ;3
        DEC     R2  ;Total Instr.Clk=10
        BNE     L2
        DEC     R3
        BNE     L3
;--------------        
        PULA			;Restore Reg A
        RTS
;-------------------

            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry     ;Reset Vector. CPU wakes here and it is sent to start of the code at $4000