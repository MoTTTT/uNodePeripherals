//	File:		UM2681_1.H	Header file for DUART
//	Programmer:	M.J.COlley

//			Register Addresses

#define		UART	(( char *)	0x2XXXXL )	// Base Address of UART
#define		MRA	BASE+ 0				// R/W Mode Reg 1/2 A
#define		SRA	BASE+ 1				// R Status Reg A
#define		CSRA	BASE+ 1				// W Clock Sel Reg A
#define		CRA	BASE+ 2				// W Command Reg A
#define		RHRA	BASE+ 3				// R RX Holding Reg A
#define		THRA	BASE+ 3				// W TX Holding Reg A
#define		IPCR	BASE+ 4				// R Input Port Change
#define		ACR	BASE+ 4				// W Aux. Control
#define		ISR	BASE+ 5				// R Interrupt Status
#define		IMR	BASE+ 5				// W Interrupt Mask
#define		CTU	BASE+ 6				// R Count/Timer Upper
#define		CTUR	BASE+ 6				// W C/T Upper
#define		CTL	BASE+ 7				// R C/T Lower
#define		CTLR	BASE+ 7				// W C/T Lower
#define		MRB	BASE+ 8				// R/W Mode Reg B
#define		SRB	BASE+ 9				// R Status Reg B
#define		CSRB	BASE+ 9				// W Clock Select B
#define		CRB	BASE+ 10			// W Command Reg B
#define		RHRB	BASE+ 11			// R RX Holding Reg B
#define		THRB	BASE+ 11			// W TX Holding Reg B
#define		IP	BASE+ 13			// R Input Port
#define		OPCR	BASE+ 13			// W Output Port Config
#define		STCC	BASE+ 14			// R Start Counter Comm
#define		SOPBC	BASE+ 14			// W Set Out Port Bits
#define		SPCC	BASE+ 15			// R Stop Counter Comm
#define		ROPBC	BASE+ 15			// W Reset Out Port Bits

//			Interrupt Masks
#define		IPCS	0x80
#define		B_RX	0x20
#define		B_TX	0x08
#define		COUNT	0x04
#define		A_RX	0x02
#define		A_TX	0x01


void	init_UART	( )
{
	*IMR=	( IPCS & B_RX & B_TX & A_RX & A_TX );	// Set interrupt mask
	*CRA=	0x1A;					// Reset MR ptr
	*CRA=	0x2A;					// Reset, disable RX_A
	*CRA=	0x3A;					// Reset, disable TX_A
	*CRA=	0x4A;					// Reset error stat A
	*MRA=	0x13;					// No parity, 8 bits
	*MRA=	0x07;					// Normal, S bit = 1
	*CRB=	0x1A;
	*CRB=	0x2A;					// Reset, disable RX_B
	*CRB=	0x3A;					// Reset, disable TX_B
	*CRB=	0x4A;					// Reset error stat B
	*MRB=	0x13;					// No parity, 8 bits
	*MRB=	0x07;					// Normal mode, S= 1
	*CSRA=	0x					// Set Clock rate A
	*CSRB=	0x					// Set Clock rate B
	*OPCR=	0x00;					// No Handshaking
	*ACR=	0xF1;					// BR set 2, /16, IP0
}

void	UART_int	( ) interrupt N using 2		// Interrupt Routine
{
char	status;
	status=	*ISR;
	if	( status & IPCS )			// Bus Error
	{
		
	}
	if	( status & B_RX )			// Chan B RX int
	{
	
	}
	if	( status & B_TX )			// Chan B TX int
	{

	}
	if	( status & A_RX )			// Chan A RX int
	{

	}
	if	( status & A_TX )			// Chan A TX int
	{

	}
}
