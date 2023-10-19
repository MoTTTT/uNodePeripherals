/*	File:		UM2681_1.H	Header file for DUART		*/
/*	Programmer:	M.J.Colley					*/

/*			Register Addresses				*/

#define		UART	(( char *) 0x28400L )	/* Base Address of UART	*/
#define		MR1A	0			/* R/W Mode Reg 1 A	*/
#define		MR2A	0			/* R/W Mode Reg 2 A	*/
#define		SRA	1			/* R Status Reg A	*/
#define		CSRA	1			/* W Clock Sel Reg A	*/
#define		CRA	2			/* W Command Reg A	*/
#define		RHRA	3			/* R RX Holding Reg A	*/
#define		THRA	3			/* W TX Holding Reg A	*/
#define		IPCR	4			/* R Input Port Change	*/
#define		ACR	4			/* W Aux. Control	*/
#define		ISR	5			/* R Interrupt Status	*/
#define		IMR	5			/* W Interrupt Mask	*/
#define		CTU	6			/* R Count/Timer Upper	*/
#define		CTUR	6			/* W C/T Upper		*/
#define		CTL	7			/* R C/T Lower		*/
#define		CTLR	7			/* W C/T Lower		*/
#define		MR1B	8			/* R/W Mode Reg 1 B	*/
#define		MR2B	8			/* R/W Mode Reg 2 B	*/
#define		SRB	9			/* R Status Reg B	*/
#define		CSRB	9			/* W Clock Select B	*/
#define		CRB	10			/* W Command Reg B	*/
#define		RHRB	11			/* R RX Holding Reg B	*/
#define		THRB	11			/* W TX Holding Reg B	*/
#define		IP	13			/* R Input Port		*/
#define		OPCR	13			/* W Output Port Config	*/
#define		STCC	14			/* R Start Counter Comm	*/
#define		SOPBC	14			/* W Set Out Port Bits	*/
#define		SPCC	15			/* R Stop Counter Comm	*/
#define		ROPBC	15			/* W Reset Out Port Bits*/

/*			Interrupt Masks					*/
#define		IPCS	0x80
#define		B_RX	0x20
#define		B_TX	0x10
#define		COUNT	0x08
#define		A_RX	0x02
#define		A_TX	0x01
#define		I_MASK	A_RX + COUNT + A_TX

/*			PORT masks					*/
#define		DE_B	0x01
#define		LED1	0x02
#define		LED2	0x04

/*			Communication states				*/
#define		IDLE	0
#define		BUSY	1
#define		TOUT	2
#define		PROC	3
#define		FIN	4
#define		ERR	5

/*			Communication Frames, States & Pointers		*/
#define		FRAME_SIZE	0xFF
char	xdata	rxa_frame[FRAME_SIZE];
char	xdata	txa_frame[FRAME_SIZE]= {"RS232 transmitter test."};
char	xdata	rxb_frame[FRAME_SIZE];
char	xdata	txb_frame[FRAME_SIZE]= {"RS485 transmitter test."};
int		rxa_ptr, txa_ptr, rxb_ptr, txb_ptr;
int		txa_len, txb_len, rxa_len, rxb_len;
char		rxa_stat, txa_stat, rxb_stat, txb_stat;

void	init_A		( )
{
	UART[CRA]=	0x10;			/* Reset MR ptr		*/
	UART[CRA]=	0x20;			/* Reset Rx A		*/
	UART[CRA]=	0x30;			/* Reset TX A		*/
	UART[CRA]=	0x40;			/* Res err stat A	*/
	UART[MR1A]=	0x13;			/* No parity, 8 bits	*/
	UART[MR2A]=	0x03;			/* Normal, S bit = 0.75	*/
	UART[CSRA]=	0x66;			/* A: 1200 Baud		*/
	UART[CRA]=	0x01;			/* Enable A Rx		*/
	rxa_stat=	IDLE;
	txa_stat=	IDLE;
}

