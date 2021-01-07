all: modules kernel link

#modules
modules: output idt keyboard

#modules.output
output:
	@echo "CC      output.c"
	@gcc -m32 -c ./modules/output/output.c -o ./bin/output.o

#modules.idt
idt:
	@echo "CC      idt.c"
	@gcc -m32 -c ./modules/idt/idt.c -o ./bin/idt.o

#modules.keyboard
keyboard:
	@echo "NASM    keyboard.asm"
	@nasm -f elf32 ./modules/keyboard/keyboard.asm -o ./bin/keyboard.asm.o
	@echo "CC      keyboard.c"
	@gcc -m32 -c ./modules/keyboard/keyboard.c -o ./bin/keyboard.o

#kernel
kernel:
	@echo "NASM    kernel.asm"
	@nasm -f elf32 ./kernel.asm -o ./bin/kernel.asm.o
	@echo "CC      kernel.c"
	@gcc -m32 -c ./kernel.c -o ./bin/kernel.o

#linking
link:
	@echo "LD      linking"
	@ld -m elf_i386 -T link.ld -o kernel ./bin/kernel.o ./bin/kernel.asm.o  ./bin/output.o ./bin/keyboard.asm.o ./bin/keyboard.o ./bin/idt.o

iso:
	@echo "ISO     creating\n"
	@cp ./kernel ./isofiles/boot/kernel.bin
	@grub-mkrescue -o os.iso isofiles

clean:
	@rm ./bin/*

#starting emulation
run:
	#@qemu-system-x86_64 -cdrom os.iso
	@qemu-system-x86_64 -kernel kernel
