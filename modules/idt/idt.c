#define INTERRUPT_GATE 0x8e

typedef struct idt_descr {
	unsigned short int offset_lowerbits;
	unsigned short int selector;
	unsigned char zero;
	unsigned char type_attr;
	unsigned short int offset_higherbits;
} IDT_Descriptor;

IDT_Descriptor IDT[256];

extern void keyboard_handler(void);
extern int read_port(int port_number);
extern void write_port(int port_number, int value);
extern void load_idt(long unsigned int *idt_ptr);

void idt_init(void)
{
	unsigned long keyboard_address;
	unsigned long idt_address;
	unsigned long idt_ptr[2];

	/* setting up interrupts to work with keyboard */
	keyboard_address = (unsigned long)keyboard_handler;
	IDT[0x21].offset_lowerbits = keyboard_address & 0xffff;
	IDT[0x21].selector = 0x08;
	IDT[0x21].zero = 0;
	IDT[0x21].type_attr = INTERRUPT_GATE;
	IDT[0x21].offset_higherbits = (keyboard_address & 0xffff0000) >> 16;

	write_port(0x20, 0x11);
	write_port(0xA0, 0x11);

	write_port(0x21, 0x20);
	write_port(0xA1, 0x28);

	write_port(0x21, 0x00);
	write_port(0xA1, 0x00);

	write_port(0x21, 0x01);
	write_port(0xA1, 0x01);

	write_port(0x21, 0b11111111);
	write_port(0xA1, 0b11111111);

	/* fill the IDT descriptors */
	idt_address = (unsigned long)IDT;
	idt_ptr[0] = (sizeof (IDT_Descriptor) * 256) + ((idt_address & 0xffff) << 16);
	idt_ptr[1] = idt_address >> 16 ;

  /* push IDT to ram */
	load_idt(idt_ptr);
}
