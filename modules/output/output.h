#ifndef __OUTPUT_H__
#define __OUTPUT_H__


#define LINES 25
#define COLUMNS 80
#define ELEMENT_BYTES 2
#define SCREENSIZE ELEMENT_BYTES * COLUMNS * LINES
#define LINE_SIZE ELEMENT_BYTES * COLUMNS

void kprint_newline(void);
void kprint(const char *str);
void clear_screen(void);
void kscroll();

#endif //__OUTPUT_H__