;
; Final Project.asm
;
; Created: 11/20/2019 11:48:12 PM
; Author : Drew Meseck
;


; Replace with your application code
;------------------------DIRECTIVES----------------------------

;defines a basic workhorse registers
.def		reg_workhorse    = r16
.def		reg_workhorse_2	 = r25
;defines the coordinate registers (for gameplay only, title screen inverts these)
.def		x_write		     = r19
.def		y_write			 = r18
.def		character		 = r17
.def		adc_value_low	 = r20
.def		adc_value_high	 = r21
.def		counter			 = r22
.def		win_counter		 = r23
.def		lose_counter	 = r24



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
;.org 0x0011 ;ADC interrupt
	;rjmp	update_position
.org 0x0080

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

	write_16_to_IO	TCA0_SINGLE_PER, 500, reg_workhorse ;26 with prescaler 111 (1024) gives appx 60Hz Squarewave output.

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
	ldi		win_counter, 0x00
	ldi		lose_counter, 0x00
	rcall	GFX_clear_array
	ldi		reg_workhorse, 0b00000001
	sts		ADC0_COMMAND, reg_workhorse
	rjmp	game_loop
;--------------------------------------------------------------


;-------------------------LOOPS--------------------------------
game_loop:
	rcall	spawn_proj
	rcall	delay_10ms
	rcall	move_projectiles_down
	rjmp	game_loop

;--------------------------Subroutines-----------------------------
spawn_proj:
	;call rng to get x position or no spawn
	ldi		x_write, 0x00 ;TEMP
	cpi		x_write, 0x08
	brlo	new_proj
	ret
	new_proj:
		ldi		y_write, 0x0E
		rcall	GFX_set_array_pos
		ldi		character, 27 
		st		X, character
		ret

move_projectiles_down:
	ldi		x_write, 0x00
	ldi		y_write, 0x01
	rcall	btm_row_check
	ldi		x_write, 0x00
	ldi		y_write, 0x02
	rcall	move_down
	ret
	move_down:
		cpi		x_write, 0x07
		breq	return_1
		rcall	move_down_col
		rjmp	move_down
		inc_x:
			inc		x_write
			ldi		y_write, 0x02
			rjmp	move_down

		
	move_down_col:
		rcall	GFX_set_array_pos
		ld		reg_workhorse, X
		cpi		reg_workhorse, 27
		breq	handle_proj
		inc		y_write
		cpi		y_write, 0x0F
		breq	inc_x
		rjmp	move_down_col
		handle_proj:
			dec		y_write
			rcall	GFX_set_array_pos
			ldi		reg_workhorse, 27
			st		X, reg_workhorse
			inc		y_write
			rcall	GFX_set_array_pos
			ldi		reg_workhorse, 0xFF
			st		X, reg_workhorse
			rjmp	move_down_col

btm_row_check:
	cpi		x_write, 0x08
	breq	return_1
	rcall	GFX_set_array_pos
	ld		reg_workhorse, X
	cpi		reg_workhorse, 27
	breq	process_proj
	inc		x_write
	rjmp	btm_row_check
	process_proj:
		dec		y_write
		rcall	GFX_set_array_pos
		ld		reg_workhorse_2, X
		cpi		reg_workhorse_2, 219
		breq	win_inc
		inc		lose_counter
		rcall	check_win_loss
		inc		y_write
		ret
		win_inc:
			inc		win_counter
			rcall	check_win_loss
			ret
	return_1:
		ret
	check_win_loss:
	cpi		win_counter, 10
	breq	win_screen
	cpi		lose_counter, 10
	breq	loss_screen	
	ret
win_screen:
	rcall	GFX_clear_array
	ldi		character, 65

	nop
loss_screen:
	rcall	GFX_clear_array
	nop


refresh: ;refreshes the screen
	PUSH			reg_workhorse
	lds				reg_workhorse, CPU_SREG
	PUSH			reg_workhorse
	PUSH			x_write
	PUSH			y_write
	lds				adc_value_low, ADC0_RES
	lds				adc_value_high, ADC0_TEMP

	rcall			update_position

	rcall			GFX_refresh_screen
	sts				TCA0_SINGLE_INTFLAGS, reg_workhorse

	POP				y_write
	POP				x_write
	POP				reg_workhorse
	sts				CPU_SREG, reg_workhorse
	POP				reg_workhorse
																	
	reti

update_position:
	push	reg_workhorse
	lds		reg_workhorse, CPU_SREG
	push	reg_workhorse

	;WRITE BLOCKS TO PROPER POSITION------
	;Clear Bottom Row
	ldi		y_write, 0x00
	ldi		x_write, 0x00
	ldi		counter, 0x00
	rcall	clr_btm_row
	;Write New Blocks
	ldi		y_write, 0x00
	ldi		counter, 0x00
	rcall	set_x_write

	;-------------------------------------
	ldi		reg_workhorse, 0x01
	sts		ADC0_INTFLAGS, reg_workhorse
	sts		ADC0_COMMAND, reg_workhorse

	pop		reg_workhorse
	sts		CPU_SREG, reg_workhorse
	pop		reg_workhorse

	ret


;----------------------------------------------------------------------
clr_btm_row:
	rcall	GFX_set_array_pos
	ldi		character, 0xFF
	st		X, character
	inc		x_write
	inc		counter
	cpi		counter, 8
	breq	return
	rjmp	clr_btm_row
	return:
		ret

set_x_write:
	andi	adc_value_high, 0b00000011		
	rol		adc_value_low
	rol		adc_value_high
	mov		x_write, adc_value_high
	ldi		y_write, 0x00
	rcall	GFX_set_array_pos

	ldi		character, 219
	st		X, character
	inc		x_write
	rcall	GFX_set_array_pos
	st		X, character
	ret











