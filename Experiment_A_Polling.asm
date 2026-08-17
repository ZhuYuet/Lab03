; UGEA2633 Lab 3 - Experiment A
; 8051 UART transmission using polling (no serial interrupt)
; Target: AT89S52, 11.0592 MHz crystal, 9600 baud, 8-N-1

; Keil A51 predefines the standard 8051 SFR and bit names used below.

        ORG 0000H
        LJMP START

START:
        MOV SP, #5FH
        LCALL UART_INIT

        MOV DPTR, #MESSAGE

SEND_NEXT:
        CLR A
        MOVC A, @A+DPTR
        JZ TRANSMISSION_DONE
        LCALL UART_PUTC
        INC DPTR
        SJMP SEND_NEXT

TRANSMISSION_DONE:
        SJMP TRANSMISSION_DONE

; Configure UART mode 1 and Timer 1 mode 2.
; Baud = 11.0592 MHz / (384 * (256 - FDH)) = 9600 baud.
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

; Send the character in A, then poll TI until transmission completes.
UART_PUTC:
        CLR TI
        MOV SBUF, A
WAIT_FOR_TI:
        JNB TI, WAIT_FOR_TI
        CLR TI
        RET

MESSAGE:
        DB 'TRANSMIT OK!', 0DH, 0AH, 00H

        END
