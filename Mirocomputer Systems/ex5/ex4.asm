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
	input db 17 dup(?)
	new_line db 0dh,0ah,'$'
	err db "ERR",'$'
data ends



stack segment
stack ends


;Add your code here
code segment
initiliaze:
	;Set segment registers
	mov ax,data
	mov ds,ax
	mov es,ax

begin:
	mov di,offset input
	cld				;df = 0
	mov cx,16 			;Counter, DONT change it so that loop instruction can be used

begin_again:
	call read_key

	cmp al,0dh 			;ASCII code for 'Enter'
	je end_execution

	stosb 				;Store in memory
	loop begin_again

;Data processing
begin_numbers:
	print_str new_line
	cld 				;df = 0
	mov si,offset input
	mov cx,17

begin_numbers_again:
	dec cx
	cmp cx,0
	je print_pavla
	lodsb

	cmp al,48 			;AL>=48 <=> AL>=ASCII code for 0
	jl begin_numbers_again 		;No?Continue
	cmp al,57 			;AL<=57 <=> AL<=ASCII code for 9
	jg begin_numbers_again		;No?Continue
	
	print al
	jmp begin_numbers_again

print_pavla:
	print "-"

begin_letters:
	cld 				;df = 0
	mov si,offset input
	mov cx,17

begin_letters_again:
	dec cx
	cmp cx,0
	je print_end
	lodsb

	cmp al,65			;AL>=65 <=> AL>=ASCII code for 'A'
	jl begin_letters_again 		;No? Continue
	cmp al,90 			;AL<=90 <=> AL<=ASCII code for 'Z'
	jg begin_letters_again 		;No?Continue
	
	call decapitalize 		;Decapitize first and then print
	print al
	jmp begin_letters_again


print_end:
	print_str new_line
	print_str new_line
	jmp initiliaze

error:
	print_str new_line
	print_str err

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


;This routine reads a valid digit (0-9) or capitalized letters (A-Z)
read_key proc near
again_read_key:
	;Read the digit

	mov ah,1
	int 21h
	
	cmp al,0dh			;ASCII code for 'Enter'
	je exit_read_key
	
	cmp al,48 			;AL>=48 <=> AL>=ASCII code for 0
	jl wrong_read_key 		;No?Delete character and read again
	cmp al,57 			;AL<=57 <=> AL<=ASCII code for 9
	jg check_letter_read_key	;No? Check if it is a letter form 'A' to 'Z'

	jmp exit_read_key
check_letter_read_key:
	cmp al,65 			;AL>=65 <=> AL>=ASCII code for 'A'
	jl wrong_read_key 		;No?Delete character and read again
	cmp al,90 			;AL<=90 <=> AL<=ASCII code for 'Z'
	jg wrong_read_key		;No?Delete character and read again

	jmp exit_read_key
wrong_read_key:
	call delete_char
	jmp again_read_key
exit_read_key:
	ret
read_key endp


decapitalize proc near
	
	add al,32 			;If it a capitalized letter, add ASCII code 32,
					;to convert it in non - capitalized
exit_decapitalize:
	ret
decapitalize endp

	
code ends
end initiliaze 				;Set entry point and stop the assembler