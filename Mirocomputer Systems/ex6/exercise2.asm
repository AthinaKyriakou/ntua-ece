.include "m32def.inc" 		;Define microcontroller
.def tmp = r19 				;we call temp a register
.def input = r17 			
.def result = r18			;For the LEDs we suppose hight impudence => Turned on if ones
							;F2 F1 F0 _ _ _ _ _ 


start:
	;B έξοδος, D είσοδος

	;Transform port into input
	clr tmp
	out DDRD, tmp 			;digits of portD became input

	;Transform port into output
	ser tmp
	out DDRB, tmp			;digits of portB became output
	out PORTD, tmp 			;(Since instruction "ser tmp" is executed before there is no need for that again)
							;pull up input with the intention to have stable input in hight impudence
	in tmp, PIND 			;Read input from , store it in register tmp

	;F0 and F1 calculated based on the calculations of the terms with the least variables
	;to save run space and time, since there are "or" operations in the functions
	;Calculate F0 = A+B·C’·D’

calc_F0:
	;A
	mov input, tmp
	andi tmp, 0b00000001
	cpi tmp, 0b00000001
	breq FO_is_one
	;If A = 1, then F0 = 1 so we dont need to calculate B·C’·D’
	;Either A = 1 or A = 0, we cannot conclude about the result neither F1 nor F2
	
	;B·C’·D’
	mov input, tmp  		;Restore value of tmp
	andi tmp, 0b00001110
	cpi tmp, 0b00000010
	rjmp calc_F1  			;If F0 = 0, then F2 = 0, but we should first caclulate F1

F0_is_one:
	ldi result, 0x02 		;If F0 = 1, then update LEDs

	;Calculate  F1=A’·B·C’·D+E·G
calc_F1:
	;E·G
	mov input, tmp  		
	andi tmp, 0b00110000
	cpi tmp, 0b00110000
	breq F1_is_one

	;A'B·C’·D
	mov input, tmp 			;Restore value of tmp
	andi tmp, 0b00001111
	cpi tmp, 0b00001010
	brne set_LEDs 			;If F1 = 0, then F2 = 0

F1_is_one:
	ldi result, 0x01 		;If F1 = 1, then update
	mov tmp, result
	andi tmp, 0b01100000
	cpi tmp, 0b01100000 	;If both F0 = F1 = 1, then F2 = 1, jump to F2_is_one and update the LEDs
	breq F2_is_one
	rjmp set_LEDS 

F2_is_one:
	ldi result, 0x00 		;If both F0 = F1 = 1, then F2 = 1, update the LEDs

set_LEDs:
	out PORTB, result
	jmp start












