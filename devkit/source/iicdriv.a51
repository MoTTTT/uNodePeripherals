;-----------------------------------------------------------------------;
;			Copyright Q Solutions				;
;	File:		iic.a51						;
;	Programmer:	MoT						;
;	Module:		IIC Bus Low level assembler routine		;
;									;
;			History						;
; 19:14 12/04/1997 	Cleanup						;
; 19:06 16/04/1997 	Completed data descriptions			;
; To Do: Complete and test general call handler				;
;-----------------------------------------------------------------------;

PUBLIC	_iic_init		; Initialise IIC bus
PUBLIC	_iic_mstart		; Start a master transmission
PUBLIC	_iic_sset		; Prepare for a slave reception
PUBLIC	iic_mready		; Master transmit buffer empty flag
PUBLIC	iic_sready		; Slave receive buffer full

;-------------------IIC SFR's--------------------------------------------;
S1CON		data	0D8H	; Control
S1STA		data	0D9H	; Status
S1DAT		data	0DAH	; Data
S1ADR		data	0DBH	; Own slave Address
IEN0		data	0A8H	; Interrupt enable
STA		bit	0DDH	; Start flag of S1CON
SIO1HP		bit	0BDH	; IIC interrupt priority

;-------------------GENERAL CONSTANTS------------------------------------;
ENSIO1		EQU	0A0H	; Enable IIC mask for IEN0
PAG1		EQU	001H	; Page Address = 1
SELRB3		EQU	018H	; Select register bank 3 mask for PSW

;-------------------CONTROL SETTINGS FOR IIC BUS (S1CON)-----------------;
NA_O_NI_A	EQU	0D5H	; No start; Stop; No int; Acknowledge
NA_NO_NI_A	EQU	0C5H	; No start; No Stop; No int; Acknowledge
NA_NO_NI_NA	EQU	0C1H	; No start; No Stop; No int; No Acknowledge
A_NO_NI_A	EQU	0E5H	; Start; No Stop; No int; Acknowledge

;-------------------DATA SEGMENTS----------------------------------------;
IICDATA	SEGMENT	DATA
	RSEG	IICDATA
SD:		DS	1		; Slave Data pointer
MD:		DS	1		; Master Data pointer
SLEN:		DS	1		; ?
BACKUP:		DS	1		; Scratch for storing counters
NUMBYTMST:	DS	1		; Master bytes to be sent
NUMBYTSLA:	DS	1		; Slave bytes expected
SLA:		DS	1		; Slave Address
HADD:		DS	1		; Page Address
	BSEG
iic_sready:	DBIT	1		; Slave reception flag
iic_mready:	DBIT	1		; Master rx/tx complete

;----------------------------Public Routines-----------------------------;
IICCODE	SEGMENT	CODE
	RSEG	IICCODE
	USING	0
_iic_init:				; INITIALIZATION ROUTINE
	MOV	S1ADR,	R7		; Set slave address parameter
	SETB	P1.6			; Port 1.6, 1.7 must be set for 
	SETB	P1.7			;     IýC bus communication
	MOV	HADD,	#PAG1		; Use Page 1
	ORL	IEN0,	#ENSIO1		; Enable SIO1 interrupt
	CLR	SIO1HP			; SIO1 to low piority
	MOV	S1CON,	#NA_NO_NI_A	; No_Start, No_Stop, No_Serial-Int
	RET				;     Return Ack @ 100Khz Bit Rate
_iic_sset:				; SET UP SLAVE RECEIVER
	MOV	SD,	R7		; Set buffer pointer parameter
	MOV 	NUMBYTSLA,R5		; Set recieve counter parameter
	CLR	iic_sready		; Clear ready flag
	RET
_iic_mstart:				; SET UP MASTER TX/RX
	MOV	NUMBYTMST,R5		; Set buffer length from param
	MOV	SLA,	R7		; Set destination address from param
	MOV	MD,	R3		; Set buffer pointer from param
	SETB	STA			; Generate Start
	CLR	iic_mready		; Clear ready flag
	RET

;--------------------SIO1 INTERRUPT ROUTINE------------------------------;
CSEG	AT	002BH			; IIC interrupt vector
	PUSH	PSW			; Prepare
	PUSH	S1STA			; Push IIC status vector
	PUSH	HADD			; Push page address
	RET				; Execute from address on stack
