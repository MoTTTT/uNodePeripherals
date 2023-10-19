/*			Copyright Q Solutions				*/
/*	File:		iic.h						*/
/*	Programmer:	MoT						*/
/*	Module:		I2C Bus Wrapper routines header file		*/
/*									*/
/*			History						*/
/* 12:45 20/04/1997  	Written from scratch.				*/
/*									*/

#include	<iicdriv.h>			/* IIC asm routines	*/

void	init_iic	( char addr );		/* Initialise I2C bus	*/
bit	iic_wait	( void );		/* Timed out wait for Tx*/
bit	iic_mtx					/* Master Tx; 1: success*/
			( char addr, 		/* IIC bus dest address	*/
			  char length, 		/* Transmission length	*/
			  char idata *out );	/* Output buffer	*/

