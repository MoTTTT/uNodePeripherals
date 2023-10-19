/*			Copyright Q Solutions				*/
/*	File:		serial.h					*/
/*	Programmer:	MoT						*/
/*	Module:		uNode Serial Port routines 			*/
/*									*/

#ifndef BYTETYPE
#define BYTETYPE
typedef unsigned char byte;		/* Optimise index maths		*/
#endif

#define		B19200	0xFD		/* Serial Port Baud rate	*/

extern char s_tbuf[];			/* Serial transmit buffer	*/
extern char s_rbuf[];			/* Serial recieve buffer	*/
extern bit s_rnew;			/* Serial Buffer : Frame Rx flag*/
extern byte s_rlen;			/* Serial Buffer : Rx length	*/

char	sputchar	( char in );	/* Print char to serial buffer	*/
void	init_serial	( char th1 );	/* Initialise Serial Port	*/
void	s_rxh		( void );	/* Serial port frame handler	*/

