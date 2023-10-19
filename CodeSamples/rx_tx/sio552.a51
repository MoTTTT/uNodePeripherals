;******************************************************************************
;                            SIO552 SERVICE ROUTINE				
;******************************************************************************
PUBLIC	_set_sio1_master
PUBLIC	_set_sio1_slave
PUBLIC	_sio1_init
PUBLIC	NUMBYTMST
PUBLIC	SLAVE_R_flag

;-------------------SIO1 SFR's--------------------------;

S1CON		data	0D8H
S1STA		data	0D9H
S1DAT		data	0DAH
S1ADR		data	0DBH
IEN0		data	0A8H
IP0		data	0B8H

;-------------------BIT LOCATIONS-----------------------;

STA		bit	0DDH
SIO1HP		bit	0BDH

;-------------------S1CON DATA--------------------------;

NA_O_NI_A	EQU	0D5H
NA_NO_NI_A	EQU	0C5H
NA_NO_NI_NA	EQU	0C1H
A_NO_NI_A	EQU	0E5H

;-------------------GENERAL DATA------------------------;

OWNSLA		EQU	031H
ENSIO1		EQU	0A0H
PAG1		EQU	001H
SLAW		EQU	0A1H
SLAR		EQU	0A0H
SELRB3		EQU	018H

IICDATA	SEGMENT	DATA
	RSEG	IICDATA
SD:		DS	1
MD:		DS	1
SLEN:		DS	1
BACKUP:		DS	1
NUMBYTMST:	DS	1
NUMBYTSLA:	DS	1
SLA:		DS	1
HADD:		DS	1

	BSEG
SLAVE_R_flag:	DBIT	1
SLAVE_T_flag:	DBIT	1

IICCODE	SEGMENT	CODE
	RSEG	IICCODE
	USING	0

;-------------------INITIALIZATION ROUTINE--------------;
;-------------------R7 contains OWNSLA------------------;

_sio1_init:
	MOV	S1ADR,R7			;slave address = 48H
	SETB	P1.6				;Port 1.6, 1.7 must be set for 
	SETB	P1.7				;IýC bus communication
	MOV	HADD,#PAG1			;use Page 1
	ORL	IEN0,#ENSIO1			;enable SIO1 interrupt
	CLR	SIO1HP				;SIO1 to low piority
	MOV	S1CON,#NA_NO_NI_A		;No_Start, No_Stop, No_Serial-Int
	RET					;Return Ack @ 100Khz Bit Rate


;--------------------SET UP SLAVE Rx--------------------;
;------- R7: d_ptr, R5: length -------------------------;

_set_sio1_slave:
	MOV	SD,R7
	MOV 	NUMBYTSLA,R5
	RET

;--------------------SET UP MASTER TX/RX----------------;
;------- R7: addr, R5: length, R3: d_ptr----------------;

_set_sio1_master:
	MOV	NUMBYTMST,R5
	MOV	SLA,R7
	MOV	MD,R3
	SETB	STA
	RET

;--------------------SIO1 INTERRUPT ROUTINE-------------;

	CSEG	AT	002BH
	PUSH	PSW
	PUSH	S1STA
	PUSH	HADD
	RET

;--------------------STATE ROUTINES---------------------;
;-------STATE 00, Bus Error-----------------------------;

	CSEG	AT	0100H 
	MOV	S1CON,#NA_O_NI_A
	POP	PSW
	RETI

;-------MASTER STATE SERVICE ROUTINES-------------------;
;-------STATE 08, A start condition has been Tx---------;

	CSEG	AT	0108H
	MOV	S1DAT,SLA
	MOV	S1CON,#NA_NO_NI_A
	AJMP	INITBASE1

;-------STATE 10, A repeat start condition has been Tx--;

	CSEG	AT	0110H
	MOV	S1DAT,SLA
	MOV	S1CON,#NA_NO_NI_A
	AJMP	INITBASE1

	CSEG	AT	00A0H
	USING	3
INITBASE1:	
	MOV	PSW,#SELRB3
	MOV	R0,MD
	MOV	R1,MD
	MOV	BACKUP,NUMBYTMST
	POP	PSW
	RETI

;-------STATE 18, ACK recieved--------------------------;

	CSEG	AT	0118H
	MOV	PSW,#SELRB3
	MOV	S1DAT,@R1
	AJMP	CON

;-------STATE 20, NACK recieved-------------------------;

	CSEG	AT	0120H
	MOV	S1CON,#NA_O_NI_A
	POP	PSW
	RETI

;-------STATE 28, DATA Tx, ACK Rx-----------------------;

	CSEG	AT	0128H
	DJNZ	NUMBYTMST,NOTLDAT1
	MOV	S1CON,#NA_O_NI_A
	AJMP	RETmt

	CSEG	AT	00B0H
NOTLDAT1:
	MOV	PSW,#SELRB3
	MOV	S1DAT,@R1
CON:	MOV	S1CON,#NA_NO_NI_A
	INC	R1
RETmt:
	POP	PSW
	RETI

;-------STATE 30, DATA Tx, NACK Rx----------------------;

	CSEG	AT	0130H
	MOV	S1CON,#NA_O_NI_A
	POP	PSW
	RETI

;-------STATE 38, Arbitration lost----------------------;

	CSEG	AT	0138H
	MOV	S1CON,#A_NO_NI_A
	MOV	NUMBYTMST,BACKUP
	AJMP	RETmt

