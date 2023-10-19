/************************************************************************/
/*		DEMO.F : Demonstration Code for uNode3			*/
/*		M.J.Colley '92						*/
/************************************************************************/

#include	<inc.c>
#define		A_REG		((char *) 0x28400L )
#define		B_REG		((char *) 0x28401L )
#define		DEC_REG		((char *) 0x28402L )
#define		STAT_REG	((char *) 0x28404L )
#define		POW_REG		((char *) 0x28405L )
#define		ENC_REG		((char *) 0x28406L )
#define		A_INIT		0x49
#define		B_INIT		0x57
#define		A_REC		0x48
#define		B_REC		0x17
#define		A_PLAY		0x49
#define		B_PLAY		0x07
#define		EDR_MASK	0x01
#define		DDR_MASK	0x02
#define		PR_MASK		0x04
#define		EO_MASK		0x08
#define		DO_MASK		0x10
#define		PO_MASK		0x20


#define	s_dat	(( char * ) 0x24000L )


date	d1;
time	t1;
bit	int3_flag, int4_flag;
char	page;
char	idata	sr0, sr1, sr2, sr3, sr4, sr5;
	init_int	( )
{
	EX1	= 1;				/* ENABLE XINT1		*/
	IT1	= 1;				/* XINT1 -> edge int	*/
	ECT1	= 1;			/* CAL REQ ENABLE CAP1 INT (3)	*/
	ECT2	= 1;			/* CVSD    ENABLE CAP2 INT (4)	*/
	CTCON	= 0x28;				/* CAP1 INT falling edge*/
	EA	= 1;				/* ENABLE GLOBAL INT	*/
	PX1	= 0;				/* EX1 -> LOW PRIORITY	*/
}
	init_CVSD	( )
{
char	temp;
	sr0=	*STAT_REG;
	*A_REG= A_INIT;
	*B_REG= B_INIT;
	temp=	*DEC_REG;
	temp=	*POW_REG;
	*DEC_REG= temp;
	sr1=	*STAT_REG;
}

	init		( )
{
	init_int ( );
	init_sio0( );
	init_lcd ( );
	sio1_init( 0x31 );
	init_RTC ( );
	init_CVSD( );
}

	toggle_P4_4	( )
{
	P4_4= ( P4_4 ) ? 0 : 1;
}

	record		( )
{
char	idata	stat_reg, enc_reg;
int	idata	index= 0;
	P4_4=	0;
	*B_REG= B_REC;
	*A_REG= A_REC;
	enc_reg=*ENC_REG;
	while	( index < 0x3FFF )
	{
		if	( *STAT_REG & (EDR_MASK | EO_MASK))
		{	
			s_dat[ index ]=	*ENC_REG;
			index++;
		}
		P4_4=	1;
		while	( !int4_flag );
		P4_4=	0;
		int4_flag=0;
	}
	set_lcd	( LINE_2 + 4 );		putchar	( 'B' );
	set_lcd	( LINE_2 + 2 );		putchar	( ' ' );
	set_lcd	( LINE_2 + 5 );		printf	( "%04X", index );
	*A_REG= A_INIT;
	*B_REG= B_INIT;
}

	playback	( )
{
char	idata	stat_reg, dec_reg;
int	idata	index= 0;
	*B_REG= B_PLAY;
	*A_REG= A_PLAY;
	*DEC_REG=0;
	while	( index < 0x3FFF )
	{
		if	( *STAT_REG & ( DDR_MASK | DO_MASK ))
		{	
			*DEC_REG=	s_dat[index];
			index++;
		}
		P4_4=	1;
		while	( !int4_flag );
		P4_4=	0;
		int4_flag=0;
	}
	set_lcd	( LINE_2 + 3 );	putchar	( ' ' );
	*A_REG= A_INIT;
	*B_REG= B_INIT;
}

	service_pad	( char in )
{
	x1_flag=0;
	switch	( in )	
	{
	case 0x01:	set_lcd	( LINE_2 + 2 );	putchar	( 'R' );
			record	( );
			break;
	case 0x03:	set_lcd	( LINE_2 + 3 );	putchar	( 'P' );
			playback( );
			break;
	case 0x0C:	while	( !get_time( ) );	break;
	}
}

	cvsd_int	( ) interrupt 8
{
	CTI2=	0;
	toggle_P4_4	( );
	int4_flag=1;
}

	calibrate 	( ) interrupt 7
{
	int3_flag=1;
	CTI1=	0;
}

	loop_cvsd	( )
{
char	idata	stat, enc, dec, pow;
	sr2=	*STAT_REG;
	*A_REG=	A_PLAY;
	*B_REG= B_PLAY;
	enc=	*ENC_REG;
	*DEC_REG=enc;
	pow=	*POW_REG;
	sr3=	*STAT_REG;
}

	main		( )
{
	init	( );
	while	( 1 )
	{
		loop_cvsd( );
		if	( x1_flag && test_x1 ())
			service_pad	((*KPAD)-240 );
		if	( int3_flag )
		{
			set_lcd	( LINE_2 );	putchar	( '3' );
			int3_flag=0;
		}
		set_lcd	( LINE_1 );
		printf	( "%02bX %02bX %02bX %02bX", sr0, sr1, sr2, sr3 );
		getkey	( );
	}
}