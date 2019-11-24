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
.def		x_position = r19
.def		y_position = r18
.def		character = r17

;------MACRO SUBSECTION------
.macro write_16_to_IO											; macro for writing to a 16-bit IO register. parameters are:
						ldi			@2, low(@1)					; - [0] IO register
						sts			@0, @2						; - [1] value
						ldi			@2, high(@1)				; - [2] general purpose register to be used
						sts			@0+1, @2					; - e.g.: write_16_to_IO TCA0_SINGLE_CMP0, 1024, reg_workhorse 
.endMacro

.macro set_active_box

.endmacro

.macro _rotate

.endmacro

.macro new_piece

.endmacro

.macro move_right

.endmacro

.macro move_left

.endmacro


;----END MACRO SUBSECTION----
.cseg
.org 0x0000
	rjmp setup
.org 0x0008 ;Timer interrupt for refresh screen
	rjmp	refresh
.org 0x0004 ;PortB interrupt for game start
	rjmp	game_loop
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
	sei

;--------------------------------------------------------------


;-------------------------LOOPS--------------------------------
title_screen:	;draws the title screen until button is pressed

;OBJECT "Drews"
	ldi		y_position, 6
	ldi		x_position, 3
	rcall	GFX_set_array_pos
	ldi		character, 68
	st		X, character
	
	ldi		y_position, 7
	ldi		x_position, 3
	rcall	GFX_set_array_pos
	ldi		character, 114
	st		X, character

	ldi		y_position, 8
	ldi		x_position, 3
	rcall	GFX_set_array_pos
	ldi		character, 101
	st		X, character

	ldi		y_position, 9
	ldi		x_position, 3
	rcall	GFX_set_array_pos
	ldi		character, 119
	st		X, character


;OBJECT "Tetris"
	ldi		y_position, 5
	ldi		x_position, 4
	rcall	GFX_set_array_pos
	ldi		character, 84
	st		X, character
	
	ldi		y_position, 6
	ldi		x_position, 4
	rcall	GFX_set_array_pos
	ldi		character, 101
	st		X, character

	ldi		y_position, 7
	ldi		x_position, 4
	rcall	GFX_set_array_pos
	ldi		character, 116
	st		X, character

	ldi		y_position, 8
	ldi		x_position, 4
	rcall	GFX_set_array_pos
	ldi		character, 114
	st		X, character

	ldi		y_position, 9
	ldi		x_position, 4
	rcall	GFX_set_array_pos
	ldi		character, 105
	st		X, character

	ldi		y_position, 10
	ldi		x_position, 4
	rcall	GFX_set_array_pos
	ldi		character, 115
	st		X, character

;OBJECT "Left Top Piece"

	ldi		y_position, 1
	ldi		x_position, 1
	rcall	GFX_set_array_pos
	ldi		character, 219
	st		X, character

	ldi		y_position, 2
	ldi		x_position, 1
	rcall	GFX_set_array_pos
	ldi		character, 219
	st		X, character

	ldi		y_position, 3
	ldi		x_position, 1
	rcall	GFX_set_array_pos
	ldi		character, 219
	st		X, character

	ldi		y_position, 4
	ldi		x_position, 1
	rcall	GFX_set_array_pos
	ldi		character, 219
	st		X, character

;OBJECT "Left Bottom Piece"

	ldi		y_position, 1
	ldi		x_position, 4
	rcall	GFX_set_array_pos
	ldi		character, 8
	st		X, character

	ldi		y_position, 1
	ldi		x_position, 5
	rcall	GFX_set_array_pos
	ldi		character, 8
	st		X, character

	ldi		y_position, 1
	ldi		x_position, 6
	rcall	GFX_set_array_pos
	ldi		character, 8
	st		X, character

	ldi		y_position, 2
	ldi		x_position, 6
	rcall	GFX_set_array_pos
	ldi		character, 8
	st		X, character

;OBJECT "Right Piece"

	ldi		y_position, 13
	ldi		x_position, 1
	rcall	GFX_set_array_pos
	ldi		character, 10
	st		X, character

	ldi		y_position, 14
	ldi		x_position, 1
	rcall	GFX_set_array_pos
	ldi		character, 10
	st		X, character

	ldi		y_position, 13
	ldi		x_position, 2
	rcall	GFX_set_array_pos
	ldi		character, 10
	st		X, character

	ldi		y_position, 14
	ldi		x_position, 2
	rcall	GFX_set_array_pos
	ldi		character, 10
	st		X, character


	rjmp	title_screen


refresh: ;refreshes the screen
	PUSH			reg_workhorse
	lds				reg_workhorse, CPU_SREG
	PUSH			reg_workhorse

	ldi				reg_workhorse, 0b00000001
	rcall			GFX_refresh_screen
	sts				TCA0_SINGLE_INTFLAGS, reg_workhorse

	POP				reg_workhorse
	sts				CPU_SREG, reg_workhorse
	POP				reg_workhorse
																	
	reti
