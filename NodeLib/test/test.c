/*			Copyright Q Solutions				*/
/*	File:		test.c						*/
/*	Programmer:	MoT						*/
/*	Module:		Library routine test program			*/
/*									*/
/*			History						*/
/* 15:58 20/04/1997  	Written from scratch				*/
/*			Initialisation and main loop.			*/

#pragma		ROM (COMPACT)
#pragma		LARGE

/* Library files							*/
#include	<stdio.h>
#include	<reg552.h>

typedef	unsigned int uint;		/* Optimise for size & speed:	*/
typedef	unsigned char byte;		/* Use unsigned char and int	*/

#include	<iic.h>			/* IIC Bus routines		*/
#include	<rtc.h>			/* Real time clock routines	*/
#include	<adc.h>			/* Analog to Digital routines	*/
#include	<nodelcd.h>		/* Local LCD module routines	*/
#include	<nkey.h>		/* Local Keypad module routines	*/
#include	<wdog.h>		/* Watchdog refresh routine	*/

#define		IIC_ADDR 0x68		/* IIC Slave Address		*/
#define		REM_ADDR 0x60		/* IIC Remote Address		*/
#define		IO_NLCD	0x01		/* Output to uNode LCD		*/

const char *signon1= "  uNode Library ";/* Line 1 of sign on screen	*/
const char *signon2= "     Tester     ";/* Line 2 of signon screen	*/

char	out_stream= IO_NLCD;		/* Output port			*/
uint	counter;			/* Routine cycle counter	*/
byte	iiccount= 0;			/* IIC input frame counter	*/
char idata iic_in[2];			/* IIC Bus input buffer		*/
char idata iic_out[2];			/* IIC Bus output buffer	*/

void	signon		( )		/* Splash Screen		*/
{
	paint_nlcd ( signon1, signon2 );
}

void	initialise	( )		/* Initialise Hardware		*/
{
	EA=		1;		/* Enable Global Interrupt	*/
	init_nlcd	( );		/* Initialise local LCD		*/
	init_nkey	( );		/* Initialise local keypad	*/
	iic_init	( IIC_ADDR );	/* Initialise IIC Bus		*/
	signon		( );		/* Splash screen		*/
//	iic_sset	( iic_in, 1 );	/* Set up slave input buffer	*/
	init_rtc	( );
	init_adc	( );
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

void	service_iicin	( )
{
	if	( iic_sready )
	{
		iiccount++;
		set_nlcd( NLCD_L1 );
		printf	( "%3bu, Code: %3bu", iiccount, iic_in[0] );
		iic_sready=0;
	}
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
			set_nlcd	( NLCD_L2 );
			printf		( "  Sending CLEAR " );
			iic_out[0]= 0;
			iic_mtx(REM_ADDR, 2, iic_out );
			break;
		case 1:
			set_nlcd	( NLCD_L2 );
			printf		( "  Sending 'A'   " );
			iic_out[0]= 2;
			iic_out[1]= 'A';
			iic_mtx(REM_ADDR, 2, iic_out );
			break;
		case 2:
			set_nlcd	( NLCD_L2 );
			printf		( "  Sending CLEAR " );
			break;
		case 3:
			set_nlcd	( NLCD_L2 );
			printf		( "  Sending CLEAR " );
			break;
		default:
			set_nlcd	( NCLEAR );
//			paint_nlcd    ( "        OK      ",
//					"  Press Another " );
			break;
		}
	}
}

void	main	( void )		/* Main Loop			*/
{
int	i;
//	initialise	( );		/* Set up drivers, sign on	*/
	while	( 1 )
	{
		P4=	0xFF;
//		while	( i++ );
//		i++;
		P4=	0x00;
//		while	( i++ );
	}
	while	( 1 )
	{
		wdog	( 10 );		/* Refresh watchdog		*/
		adc_start( );
		while	( adc_read );
		set_nlcd( NLCD_L1 );
		printf	( " %02bX ", adc[1] );
//		set_nlcd( NLCD_L1 );
//		show_time( );
//		service_keypad	( );	/* Process input		*/
//		service_iicin	( );	/* Process input		*/
		counter++;		/* Increment loop counter	*/
	}
}