/*			Copyright Q Solutions				*/
/*	File:		testkl.c					*/
/*	Programmer:	MoT						*/
/*	Module:		Library routine test program (nodelcd,nkey,wdog)*/
/*									*/
/*			History						*/
/* 05:19am 06-07-1997  	Written from scratch				*/
/* 20:06 29/03/1998	Cleaned up for release				*/
/*									*/

#pragma		ROM (COMPACT)
#pragma		LARGE

/* Standard Library Header Files					*/
#include	<stdio.h>
#include	<reg552.h>

typedef	unsigned int uint;		/* Optimise for size & speed:	*/
typedef	unsigned char byte;		/* Use unsigned char and int	*/

/* uNode Developer Kit Library Header Files				*/
#include	<nodelcd.h>		/* Local LCD module routines	*/
#include	<nkey.h>		/* Local Keypad module routines	*/
#include	<wdog.h>		/* Watchdog refresh routine	*/

#define		IO_NLCD	0x01		/* Output to uNode LCD		*/

const char *hi1= " \xe4Node Dev. Kit ";	/* Line 1 of signon prompt	*/
const char *hi2= "Q Solutions 1998";	/* Line 2 of signon screen	*/
const char *tst1="LCD& Keypad Test";	/* Line 1 of test prompt	*/
const char *tst2=" Key Pressed:   ";	/* Line 2 of test prompt	*/

char	out_stream= IO_NLCD;		/* Output port			*/
uint	counter;			/* Routine cycle counter	*/

void	signon		( )		/* Splash Screen		*/
{
	paint_nlcd ( hi1, hi2 );	/* Say Hello.			*/
}

void	initialise	( )		/* Initialise Hardware		*/
{
	EA=		1;		/* Enable Global Interrupt	*/
	init_nlcd	( );		/* Initialise local LCD		*/
	init_nkey	( );		/* Initialise local keypad	*/
	signon		( );		/* Splash screen		*/
}

char	putchar		( char out )
{
	switch	( out_stream )
	{
	case IO_NLCD:			/* Write to local LCD		*/
		nputchar	( out );
		break;
	}
	return	( out );
}

void	putkey	( byte in )		/* Print a key value		*/
{
	if	( in < 10 )	
		putchar	( '0'+ in );	/* Numeric part of hexidecimal	*/
	else	putchar	( 'A'+ in- 10 );/* Alpha part of hexidecimal	*/
}

void	service_keypad	( )		/* Read and process keypad	*/
{
byte	in;
	if	( x1_flag )
	{
		in= ngetkey	( );	/* Read key from buffer		*/
		paint_nlcd(tst1,tst2);	/* Print test and result prompt	*/
		set_nlcd( NLCD_L2+ 14 );/* Set cursor			*/
		putkey	( in );		/* Print key value		*/
	}
}

void	main	( void )		/* Main Loop			*/
{
	initialise	( );		/* Set up drivers, sign on	*/
	while	( 1 )
	{
		wdog	( 10 );		/* Refresh watchdog		*/
		service_keypad	( );	/* Process input		*/
		counter++;		/* Bide our time		*/
	}
}