/*			Copyright Q Solutions				*/
/*	File:		PortLCD.c					*/
/*	Programmer:	MoT						*/
/*	Module:		I/O Port Controlled LCD 			*/
/*									*/
/*			History						*/
/* 8 April '97		Written from scratch				*/
/*									*/

#include	<stdio.h>
#include	<reg552.h>

#define	LCD_BF	0x08			/* Busy flag mask		*/
#define	LCD_I1	0x2C			/* 4 bits; 2 line; 5x10		*/
#define	LCD_I2	0x0C			/* Display ON; Cursor off	*/
#define	LCD_I3	0x06			/* Auto increment; Freeze	*/
#define	LCD_CLR	0x01			/* Clear LCD			*/
#define	LCD_L1	0x80			/* Line 1			*/
#define	LCD_L2	0xC0			/* Line 2			*/

typedef unsigned char byte;

/* Control and DATA port defines					*/
#define	L_IO	P1			/* LCD Data Port		*/
#define	LINES	2			/* Number of LCD lines		*/
#define	COLUMNS	16			/* Number of LCD columns	*/
sbit	L_ENAB=	0xC7;			/* LCD Enable			*/
sbit	L_READ=	0xC6;			/* LCD Read			*/
sbit	L_DATA= 0xC5;			/* LCD DATA			*/

void	init_plcd	( void );	/* Initialise LCD module	*/
void	set_plcd	( char in );	/* Control LCD			*/
char	pputchar	( char in );	/* Write data/command to LCD	*/
char	writeln	( char *in, char len );	/* Write a line to LCD		*/
void	paint_plcd (char*l1,char*l2);	/* Draw Screen			*/

void	paint_plcd (char*l1,char*l2)	/* Draw Screen			*/
{
	set_plcd( LCD_L1 );		/* Goto Line 1			*/
	printf	( l1 );			/* Print first string		*/
	set_plcd( LCD_L2 );		/* Goto Line 2			*/
	printf	( l2 );			/* Print second string		*/
}

void	init_plcd	( void )	/* Initialise LCD module	*/
{
char	i= 1;
	set_plcd	( LCD_I1 );	/* See #define's for details	*/
	set_plcd	( LCD_I2 );
	set_plcd	( LCD_I3 );
	set_plcd	( LCD_CLR );	/* Clear display		*/
	while	( i++ );		/* Wait for clear display	*/
}

void	set_plcd	( char in )	/* Control LCD			*/
{
	L_DATA=	0;			/* Set control			*/
	pputchar	( in );		/* Send control settings	*/
}

char	pputchar	( char in )
{
byte	busy, busycount=1;
	L_READ=	0;			/* Select write			*/
	L_ENAB=	1;			/* Enable LCD			*/
	L_IO= (L_IO& 0xF0)| (in>> 4);	/* Write 1st nibble		*/
	L_ENAB=	0;			/* Clock data into LCD		*/
	L_ENAB=	1;			/* Enable LCD			*/
	L_IO= (L_IO& 0xF0)| (in& 0x0F);	/* Write 2nd nibble		*/
	L_ENAB=	0;			/* Clock data into LCD		*/
	L_DATA=	0;			/* Select register		*/
	L_READ=	1;			/* Select read			*/
	do				/* Wait for busy flag to clear	*/
	{
		L_ENAB=	1;		/* Enable LCD			*/
		busy= L_IO& LCD_BF;	/* Read and mask out busy flag	*/
		L_ENAB=	0;
		L_ENAB=	1;		/* Dummy read of second nibble	*/
		L_ENAB=	0;
		if	( !busycount++ )/* Notch one up			*/
			return	( -1 );	/* WRITE FAIL !!		*/
	}	while	( busy );
	L_DATA=	1;			/* Next byte defaults to DATA	*/
	return	( in );
}
