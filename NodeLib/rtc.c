/*			Copyright Q Solutions				*/
/*	File:		rtc.c						*/
/*	Programmer:	MoT						*/
/*	Module:		I2C Bus PCF8583 Real Time Clock Handler		*/
/*									*/
/*			History						*/
/* 21:02 12/04/1997  	Cleanup						*/
/* To Do:		_Realy_ clean up :)				*/

#include	<reg552.h>
#include	<stdio.h>
#include	<iic.h>
#include	<wdog.h>

#define		RTC_R		0xA1		/* PCF8583 read		*/
#define		RTC_W		0xA0		/* PCF8583 write	*/

typedef unsigned char byte;
typedef unsigned int uint;

bit	init_rtc	(  void )		/* RTC answering	*/
{
char	idata	set[2];
	set[0]=	0x0;				/* Word Address		*/
	set[1]=	0x0C;				/* Status Control Reg	*/
	iic_mstart( RTC_W, 2, set );		/* Send Control Reg	*/
	return	( iic_wait( ) );		/* Wait for Transmission*/
}

bit	show_time	( void )		/* Prints time		*/
{
char	idata	time[5];
	time[0]=0x0;
	iic_mstart	( RTC_W, 1, time );	/* Reset pointer	*/
	if	( !iic_wait	( ) )		/* Wait for transmission*/
		return	( 0 );
	iic_mstart	( RTC_R, 5, time );	/* Read time		*/
	if	( !iic_wait	( ) )		/* Wait for transmission*/
		return	( 0 );
	printf	( "%02bX:%02bX:%02bX",		/* Print time		*/
		time[4], time[3], time[2] );
	return	( 1 );				/* Success		*/
}

bit	show_date	( void )		/* Prints date 		*/
{
char	idata	date[2];
	date[0]=0x00;
	iic_mstart	( RTC_W, 1, date );	/* Reset pointer	*/
	if	( !iic_wait	( ) )		/* Wait for transmission*/
		return	( 0 );
	iic_mstart	( RTC_R, 8, date );	/* Read date		*/
	if	( !iic_wait	( ) )		/* Wait for transmission*/
		return	( 0 );
	printf	( "%02bX/%02bX", date[6], date[5] );
	return	( 1 );				/* Sucess		*/
}

bit	range_getkey	( char in_key, char cursor_pos )
{	
	switch ( cursor_pos )
	{
		case ( 0 ) : if (in_key <= 2 ) return ( 1 ); break;
		case ( 1 ) : if (in_key <= 9 ) return ( 1 ); break;
		case ( 2 ) :
		case ( 4 ) : if (in_key <= 5 ) return ( 1 ); break;
		case ( 3 ) :
  		case ( 5 ) : if (in_key <= 9 ) return ( 1 ); break;
	}
	return	( 0 );
}

void	prompt_time	( )
{
	printf	( " Time: HH:MM:SS" );
}

bit	get_time	( )			/* Assume no alarm int	*/
{
char	idata	in, busy= 1, cursor= 0;
char	idata	time[4];
char	buffer[6];
//	set_lcd	( LINE_2 );			
//	set_lcd	( LINE_2+ 7 );
//	set_lcd	( 0x0F );
	while	( cursor< 6 )
	{
		in=	getkey	( );
		if	( range_getkey( in, cursor ))
		{
			buffer[ cursor ]= in;
			printf	( "%bX", in );
			if(( cursor== 1 )|| ( cursor== 3 ))
				printf	( ":" );
			cursor++;
		}
	}
	time[0]=	2;
	time[3]= 16* buffer[0]+ buffer[1];
	time[2]= 16* buffer[2]+ buffer[3];
	time[1]= 16* buffer[4]+ buffer[5];
	if	((time[3] <= 0x23) && (time[2] <= 0x59) && (time[1] <= 0x59))
	{
		iic_mstart	( RTC_W, 4, time );
		iic_wait	( );		/* Wait for transmission*/
//		set_lcd		( CLEAR );
//		time[0]	= 0;
//		set_lcd	( 0x0C );
		return	( 1 );
	}
	return	( 0 );
}

bit	test_alarm	( )
{
char	idata	test=0;
	iic_mstart	( RTC_W, 1, &test );	/* Set pointer		*/
	iic_wait	( );			/* Wait for transmission*/
	iic_mstart	( RTC_R, 1, &test );	/* Read register	*/
	iic_wait	( );			/* Wait for transmission*/
	if	( !(test & 0x02) ) return ( 1 );
	return	( 0 );
}