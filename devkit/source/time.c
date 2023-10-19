/*			Copyright Q Solutions				*/
/*	File:		time.c						*/
/*	Programmer:	MoT						*/
/*	Module:		Time related functions				*/
/*									*/
/*			History						*/
/* 20:44pm 07-05-1997  	Extracted from rtc.c (time.c)			*/
/*									*/

typedef unsigned char byte;
typedef unsigned int uint;
#include	<stdio.h>
#include	<rtc.h>

byte	bcd2byt	( byte hex )			/* BCD to byte converter*/
{
	return	( 10* (( hex& 0xF0)/16 )+ ( hex& 0x0F ) );
}

long	tim2lng	( time *t )			/* Time to total seconds*/
{
long	l;
	l=	bcd2byt( t.s );			/* Times packed in BCD	*/
	l+=(long)bcd2byt( t.m )* 60;		/* Add minutes		*/
	l+=(long)bcd2byt( t.h )* 60* 60;	/* Add hours		*/
	return	( l );				/* Return result	*/
}

long	dif_time ( time *t1, time *t2 )		/* Calculate time diff	*/
{
long	d;
	d=	tim2lng(t1)- tim2lng(t2);	/* First less second	*/
	if	( d< 0 )			/* 24 hour rollover	*/
		d+= 60* 60* 24;
	return	( d );
}

void	print_time	( time *out )		/* Print the time	*/
{
	printf	( "%02bX:%02bX:%02bX",		/* Print time hh:mm:ss	*/
		out.h, out.m, out.s );
}

void	print_date	( date *out )		/* Print the date	*/
{
	printf	( "%02bX/%02bX",		/* Print date dd/mm	*/
		out.d, out.m );
}

bit	show_time	( void )		/* Prints time		*/
{
time	t;
	if	( ! get_time ( &t ) )		/* Get the time		*/
		return	( 0 );
	print_time ( &t );
	return	( 1 );				/* Success		*/
}

bit	show_date	( void )		/* Prints date 		*/
{
date	d;
	if	( ! get_date ( &d ) )		/* Get the time		*/
		return	( 0 );
	print_date ( &d );
	return	( 1 );				/* Success		*/
}