/*			Copyright Q Solutions				*/
/*	File:		serial.c					*/
/*	Programmer:	MoT						*/
/*	Module:		uNode Serial Port routines			*/
/*									*/
/*			History						*/
/* 12:49pm 06-03-1997 	Written from scratch				*/
/* 01:34am 09-15-1997 	Optimised for speed				*/
/* 17:36 30/11/1997 	Added frame reception handler			*/
/* 18:36 07/04/1998 	Changed init parameter to Baud Rate Define	*/
/*				(see header file for baud rate options)	*/
/* 00:13 08/04/1998 	To Do: Add Error checking (buffer overflow etc)	*/
/*									*/

#include	<reg552.h>
#include	<stdio.h>
#include	<serial.h>

#define	SBUFLEN	256			/* Serial Buffer Length		*/
#define	S_TSET	0x20			/* Serial Port Timer 1 Config 	*/
#define	S_S0CON	0x70			/* Set Serial Port Mode		*/
#define	S_RTIM	10			/* Receive frame timout		*/

char	s_tbuf[SBUFLEN];		/* Serial transmit buffer	*/
char	s_rbuf[SBUFLEN];		/* Serial recieve buffer	*/
bit	s_run=	0;			/* Serial Port Status		*/
bit	s_rnew=	0;			/* Serial Buffer : Frame Rx flag*/
byte	s_rlen=	0;			/* Serial Buffer : Rx length	*/
byte idata s_tin= 0;			/* Serial Buffer : Transmit In	*/
byte idata s_tout=0;			/* Serial Buffer : Transmit Out	*/
byte idata s_rin= 0;			/* Serial Buffer : Receive In	*/
byte idata s_rtim;			/* Serial Buffer : Recieve Timer*/

char	sputchar	( char in );	/* Print char to serial buffer	*/
void	init_serial	( char baudr );	/* Initialise Serial Port	*/
void	s_rxh		( void );	/* Serial port frame handler	*/

void	init_serial	( char baudr )	/* Initialise Serial Port	*/
{
	TMOD=(TMOD&0x0F)|(S_TSET&0xF0);	/* Set Timer 1 Mode		*/
	switch	( baudr )
	{
	case B19200:
		TH1=	0xFD;		/* Set Time 1 Preload		*/
		PCON|=	0x80;		/* Double Baud rate		*/
		break;
	case B9600:
		TH1=	0xFD;		/* Set Time 1 Preload		*/
		break;
	case B4800:
		TH1=	0xFA;		/* Set Time 1 Preload		*/
		break;
	case B2400:
		TH1=	0xF4;		/* Set Time 1 Preload		*/
		break;
	case B1200:
		TH1=	0xE8;		/* Set Time 1 Preload		*/
		break;
	case B600:
		TH1=	0xC0;		/* Set Time 1 Preload		*/
		break;
	default:
		TH1=	0xFD;		/* Set Time 1 Preload		*/
		PCON|=	0x80;		/* Double Baud rate		*/
		break;
	}
	TR1=	1;			/* Start Timer 1		*/
	ES0=	1;			/* Enable serial interrupt	*/
	S0CON=	S_S0CON;		/* Set Serial Port Mode		*/
}

void	s_rxh		( void )	/* Serial port frame handler	*/
{
	if	( s_rin )		/* Frame reception in progress	*/
	{
		if	( !s_rtim-- )	/* Decrement Frame Timout count	*/
		{
			s_rlen=	s_rin;	/* Set frame length		*/
			s_rin=	0;	/* Reset frame pointer		*/
			s_rnew=	1;	/* Flag frame reception		*/
		}
	}
}

char	sputchar	( char in )	/* Print char to serial buffer	*/
{
	if	( in== 0x0A )		/* Carriage Return		*/
	{
		s_tbuf[s_tin]=0x0D;	/* Put Line Feed in the buffer	*/
		s_tin++;		/* Increment write pointer	*/
	}
	s_tbuf[s_tin]=in;		/* Put character in the buffer	*/
	s_tin++;			/* Increment write pointer	*/
	if	( !s_run )		/* New transmission		*/
	{
		s_run=	1;		/* Set Serial Status to RUN	*/
		S0BUF= s_tbuf[s_tout];	/* Write character		*/
		s_tout++;		/* Inc. tx buffer out pointer	*/
	}
	return	( in );
}

void	serial_int ( void ) interrupt 4 /* SIO1 Interrupt 		*/
{
	if	( TI )			/* Transmit Interrupt		*/
	{
		if( s_tout== s_tin )	/* Buffer empty			*/
			s_run=	0;	/* Set Serial Status to OFF	*/
		else
		{
			S0BUF= s_tbuf[s_tout];	/* Write character	*/
			s_tout++;		/* Inc. tx buff out ptr	*/
		}
		TI=	0;		/* Reset Interrupt		*/
	}
	if	( RI )			/* Recieve Interrupt		*/
	{
		s_rtim=	S_RTIM;		/* Reset Recieve Timer		*/
		s_rbuf[s_rin]= S0BUF;	/* Store byte in buffer		*/
		s_rin++;		/* Increment Rx buffer in pointr*/
		RI=	0;		/* Reset Interrupt		*/
	}
}