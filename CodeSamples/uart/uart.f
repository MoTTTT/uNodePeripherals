/*			Project:	Maritel				*/
/*			File:		UART.F				*/
/*			Programmer:	M.J.Colley			*/

#include	< testinc.c >

/*				Mediation states			*/
#define		IDLE	0		/* Mediation device Idle	*/
#define		RX485	1		/* Recieving on RS485 bus	*/
#define		P_R485	2		/* Process RS485 Rx frame	*/
#define		P_T232	3		/* Process RS232 Tx frame	*/
#define		TX232	4		/* Transmitting on RS232 bus	*/
#define		W_R232	5		/* Waiting for RS232 revertive	*/
#define		RX232	6		/* Recieving on RS232 bus	*/
#define		P_R232	7		/* Process RS232 Rx frame	*/
#define		P_T458	8		/* Process RS485 Tx frame	*/
#define		TX485	9		/* Transmitting on RS485 bus	*/

char	med_stat= IDLE;			/* Med device state variable	*/

char	ADDR[2];			/* Mediation device address	*/

char	com1[2];
char	com2[2];

void	wait		( long	T )	/* Wait routine			*/
{
long	t;
	for	( t= 0; t< T; t++ );
}

	init		( )		/* Initialisation Routine	*/
{
	EX1	= 1;				/* ENABLE XINT1		*/
	EX0	= 1;				/* ENABLE UART INT ( 0 )*/
	ES0	= 1;				/* ENABLE RS232 int	*/
	IT1	= 1;				/* XINT1 -> edge int	*/
	IT0	= 1;				/* XINT0 -> edge int	*/
	EA	= 1;				/* ENABLE GLOBAL INT	*/
	PX1	= 0;				/* EX1 -> LOW PRIORITY	*/
	init_sio0( );				/* INIT RS232 PORT	*/
	wait	( 0xF0 );
	init_uart( );
}

	f_error		( char err_no )
{
	if	( !err_no )	return;
	set_lcd	( CLEAR );
	set_lcd	( LINE_1 );
	printf	( "  ERROR [%03bd]", err_no );
}

	command1	( )
{
	set_lcd	( LINE_1 );
	printf	( " COM1 " );
	txa_frame[0]= 0x00;
	txa_frame[1]= 0xDF;
	txa_frame[2]= 0x8A;
	txa	( 3 );
}

	command2	( )
{
	set_lcd	( LINE_1 );
	printf	( " COM2 " );
	txa_frame[0]= 0x00;
	txa_frame[1]= 0xDC;
	txa_frame[2]= 0x10;
	txa	( 3 );
}

char	proc_frame	( )
{
	if	( rxb_frame[0] != ':' )		return	( 1 );
	if	( rxb_frame[1] != ADDR[0] )	return	( 2 );
	if	( rxb_frame[2] != ADDR[1] )	return	( 2 );
	set_lcd	( LINE_2 );
	printf	( "Command: %c%c", rxb_frame[3], rxb_frame[4] );
	if	( !strncmp( &rxb_frame[3], com1, 2 ))
		command1( );
	if	( !strncmp( &rxb_frame[3], com2, 2 ))
		command2( );
	return	( 0 );
}

	main	( )
{
char	cu, cl;
	init	( );
	set_lcd	( CLEAR );
	printf	( "UART TEST" );
	txa_frame[23]=	0x0D;
	txa_frame[24]=	0x0A;
	while	( 1 )	
	{
		if	( rxa_stat== TOUT )
		{
			set_lcd	( LINE_1 );
			printf	( "Rx A:%02d", rxa_ptr );
			rxa_stat=	IDLE;
			rxa_ptr=	0;
		}
		if	( rxb_stat== TOUT )
		{
			set_lcd	( LINE_1+ 8 );
			printf	( "Rx B:%02d", rxb_ptr );
			rxb_stat=	IDLE;
			rxb_ptr=	0;
		}
		if	( txa_stat== FIN )
		{
			set_lcd	( LINE_2 );
			printf	( "Tx A:%02d", txa_len );
			txa_stat=	IDLE;
		}
		if	( txb_stat== FIN )
		{
			set_lcd	( LINE_2 );
			printf	( "Tx B:%02d", txb_len );
			txa_stat=	IDLE;
		}
		if	( x1_flag )
		{
			getkey	( );
			txa	( 25 );
		}
	}
}