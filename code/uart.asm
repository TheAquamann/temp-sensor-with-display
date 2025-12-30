$INCLUDE (global.inc)

NAME UART_MODULE

; --- 1. EXPORT SYMBOLS ---
; This tells the assembler: "Let other files use these labels"
PUBLIC UART_INIT
PUBLIC UART_SEND

; --- 2. DEFINE CODE SEGMENT ---
; This creates a relocatable code segment named 'UART_CODE'
UART_CODE SEGMENT CODE
RSEG UART_CODE

UART_INIT:
    MOV TMOD, #20H      ; Timer 1, Mode 2 (8-bit auto-reload)
    MOV TH1, #0FDH      ; 9600 Baud at 11.0592 MHz
    MOV TL1, #0FDH
    MOV SCON, #50H      ; Mode 1, Enable Receive
    SETB TR1            ; Start Timer 1
    RET

UART_SEND:
    MOV SBUF, A         ; Load data to buffer
WAIT_TI:
    JNB TI, WAIT_TI     ; Wait until TI=1
    CLR TI              ; Clear Interrupt flag
    RET

END