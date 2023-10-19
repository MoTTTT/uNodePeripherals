/*			Copyright Q Solutions				*/
/*	File:		nodelcd.h					*/
/*	Programmer:	MoT						*/
/*	Module:		uNode LCD module routines			*/
/*									*/
/*			History						*/
/* 20:03 19/04/1997  	Cleanup						*/
/*									*/

#define		NCLEAR		0x01		/* Clear LCD 		*/
#define		NLCD_L1		0x80		/* Set LCD to Line 1	*/
#define		NLCD_L2		0xC0		/* Set LCD to Line 2	*/
#define		NLCD_CB		0x0F		/* Set LCD Cursor Blink	*/

extern bit	nlcd_data;			/* used by nputchar	*/

char	nputchar	( char in );		/* uNode LCD putchar	*/
void	set_nlcd	( char command );	/* Send to command reg.	*/
void	init_nlcd	( void );		/* Initialise LCD dis	*/
void	paint_nlcd	( char* l1, char* l2 );	/* Paint 2 lines on LCD	*/