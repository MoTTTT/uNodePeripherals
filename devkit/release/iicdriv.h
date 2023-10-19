/*			Copyright Q Solutions				*/
/*	File:		iicdriv.h					*/
/*	Programmer:	MoT						*/
/*	Module:		IIC Bus Low Level Routines			*/
/*									*/

extern	bit	iic_mready;	/* Master transmission flag		*/
extern	bit	iic_sready;	/* Slave reception flag			*/
void	iic_mstart	( char addr, char length, char idata *d_ptr );
void	iic_sset	( char idata *d_ptr, char length );
void	iic_init	( char own_slave_addr );