;-------------------MASTER RECIEVER ROUTINES------------;
;-------STATE 40, SLA+R Tx, ACK Rx----------------------;

	CSEG	AT	0140H
	MOV	S1CON,#NA_NO_NI_A
	AJMP	RETmr

;-------STATE 48, SLA+R Tx, NACK Rx---------------------;

	CSEG	AT	0148H
	MOV	S1CON,#NA_O_NI_A
	POP	PSW
	RETI

;-------STATE 50, DATA Rx, ACK Tx-----------------------;

	CSEG	AT	0150H
	MOV	PSW,#SELRB3
	MOV	@R0,S1DAT
	AJMP	REC1

	CSEG	AT	00C0H
REC1:
	DJNZ	NUMBYTMST,NOTLDAT2
	MOV	S1CON,#NA_NO_NI_NA
	SJMP	RETmr
NOTLDAT2:
	MOV	S1CON,#NA_NO_NI_A
	INC	R0
RETmr:
	POP	PSW
	RETI

;-------STATE 58, DATA Rx, NACK Tx----------------------;

	CSEG	AT	0158H
	MOV	S1CON,#NA_O_NI_A
	POP	PSW
	RETI

;==============================================================================

;-------SLAVE RECIEVER STATE SERVICE ROUTINES-----------;
;-------STATE 60, OWN SLA+R/W Rx, ACK Tx----------------;

	CSEG	AT	0160H
	MOV	S1CON,#NA_NO_NI_A
	MOV	PSW,#SELRB3
	AJMP	INITSRD

	CSEG	AT	00D0H
INITSRD:
	MOV	R0,SD
	MOV	R1,NUMBYTSLA
	POP	PSW
	RETI

;-------STATE 68, ARBIT LOST SLA&R/W (MST), OWNSLA Rx---;

	CSEG	AT	0168H
	MOV	S1CON,#A_NO_NI_A
	MOV	PSW,#SELRB3
	AJMP	INITSRD



;-------STATE 70, GEN CALL Rx, Rx DATA-----------------;
;
;	CSEG	AT	0170H
;	MOV	S1CON,#NA_NO_NI_A
;	MOV	PSW,#SELRB3
;	AJMP	INITSRD
;
;-------STATE 78, ARBIT LOST SLA&R/W (MST), GEN CALL Rx-;
;
;	CSEG	AT	0178H
;	MOV	S1CON,#A_NO_NI_A
;	MOV	PSW,#SELRB3
;	AJMP	INITSRD


;-------STATE 80, OWNSLA DATA Rx, Tx ACK----------------;

	CSEG	AT	0180H
	MOV	PSW,#SELRB3
	MOV	@R0,S1DAT
	AJMP	REC2

	CSEG	AT	00D8H
REC2:
	DJNZ	R1,NOTLDAT3
	MOV	S1CON,#NA_NO_NI_NA
	SETB	SLAVE_R_flag
	AJMP	RETsr
NOTLDAT3:
	MOV	S1CON,#NA_NO_NI_A
	INC	R0
RETsr:
	POP	PSW
	RETI
	
;-------STATE 88, OWNSLA DATA Rx, NACK Tx---------------;

	CSEG	AT	0188H
	MOV	S1CON,#NA_NO_NI_A
	AJMP	RETsr


;-------STATE 90, GEN CALL DATA Rx, ACK Tx--------------;
;
;	CSEG	AT	0190H
;	MOV	@R0,S1DAT
;	AJMP	LDAT
;
;-------STATE 98, GEN CALL DATA Rx, NACK Tx-------------;
;
;	CSEG 	AT	0198H
;	MOV	S1CON,#NA_NO_NI_A
;	POP	PSW
;	RETI


;-------STATE A0, STP OR RSTRT Rx ---------------------;

	CSEG	AT	01A0H
	MOV	S1CON,#NA_NO_NI_A
	POP	PSW
	RETI

;-------SLAVE TRANSMITTER STATE SERVICES ROUTINES-------;
;-------STATE A8, OWN SLA+R Rx, ACK Tx------------------;

	CSEG	AT	01A8H
	AJMP	INITBASE2

	CSEG	AT 	00E8H
INITBASE2:
	MOV	PSW,#SELRB3
	MOV	R1,SD
	MOV	S1DAT,@R1
	MOV	S1CON,#NA_NO_NI_A
	POP	PSW
	RETI

;-------STATE B0, ARBIT LOST SLA&R/W (MST), OWN SLA+R Rx ACK Tx-;

	CSEG	AT	01B0H	
	AJMP 	INITBASE2

;-------STATE B8, DATA Tx ACK Rx ---------------------;

	CSEG	AT	01B8H
	MOV	PSW,#SELRB3
	MOV	S1DAT,@R1
	AJMP	CON2

	CSEG	AT	00F8H
CON2:	
	MOV	S1CON,#NA_NO_NI_A
	INC	R1
	POP	PSW
	RETI

;-------STATE C0, DATA Tx NACK Rx---------------------;

	CSEG	AT	01C0H
	MOV	S1CON,#NA_NO_NI_A
	POP	PSW
	RETI

;-------STATE C8, DATA Tx (AA=0) ACK Rx--------------;

	CSEG	AT	01C8H
	MOV	S1CON,#NA_NO_NI_A
	POP	PSW
	RETI 

;----------------------------------------------------;

	END