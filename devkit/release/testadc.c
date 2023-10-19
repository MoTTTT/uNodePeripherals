/*			Copyright Q Solutions				*/
/*	File:		testadc.c					*/
/*	Programmer:	MoT						*/
/*	Module:		Library routine test program (nodelcd,adc)	*/
/*									*/
/*			History						*/
/* 15:58 20/04/1997  	Written from scratch				*/
/*			Initialisation and main loop.			*/
/* 22:11 29/03/1998 	Cleaned up for release.				*/
/*									*/

#pragma		ROM (COMPACT)
#pragma		LARGE

/* Standard Library Header Files					*/
#include	<stdio.h>
#include	<reg552.h>

typedef	unsigned int uint;		/* Optimise for size & speed:	*/
typedef	unsigned char byte;		/* Use unsigned char and int	*/

/* uNode Developer's Kit Library Header Files				*/
#include	<adc.h>			/* Analog to Digital routines	*/
#include	<nodelcd.h>		/* Local LCD module routines	*/
#include	<wdog.h>		/* Watchdog refresh routine	*/

#define		IIC_ADDR 0x68		/* IIC Slave Address		*/
#define		REM_ADDR 0x60		/* IIC Remote Address		*/
#define		IO_NLCD	0x01		/* Output to uNode LCD		*/

const char *signon1= " \xe4Node Dev. Kit ";/* Line 1 of sign on screen	*/
const char *signon2= "Q Solutions 1998";/* Line 2 of signon screen	*/

char	out_stream= IO_NLCD;		/* Output port			*/

void	signon		( )		/* Splash Screen		*/
{
	paint_nlcd ( signon1, signon2 );
}

void	initialise	( )		/* Initialise Hardware		*/
{
	EA=		1;		/* Enable Global Interrupt	*/
	init_nlcd	( );		/* Initialise local LCD		*/
	signon		( );		/* Splash screen		*/
	init_adc	( );		/* Initialise Analog -> Digital	*/
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

void	show_adc( void )		/* Print adc results 		*/
{
byte	i;
	set_nlcd( NLCD_L1 );		/* Set cursor to line 1		*/
	for	( i= 0; i<= 3; i++ )
		printf	( "%03bu ",adc[i] );	/* Print first results	*/
	set_nlcd( NLCD_L2 );		/* Set cursor to line 2		*/
	for	( i= 4; i<= 7; i++ )	
		printf	( "%03bu ",adc[i] );	/* Print the rest	*/
}

void	main	( void )		/* Main Loop			*/
{
uint	wait= 1;			/* Signon pause counter		*/
	initialise	( );		/* Set up drivers, sign on	*/
	while	( wait++ )		/* Wait a while			*/
		wdog	( 10 );		/* Refresh watchdog		*/
	while	( 1 )
	{
		wdog	( 10 );		/* Refresh watchdog		*/
		adc_start( );		/* Start conversion (8 channels)*/
		while	( adc_read );	/* Wait for completion		*/
		show_adc( );		/* Print results to the screen	*/
	}
}