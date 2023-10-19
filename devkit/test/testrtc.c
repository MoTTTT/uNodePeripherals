/*			Copyright Q Solutions				*/
/*	File:		testrtc.c					*/
/*	Programmer:	MoT						*/
/*	Module:		Library routine test program (iic, iicdriv, rtc)*/
/*									*/
/*			History						*/
/* 15:58 20/04/1997  	Written from scratch				*/
/*			Initialisation and main loop.			*/
/* 23:06 29/03/1998 	Cleanup for release				*/
/*			To Do: Add set_time, set_date support		*/
/*									*/

#pragma		ROM (COMPACT)
#pragma		LARGE

/* Standard Library Header Files					*/
#include	<stdio.h>
#include	<reg552.h>

typedef	unsigned int uint;		/* Optimise for size & speed:	*/
typedef	unsigned char byte;		/* Use unsigned char and int	*/

/* uNode Developer Kit Library Header Files				*/
#include	<iic.h>			/* IIC Bus routines		*/
#include	<rtc.h>			/* Real time clock routines	*/
#include	<time.h>		/* Time routines		*/
#include	<nodelcd.h>		/* Local LCD module routines	*/
#include	<nkey.h>		/* Local Keypad module routines	*/
#include	<wdog.h>		/* Watchdog refresh routine	*/

#define		IIC_ADDR 0x68		/* IIC Slave Address		*/
#define		IO_NLCD	0x01		/* Output to uNode LCD		*/

const char *signon1= " \xe4Node Dev. Kit ";/* Line 1 of sign on screen	*/
const char *signon2= "Q Solutions 1998";/* Line 2 of signon screen	*/
const char *prompt1= " Time           ";/* Time Prompt			*/
const char *prompt2= " Date           ";/* Date Prompt			*/

char	out_stream= IO_NLCD;		/* Output port			*/

void	signon		( )		/* Splash Screen		*/
{
	paint_nlcd ( signon1, signon2 );
}

void	initialise	( )		/* Initialise Hardware		*/
{
uint	wait= 1;			/* Signon pause counter		*/
	EA=		1;		/* Enable Global Interrupt	*/
	init_nlcd	( );		/* Initialise local LCD		*/
	init_nkey	( );		/* Initialise local keypad	*/
	iic_init	( IIC_ADDR );	/* Initialise IIC Bus		*/
	signon		( );		/* Splash screen		*/
	init_rtc	( );
	while	( wait++ )		/* Pause a while		*/
		wdog	( 10 );		/* Refresh watchdog		*/
	paint_nlcd ( prompt1, prompt2 );/* Set up LCD			*/
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

void	service_keypad	( )		/* Read and process keypad	*/
{
byte	in;
	if	( x1_flag )
	{
		in= ngetkey	( );
		switch	( in )
		{
		case 0:
		default:
			break;
		}
	}
}

void	main	( void )		/* Main Loop			*/
{
	initialise	( );		/* Set up drivers, sign on	*/
	while	( 1 )
	{
		wdog	( 10 );		/* Refresh watchdog		*/
		set_nlcd( NLCD_L1+ 7 );	/* Set cursor			*/
		show_time( );		/* Print the time		*/
		set_nlcd( NLCD_L2+ 7 );	/* Set cursor			*/
		show_date( );		/* Print the date		*/
	}
}