void	init_B		( )
{
	UART[CRB]=	0x10;			/* Reset MR pointer	*/
	UART[CRB]=	0x20;			/* Reset, disable RX_B	*/
	UART[CRB]=	0x30;			/* Reset, disable TX_B	*/
	UART[CRB]=	0x40;			/* Reset error stat B	*/
	UART[MR1B]=	0x13;			/* No parity, 8 bits	*/
	UART[MR2B]=	0x03;			/* Normal mode, S= 0.75	*/
	UART[CSRB]=	0xBB;			/* B: 9600 Baud		*/
	UART[CRB]=	0x01;			/* Enable B Rx		*/
	UART[SOPBC]=	DE_B;			/* Enable line reciever	*/
	rxb_stat=	IDLE;
	txb_stat=	IDLE;
}

void	init_uart	( )
{
	UART[OPCR]=	0x00;			/* No Handshaking	*/
	UART[SOPBC]=	( LED1 | LED2 );	/* Set Output Port Bits	*/
	UART[IMR]=	I_MASK;			/* Write int mask	*/
	UART[ACR]=	0x91;			/* BR set 2, /16, IP0	*/
	UART[CTUR]=	0x00;
	UART[CTLR]=	0x38;			/* 0x38=3.5 byte lengths*/
	init_A	( );
	init_B	( );
}


void	txa	( char len )
{
	txa_len=	len;
	UART[CRA]=	0x04;			/* Enable transmitter	*/
	txa_stat=	BUSY;
}

void	txb	( char len )
{
	txb_len=	len;
	UART[ROPBC]=	DE_B;			/* Enable 485 driver	*/
	UART[CRB]=	0x04;
	txb_stat=	BUSY;
}

	UART_int	( ) interrupt 0 using 2	/* Interrupt Routine	*/
{
char	status, command;
	status=	UART[ISR]& I_MASK;
	if	( status & IPCS )		/* Bus Error		*/
	{
	}
	if	( status & B_RX )		/* Chan B RX int	*/
	{
		UART[ROPBC]=	LED2;
		rxb_frame[rxb_ptr]= UART[RHRB];	/* Read byte from frame	*/
		rxb_ptr++;			/* Inc frame ptr	*/
		command=	UART[SPCC];	/* Stop timout counter	*/
		command=	UART[STCC];	/* Start timout counter	*/
		rxb_stat=	BUSY;
	}
	if	( status & B_TX )		/* Chan B TX int	*/
	{
		if	( txb_ptr == txb_len )	/* Test for end of frame*/
		{
			txb_stat=	FIN;	/* Set frame sent stat	*/
			txb_ptr=	0;	/* Reset frame ptr	*/
			UART[CRB]=	0x08;	/* Disable transmitter	*/
			UART[SOPBC]=	DE_B;	/* Enable line reciever	*/
		}
		else
		{
			UART[THRB]= txb_frame[txb_ptr];
						/* Write new byte to buf*/
			txb_ptr++;		/* Inc frame ptr	*/
		}
	}
	if	( status & COUNT )		/* Counter ready	*/
	{
		command=	UART[SPCC];	/* Stop timout counter	*/
		UART[ROPBC]=	LED2;
		if	( rxa_stat== BUSY )
			rxa_stat= TOUT;
		if	( rxb_stat== BUSY )
			rxb_stat= TOUT;
	}
	if	( status & A_RX )		/* Chan A RX int	*/
	{
		UART[ROPBC]=	LED1;
		rxa_frame[rxa_ptr]= UART[RHRA];	/* Read byte from frame	*/
		rxa_ptr++;			/* Inc frame ptr	*/
		command=	UART[SPCC];	/* Stop timout counter	*/
		command=	UART[STCC];	/* Start timout counter	*/
		rxa_stat=	BUSY;
	}
	if	( status & A_TX )		/* Chan A TX int	*/
	{
		UART[ROPBC]=	LED1;
		if	( txa_ptr == txa_len )	/* Test for end of frame*/
		{
			txa_stat=	FIN;	/* Set frame sent stat	*/
			txa_ptr=	0;	/* Reset frame ptr	*/
			UART[CRA]=	0x08;	/* Disable transmitter	*/
		}
		else
		{
			UART[THRA]= txa_frame[txa_ptr];	
						/* Write new byte to buf*/
			txa_ptr++;		/* Inc frame ptr	*/
		}
	}
}