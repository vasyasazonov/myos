bits 32

section .data
	no_mtb db "[INFO] Kernel was not loaded by multiboot", 0h
	no_cpui db "[WARN] your cpu does not support CPUID", 0h
	no_long db "[ERROR] Your cumputer does not support long mode (x64)", 0h

section .text
  ;multiboot spec
  align 4
  dd 0x1BADB002              ;magic
  dd 0x00                    ;flags
	dd - (0x1BADB002 + 0x00)

section .multiboot_header
header_start:
	dd 0xe85250d6                ; magic number (multiboot 2)
	dd 0                         ; architecture 0 (protected mode i386)
	dd header_end - header_start ; header length
	; checksum
	dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

	; insert optional multiboot tags here

	; required end tag
	dw 0    ; type
	dw 0    ; flags
	dd 8    ; size
header_end:

global start
global read_port
global write_port
global stack_space
global load_idt
global check_cpuid
global check_long_mode

; functions defined in C
extern kmain
extern kprint
extern kprint_newline

nmtb:
	push no_mtb
	call kprint
	pop ax
	ret

ncpui:
	push no_cpui
	call kprint
	pop ax
	ret

nlong:
	push no_long
	call kprint
	pop ax
	hlt

error:
	cmp al, "0"
	je nmtb

	cmp al, "1"
	je ncpui

	cmp al, "2"
	je nlong

	ret


check_multiboot:
	cmp eax, 0x36d76289
	jne .no_multiboot
	ret
.no_multiboot:
	mov al, "0"
	jmp error

check_cpuid:
	; Check if CPUID is supported by attempting to flip the ID bit (bit 21)
	; in the FLAGS register. If we can flip it, CPUID is available.

	; Copy FLAGS in to EAX via stack
	pushfd
	pop eax

	; Copy to ECX as well for comparing later on
	mov ecx, eax

	; Flip the ID bit
	xor eax, 1 << 21

	; Copy EAX to FLAGS via the stack
	push eax
	popfd

	; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
	pushfd
	pop eax

	; Restore FLAGS from the old version stored in ECX (i.e. flipping the
	; ID bit back if it was ever flipped).
	push ecx
	popfd

	; Compare EAX and ECX. If they are equal then that means the bit
	; wasn't flipped, and CPUID isn't supported.
	cmp eax, ecx
	je .no_cpuid
	ret

.no_cpuid:
	mov al, "1"
	jmp error

check_long_mode:
	; test if extended processor info in available
	mov eax, 0x80000000    ; implicit argument for cpuid
	cpuid                  ; get highest supported argument
	cmp eax, 0x80000001    ; it needs to be at least 0x80000001
	jb .no_long_mode       ; if it's less, the CPU is too old for long mode

	; use extended info to test if long mode is available
	mov eax, 0x80000001    ; argument for extended processor info
	cpuid                  ; returns various feature bits in ecx and edx
	test edx, 1 << 29      ; test if the LM-bit is set in the D-register
	jz .no_long_mode       ; If it's not set, there is no long mode
	ret

.no_long_mode:
	mov al, "2"
	jmp error


load_idt:
	mov edx, [esp + 4]
	lidt [edx]
	sti 				;turn on interrupts
	ret

read_port:      ;C: int read_port(int port_number)
	mov edx, [esp + 4]
	in al, dx
	ret

write_port:     ;C: void write_port(int port_number, int value)
	mov   edx, [esp + 4]
	mov   al, [esp + 4 + 4]
	out   dx, al
	ret

start:
	;call check_multiboot
	call check_cpuid
	call check_long_mode
	cli 				;block interrupts
	mov esp, stack_top
	call kmain          ;call defined in C function
	hlt                 ;halt system

section .bss
stack_buttom:
resb 64               ;8KB for stack
stack_top:            ;lable witch adress is adress of stack space
