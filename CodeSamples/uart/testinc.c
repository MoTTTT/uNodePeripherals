/************************************************************************/
/*		testinc.c: Node3 80C552 Dev Include File		*/
/*		M.J.Colley '92						*/
/************************************************************************/
#pragma		ROM ( COMPACT )
#pragma		SMALL
#pragma		CODE
#pragma		SYMBOLS
#include	<reg552.h>
#include	<stdio.h>
#include	<string.h>
#include	<um2681_1.h>

#define		KPAD	(( char *) 0x28000L)	/* Address of keypad	*/

#define		RS232		2		/* Values of io_stream	*/
#define		LCD_DATA	0		/*			*/
#define		LCD_COMMAND	1		/*			*/
#define		CLEAR		0x01		/* LCD control commands	*/
#define		LINE_1		0x80		/*			*/
#define		LINE_2		0xC0		/*			*/


bit		x1_flag	=0;			/* set by x1_int	*/
char		par_addr = 0;
char		lcd_addr = 0x82;
char		io_stream = 0x00;		/* used by putchar	*/

	X1_int	 	( ) interrupt 2		/* X1 Interrupt routine	*/
{	x1_flag= 1;	}

	set_lcd		( char command )	/* Sets up Command reg	*/
{	io_stream= LCD_COMMAND;	putchar	( command ); io_stream= LCD_DATA;}

	init_lcd		( )		/* Initialise LCD dis	*/
{
	io_stream= LCD_COMMAND;
	putchar	( 0x38 );			/* SET LCD FOR 8 BIT	*/
	putchar	( 0x0C );			/* DISP= ON, CURSOR= OFF*/
	putchar	( 0x06 );			/* AUTO INC, FREEZE	*/
	putchar	( CLEAR );			/* CLEAR SCREEN		*/
	io_stream= LCD_DATA;
}

	init_sio0		( )		/* Init RS232 port	*/
{
	TMOD	= 0x21;				/* SET TIMER 1 & 2 MODE	*/
	TH1	= 0xE8;				/* SET TIMER 1 PRELOAD	*/
	TR1	= 1;				/* START TIMER 1	*/
	S0CON	= 0x78;				/* SET SERIAL PORT MODE	*/
}

char	getkey		( )
{	
	while	( !x1_flag );
	x1_flag=0;
	return	( (*KPAD)- 240 );
}