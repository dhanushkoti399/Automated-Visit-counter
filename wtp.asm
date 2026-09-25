ORG 0000H

;========================================
; 8052 BIDIRECTIONAL VISITOR COUNTER
;========================================

; LCD Connections
RS EQU P3.0
EN EQU P3.2

; Sensors
ENTRY_SENSOR EQU P1.0
EXIT_SENSOR  EQU P1.1

; Buzzer
BUZZER EQU P3.3

COUNT EQU R7

;========================================
; START
;========================================
START:

    MOV COUNT,#00H

    CLR BUZZER

    ACALL DELAY

    ; LCD INITIALIZATION
    MOV A,#38H
    ACALL CMD

    MOV A,#0CH
    ACALL CMD

    MOV A,#06H
    ACALL CMD

    MOV A,#01H
    ACALL CMD

    ; DISPLAY MESSAGE
    MOV A,#80H
    ACALL CMD

    MOV DPTR,#MSG

PRINT:
    CLR A
    MOVC A,@A+DPTR
    JZ SHOW_COUNT

    ACALL DATAW

    INC DPTR
    SJMP PRINT

;========================================
; SHOW INITIAL COUNT
;========================================
SHOW_COUNT:

    MOV A,#87H
    ACALL CMD

    MOV A,COUNT
    ADD A,#30H
    ACALL DATAW

;========================================
; MAIN LOOP
;========================================
MAIN:

;----------------------------------------
; ENTRY DETECT
;----------------------------------------
    JB ENTRY_SENSOR,CHECK_EXIT

    ACALL DELAY

WAIT1:
    JNB ENTRY_SENSOR,WAIT1

    INC COUNT

    ACALL BUZZ

    ACALL UPDATE

;----------------------------------------
; EXIT DETECT
;----------------------------------------
CHECK_EXIT:

    JB EXIT_SENSOR,MAIN

    ACALL DELAY

WAIT2:
    JNB EXIT_SENSOR,WAIT2

    CJNE COUNT,#00H,DECVAL
    SJMP MAIN

DECVAL:

    DEC COUNT

    ACALL BUZZ

    ACALL UPDATE

    SJMP MAIN

;========================================
; UPDATE DISPLAY
;========================================
UPDATE:

    MOV A,#87H
    ACALL CMD

    MOV A,COUNT
    ADD A,#30H
    ACALL DATAW

    RET

;========================================
; BUZZER
;========================================
BUZZ:

    SETB BUZZER

    ACALL DELAY

    CLR BUZZER

    RET

;========================================
; LCD COMMAND
;========================================
CMD:

    MOV P2,A

    CLR RS

    SETB EN

    ACALL DELAY

    CLR EN

    ACALL DELAY

    RET

;========================================
; LCD DATA WRITE
;========================================
DATAW:

    MOV P2,A

    SETB RS

    SETB EN

    ACALL DELAY

    CLR EN

    ACALL DELAY

    RET

;========================================
; DELAY
;========================================
DELAY:

    MOV R5,#255

D1:
    MOV R6,#255

D2:
    DJNZ R6,D2
    DJNZ R5,D1

    RET

;========================================
; MESSAGE
;========================================
MSG:
DB 'COUNT: ',00H

END];