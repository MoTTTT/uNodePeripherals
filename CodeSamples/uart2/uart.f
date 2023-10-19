/*			Project:	Maritel				*/
/*			File:		UART.F				*/
/*			Programmer:	M.J.Colley			*/

#include	< testinc.c >

/*				Mediation states			*/
/*		IDLE	0	*/	/* Mediation device Idle	*/
#define		RX485	1		/* Frame recieved on RS485 bus	*/
#define		P_R485	2		/* Process RS485 Rx frame	*/
#define		P_T485	3		/* Process RS485 Tx frame	*/
#define		TX485	4		/* Transmitting on RS485 bus	*/

/*				Equipment states			*/
/*		IDLE	0	*/	/* Equipment comms idle		*/
#define		P_T232	1		/* Process RS232 Tx frame	*/
#define		TX232	2		/* Transmitting on RS232 bus	*/
#define		W_R232	3		/* Waiting for RS232 revertive	*/
#define		RX232	4		/* Recieving on RS232 bus	*/
#define		P_R232	5		/* Process RS232 Rx frame	*/

char	med_stat= IDLE;			/* Med device state variable	*/
char	equ_stat= IDLE;			/* Equip comms state		*/
bit	command= 0;			/* Mediation command flag	*/

char	ADDR[2];			/* Mediation device address	*/

char	com1[2];
char	com2[2];

char	fsize_a, fsize_b;

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

bit	check_addr	( )
{
	if	( rxb_frame[0] != ':' )		return	( 0 );
	if	( rxb_frame[1] != ADDR[0] )	return	( 0 );
	if	( rxb_frame[2] != ADDR[1] )	return	( 0 );
	return	( 1 );
}

void	proc_r485	( )
{
	set_lcd	( LINE_2 );
	printf	( "Command: %c%c", rxb_frame[3], rxb_frame[4] );
	if	( !strncmp( &rxb_frame[3], com1, 2 ))
		command1( );
	if	( !strncmp( &rxb_frame[3], com2, 2 ))
		command2( );
}

void	proc_t485	( )
{
}

void	proc_t232	( )
{
}

void	proc_r232	( )
{
}


	main	( )
{
char	inkey;
	init	( );
	set_lcd	( CLEAR );
	printf	( "Mediation Device" );
	set_lcd	( LINE_2 );
	printf	( "      Test      " );
	txa_frame[23]= 0x0D;
	txb_frame[23]= 0x0D;
	txa_frame[24]= 0x0A;
	txb_frame[24]= 0x0A;
	while	( 1 )	
	{
		if	( x1_flag )
		{
			inkey=	getkey	( );
			set_lcd	( CLEAR );
			set_lcd	( LINE_1 );
			printf	( "%02bX", inkey );
			switch	( inkey )
			{
			case 0x00:	med_stat=	IDLE;
					equ_stat=	IDLE;
					break;
			case 0x01:	med_stat=	P_T485;
					break;
			case 0x02:	command=	1;
					break;
			case 0x03:	equ_stat=	W_R232;
					rxa_len=	3;
			}
		}
		switch	( med_stat )
		{
		case IDLE:	if	( b_stat== TOUT_RX )
				{
					set_lcd	( LINE_1+ 8 );
					printf	( "Rx B:%02bd", rxb_len );
					med_stat= RX485;
				}
				break;
		case RX485:	if	( check_addr( ) )
				{
					med_stat= P_R485;
				}
				else
				{
					b_stat= WAIT_RX;
					med_stat= IDLE;
				}
				break;
		case P_R485:	proc_r485( );
				med_stat= P_T485;
				break;
		case P_T485:	proc_t485( );
				med_stat= TX485;
				fsize_b=  25;
				txb	( fsize_b );
				break;
		case TX485:	if	( b_stat== WAIT_RX )
				{
					med_stat= IDLE;
					set_lcd	( LINE_2+ 8 );
					printf	( "Tx B:%02bd", txb_len );
				}
				break;
		}
		switch	( equ_stat )
		{
		case IDLE:	if	( command )
				{
					equ_stat= P_T232;
					command= 0;
				}
				break;
		case P_T232:	proc_t232( );
				equ_stat= TX232;
				fsize_a=  25;
				txa	( fsize_a );
				break;
		case TX232:	if	( a_stat== WAIT_RX )
				{
					set_lcd	( LINE_2 );
					printf	( "Tx A:%02bd ", txa_len );
					equ_stat= W_R232;
				}
				break;
		case W_R232:	if	( a_stat== BUSY_RX )
				{
					equ_stat= RX232;
				}
				break;
		case RX232:	if	( rxa_ptr== rxa_len )
				{
					set_lcd	( LINE_1 );
					printf	( "Rx A:%02bd ", rxa_ptr );
					equ_stat= P_R232;
					rxa_ptr= 0;
				}
				break;
		case P_R232:	proc_r232( );
				equ_stat=	IDLE;
				break;
		}
	}
}