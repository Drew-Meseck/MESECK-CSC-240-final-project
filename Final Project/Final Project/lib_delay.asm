; --------------------------------------------------------------------------------
; --------------------------------------------------------------------------------
; lib_delay
; Author: Kristof Aldenderfer (aldenderfer.github.io)
; Description: common delay time subroutines for ATTiny416. All delays generated
;     by delay loop calculator at http://www.bretmulvey.com/avrdelay.html .
; --------------------------------------------------------------------------------
; --------------------------------------------------------------------------------

; --------------------------------------------------------------------------------
; Delay 15 999 984 cycles
; 999ms 999us at 16 MHz
; --------------------------------------------------------------------------------
delay_1s:
                            push            r23
                            push            r24
                            push            r25
                            ldi             r23, 82
                            ldi             r24, 43
                            ldi             r25, 252
    delay_1s_cont:          
                            dec             r25
                            brne            delay_1s_cont
                            dec             r24
                            brne            delay_1s_cont
                            dec             r23
                            brne            delay_1s_cont
                            nop
                            pop             r25
                            pop             r24
                            pop             r23
                            ret

; --------------------------------------------------------------------------------
; Delay 1 599 984 cycles
; 99ms 999us at 16 MHz
; --------------------------------------------------------------------------------
delay_100ms:
                            push            r23
                            push            r24
                            push            r25
                            ldi             r23, 9
                            ldi             r24, 30
                            ldi             r25, 224
    delay_100ms_cont:
                            dec             r25
                            brne            delay_100ms_cont
                            dec             r24
                            brne            delay_100ms_cont
                            dec             r23
                            brne            delay_100ms_cont
                            nop
                            pop             r25
                            pop             r24
                            pop             r23
                            ret

; --------------------------------------------------------------------------------
; Delay 159 988 cycles
; 9ms 999us 250 ns at 16 MHz
; --------------------------------------------------------------------------------
delay_10ms:
                            push            r23
                            push            r24
                            ldi             r23, 208
                            ldi             r24, 198
    delay_10ms_cont:        dec             r24
                            brne            delay_10ms_cont
                            dec             r23
                            brne            delay_10ms_cont
                            nop
                            pop             r24
                            pop             r23
                            ret

; --------------------------------------------------------------------------------
; Delay 15 988 cycles
; 999us 249 0/1 ns at 16 MHz
; --------------------------------------------------------------------------------
delay_1ms:
                            push            r23
                            push            r24
                            ldi             r23, 21
                            ldi             r24, 195
    delay_1ms_cont:
                            dec             r24
                            brne            delay_1ms_cont
                            dec             r23
                            brne            delay_1ms_cont
                            pop             r24
                            pop             r23
                            ret

; --------------------------------------------------------------------------------
.exit
; --------------------------------------------------------------------------------