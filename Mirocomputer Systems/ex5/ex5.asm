include 'C:\EMU8086\inc\emu8086.inc'
;Multi-segment executable file template


print_str macro string
	push dx
	push ax
	mov dx,offset string
	mov ah,9
	int 21h
	pop ax
	pop dx
endm

print macro char
	push dx
	push ax
	mov dl,char
	mov ah,2
	int 21h
	pop ax
	pop dx
endm


;Add your data here
data segment
	start_msg db "START(Y/N):",'$'
	input db "insert input: ",'$'
	;The combination of the two moves the cursor to the beginning of the next row of the screen
	;0ah=(10D), moves the cursor to the next row of the screen but maintaining the same column
	;0dh=(13D) Carriage return, moves the cursor to the beginning of the current row
	new_line db 0dh,0ah,'$'
	err db "ERR",'$'
data ends



stack segment
stack ends


;Add your code here
code segment

begin_message:
	;Set segment registers
	mov ax,data
	mov ds,ax
	mov es,ax
	print_str start_msg
begin_decision:

	mov ah,1 			;Get Y/y to begin the execution of the program
	int 21h 			;or N/n to stop the starting of a newexecution
					;Below is described the management of each input hlt or continue

	cmp al,78 			;ASCII code for N
	je end_execution
	cmp al,110 			;ASCII code for n
	je end_execution

	cmp al,89 			;ASCII code for Y
	je start
	cmp al,121 			;ASCII code for y
	je start

	call delete_char		;If Y/y/N/y are not given, then erase the last character
					;inserted (by calling the delete_char proc) and start
					;over the routine to read new int
	jmp begin_decision
		
