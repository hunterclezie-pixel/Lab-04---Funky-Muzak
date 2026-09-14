// Hunter Clezie
// RCET3375
// Lab4MuzakPt1
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
count EQU 0x20	;use data memory address 0x20 as an 8-bit loop counter
 
; Reset Vector at 0000h. Execution starts here after reset.
PSECT resetVect,class=CODE,delta=2
ResetVector:
    goto Setup

; Main code section starts at 0008h. User code goes here.
PSECT code,class=CODE,delta=2
 
Setup:
    BCF 0x03,6 ; Sets Bank 0
    BCF 0x03,5 ; Sets Bank 0
    ; CCP1CON on power up reset is all LOW
    ; INTCON on power up reset is all LOW
    CLRF 0x05	; Setting PORTA on reset to LOW
    CLRF 0x06	; Setting PORTB on reset to LOW
    
    BCF 0x03,6	; Sets Bank 1
    BSF 0x03,5	; Sets Bank 1
    ; OPTION_REG on power up reset is all HIGH
    CLRF 0x85 ; Setting TRISA on reset to LOW, making PORTA an output
    MOVLW 0xFF ; Entering bits to set TRISB logic HIGH
    MOVWF 0x86 ;Setting TRISB High, making PORTB an input 
    ; WPUB on power up reset is all HIGH
    ; ICOB on power up reset is all HIGH
    
    BSF 0x03,6	; Sets Bank 3
    BSF 0x03,5	; Sets Bank 3
    CLRF 0x89	; Setting the ANSELH to LOW for the I/O to be digital
    CLRF 0x88	; Setting the ANSELH to LOW for the I/O to be digital on porta
    
    BCF 0x03,6	; Sets Bank 0
    BCF 0x03,5	; Sets Bank 0
    GOTO Main
    
Main:
    BTFSC PORTB,0	;1(2) TCY
    GOTO Main		;2 TCY

ButtonPress:
    MOVLW 0x01		;1 TCY
    XORWF 0x05,1	;1 TCY
    CALL Delay_1ms	;2 TCY
    GOTO Main		;2 TCY
    
Delay_1ms:
    MOVLW 0xA3          ;1 TCY delay overhead
    MOVWF count         ;1 TCY delay overhead
    
DelayLoop:                     
    DECFSZ count,1      ;1(2) 1 TCY if not zero, 2 TCY if zero
    GOTO DelayLoop      ;2 TCY
    RETURN		;2 TCY code not part of delay
End