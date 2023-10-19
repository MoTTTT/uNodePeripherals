/*	File:		UM2681_1.H	Header file for DUART		*/
/*	Programmer:	M.J.COlley					*/

/*			Register Addresses				*/

#define		UART	(( char *) 0x28400L )	/* Base Address of UART	*/
#define		MRA	0			/* R/W Mode Reg 1/2 A	*/
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
#define		MRB	8			/* R/W Mode Reg B	*/
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
#define		B_TX	0x08
#define		COUNT	0x04
#define		A_RX	0x02
#define		A_TX	0x01


void	init_uart	( )
{
	UART[IMR]=(IPCS& B_RX& B_TX& A_RX& A_TX );/* Set interrupt mask	*/
	UART[CRA]=	0x1A;			/* Reset MR ptr		*/
	UART[CRA]=	0x2A;			/* Reset, disable RX_A	*/
	UART[CRA]=	0x3A;			/* Reset, disable TX_A	*/
	UART[CRA]=	0x4A;			/* Reset error stat A	*/
	UART[MRA]=	0x13;			/* No parity, 8 bits	*/
	UART[MRA]=	0x07;			/* Normal, S bit = 1	*/
	UART[CRB]=	0x1A;			
	UART[CRB]=	0x2A;			/* Reset, disable RX_B	*/
	UART[CRB]=	0x3A;			/* Reset, disable TX_B	*/
	UART[CRB]=	0x4A;			/* Reset error stat B	*/
	UART[MRB]=	0x13;			/* No parity, 8 bits	*/
	UART[MRB]=	0x07;			/* Normal mode, S= 1	*/
	UART[CSRA]=	0x66;			/* A: 1200 Baud		*/
	UART[CSRB]=	0xBB;			/* B: 9600 Baud		*/
	UART[OPCR]=	0x00;			/* No Handshaking	*/
	UART[ACR]=	0xF1;			/* BR set 2, /16, IP0	*/
	UART[SOPBC]=	0xFF;			/* Set Output Port Bits	*/
}

	UART_int	( ) interrupt 6		/* Interrupt Routine	*/
{
char	status;
	status=	UART[ISR];
	if	( status & IPCS )		/* Bus Error		*/
	{
		
	}
	if	( status & B_RX )		/* Chan B RX int	*/
	{
	
	}
	if	( status & B_TX )		/* Chan B TX int	*/
	{

	}
	if	( status & A_RX )		/* Chan A RX int	*/
	{

	}
	if	( status & A_TX )		/* Chan A TX int	*/
	{

	}
}