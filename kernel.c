#include "modules/output/output.h"


extern int read_port(int port_number);
extern void write_port(int port_number, int value);
extern void idt_init(void);


void kmain(void)
{
	clear_screen();
	kprint("Kernel started successful");
	kprint_newline();
	idt_init();
	write_port(0x21 , 0b11111101); // Enable IRQ1
	while(1);
}
