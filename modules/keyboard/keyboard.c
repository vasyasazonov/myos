#include "keyboard.h"

extern char *vidptr;
extern int current_loc;

extern int read_port(int port_number);
extern void write_port(int port_number, int value);

extern void kprint_newline(void);

void keyboard_handler_c(void)
{
	unsigned char status;
	char keycode;
	/* write EOI */
	write_port(0x20, 0x20);


	status = read_port(KEYBOARD_STATUS_PORT);

	if (status & 0x01)
	{
		keycode = read_port(KEYBOARD_DATA_PORT);
		if(keycode < 0)
			return;

		if(keycode == 0x1C)
		{
			kprint_newline();
			return;
		}

		vidptr[current_loc++] = keyboard_map[(unsigned char) keycode];
		vidptr[current_loc++] = 0x07;
	}
}
