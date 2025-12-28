$INCLUDE (global.inc)

NAME DS18B20_MODULE

PUBLIC DS_RESET
PUBLIC DS_WRITE
PUBLIC DS_READ

; Define a unique segment name for this file
DS_CODE SEGMENT CODE
RSEG DS_CODE

; --- Microsecond Delays ---
DELAY_5US:  
    MOV R7, #2    
    DJNZ R7, $ 
    RET
    
DELAY_60US: 
    MOV R7, #30   
    DJNZ R7, $ 
    RET
    
DELAY_480US:
    MOV R7, #240  
    DJNZ R7, $ 
    RET

; --- Reset Sensor ---
DS_RESET:
    CLR DS_DQ
    LCALL DELAY_480US   
    SETB DS_DQ
    MOV R7, #40         ; Wait for presence pulse
    DJNZ R7, $
    MOV C, DS_DQ        ; Read presence (0=OK)
    LCALL DELAY_480US   ; Wait for slot to end
    RET                 

; --- Write Byte (Input: A) ---
DS_WRITE:
    MOV R6, #8
WRITE_LOOP:
    CLR DS_DQ           
    LCALL DELAY_5US
    RRC A               ; Move LSB to Carry
    MOV DS_DQ, C        ; Output Carry to Pin
    LCALL DELAY_60US    
    SETB DS_DQ
    DJNZ R6, WRITE_LOOP
    RET

; --- Read Byte (Output: A) ---
DS_READ:
    MOV R6, #8
READ_LOOP:
    CLR DS_DQ
    LCALL DELAY_5US     
    SETB DS_DQ          ; Release bus
    LCALL DELAY_5US     
    MOV C, DS_DQ        ; Sample bus
    RRC A               ; Shift Carry into A
    LCALL DELAY_60US    
    DJNZ R6, READ_LOOP
    RET

END