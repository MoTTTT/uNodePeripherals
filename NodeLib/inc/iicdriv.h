/*			Copyright Q Solutions				*/
/*	File:		iic.h						*/
/*	Programmer:	MoT						*/
/*	Module:		IIC Bus Low Level Routines			*/
/*									*/
/*			History						*/
/* 19:36 12/04/1997 	Cleanup						*/
/*									*/

extern	bit	iic_mready;	/* Master transmission flag		*/
extern	bit	iic_sready;	/* Slave reception flag			*/
void	iic_mstart	( char addr, char length, char idata *d_ptr );
void	iic_sset	( char idata *d_ptr, char length );
void	iic_init	( char own_slave_addr );

