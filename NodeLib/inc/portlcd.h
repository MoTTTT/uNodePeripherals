/*			Copyright Q Solutions				*/
/*	File:		PortLCD.h					*/
/*	Programmer:	MoT						*/
/*	Module:		I/O Port Controlled LCD 			*/
/*									*/
/*			History						*/
/* 8 April '97		Written from scratch				*/
/*									*/

#define	LCD_CLR	0x01			/* Clear LCD			*/
#define	LCD_L1	0x80			/* Line 1			*/
#define	LCD_L2	0xC0			/* Line 2			*/

void	init_plcd	( void );	/* Initialise LCD module	*/
void	set_plcd	( char in );	/* Control LCD			*/
char	pputchar	( char in );	/* Write data/command to LCD	*/
void	paint_plcd (char*l1,char*l2);	/* Draw Screen			*/
