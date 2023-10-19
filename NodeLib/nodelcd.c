/*			Copyright Q Solutions				*/
/*	File:		nodelcd.c					*/
/*	Programmer:	MoT						*/
/*	Module:		uNode LCD module routines			*/
/*									*/
/*			History						*/
/* 20:03 19/04/1997  	Cleanup						*/
/*									*/

#include	<reg552.h>
#include	<stdio.h>

#define		NLCD	(( char * ) 0x28200L)	/* LCD Address		*/
#define		STATUS	2			/* LCD Address		*/
#define		DATA	1			/* LCD data select	*/
#define		COMMAND	0			/* LCD command select	*/
#define		BUSY	0x80			/* LCD Busy mask	*/

#define		NCLEAR	0x01			/* LCD control commands	*/
#define		NLCD_L1	0x80			/* Set LCD to Line 1	*/
#define		NLCD_L2	0xC0			/* Set LCD to Line 2	*/

bit		nlcd_data;			/* used by nputchar	*/

char	nputchar	( char in )		/* Print a character	*/
{
char	status;
	while	( NLCD[STATUS]& BUSY );		/* Wait for busy flag	*/
	if	( nlcd_data )			/* Check contol or data	*/
		NLCD[DATA]= in;			/* Data register	*/
	else	NLCD[COMMAND]= in;		/* Control register	*/
	return	( in );
}

void	set_nlcd	( char command )	/* Send to command reg.	*/
{
	nlcd_data= 0;				/* Select LCD command	*/
	nputchar ( command ); 			/* Send the command	*/
	nlcd_data= 1;				/* Reset to LCD Data	*/
}

void	init_nlcd	( void )		/* Initialise LCD dis	*/
{
	nlcd_data=	0;			/* Select LCD command	*/
	nputchar	( 0x38 );		/* SET LCD FOR 8 BIT	*/
	nputchar	( 0x0C );		/* DISP= ON, CURSOR= OFF*/
	nputchar	( 0x06 );		/* AUTO INC, FREEZE	*/
	nputchar	( NCLEAR );		/* CLEAR SCREEN		*/
	nlcd_data=	1;			/* Reset to LCD Data	*/
}

void	paint_nlcd	( char *l1, char *l2 )	/* Draw Screen		*/
{
	set_nlcd( NLCD_L1 );		/* Goto Line 1			*/
	printf	( l1 );			/* Print first string		*/
	set_nlcd( NLCD_L2 );		/* Goto Line 2			*/
	printf	( l2 );			/* Print second string		*/
}
