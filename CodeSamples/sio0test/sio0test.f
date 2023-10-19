//	Project:	Maritime Radio
//	File:		Sio0Test.f
//	Programmer:	M.J.Colley

#include	< testinc.c >

char	idata	ADDR[]= { "01" };
char	idata	RX_busy;
char	idata	RX_complete;
char	xdata	frame[16384];
unsigned int	ram_index= 0;
unsigned int	f_size;

	init		( )
{
	EX1	= 1;				/* ENABLE XINT1		*/
	ES0	= 1;				/* ENABLE RS232 int	*/
	ET0	= 1;				/* ENABLE T0 OV int	*/
	IT1	= 1;				/* XINT1 -> edge int	*/
	EA	= 1;				/* ENABLE GLOBAL INT	*/
	PX1	= 0;				/* EX1 -> LOW PRIORITY	*/
	PT0	= 1;				/* T0  -> HIGH PRIORITY	*/
	PS0	= 0;				/* SIO -> HIGH PRIORITY	*/
	init_sio0( );				/* INIT RS232 PORT	*/
}

	timeout		( ) interrupt 1		/* T0 Interrupt routine	*/
{
	TR0=		0;
	RX_complete=	1;
	RX_busy=	0;
	f_size=		ram_index;
	ram_index=	0;
}

	f_error		( char err_no )
{
	if	( !err_no )	return;
	set_lcd	( CLEAR );
	set_lcd	( LINE_1 );
	printf	( "  ERROR [%03bd]" );
	RX_complete=	0;
}

char	proc_frame	( )
{
	if	( frame[0] != ':' )	return	( 1 );
	if	( frame[1] != ADDR[0] )	return	( 2 );
	if	( frame[2] != ADDR[1] ) return	( 2 );
///
	set_lcd	( CLEAR );
	set_lcd	( LINE_2 );
	printf	( "Command: %c%c", frame[3], frame[4] );
	RX_complete=	0;
	return	( 0 );
}

	write_bytes	( )
{
unsigned char	i;
	set_lcd	( LINE_2 );
	printf	( " Bytes RX: %d ", f_size );
	set_lcd	( LINE_1 );
	printf	( " Press to View  " );
	if	( x1_flag )
	{
		getkey	( );
		set_lcd	( CLEAR );
		set_lcd	( LINE_2 );
		for	( i= 0; i<=f_size; i++ )
			printf	( "%c", frame[i] );
		RX_complete=0;
	}
}

	RX_code		( ) interrupt 4 using 3	/* SIO1 Interrupt 	*/
{
	RX_busy= 1;
	TR0=	1;				/* START TIMEOUT CLOCK	*/
	RI=	0;				/* RESET RI		*/
	TH0=	0x00;				/* RESET T0		*/
	frame[ ram_index ]= S0BUF;
	ram_index++;
}

	main	( )
{
	init	( );
	set_lcd	( CLEAR );
	printf	( "sio0test" );
	while	( 1 )	
	{
		if	( RX_complete )
		{
			f_error	( proc_frame	( ));
		}
	}
}