/*			Copyright Q Solutions				*/
/*	File:		serial.c					*/
/*	Programmer:	MoT						*/
/*	Module:		uNode LCD module routines			*/
/*									*/
/*			History						*/
/* 12:49pm 06-03-1997 	Written from scratch				*/
/*									*/

#include	<reg552.h>
#include	<stdio.h>

#define	SBUFLEN	256			/* Serial Buffer Length		*/
#define	S_TSET	0x20			/* Serial Port Timer 1 Config 	*/
#define	S_S0CON	0x70			/* Set Serial Port Mode		*/

typedef unsigned char byte;		/* Optimise index maths		*/

char	*s_tbuf[SBUFLEN];		/* Serial transmit buffer	*/
bit	s_run=	0;			/* Serial Port Status		*/
byte	s_tin=	0;			/* Serial Buffer : Transmit In	*/
byte	s_tout=	0;			/* Serial Buffer : Transmit Out	*/

char	sputchar	( char in )	/* Print char to serial buffer	*/
{
	if	( s_tin++== SBUFLEN )	/* Increment write pointer	*/
		s_tin= 0;
	if	( s_tin== s_tout )	/* Buffer overflow		*/
		return	( -1 );		/* Return error			*/
	s_tbuf[s_tin]=	in;		/* Put character in the buffer	*/
	if	( !s_run )		/* New transmission		*/
	{
		S0BUF=	in;		/* Write to serial port		*/
		s_run=	1;		/* Set Serial Status to RUN	*/
	}
	return	( in );
}

void	init_serial	( void )	/* Initialise Serial Port	*/
{
	TMOD= (TMOD& 0x0F)| S_TSET;	/* Set Timer 1 Mode		*/
	TH1= S_TH1;			/* Set Time 1 Preload		*/
	TR1= 1;				/* Start Timer 1		*/
	S0CON= S_S0CON;			/* Set Serial Port Mode		*/
}

void	serial_int ( void ) interrupt 4 /* SIO1 Interrupt 		*/
{
	if	( TI )			/* Transmit Interrupt		*/
	{
		if (s_tout++== SBUFLEN)	/* Inc. tx buffer out pointer	*/
			s_tout= 0;
		if( s_tin== s_tout )	/* Buffer empty			*/
			s_run=	0;	/* Set Serial Status to OFF	*/
		else S0BUB= s_tbuf[s_tout];	/* Write character	*/
		TI=	0;		/* Reset Interrupt		*/
	}
	if	( RI )			/* Recieve Interrupt		*/
	{
		RI=	0;		/* Reset Interrupt		*/
	}
}
