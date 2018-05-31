
;To Download and Execute, Make sure you are in HCS12 Serial Monitor Mode before downloading 
;and also make sure SW7=LOAD (SW7 is 2-bit red DIP Switch on bottom right side of the board and must be 00, or LOAD) 
;Press F7 (to Make), then F5(Debug) to downLOAD,and F5 once more to start the program execution

    
        ABSENTRY Entry        ; for absolute assembly: mark this as application entry point
        
    
; Include derivative-specific definitions 
		INCLUDE 'mc9s12dp256.inc'     ;CPU used by Dragon12+ board
 
 
;----------------------USE $1000-$2FFF for Scratch Pad <This is DATA SEGMENT> 
R1      EQU     $1001  ; example of using memory as "registers"
R2      EQU     $1002
R3      EQU     $1003

 

        ORG     $1010
MYNAME  FCC     "Soojin Chung"   ; ----> Defining Registers

        ORG $1050
        
NUM1    DC.B $1 
NUM2    DC.B $3 
NUM3    DC.B $7 
NUM4    DC.B $F 
NUM5    DC.B $1F 
NUM6    DC.B $3F 
NUM7    DC.B $7F
NUM8    DC.B $FF


;code section
        ORG   $4000     ;Flash ROM address for Dragon12+ <FROM $4000, THERE IS CODE SEGMENT>
Entry:
	LDS     #$4000    ;Stack
	
	LDAA #$FF
	STAA DDRB
	LDAA #$0
	STAA DDRH
	
	LDAA #$FF
	STAA DDRJ
	LDAA #$0
	STAA PTJ

;
;-------Put your code here
        NOP         ;put your code here
 
BACK    MOVB NUM1, PORTB
        JSR DELAY 
        MOVB NUM2, PORTB
        JSR DELAY
        MOVB NUM3, PORTB
        JSR DELAY
        MOVB NUM4, PORTB
        JSR DELAY
        MOVB NUM5, PORTB
        JSR DELAY
        MOVB NUM6, PORTB
        JSR DELAY
        MOVB NUM7, PORTB
        JSR DELAY
        MOVB NUM8, PORTB
        JSR DELAY
     
        BRA BACK 

    
    
;----- ------------FOR DELAY 
DELAY

        PSHA		;Save Reg A on Stack
        LDAA    #50		;Change this value to see  
        STAA    R3		;how fast LEDs shows data coming from PTH DIP switches
;--10 msec delay. The Serial Monitor works at speed of 48MHz with XTAL=8MHz on Dragon12+ board
;Freq. for Instruction Clock Cycle is 24MHz (1/2 of 48Mhz). 
;(1/24MHz) x 10 Clk x240x100=10 msec. Overheads are excluded in this calculation.         
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