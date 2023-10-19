/*			Copyright Q Solutions				*/
/*	File:		testser.c					*/
/*	Programmer:	MoT						*/
/*	Module:		Library routine test program			*/
/*									*/
/*			History						*/
/* 05:19am 06-07-1997  	Written from scratch				*/
/* 23:58 29/03/1998 	Cleaned up for release				*/
/*									*/

#pragma		ROM (COMPACT)
#pragma		LARGE

/* Standard Library Header Files					*/
#include	<stdio.h>
#include	<reg552.h>

/* uNode Developer Kit Library Header Files				*/
typedef	unsigned int uint;		/* Optimise for size & speed:	*/
#include	<nodelcd.h>		/* Local LCD module routines	*/
#include	<nkey.h>		/* Local Keypad module routines	*/
#include	<wdog.h>		/* Watchdog refresh routine	*/
#include	<serial.h>		/* Serial port routines		*/

const char *signon1= " \xe4Node Dev. Kit ";/* Line 1 of sign on screen	*/
const char *signon2= "Q Solutions 1998";/* Line 2 of signon screen	*/
const char *sertest=	"Serial Port Library Test.\n";
const char *devkit=	"uNode Developer's Kit.\n";
const char *copyr=	"Copyright Q Solutions 1998.\n";
const char *quality=	"Quality Controller Solutions.\n";

#define		PAUSE	10000		/* Pause Period			*/
#define		IO_NLCD	1		/* Output to uNode LCD		*/
#define		IO_SER	2		/* Output to Serial Port	*/
char	out_stream;			/* Output port			*/
byte	nextstr= 0;			/* Message index		*/
uint	wait= PAUSE;			/* Pause counter		*/

void	signon		( )		/* Splash Screen		*/
{
	out_stream= IO_NLCD;		/* Output port: LCD		*/
	paint_nlcd ( signon1, signon2 );
	out_stream= IO_SER;		/* Output port: Serial		*/
	printf	( "\nSerial Port Tester...\n" );
}

void	initialise	( )		/* Initialise Hardware		*/
{
	EA=		1;		/* Enable Global Interrupt	*/
	init_nlcd	( );		/* Initialise local LCD		*/
	init_serial	( B19200 );	/* Initialise Serial Port	*/
	signon		( );		/* Splash screen		*/
}

char	putchar		( char out )
{
char	result;
	switch	( out_stream )
	{
	case IO_NLCD:			/* Write to local LCD		*/
		result= nputchar ( out );
		break;
	case IO_SER:			/* Write to serial Port		*/
		result= sputchar ( out );
		break;
	default:
		return	( -1 );
	}
	return	( result );
}

void	printmesg	( void )	/* Print Message to serial port	*/
{
	switch	( nextstr )
	{
	case 0:	printf	( sertest );
		break;
	case 1:	printf	( devkit );
		break;
	case 2:	printf	( copyr );
		break;
	case 3:	printf	( quality );
		break;
	default:
		nextstr= 0;
		break;
	}
	if	( ++nextstr > 3 ) nextstr= 0;
}

void	main	( void )		/* Main Loop			*/
{
	initialise	( );		/* Set up drivers, sign on	*/
	while	( 1 )
	{
		while	( wait-- )	/* Pause a while		*/
			wdog	( 10 );	/* Refresh watchdog		*/
		printmesg( );		/* Print a serial message	*/
		wait=	PAUSE;
	}
}