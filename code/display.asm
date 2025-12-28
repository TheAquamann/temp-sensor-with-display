$INCLUDE (global.inc)

NAME DISPLAY_MODULE

; Exported symbols
PUBLIC SEG_INIT
PUBLIC SEG_DISPLAY_NUMBER
PUBLIC SEG_TENS
PUBLIC SEG_UNITS
PUBLIC T0_ISR

; Variables (Absolute placement at RAM 0x30)
DSEG AT 30H
SEG_TENS:  DS 1
SEG_UNITS: DS 1

; Bit Variables
BSEG
SEG_FLAG:  DBIT 1

; Define a unique segment name for this file
DISP_CODE SEGMENT CODE
RSEG DISP_CODE
    
; Font Table (0-9)
SEG_FONT:
    DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH

; --- Initialize Timer0 ---
SEG_INIT:
    ANL TMOD, #0F0H
    ORL TMOD, #01H      ; Mode 1 16-bit
    MOV TH0, #0F8H      
    MOV TL0, #0CDH
    SETB ET0            
    SETB EA             
    SETB TR0            
    RET

; --- Set Number Logic ---
SEG_DISPLAY_NUMBER:
    ; Input: A = Number (0-99)
    MOV B, #10
    DIV AB              ; A = Tens, B = Units
    MOV SEG_TENS, A
    MOV SEG_UNITS, B
    RET

; --- Timer0 Interrupt Service Routine ---
T0_ISR:
    PUSH ACC            ; Save context
    PUSH PSW
    MOV TH0, #0F8H      ; Reload Timer
    MOV TL0, #0CDH
    
    SETB DIG1           ; Turn off both (Ghosting check)
    SETB DIG2

    JB SEG_FLAG, SHOW_UNITS
    
    ; Show Tens
    MOV A, SEG_TENS
    MOV DPTR, #SEG_FONT
    MOVC A, @A+DPTR
    MOV SEG_PORT, A
    CLR DIG1            ; Turn on Tens
    SETB SEG_FLAG
    SJMP ISR_EXIT
    
SHOW_UNITS:
    ; Show Units
    MOV A, SEG_UNITS
    MOV DPTR, #SEG_FONT
    MOVC A, @A+DPTR
    MOV SEG_PORT, A
    CLR DIG2            ; Turn on Units
    CLR SEG_FLAG
    
ISR_EXIT:
    POP PSW             ; Restore context
    POP ACC
    RETI

END