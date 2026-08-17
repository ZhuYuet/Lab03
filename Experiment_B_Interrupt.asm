; UGEA2633 Lab 3 - Experiment B
; 8051 UART transmission driven by the serial interrupt
; Target: AT89S52, 11.0592 MHz crystal, 9600 baud, 8-N-1
;
; While the serial ISR sends the message, the main loop continuously changes
; Port 1. In the Keil simulator, observe P1 to prove that the main loop keeps
; running while transmission is handled by interrupts.

; Keil A51 predefines the standard 8051 SFR and bit names used below.

        ORG 0000H
        LJMP START

        ORG 0023H            ; 8051 serial interrupt vector
        LJMP SERIAL_ISR

        ORG 0030H
START:
        MOV SP, #5FH
        MOV P1, #00H
        LCALL UART_INIT

        MOV DPTR, #MESSAGE
        SETB ES               ; enable serial interrupt
        SETB EA               ; enable global interrupt
        SETB TI               ; software kick: request first ISR service

; Independent foreground work. This does not poll TI or wait for the UART.
MAIN_LOOP:
        INC P1
        LCALL VISIBLE_DELAY
        SJMP MAIN_LOOP

; Configure UART mode 1 and Timer 1 mode 2.
UART_INIT:
        ANL PCON, #07FH       ; SMOD = 0
        ANL TMOD, #00FH       ; preserve Timer 0 settings
        ORL TMOD, #020H       ; Timer 1 mode 2, 8-bit auto-reload
        MOV TH1, #0FDH
        MOV TL1, #0FDH
        MOV SCON, #050H       ; UART mode 1, receiver enabled
        CLR TI
        CLR RI
        SETB TR1
        RET

; The serial interrupt is shared by transmit (TI) and receive (RI), so both
; flags are checked. Received bytes are discarded because this experiment only
; requires transmission.
SERIAL_ISR:
        PUSH ACC
        PUSH PSW
        PUSH DPL
        PUSH DPH

        JNB RI, CHECK_TI
        CLR RI
        MOV A, SBUF           ; read and discard any received character

CHECK_TI:
        JNB TI, SERIAL_EXIT
        CLR TI
        CLR A
        MOVC A, @A+DPTR
        JZ MESSAGE_DONE
        MOV SBUF, A
        INC DPTR
        SJMP SERIAL_EXIT

MESSAGE_DONE:
        CLR ES               ; one message is complete; stop serial IRQs

SERIAL_EXIT:
        POP DPH
        POP DPL
        POP PSW
        POP ACC
        RETI

; Slow enough for P1 changes to be visible in the simulator.
VISIBLE_DELAY:
        MOV R5, #08H
DELAY_OUTER:
        MOV R6, #0FFH
DELAY_MIDDLE:
        MOV R7, #0FFH
        DJNZ R7, $
        DJNZ R6, DELAY_MIDDLE
        DJNZ R5, DELAY_OUTER
        RET

MESSAGE:
        DB 'TRANSMIT OK!', 0DH, 0AH, 00H

        END
