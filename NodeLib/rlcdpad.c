/*			Copyright Q Solutions				*/
/*	File:		lcdpad.c					*/
/*	Programmer:	MoT						*/
/*	Module:		IIC bus LcdPad module				*/
/*									*/
/*			History						*/
/* 22:12 20/04/1997    	Cleanup						*/
/*									*/

#include	<stdio.h>
#include	<iic.h>
#include	<wdog.h>
/*				Public					*/
#define		PING	100		/* LcdPad test byte		*/
#define		RL_RST	0x00		/* Reset LCD			*/
#define		RL_CTR	0x01		/* Write control to LCD		*/
#define		RL_DAT	0x02		/* Write data to LCD		*/
#define		RL_CLR	0x01		/* Clear LCD			*/
#define		RL_L1	0x80		/* Cursor to line 1		*/
#define		RL_L2	0xC0		/* Cursor to line 2		*/

const char k_map[]=	{ 'C', 'E', '.', '0', '*',	/* Keycode to	*/
			  'D', 'U', '9', '8', '7',	/* character	*/
			  126, 127, '6', '5', '4',	/* mapping	*/
			  'O', 'R', '3', '2', '1' };

void	init_rkpad	( void );	/* Init Remote Key Pad		*/
bit	init_rlcd	( void );	/* Rem LCD to defaults, clear	*/
void	set_rlcd	( char in );	/* Control Remote LCD		*/
char	rputchar	( char out );	/* Send char to remote LCD	*/
void	paint_rlcd	( char*l1, char*l2 );	/* Splash Screen	*/
bit	test_rkey	( void );	/* Test for keypress		*/
char	rgetkey		( void );	/* Get keypress from remote pad	*/

bit	rlcd_data= 1;			/* Remote LCD DATA flag		*/

/*				Private					*/
#define	RLCC_WAIT	0x0100		/* Wait period: Reset LCD	*/
#define	RLCD_WAIT	60		/* Wait period: Putchar		*/
#define	RL_ADR		0x60		/* LcdPad Module Address	*/

char idata iic_in[2];			/* IIC Bus input buffer		*/
char idata iic_out[2];			/* IIC Bus output buffer	*/
typedef	unsigned char byte;

void	paint_rlcd ( char* l1, char* l2 )/* Splash Screen		*/
{
	set_rlcd	( RL_L1 );	/* Goto Line 1			*/
	printf		( l1 );		/* Print first line		*/
	set_rlcd	( RL_L2 );	/* Goto Line 2			*/
	printf		( l2 );		/* Print second line		*/
}

bit	init_rlcd	( void )	/* Rem LCD to defaults, clear	*/
{
int	wait= RLCC_WAIT;
	iic_out[0]= 0;			/* Set command= Reset		*/
	iic_out[1]= 0xAA;		/* Copy control byte to buffer	*/
	if (!iic_mtx(RL_ADR,2,iic_out))	/* Send frame			*/
		return ( 0 );		/* Return error			*/
	while	( wait-- )		/* Wait for remote unit		*/
	{
		wdog	( 10 );		/* Refresh watchdog		*/
	}
	return	( 1 );			/* Return 			*/
}

void	init_rkpad	( void )	/* Initialise Remote Keypad	*/
{
	iic_sset	( iic_in, 1 );	/* Set up slave input buffer	*/
}

char	rputchar	( char out )	/* Send char to remote LCD	*/
{
byte	i= RLCD_WAIT;
	if	( rlcd_data )		/* Data to remote LCD		*/
	{
		iic_out[0]= 2;		/* Set command= DATA		*/
		iic_out[1]= out;	/* Copy data into buffer	*/
		iic_mtx(RL_ADR, 2, iic_out );	/* Send frame		*/
		while	( i-- );	/* Wait for remote unit		*/
	}
	else				/* Control to remote LCD	*/
	{
		iic_out[0]= 1;		/* Set command= Control		*/
		iic_out[1]= out;	/* Copy control byte to buffer	*/
		iic_mtx(RL_ADR, 2, iic_out );	/* Send frame		*/
		while	( i-- );	/* Wait for remote unit		*/
	}
	return	( out );
}

void	set_rlcd	( char in )	/* Control Remote LCD		*/
{
	rlcd_data=	0;		/* Set output stream to control	*/
	rputchar	( in );		/* Send control character	*/
	rlcd_data=	1;		/* Set output stream to data	*/
}

bit	test_rkey	( void )	/* Test for keypress		*/
{
	return	( iic_sready );		/* Return slave reception flag	*/
}

char	rgetkey		( void )	/* Get keypress from remote pad	*/
{
	while	( !iic_sready );	/* Wait for slave reception	*/
	iic_sready=	0;		/* Reset reception flag		*/
	if	( iic_in[0]== PING )	/* If test for Acknowledge	*/
		return	( PING );	/* Don't map			*/
	return	( k_map[iic_in[0]] );	/* Return mapped key		*/
}