;--------------------STATE VECTORS---------------------------------------;
CSEG	AT	0100H			; STATE 00, Bus Error
	MOV	S1CON,	#NA_O_NI_A	; Generate Stop
	POP	PSW
	RETI
;--------------------MASTER ROUTINES-------------------------------------;
CSEG	AT	0108H			; STATE 08, Start condition Tx
	MOV	S1DAT,	SLA
	MOV	S1CON,	#NA_NO_NI_A	;
	AJMP	INITBASE1		; Initialise addresses
CSEG	AT	0110H			; STATE 10, Repeat start cond Tx
	MOV	S1DAT,	SLA		; Send slave address
	MOV	S1CON,	#NA_NO_NI_A	;
	AJMP	INITBASE1		; Initialise addresses
CSEG	AT	0118H			; STATE 18, ACK recieved
	MOV	PSW,	#SELRB3		; Select register bank
	MOV	S1DAT,	@R1		; Copy data into send register
	AJMP	CON			; Continue
CSEG	AT	0120H			; STATE 20, NACK recieved
	MOV	S1CON,	#NA_O_NI_A	; Generate stop
	POP	PSW
	RETI
CSEG	AT	0128H			; STATE 28, DATA Tx, ACK Rx
	DJNZ	NUMBYTMST,NOTLDAT1	; Check for empty buffer
	MOV	S1CON,	#NA_O_NI_A	; Generate Stop
	AJMP	T_MREADY		; Transmision complete
CSEG	AT	0130H			; STATE 30, DATA Tx, NACK Rx
	MOV	S1CON,	#NA_O_NI_A	; Generate Stop
	POP	PSW
	RETI
CSEG	AT	0138H			; STATE 38, Arbitration lost
	MOV	S1CON,	#A_NO_NI_A	; Start again
	MOV	NUMBYTMST,BACKUP	; Restore buffer length
	AJMP	RETmt
CSEG	AT	0140H			; STATE 40, SLA+R Tx, ACK Rx
	MOV	S1CON,	#NA_NO_NI_A	; Acknowledge requested data
	AJMP	RETmr
CSEG	AT	0148H			; STATE 48, SLA+R Tx, NACK Rx
	MOV	S1CON,	#NA_O_NI_A	; Generate Stop
	POP	PSW
	RETI
CSEG	AT	0150H			; STATE 50, DATA Rx, ACK Tx
	MOV	PSW,	#SELRB3
	MOV	@R0,	S1DAT		; Copy data into buffer
	AJMP	REC1			; Master receiver routine
CSEG	AT	0158H			; STATE 58, DATA Rx, NACK Tx
	MOV	S1CON,	#NA_O_NI_A	; Generate Stop
	SETB	iic_mready
	POP	PSW
	RETI
;--------------------SLAVE ROUTINES--------------------------------------;
CSEG	AT	0160H			; STATE 60, OWN SLA+R/W Rx, ACK Tx
	MOV	S1CON,	#NA_NO_NI_A
	MOV	PSW,	#SELRB3
	AJMP	INITSRD			; Initialise slave read
CSEG	AT	0168H		; 68 ARB LOST S+R/W (MST) OWN SLAVE Rx
	MOV	S1CON,	#A_NO_NI_A	; Generate start
	MOV	PSW,	#SELRB3
	AJMP	INITSRD			; Initialise Slave read
;CSEG	AT	0170H			; STATE 70, GEN CALL Rx, Rx DATA
;	MOV	S1CON,	#NA_NO_NI_A	; Acknowledge
;	MOV	PSW,	#SELRB3
;	AJMP	INITSRD			; Initialise slave read
;CSEG	AT	0178H		; 78 ARB LOST SLA&R/W (MST), GEN CALL Rx
;	MOV	S1CON,	#A_NO_NI_A
;	MOV	PSW,	#SELRB3
;	AJMP	INITSRD
CSEG	AT	0180H			; STATE 80, OWNSLA DATA Rx, Tx ACK
	MOV	PSW,	#SELRB3
	MOV	@R0,	S1DAT		; Copy data into buffer
	AJMP	REC2			; Slave reciever routine
CSEG	AT	0188H			; STATE 88, OWNSLA DATA Rx, NACK Tx
	MOV	S1CON,	#NA_NO_NI_A
	AJMP	RETsr
