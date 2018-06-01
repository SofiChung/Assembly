    
        ABSENTRY Entry        ; for absolute assembly: mark this as application entry point
        
    
; Include derivative-specific definitions 
        INCLUDE 'mc9s12dp256.inc'     ;CPU used by Dragon12+ board
 
 
;----------------------USE $1000-$2FFF for Scratch Pad 
R1      EQU     $1001  ; example of using memory as "registers"
R2      EQU     $1002
R3      EQU     $1003
    ORG $1100
COUNT   DC.B    5
NUMS    DC.B    5,-7,18,-9,6
SUM DS.B    1
ERR DS.B    1

;code section
        ORG   $4000     ;Flash ROM address for Dragon12+
Entry:
    LDS     #$4000    ;Stack

;
;-------Put your code here
        LDAA    #0
    STAA    ERR ; No error
    LDX #NUMS
    LDD #0
NEXT:   ADDB    0,X
    BVC NOV
    LDAA    #1
    STAA    ERR
NOV:    INX
    DEC COUNT
    BNE NEXT
    STAB    SUM

      
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
       ORG   $FFFE
       DC.W  Entry     ;Reset Vector. CPU wakes here and it is sent to start of the code at $4000