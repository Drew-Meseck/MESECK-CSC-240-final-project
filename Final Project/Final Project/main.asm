;
; Final Project.asm
;
; Created: 11/20/2019 11:48:12 PM
; Author : droot
;


; Replace with your application code
;------------------------DIRECTIVES----------------------------

;defines a basic workhorse register
.def		reg_workhorse = r16
;defines the coordinate registers (for gameplay only, title screen inverts these)
.def		x_write		 = r19
.def		y_write		 = r18
.def		character	 = r17
.def		adc_value	 = r20
.def		counter		 = r21



;------MACRO SUBSECTION------
.macro write_16_to_IO											; macro for writing to a 16-bit IO register. parameters are:
						ldi			@2, low(@1)					; - [0] IO register
						sts			@0, @2						; - [1] value
						ldi			@2, high(@1)				; - [2] general purpose register to be used
						sts			@0+1, @2					; - e.g.: write_16_to_IO TCA0_SINGLE_CMP0, 1024, reg_workhorse 
.endmacro


;----END MACRO SUBSECTION----
.cseg
.org 0x0000
	rjmp setup
.org 0x0008 ;Timer interrupt for refresh screen
	rjmp	refresh
.org 0x0011 ;ADC interrupt
	rjmp	update_position
.org 0x0100

.equ		OLED_WIDTH = 128
.equ		OLED_HEIGHT = 64

.include	"lib_delay.asm"
.include	"lib_SSD1306_OLED.asm"
.include	"lib_GFX.asm"
;--------------------------------------------------------------


;-------------------------SETUP--------------------------------
setup:
	rcall		OLED_initialize			;Initialize the Screen
	rcall		GFX_clear_array			;Clear the Screen
	rcall		GFX_refresh_screen		;Refresh the Screen

	;Set up the timer for interrupts.
	ldi		reg_workhorse, 0b0001111
	sts		TCA0_SINGLE_CTRLA, reg_workhorse

	write_16_to_IO	TCA0_SINGLE_PER, 27, reg_workhorse ;26 with prescaler 111 (1024) gives appx 60Hz Squarewave output.

	ldi		reg_workhorse, 0b00000001
	sts		TCA0_SINGLE_INTCTRL, reg_workhorse	

	;Configure PortB

	ldi		reg_workhorse, 0b00000000
	sts		PORTB_DIR, reg_workhorse

	;ldi		reg_workhorse, 0b10000101
	;sts		PORTB_PIN0CTRL, reg_workhorse

	;Configure the ADC

	ldi		reg_workhorse, 0b00000001
	sts		ADC0_CTRLA, reg_workhorse

	ldi		reg_workhorse, 0b00000000
	sts		ADC0_CTRLB, reg_workhorse

	ldi		reg_workhorse, 0b00010001
	sts		ADC0_CTRLC, reg_workhorse

	ldi		reg_workhorse, 0x08
	sts		ADC0_MUXPOS,   reg_workhorse

	sei

game_setup:
	
	rcall	GFX_clear_array
	rcall	delay_1s
	rcall	setup_screen
	rjmp	game_loop
;--------------------------------------------------------------


;-------------------------LOOPS--------------------------------
game_loop:
	

;--------------------------Subroutines-----------------------------
refresh: ;refreshes the screen
	PUSH			reg_workhorse
	lds				reg_workhorse, CPU_SREG
	PUSH			reg_workhorse

	rcall			GFX_refresh_screen
	sts				TCA0_SINGLE_INTFLAGS, reg_workhorse

	POP				reg_workhorse
	sts				CPU_SREG, reg_workhorse
	POP				reg_workhorse
																	
	reti

update_position:
	push	reg_workhorse
	lds		reg_workhorse, CPU_SREG
	push	reg_workhorse

	lds		adc_value, ADC0_RES
	;WRITE BLOCKS TO PROPER POSITION------
	;Clear Bottom Row
	ldi		y_write, 0x00
	ldi		x_write, 0x00
	ldi		counter, 0x00
	rcall	clr_btm_row
	;Write New Blocks
	ldi		y_write, 0x00
	ldi		counter, 0x00
	rcall	write_shield

	;-------------------------------------
	ldi		workhorse, 0x01
	sts		ADC0_INTFLAGS, reg_workhorse
	sts		ADC0_COMMAND, reg_workhorse

	pop		reg_workhorse
	sts		CPU_SREG, reg_workhorse
	pop		reg_workhorse

	reti

setup_screen:
	ldi		reg_workhorse, 0b00000001
	sts		ADC0_COMMAND, reg_workhorse
	rcall	delay_1s
	ret

clr_btm_row:
	rcall	GFX_set_array_pos
	ldi		character, 0xFF
	st		X, character
	inc		x_write
	inc		counter
	ldi		reg_workhorse, 8
	cp		counter, reg_workhorse
	breq	return
	rjmp	clr_btm_row
	return:
		ret

write_shield:
	clc
	rol		adc_result
	ldi		reg_workhorse, 0x01
	cpc		reg_workhorse
	breq	set_x_write
	inc		counter
	rjmp	write_shield
	set_x_write:
		mov		x_write, counter
		ldi		y_write, 0x00
		rcall	GFX_set_array_pos

		ldi		character, 219
		st		X, character
		inc		x_write
		rcall	GFX_set_array_pos
		st		X, character

		ret











