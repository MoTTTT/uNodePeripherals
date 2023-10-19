/*			Copyright Q Solutions				*/
/*	File:		iic.c						*/
/*	Programmer:	MoT						*/
/*	Module:		IIC Bus Wrapper routines			*/
/*									*/
/*			History						*/
/* 12:45 20/04/1997  	Written from scratch.				*/
/*									*/

#include	<iicdriv.h>	/* IIC low level routines		*/

typedef	unsigned char byte;	/* Optimise compiled code		*/

void	init_iic	( char addr );		/* Initialise I2C bus	*/
bit	iic_wait	( void );		/* Timed out wait for Tx*/
bit	iic_mtx					/* Master Tx; 1: success*/
		( char addr, 			/* IIC bus dest address	*/
		  char length, 			/* Transmission length	*/
		  char idata *out );		/* Output buffer	*/

void	init_iic	( char addr )		/* Initialise I2C bus	*/
{
	iic_init ( addr );
}

bit	iic_wait	( void )		/* Wait for transmission*/
{
byte	i= 1;
	while	( i++ )				/* Wait for transmission*/
	{
		if	( iic_mready )		/* Success		*/
			return	( 1 );		/* Return True		*/
	}
	return	( 0 );
}

bit	iic_mtx	( char addr, char length, char idata *out )
{
	iic_mstart	( addr, length, out );
	return	( iic_wait ( ) );
}