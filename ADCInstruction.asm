    
        ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

	INCLUDE 'mc9s12dp256.inc'     ;CPU used by Dragon12+ board
 
 
;----------------------USE $1000-$2FFF for Scratch Pad <This is DATA SEGMENT> 
R1      EQU     $1001  ; example of using memory as "registers"
R2      EQU     $1002
R3      EQU     $1003
        ORG     $1300

COUNT	DC.B	$4
NUM1	DC.B	$12, $34, $56, $78
NUM2	DC.B	$90, $AB, $CD, $EF
ANS	DS.B	5 		  ; 4 bytes + carry 

;code section
        ORG   $4000     ;Flash ROM address for Dragon12+ <FROM $4000, THERE IS CODE SEGMENT>
Entry:
	LDS     #$4000    ;Stack

;
;-------Put your code here
        NOP         ;put your code here
	
	LDX	#NUM1	
	INX
	INX
	INX
	LDY	#NUM2
	INY
	INY
	INY
	CLRA
	CLC
LP1	LDAA	0,X
	ADCA	0,Y
	STAA	5,Y
	DEX
	DEY
	DEC	COUNT
	BNE	LP1

	LDAA	#0
	BCC	CARRY
	LDAA	#1
CARRY	STAA	5,Y
	BRA 	$
	
      
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
       ORG   $FFFE
       DC.W  Entry     ;Reset Vector. CPU wakes here and it is sent to start of the code at $4000