#include "output.h"

int current_loc = 0;       //current cursor location
int current_style = 0x07;

char *vidptr = (char*)0xb8000;      //video memory begins here

void kprint_newline(void)
{
	current_loc = current_loc + (LINE_SIZE - current_loc % (LINE_SIZE));
}

void kprint(const char *str)
{
	unsigned int i = 0;
	while (str[i] != '\0') {
		if(str[i] == '\n')
		{
			kprint_newline();
			i++;
		}
		else if (str[i] == '\r')
		{
			current_loc -= current_loc % 160;
			i++;
		}
		else
		{
			vidptr[current_loc++] = str[i++];
			vidptr[current_loc++] = current_style;
		}
	}
}

void clear_screen(void)
{
	unsigned int i = 0;
	while (i < SCREENSIZE) {
		vidptr[i++] = ' ';
		vidptr[i++] = 0x07;
	}
}

void kscroll(){
	if(current_loc < 160)
		return;

	char * temp;
	int temploc = current_loc;

	for(int i = 0; i < SCREENSIZE; i++)
		temp[i] = vidptr[i];
	
	for(int i = 0; i < SCREENSIZE; i++)
	{
		vidptr[i] = temp[i+80*2];
	}
  
	current_loc = temploc-80*2;
}