$INCLUDE (global.inc)

NAME MAIN_MODULE

; External Functions
EXTRN CODE (SEG_INIT)
EXTRN CODE (SEG_DISPLAY_NUMBER)
EXTRN CODE (DS_RESET)
EXTRN CODE (DS_WRITE)
EXTRN CODE (DS_READ)

; External Variables
EXTRN DATA (SEG_TENS)
EXTRN DATA (SEG_UNITS)

; Local Variables
DSEG AT 40H
TEMP_L:    DS 1
TEMP_H:    DS 1

; --- VECTOR TABLE (Fixed Addresses) ---
CSEG AT 0000H       ; Reset Vector
    LJMP START

EXTRN CODE (T0_ISR) ; Must match public name in display.asm
CSEG AT 000BH       ; Timer 0 Vector
    LJMP T0_ISR

; --- MAIN PROGRAM (Relocatable) ---
MAIN_PROG SEGMENT CODE
RSEG MAIN_PROG

START:
    MOV SP, #60H        ; Move Stack Pointer
    LCALL SEG_INIT
    
MAIN_LOOP:
    ; --- 1. Start Conversion ---
    LCALL DS_RESET
    MOV A, #0CCH        ; Skip ROM
    LCALL DS_WRITE
    MOV A, #44H         ; Convert T
    LCALL DS_WRITE
    
    ; --- 2. Wait 750ms ---
    MOV R0, #250
WAIT_LOOP: 
    LCALL DELAY_3MS  
    DJNZ R0, WAIT_LOOP

    ; --- 3. Read Temperature ---
    LCALL DS_RESET
    MOV A, #0CCH        ; Skip ROM
    LCALL DS_WRITE
    MOV A, #0BEH        ; Read Scratchpad
    LCALL DS_WRITE
    
    LCALL DS_READ
    MOV TEMP_L, A       
    LCALL DS_READ
    MOV TEMP_H, A       
    
    ; --- 4. Process Data ---
    MOV A, TEMP_L
    SWAP A              
    ANL A, #0FH         
    MOV R1, A
    
    MOV A, TEMP_H
    SWAP A
    ANL A, #0F0H        
    ORL A, R1           
    
    LCALL SEG_DISPLAY_NUMBER
    SJMP MAIN_LOOP

; Helper Delay
DELAY_3MS: 
    MOV R2, #6
D1: MOV R3, #250
    DJNZ R3, $
    DJNZ R2, D1
    RET

END