start:
	print_str new_line
	
	;Read 3 HEX digits, they will be stored in bx reg
	mov bx,0000h			;Position on the screen
	;--------------------------1st MSB--------------------------
	call read_hex			;Read the 1st MSB digit
	
	;(CHECK AGAIN after read_hex)If N/n is pressed at any time, stop the execution
	cmp al,78			;ASCII code for N
	je end_execution
	cmp al,110			;ASCII code for n
	je end_execution

	mov ah,0			;Now ax = ah|al=0|(1st MSB)
	add bx,ax 			;bx = 000(1ST MSB)h
	mov cl,4 			;Shifting the 1st MSB 4 bits left, to check the next MSB
	shl bx,cl			;So bx = 00(1ST MSB)0h

	;--------------------------2nd MSB--------------------------
	call read_hex			;Read the 2nd MSB digit
	
	;(CHECK AGAIN after read_hex)If N/n is pressed at any time, stop the execution
	cmp al,78			;ASCII code for N
	je end_execution
	cmp al,110			;ASCII code for n
	je end_execution

	mov ah,0			;Now ax = ah|al=0|(2nd MSB)
	add bx,ax 			;bx = 00(1ST MSB)(2nd MSB)h
	mov cl,4 			;Shifting both MSBs 4 bits left, to check the last MSB
	shl bx,cl			;So bx = 0(1ST MSB)(2nd MSB)0h
	
	;--------------------------3rd MSB--------------------------
	call read_hex			;Read the 3rd MSB digit
	
	;(CHECK AGAIN after read_hex)If N/n is pressed at any time, stop the execution
	cmp al,78			;ASCII code for N
	je end_execution
	cmp al,110			;ASCII code for n
	je end_execution

	mov ah,0			;Now ax = ah|al=0|(3rd MSB)
	add bx,ax 			;bx = 0(1ST MSB)(2nd MSB)(3rd MSB)h

	;-------------------------Volts--------------------------
	;Calculate volts of the temperature given based on the graph
	;V = (2/4095) * AD == X.YYY ==> V = (2*1000/4095)*AD = XYYY
	;So, volts are calculated with the precision of 3 decimals (multiplied by 1000)	

	mov ax,bx			;ax = 0(1ST MSB)(2nd MSB)(3rd MSB)h
	mov cx,2000			;cx = 7d0h
	mul cx				;(ax' = ax * 7d0h)h ==> (ax'= ax * 2000)d
	
	mov cx,4095 			;cx = 0fffh
	div cx				;Finally I will get (ax'' = ax' / 0fffh)h, and more specifically
					;V = (ax * 2000)/4095
	;Equation for the computation of the temperature: T = 500 * a when V < 1.00
	;T = 250 * V + 250 when 1.00 < V < 1.80, T = 1500 * a - 2000 when 1.80 < V < 2.00
	;DON'T Forget: Volts are multiplied by 1000
	cmp ax,1000
	jl case_1
	cmp ax,1800
	jl case_2
	jmp case_3

	;In all 3 cases, do the computations so that ax reg will be formed as: ax = XXXXY, 
	;precision of 1 decimal (or multiplied by 10)

;In linear equation, a = 5 and b = 0
case_1:
	mov cx,5
	mov bx,0
	jmp compute_2

;In linear equation, a = 25 and b = 2500
case_2:	
	mov cx,25
	mov bx,2500
	jmp compute_1

case_3:	
	mov cx,15
	mov bx,20000
	jmp compute_2

compute_1:
	mul cx
	mov cx,10	;It was the only occasion that temprateure was formed as T = ax = XXXXYY
			;so we cut the 2nd decimal by dividing with 10
	div cx
	add ax,bx
	
	jmp print_temperature
compute_2:
	mul cx
	sub ax,bx
	
	cmp ax,9999
	jg error


;Print the corresponding temperature
print_temperature:
	mov dx,ax
	print_str new_line
	mov dx,0
	mov cx,10000 					;Isolate thousands
	div cx						;ax' = ax / 10000
	mov bx,ax 					;Print the quotient
	call print_digit


	mov ax,dx 					;ax = {again ax}
	mov dx,0
	mov cx,1000					;Isolate hundreads
	div cx						;ax' = ax/1000
	mov bx,ax 					;Print the quotient
	call print_digit
	
	mov ax,dx 					;ax = {again ax}
	mov dx,0
	mov cx,100					;Isolate tens
	div cx						;ax' = ax/100
	mov bx,ax 					;Print the quotient
	call print_digit
	
	mov ax,dx 					;ax = {again ax}
	mov dx,0
	mov cx,10					;Isolate units
	div cx						;ax' = ax/10
	mov bx,ax 					;Print the quotient
	call print_digit

	print ","

	;Print the temperature with 1 decimcal precision
	mov bx,dx
	call print_digit
	print " "
	print "o"
	print "C"
	print_str new_line
	print_str new_line

	jmp begin_message

error:
	print_str new_line
	print_str err
	jmp begin_message

end_execution:
	mov ax,4c00h 					;Exit to operating system
	int 21h


;This routine deletes the last character pressed
delete_char proc near
	push ax
	mov ah,0eh 			;This function displayes a character on the screen, advancing the cursor and scrolling
					;the screen as necessary
	mov al,8 			;ASCII code for backspace
	int 10h

	mov al,32			;ASCII code for space
	int 10h

	mov al,8			;ASCII code for backspace
	int 10h
	pop ax
	ret
delete_char endp


;This routine reads a valid hexademical digit
read_hex proc near
again_read_hex:
	;Read the digit

	mov ah,1
	int 21h
	
	cmp al,78			;ASCII code for N
	je exit_read_hex
	cmp al,110			;ASCII code for n
	je exit_read_hex

	cmp al,48 			;AL>=48 <=> AL>=ASCII code for 0
	jl wrong_read_hex 		;No?Delete character and read again
	cmp al,57 			;AL<=57 <=> AL<=ASCII code for 9
	jg check_letter_read_hex	;No? Check if it is a letter form 'A' to 'F'

	;Extract hexademical number
	sub al,30h
	jmp exit_read_hex
check_letter_read_hex:
	cmp al,65 			;AL>=65 <=> AL>=ASCII code for 'A'
	jl wrong_read_hex 		;No?Delete character and read again
	cmp al,70 			;AL<=70 <=> AL<=ASCII code for 'F'
	jg wrong_read_hex		;No?Delete character and read again

	;Extract hexademical number
	sub al,37h
	jmp exit_read_hex
wrong_read_hex:
	call delete_char
	jmp again_read_hex
exit_read_hex:
	ret
read_hex endp


;Add the proper hexademical number that was substracted during the initial reading
print_digit proc near
	cmp bl,9 			;bl=>9, then add 39h, since it is a hexademical letter {A,B,C,D,E,F}
	jg add
	add bl, 30h			;else add just 30h, since it a hexademical number
	jmp print_digit_end
add:
	add bl,37h
print_digit_end:
	print bl
	ret
print_digit endp

code ends
end begin_message 			;Set entry point and stop the assembler