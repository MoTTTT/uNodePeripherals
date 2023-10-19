/************************************************************************/
/*			Copyright Q Solutions				*/
/*	File:		cbkey.c						*/
/*	Programmer:	MoT						*/
/*	Module:		Switch Matrix Keypad Driver			*/
/*									*/
/*			History						*/
/* 19:57 30/03/1997	Written from scratch				*/
/*			Usage notes added to cbkey.h			*/
/************************************************************************/

#include	<reg552.h>

/* Target Specific Parameters						*/
#define	K_CTRL	P4			/* Keypad control lines		*/
#define	K_MON	P5			/* Keypad Monitor lines		*/
#define	K_MASK	0x1F			/* Keypad Monitor mask		*/
#define K_ROWS	4			/* Number of keypad rows	*/
#define	K_COLM	5			/* Number of keypad columns	*/
/* Keypad response parameters						*/
#define	K_SS	10			/* Keypad sample size		*/
#define	K_ON	7			/* Keypad "ON" threshold	*/
#define K_OFF	3			/* Keypad "OFF" threshold	*/
#define	K_SP	0xFF			/* Timer reload-> samp period	*/

#define	ON	1
#define	OFF	0
typedef	unsigned int	uint;
typedef	unsigned char	byte;
byte	mask[8]=	{ 1, 2, 4, 8, 16, 32, 64, 128 };

void	init_cbkey	( void );	/* Initialise Keypad		*/
bit	test_cbkey	( void );	/* Nonblocking test for keypress*/
char	read_cbkey	( void );	/* Wait for keypress, return it	*/

uint	keycount= 0;			/* Keypad Samples count		*/
uint	keysum=	0;			/* Accumulated Keypad Samples	*/
bit	newkey= OFF;			/* Incoming keypress flag	*/
bit	keystate= ON;			/* Keyup or Keydown		*/
byte	key_in;				/* Keypad buffer		*/

void	init_cbkey	( void )	/* Initialise Cross Bar Keypad	*/
{
	ET0=	ON;			/* Enable timer 1 interrupt	*/
	TCON=	0x20;			/* T0: Mode 0			*/
	TH0=	K_SP;			/* Set timer reload value	*/
	TL0=	0x00;
	TR0=	ON;			/* Start timer			*/
	K_CTRL&=0xF0;			/* Pull controll lines down	*/
}

bit	test_cbkey	( void )	/* Nonblocking test for keypress*/
{
	return	( newkey );		/* Return keypress flag		*/
}

char	read_cbkey	( void )	/* Wait for keypress, return it	*/
{
	while	( !newkey );		/* Wait for keypress		*/
	newkey=	OFF;			/* Reset flag			*/
	return	( key_in );		/* Return keypad buffer		*/
}

void	storekey	( void )	/* Low level keypad read	*/
{
byte	x, y;
byte	i;
byte	row=	0;
byte	column= 0;
	for	( i= 0; i< K_COLM; i++ )/* Check each Column		*/
	{
		if (!( K_MON& mask[i] ))/* Column is low		*/
			y= i;		/* Set column number		*/
	}
	K_CTRL|=0x0F;			/* Pull control lines high	*/
	for	( i= 0; i< K_ROWS; i++ )/* Check each row		*/
	{
		K_CTRL&=~mask[i];	/* Pull row low			*/
		if ( ~K_MON& K_MASK )	/* Row is switched		*/
			x= i;		/* Set row number		*/
		K_CTRL|=mask[i];	/* Pull row high again		*/
	}
	K_CTRL&=0xF0;			/* Reset control lines		*/
	if	( ~K_MON& K_MASK )	/* Key still valid		*/
	{
		key_in=	K_COLM* x+ y;	/* Assign keycode		*/
		newkey=	ON;		/* Set new keypress flag	*/
	}
}

void	t0_int	( void ) interrupt 1	/* Keypad sampler interrupt	*/
{
	if	( ~K_MON& K_MASK )	/* Press detect			*/
		keysum++;		/* Notch one up			*/
	if	( ++keycount== K_SS )	/* Sample over			*/
	{
		if ( keysum >= K_ON ) 	/* Above threshold "ON"		*/
		{
			if (!keystate)	/* Change of state: Key Down	*/
			{
			   storekey( );	/* Put character in buffer	*/
			   keystate= ON;/* Store state			*/
			}
		}
		if ( keysum <= K_OFF )	/* Below threshold "OFF"	*/
		{
			if ( keystate )	/* Change of state: Key Up	*/
			   keystate=OFF;/* Store state			*/
		}
		keycount= 0;		/* Reset sample counter		*/
		keysum=	0;		/* Reset sum			*/
	}
}