/*			Copyright Q Solutions				*/
/*	File:		rtc.c						*/
/*	Programmer:	MoT						*/
/*	Module:		I2C Bus PCF8583 Real Time Clock Handler		*/
/*									*/
/*			History						*/
/* 21:02 12/04/1997  	Cleanup						*/
/* To Do:		_Realy_ clean up :)				*/
/* 18:17pm 07-05-1997 	Rewrite start					*/
/*									*/

#include	<reg552.h>
#include	<iic.h>

#define		RTC_R		0xA1		/* PCF8583 read		*/
#define		RTC_W		0xA0		/* PCF8583 write	*/

typedef unsigned char byte;
typedef unsigned int uint;
typedef	struct { byte h; byte m; byte s; } time;/* Time Structure	*/
typedef	struct { byte d; byte m; } date;	/* Date Structure	*/

byte	idata	rtc_dat[10];			/* Data buffer		*/

bit	init_rtc	(  void )		/* RTC answering	*/
{
	rtc_dat[0]=	0x0;			/* Word Address		*/
	rtc_dat[1]=	0x0C;			/* Status Control Reg	*/
	iic_mstart( RTC_W, 2, rtc_dat );	/* Send Control Reg	*/
	return	( iic_wait( ) );		/* Wait for Transmission*/
}

bit	set_time	( time *out )		/* Store time in rtc	*/
{
	if	((out.h> 0x23)|| (out.m> 0x59)|| (out.s> 0x59))
		return	( 0 );			/* Out of range		*/
	rtc_dat[0]=	2;			/* Set up pointer	*/
	rtc_dat[3]=	out.h;			/* Put hours in buffer	*/
	rtc_dat[2]=	out.m;			/* Put minutes in buffer*/
	rtc_dat[1]=	out.s;			/* Put seconds in buffer*/
	iic_mstart	( RTC_W, 4, rtc_dat );	/* Start transmission	*/
	if		(iic_wait ( ))		/* Wait for transmission*/
		return	( 1 );			/* Success		*/
	return	( 0 );				/* Transmission failed	*/
}

bit	get_time	( time *in )		/* Store time in struct	*/
{
	rtc_dat[0]=0x0;				/* Set up pointer data	*/
	iic_mstart	( RTC_W, 1, rtc_dat );	/* Reset pointer	*/
	if	( !iic_wait	( ) )		/* Wait for transmission*/
		return	( 0 );			/* Return fail		*/
	iic_mstart	( RTC_R, 5, rtc_dat );	/* Read time		*/
	if	( !iic_wait	( ) )		/* Wait for transmission*/
		return	( 0 );			/* Return fail		*/
	in.h=	rtc_dat[4];			/* Store hours		*/
	in.m=	rtc_dat[3];			/*   minutes		*/
	in.s=	rtc_dat[2];			/*   seconds		*/
	return	( 1 );				/* Return sucess	*/
}

bit	get_date	( date *in )		/* Store date in struct	*/
{
	rtc_dat[0]=0x00;
	iic_mstart	( RTC_W, 1, rtc_dat );	/* Reset pointer	*/
	if	( !iic_wait	( ) )		/* Wait for transmission*/
		return	( 0 );
	iic_mstart	( RTC_R, 8, rtc_dat );	/* Read date		*/
	if	( !iic_wait	( ) )		/* Wait for transmission*/
		return	( 0 );
	in.d=	rtc_dat[6];			/* Store days		*/
	in.m=	rtc_dat[5];			/* Store months		*/
	return	( 1 );				/* Sucess		*/
}

bit	test_alarm	( )
{
	iic_mstart	( RTC_W, 1, rtc_dat );	/* Set pointer		*/
	iic_wait	( );			/* Wait for transmission*/
	iic_mstart	( RTC_R, 1, rtc_dat );	/* Read register	*/
	iic_wait	( );			/* Wait for transmission*/
	if	( !( rtc_dat[0]& 0x02 ) ) return ( 1 );
	return	( 0 );
}