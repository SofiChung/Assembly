

        ABSENTRY Entry        ; for absolute assembly: mark this as application entry point
    
; Include derivative-specific definitions 
		INCLUDE 'mc9s12dp256.inc'     ;CPU used by Dragon12+ board
 
LCD_DATA  EQU   PORTK
LCD_CTRL  EQU   PORTK
RS        EQU   mPORTK_BIT0
EN        EQU   mPORTK_BIT1 
 
 
;----------------------USE $1000-$2FFF for Scratch Pad 
R1      EQU     $1001
R2      EQU     $1002
R3      EQU     $1003
TEMP    EQU     $1004
        ORG     $1100
TC      DS.B    1       ;Temp in celsius
TF      DS.B    1       ;Temp in fahrenheit
BCDC    DS.B    3       ;Unpacked BCD
BCDF    DS.B    3

;code section
        ORG   $4000     ;Flash ROM address for Dragon12+
Entry:
	      LDS     #$4000    ;Stack
	      JSR     LCDSETUP
        LDAA    #$FF
        STAA    DDRB		;Make PORTB output
  ;PTJ1 controls the LEDs connected to PORTB (For Dragon12+ ONLY)
        LDAA    #$FF      	
	      STAA    DDRJ   	;Make PORTJ output, (Needed by Dragon12+) 
	      LDAA    #$0
	      STAA    PTJ   	;Turn off PTJ1 to allow the LEDs on PORTB to show data (Needed by Dragon12+) 
;
MAIN    JSR     L11
        JSR     H1
        JSR     H2 
        JSR     DISP1
        JSR     DISP

        BRA     MAIN
        
;-------Get data fron Chan 5 of ATD0 and put it on PORTB

L11     MOVB	#$80,ATD0CTL2  
	      JSR	  DELAY	
	      MOVB	#$08,ATD0CTL3
	      MOVB	#$EB,ATD0CTL4    ;8-bit resolu, 16-clock for 2nd phase,
        RTS
        
                               ;prescaler of 24 for Conversion Freq=1MHz  
H1      MOVB	#$85,ATD0CTL5	   ;Chan 5 of ATD0  
        RTS
        
H2	    BRCLR ATD0STAT0,$80,H2
	      LDAA	ATD0DR0L		 
	      LDAB  #2
	      MUL
	      STAB  TC
;--------------------------Calculation for celsius -> fahrenheit	      
	      LDAA  TC
	      LDAB  #9
	      MUL
	      LDX   #5
	      IDIV
	      XGDX
	      
	      ADDB  #32
	      STAB  TF
;--------------------------Convert TC -> BCDC 
        LDY   #BCDC
        LDAB  TC
        LDX   #10
        IDIV  
        STAB  2,Y                                                                
        XGDX
        LDX   #10
        IDIV
        STAB  1,Y
        XGDX
        STAB  0,Y
;-------------------------Convert TF -> BCDF
        LDY   #BCDF
        LDAB  TF
        LDX   #10
        IDIV  
        STAB  2,Y
        XGDX
        LDX   #10
        IDIV
        STAB  1,Y
        XGDX
        STAB  0,Y
        RTS
;------------------------ Display first line (Showing C degree)
DISP1   LDAA  #$80        
        JSR   COMWRT4
        JSR   DELAY
        
        LDX   #BCDC
        LDAB  #0
        
LP1     LDAA  B, X
        ORAA  #$30	;Add #$30 to make the number ASCII
        JSR   DATWRT4
        JSR   DELAY
        INCB	
        CMPB  #3	;Being in loop for 3 times 
        BNE   LP1
        
        LDAA  #' '
        JSR   DATWRT4
        JSR   DELAY
        
        LDAA  #'C'
        JSR   DATWRT4
        JSR   DELAY
        
        RTS
        
;------------------------ Second line (Showing F degree)
DISP    LDAA  #$C0                    
        JSR   COMWRT4
        JSR   DELAY
        
        LDX   #BCDF
        LDAB  #0
LP2     LDAA  B, X
        ORAA  #$30
        JSR   DATWRT4
        JSR   DELAY
        INCB
        CMPB  #3
        BNE   LP2
        
        LDAA  #' '
        JSR   DATWRT4
        JSR   DELAY
        
        LDAA  #'F'
        JSR   DATWRT4
        JSR   DELAY 
        
        
        RTS        
	      
	      
;----------------------------	

LCDSETUP:
   		LDAA  #$FF
		  STAA  DDRK		
		  LDAA  #$33
		  JSR	  COMWRT4    	
  		JSR   DELAY
  		LDAA  #$32
		  JSR	  COMWRT4		
 		  JSR   DELAY
		  LDAA	#$28	
		  JSR	  COMWRT4    	
		  JSR	  DELAY   		
		  LDAA	#$0E     	
		  JSR	  COMWRT4		
		  JSR   DELAY
		  LDAA	#$01     	
		  JSR	  COMWRT4    	
		  JSR   DELAY
		  LDAA	#$06     	
		  JSR	  COMWRT4    	
		  JSR   DELAY
		  LDAA	#$80     	
		  JSR	  COMWRT4    	
		  JSR   DELAY
		  RTS
    	
;----------------------------
COMWRT4:               		
		  STAA	TEMP		
		  ANDA  #$F0
		  LSRA
		  LSRA
		  STAA  LCD_DATA
		  BCLR  LCD_CTRL,RS 	
		  BSET  LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR  LCD_CTRL,EN 	
		  LDAA  TEMP
		  ANDA  #$0F
    	LSLA
    	LSLA
  		STAA  LCD_DATA
		  BCLR  LCD_CTRL,RS 	
		  BSET  LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR  LCD_CTRL,EN 	
		  RTS
;--------------		  
DATWRT4:                   	
		  STAA	 TEMP		
		  ANDA   #$F0
		  LSRA
		  LSRA
		  STAA   LCD_DATA
		  BSET   LCD_CTRL,RS 	
		  BSET   LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR   LCD_CTRL,EN 	
		  LDAA   TEMP
		  ANDA   #$0F
    	LSLA
      LSLA
  		STAA   LCD_DATA
  		BSET   LCD_CTRL,RS
		  BSET   LCD_CTRL,EN 	
		  NOP
		  NOP
		  NOP				
		  BCLR   LCD_CTRL,EN 	
		  RTS
;-------------------	  
;----------DELAY
DELAY

        PSHA		;Save Reg A on Stack
        LDAA    #1		  
        STAA    R3		
;--0.1 msec delay. The Serial Monitor works at speed of 48MHz with XTAL=8MHz on Dragon12+ board
;Freq. for Instruction Clock Cycle is 24MHz (1/2 of 48Mhz). 
;(1/24MHz) x 10 Clk x240x1=0.1 msec. Overheads are excluded in this calculation.         
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