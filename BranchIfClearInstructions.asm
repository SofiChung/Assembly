  
        ABSENTRY Entry        ; for absolute assembly: mark this as application entry point
    
; Include derivative-specific definitions 
		INCLUDE 'mc9s12dp256.inc'     ;CPU used by Dragon12+ board
 
 
;----------------------USE $1000-$2FFF for Scratch Pad 
R1      EQU     $1001
R2      EQU     $1002
R3      EQU     $1003

;code section
        ORG   $4000     ;Flash ROM address for Dragon12+
Entry:
	      LDS     #$4000    ;Stack
        LDAA    #$FF
        STAA    DDRB		;Make PORTB output
  ;PTJ1 controls the LEDs connected to PORTB (For Dragon12+ ONLY)
        LDAA    #$FF      	
	      STAA    DDRJ   	;Make PORTJ output, (Needed by Dragon12+) 
	      LDAA    #$0
	      STAA    PTJ   	;Turn off PTJ1 to allow the LEDs on PORTB to show data (Needed by Dragon12+) 
;
;-------Toggling ALL LEDs connected to PORTB

	CLRA
AGAIN	STAA	PORTB
	JSR	DELAY
	INCA	
	BRCLR	PORTB, %00000100, AGAIN
	CLRA	
	BRA	AGAIN
	  
;----------DELAY
DELAY

        PSHA		;Save Reg A on Stack
        LDAA    #10		;Change this value to see  
        STAA    R3		;how fast LEDs Toggle        
L3      LDAA    #100
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