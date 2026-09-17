// Hunter Clezie
// RCET3375
// Lab4MuzakPt3
// https://github.com/hunterclezie-pixel/Lab-04---Funky-Muzak.git

; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>  
    noteIndex EQU 0x20	    ;Use data memory address 0x20 to store what button was pressed
    outCount EQU 0x21	    ;Use data memory address 0x22 to store data for outer delay
    inCount EQU 0x22	    ;Use data memory address 0x23 to store data for inner delay
 
; Reset Vector at 0000h. Execution starts here after reset.
PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup

; Main code section starts at 0008h. User code goes here.
PSECT code,class=CODE,delta=2
 
Setup:    
    BCF 0x03,6	; Sets Bank 0    
    BCF 0x03,5	; Sets Bank 0    
    CLRF 0x05	; Setting PORTA on reset to LOW    
    CLRF 0x06	; Setting PORTB on reset to LOW    
        
    BCF 0x03,6	; Sets Bank 1    
    BSF 0x03,5	; Sets Bank 1    
    CLRF 0x85	; Setting TRISA to LOW, making PORTA an output    
    MOVLW 0xFF	; Entering bits to set TRISB logic HIGH    
    MOVWF 0x86	; Setting TRISB HIGH, making PORTB an input     
        
    BSF 0x03,6	; Sets Bank 3    
    BSF 0x03,5	; Sets Bank 3    
    CLRF 0x89	; Setting ANSELH to LOW for PORTB digital I/O    
    CLRF 0x88	; Setting ANSEL to LOW for PORTA digital I/O    
        
    BCF 0x03,6	; Sets Bank 0    
    BCF 0x03,5	; Sets Bank 0    
    GOTO Main    


Main:    
    CALL ButtonPress	; Determine which switch is active
    
    MOVF noteIndex,W	; Move note index into W
    XORLW 0xFF		; Compare note index with 0xFF
    BTFSC 0x03,2	; Check Zero flag
    GOTO SilentOutput	; If noteIndex = 0xFF, remain silent
    
    MOVF noteIndex,W	; Move note index into W
    CALL LookupTable	; Get delay value from lookup table
    MOVWF outCount	; Store delay value
    
    MOVLW 0x01		; Select RA0
    XORWF 0x05,1	; Toggle RA0
    
    CALL OutDelay	; Wait for half cycle
    
    GOTO Main		; Repeat program
    
ButtonPress:    
    BTFSC 0x06,7	; Check RB7
    GOTO Note7    
    
    BTFSC 0x06,6	; Check RB6
    GOTO Note6    
    
    BTFSC 0x06,5	; Check RB5
    GOTO Note5    
    
    BTFSC 0x06,4	; Check RB4
    GOTO Note4    
    
    BTFSC 0x06,3	; Check RB3
    GOTO Note3    
    
    BTFSC 0x06,2	; Check RB2
    GOTO Note2    
    
    BTFSC 0x06,1	; Check RB1
    GOTO Note1    
    
    BTFSC 0x06,0	; Check RB0
    GOTO Note0

Silent:			; No switch active    
    MOVLW 0xFF		; 0xFF represents no note
    MOVWF noteIndex	; Store silent value
    RETURN    

Note7:    
    MOVLW 0x07		; Note index 7 - C4
    MOVWF noteIndex    
    RETURN    
    
Note6:    
    MOVLW 0x06		; Note index 6 - B3
    MOVWF noteIndex    
    RETURN    
    
Note5:    
    MOVLW 0x05		; Note index 5 - A3
    MOVWF noteIndex    
    RETURN    
    
Note4:    
    MOVLW 0x04		; Note index 4 - G3
    MOVWF noteIndex    
    RETURN    
    
Note3:    
    MOVLW 0x03		; Note index 3 - F3
    MOVWF noteIndex    
    RETURN    
    
Note2:    
    MOVLW 0x02		; Note index 2 - E3
    MOVWF noteIndex    
    RETURN    
    
Note1:    
    MOVLW 0x01		; Note index 1 - D3
    MOVWF noteIndex    
    RETURN    
    
Note0:    
    MOVLW 0x00		; Note index 0 - C3
    MOVWF noteIndex    
    RETURN    

SilentOutput:
    BCF 0x05,0		; Set RA0 LOW
    GOTO Main		; Continue checking switches

LookupTable:    
    MOVF noteIndex,W	; Move note index into W
    ADDWF PCL,1		; Add note index to program counter
    
    RETLW 0xEE		; 0 - C3
    RETLW 0xD4		; 1 - D3
    RETLW 0xBD		; 2 - E3
    RETLW 0xB2		; 3 - F3
    RETLW 0x9F		; 4 - G3
    RETLW 0x8E		; 5 - A3
    RETLW 0x7E		; 6 - B3
    RETLW 0x77		; 7 - C4

OutDelay:    
    MOVLW 0x04		; Load inner delay count
    MOVWF inCount	; Store inner delay count
    
InDelay:                         
    DECFSZ inCount,1	; Decrement inner count
    GOTO InDelay	; Repeat until inner count reaches zero
    
    DECFSZ outCount,1	; Decrement lookup delay count
    GOTO OutDelay	; Repeat outer delay
    
    RETURN		; Return when delay is complete
    
End