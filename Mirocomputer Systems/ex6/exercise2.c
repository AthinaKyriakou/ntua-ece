#include <avr/io.h>
unsigned char A, B, C, D, E ,G, F0, F1, F2, temp;

int main(void){

	DDRD = 0x00; 			//configure portD as input
	PORTD = 0xFF; 			//Turn ON LEDs of input
	DDRB  = 0xFF; 			//configure portB as output
	while(1)
	{
		A = PIND; 			//Read 8 bits of port PIND (switches), store them in register A
		B = PIND; 			///Read 8 bits of port PIND again(switches), store them in register B
		C = PIND;
		D = PIND;
		E = PIND;
		G = PIND;
		A >>= 0; 			//Shift register A zero positions right, interested bit already in the LSB position
		B >>= 1;			//Shift register B one position right, to take interested bit in the LSB position
		C >>= 2;
		D >>= 3;
		E >>= 4;
		G >>= 5;
		
		//All of our caclulations will take place with the LSB element of each register
		F0 = A | (B & (~C) & (~D));
		F1 = ((~A) & B & (~C) & D) | (E & G);
		F2 = F0 & F1;

		F2 &= 1;
		F1 &= 1;
		F0 &= 1;

		//Bring each register to the correct position, unite them with "or" operation and upload the result into LEDS
		//via PortB
		F2 <<= 7;
		F1 <<= 6;
		F0 <<= 5;
		F2 = F2 | F1 | F0;
		PORTB = F2;

	};
	//We suppose display with high impudence (positive)
	
	

}



