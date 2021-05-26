.include "m32def.inc"		;Define microcontroller
.def tmp = r16 
.def LEDs = r17 			;Interrupt1 in PD3 <=> r17
.def delay1 = r19 
.def delay2 = r20 
.def delay3 = r21

	;Set up the interrupt vector
	jmp reset				;Reset Handler
	.org INT1addr 			;INT1addr is the address of EXT_INT1
	jmp interrupt1			;IRQ1 Handler	

;note: it so happens that INT0 is hooked up to the PD0 pin for the mega 32
;Here is the mapping:
;INT0: PD0
;INT1: PD1
;(from pg2 of atmega32 datasheet)

reset:
	;Initialize stack in the last position of the RAM
	ldi tmp,high(RAMEND)	;Set pointer of stack to the RAM, RAMEND value is coming of microcontroller's model
	out SPH,tmp
	ldi tmp,low(RAMEND)
	out SPL,tmp

	;Set DDRC to 0xFF. DDRC is data direction register C. There 8 pins, so setting 8 bits to 1 sets, sets the 8 pins for output
	ser tmp
	out DDRC,tmp 			;digits of portC became output for the LEDs


 	ldi tmp, 1<<INT1 		;1000 0000 (INT1 = 7)
 	out GIMSK,temp 			;Activate external interrupt 1, since general register mask of interrupts is 
 							;responsible for activating/disactivating interrupts

 	ldi temp, 0b00001100 	;Defining interrupt 1 to be executed in a rising edge, or "ldi temp, (1 << ISC11) | (1 << ISC10)""
 	out MCUCR, temp 		


 	sei 					;Activate all interrupts masked, here just INT1
 							;Global Interrupts MUST be enabled for the microcontroller to react to the interrupt event.

;Routine to wait for exeternal interrupt (press of button 3 - PD3)
 wait:
 	rjmp wait

;This is the handler for PushButton3
interrupt1:
	;Push conflic registers
	push tmp
	in tmp, SREG
	push tmp

;Before starting the main operation of 1 minuted turned on LEDs, they must firstly blink for 5 secs
	ldi tmp, 5				;(tmp) = 5

blinking:
	dec tmp
	ser LEDs
	out PORTC, LEDs
	rcall Delay 
	clr LEDs
	out PORTC, LEDs
	rcall Delay 
	brne blinking

main_operation:

	;Turn on LEDs
	ser LEDs
	out PORTC, LEDs

	ldi tmp, 120			;(tmp) = 120


;Keep LEDs turned on for 60 sec = 1 minute, by calling DELAY routine 120 times since 1 DELAY equals to 0.5 sec time delay
;Total Delay = 120 x 1/2 sec = 60 sec
interrupt1_loop:
	dec tmp
	rcall Delay 	 		;We use rcall so that when the PC gets to a "ret" statement it will come back to the line following rcall.
	brne interrupt1_loop

	;After 60 secs having passed, turn off the LEDS by assigning 
	clr LEDs
	out PORTC, LEDs

	;Restore conflict registers
	pop tmp
	out SREG, tmp
	pop tmp

	reti 					;Interrupt Return, address was loaded from stack. Exiting the ISR, and automatically 
							;re-enabling the Global Interrupt Enable bit. 


Delay:
	ldi Delay1, 3
	ldi Delay2, 138
	ldi Delay3, 90
D1: 
	dec Delay3
	brne D1
	dec Delay2
	brne D1
	dec Delay1
	brne D1
	ret



