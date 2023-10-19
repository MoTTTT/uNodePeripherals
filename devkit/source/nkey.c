/*			Copyright Q Solutions				*/
/*	File:		nkey.c						*/
/*	Programmer:	MoT						*/
/*	Module:		uNode Keypad routines				*/
/*									*/
/*			History						*/
/* 12:17 20/04/1997 	Cleanup						*/
/*									*/

#include	<reg552.h>
#include	<stdio.h>
#include	<iic.h>

#define		KPAD	(( char *) 0x28000L)	/* Address of keypad	*/
#define		RTC_R		0xA1		/* PCF8583 read		*/
#define		RTC_W		0xA0		/* PCF8583 write	*/

bit		x1_flag	=0;			/* set by x1_int	*/

char	ngetkey		( void );		/* uNode getkey routine	*/
bit	test_x1 	( void );		/* Return 1 if key int	*/
void	init_nkey	( void );		/* Set up keypad	*/

void	init_nkey	( void )		/* Set up keypad	*/
{
	EX1	= 1;				/* Enable Xternal Int 1	*/
	IT1	= 1;				/* XInt1 -> edge int	*/
	EA	= 1;				/* Enable Global Int	*/
	PX1	= 0;				/* EX1 -> low priority	*/
}

void	X1_int	 ( void ) interrupt 2		/* X1 Interrupt routine	*/
{
	x1_flag= 1;				/* Set interrupt flag	*/
}

char	ngetkey		( )			/* uNode getkey routine	*/
{
	while	( !x1_flag );			/* Wait for keypress	*/
	x1_flag=0;				/* Reset flag		*/
	return	( (*KPAD)- 240 );		/* Return converted data*/
}

bit	test_x1		( )			/* Return 1 if key int	*/
{
char	idata	test=0;
char	count= 1;
	if	( !iic_mtx ( RTC_W, 1, &test ))
		return	( 1 );
	if	( !iic_mtx ( RTC_R, 1, &test ))
		return	( 1 );
	if	( test & 0x02 ) return ( 0 );
	else	return	( 1 );
}