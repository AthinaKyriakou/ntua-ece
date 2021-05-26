.INCLUDE "m16def.inc"   ; δηλώνουμε μικροελεγκτή
.def temp = R16         ; ονομάζομαι temp έναν καταχωρητή
.def Delay0 = r17       ; ορίζουμε την καθυστέρηση όταν τα led θα είναι σβηστά
.def Delay1 = r18       ; ορίζουμε την καθυστέρηση όταν τα led θα είναι ανάμμένα
main:	
	clr temp 
	out DDRD,temp   ; ορίζουμε DDRD ως θύρα εισόδου.
	ser temp
	out DDRB,temp   ; ορίζουμε DDRB ως θύρα εξόδου.
	out PORTD,temp  ; τίθενται οι αντιστάσεις πρόσδεσης pull-up.
	ldi Delay0,50   ; αν το MSB της εισόδου είναι 0 θα έχουμε 0 (σβηστά led) για 50*(10ms)
	ldi Delay1,150  ; και θα έχουμε 1 (αναμμένα led) για 150*(50ms)
	sbic PIND, 0x07 ; αν το MSB της εισόδου είναι 1 αλλάζουμε το delay του 0, αλλιώς όχι.
	ldi Delay0,150;
	sbic PIND, 0x07 ;Αντίστοιχα, αλλάζουμε και το delay του 1
	ldi Delay1,50;
leds_on:
	ldi temp,0xFF   
	out PORTB,temp  ;ανάβουμε όλα τα leds
	//rcall Delay10 ;καλούμε την Delay10 για Delay1 φορές
	dec Delay1
	brne leds_on
leds_off:
	ldi temp,0x00
	out PORTB,temp  ;σβήνουμε όλα τα leds
	//rcall Delay10 ;καλούμε στην Delay10 για Delay0 φορές
	dec Delay0
	brne leds_off
	rjmp main   ;επιστρέφουμε πάλι στην αρχή
