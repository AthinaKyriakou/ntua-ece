#include <stdio.h>
#include <stdlib.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#define F_CPU 4000000UL
#include <util/delay.h>

#define DataPort 		PORTC  		//Using PortC as our Dataport
#define DataDDR 		DDRC
unsigned char counter,leds;

/* External Interrupt 0 service routine. When a new putton is pressed
counter initialized to 120 and the interrupts starts over again 
to complete 60 secs*/

void ext_int1_isr(void){
	int i;
	counter = 120;

	/* This for loop blink LEDs on Dataport 5 times
	before LEDs turned on for 1 minute !!*/
	for(i = 0; i < 5; i++){
		DataPort = 0x00;
		_delay_ms(500); 			//Turn on 0.5 sec
		DataPort = 0xFF;
		_delay_ms(500); 			//Turn off 0.5 sec
	}
	
	leds = 0xFF; 					//Leds are ON when interrup1 starts
	DataPort = leds;
	//Implement total delay = 120 x 1/2 sec = 60 sec
	while(counter!=0){
		_delay_ms(500);
	}

	leds = 0x00; 					//Leds are OFF when interrupt1 finishes
	DataPort = leds; 
}

int main(void){
	DDRD = 1<<PD3; 					//Set PD3 as input (using for interrupt 1) =>Configure PortD as input
	PORTD = 1<<PD3; 				//Enable PD3 pull-up resisotr. Turn on the leds of input

	DataDDR = 0xFF;					//Configure Dataport as output
	DataPort = 0x00; 				//PortC as output

	GIMSK = (1<<INT1);				//Activate external interrupt1, INT1:0N
	MCUCR = 1<<ISC11 | 1<<ISC10; 	//INT1 mode: activated in the a rising edge
	sei();							//Activate all interrupts masked, here just INT1. Enable Global Interrupt


	/*Continuous operation of our program, wait for an interrupt*/
	while(1);
}
l