;CSEG	AT	0190H			; STATE 90, GEN CALL DATA Rx, ACK Tx
;	MOV	@R0,	S1DAT		; Save data
;	AJMP	LDAT			; !!! Missing routine
;CSEG 	AT	0198H			; STATE 98, GEN CALL DATA Rx, NACK Tx
;	MOV	S1CON,	#NA_NO_NI_A
;	POP	PSW
;	RETI
CSEG	AT	01A0H			; STATE A0, STP OR RSTRT Rx
	MOV	S1CON,	#NA_NO_NI_A
	POP	PSW
	RETI
CSEG	AT	01A8H			; STATE A8, OWN SLA+R Rx, ACK Tx
	AJMP	INITBASE2		; Initialise Slave Transmitter 
CSEG	AT	01B0H	; B0, ARB LOST SLA&R/W (MST), OWN SLA+R Rx ACK Tx
	AJMP	INITBASE2		; Initialise Slave Transmitter 
CSEG	AT	01B8H			; STATE B8, DATA Tx ACK Rx
	MOV	PSW,	#SELRB3
	MOV	S1DAT,	@R1		; Copy next data byte to buffer
	AJMP	CON2			; Slave transmitter routine
CSEG	AT	01C0H			; STATE C0, DATA Tx NACK Rx
	MOV	S1CON,	#NA_NO_NI_A
	POP	PSW
	RETI
CSEG	AT	01C8H			; STATE C8, DATA Tx (AA=0) ACK Rx
	MOV	S1CON,	#NA_NO_NI_A
	POP	PSW
	RETI 

CSEG	AT	0090H
	USING	3
T_MREADY:				; Shut down master: Sucess
	SETB	iic_mready		; Set ready flag
	JMP	RETmt
T_MREADYRX:				; Shut down master: Sucess
	SETB	iic_mready		; Set ready flag
	JMP	RETmr
CSEG	AT	00A0H
INITBASE1:				; Initialise master transmitter
	MOV	PSW,	#SELRB3		; Select register bank
	MOV	R0,	MD		; Set up data address
	MOV	R1,	MD
	MOV	BACKUP,	NUMBYTMST	; Keep copy of buffer length
	POP	PSW
	RETI
CSEG	AT	00B0H			; Master transmitter routine
NOTLDAT1:
	MOV	PSW,	#SELRB3
	MOV	S1DAT,	@R1		; Copy data into tx buffer
CON:	MOV	S1CON,	#NA_NO_NI_A
	INC	R1			; Increment data pointer
RETmt:	POP	PSW
	RETI
CSEG	AT	00C0H			; Master reciever routine
REC1:	DJNZ	NUMBYTMST,NOTLDAT2	; Check for end of recieve
	MOV	S1CON,	#NA_NO_NI_NA	; No Acknowledge
;	SETB	iic_mready
	SJMP	RETmr
NOTLDAT2:
	MOV	S1CON,	#NA_NO_NI_A
	INC	R0
RETmr:	POP	PSW
	RETI
CSEG	AT	00D0H			; Initialise slave reception
INITSRD:
	MOV	R0,	SD		; Set data pointer
	MOV	R1,	NUMBYTSLA	; Set buffer length
	POP	PSW
	RETI
CSEG	AT	00D8H			; Slave reciever routine
REC2:	DJNZ	R1,	NOTLDAT3	; Last byte expected
	MOV	S1CON,	#NA_NO_NI_NA	; No acknowledge
	SETB	iic_sready		; Set slave ready flag
	AJMP	RETsr
NOTLDAT3:
	MOV	S1CON,	#NA_NO_NI_A	; Acknowledge next byte
	INC	R0			; Increment data pointer
RETsr:	POP	PSW
	RETI
CSEG	AT 	00E8H			; Initialise slave transmitter
INITBASE2:
	MOV	PSW,	#SELRB3
	MOV	R1,	SD		; Set data pointer
	MOV	S1DAT,	@R1		; Copy data to tx buffer
	MOV	S1CON,	#NA_NO_NI_A
	POP	PSW
	RETI
CSEG	AT	00F8H			; Slave transmitter routine
CON2:	MOV	S1CON,	#NA_NO_NI_A
	INC	R1			; Increment data pointer
	POP	PSW
	RETI
END	