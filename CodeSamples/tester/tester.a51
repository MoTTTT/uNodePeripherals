;$NOMR XR NODEBUG
;	PC BASED TESTER embedded controller software
;	Originaly Written by David J. Hosken
;	Rewritten by M.J.Colley 09/96

;---------------------- CARD ADDRESS -----------------------------------
	ADDRESS		EQU	01H	; This is required since the DIP
					; switches don't work correctly (AFAIK)

;---------------------- BIT ADDRESSABLE FLAGS --------------------------
	STATUS		DATA	20H	; Entire status flag byte
	BCAST		BIT	20H.0	; Broadcast frame flag
	TX_FIN		BIT	20H.1	; Transmit finished indicator
	VAF             BIT	20H.2	; Valid Address Found
;			BIT	20H.3	; Unused
	F1_READY	BIT	20H.4	; FPGA1 ready for programming
	F2_READY	BIT	20H.5	; FPGA2 ready for programming
	F1_OK		BIT	20H.6	; FPGA1 recieved program
	F2_OK		BIT	20H.7	; FPGA2 recieved program

;---------------------- FPGA1 AND 2'S CONFIGURATION PINS ---------------
	CCLK1 		BIT	P1.0
	INIT1		BIT	P1.1
	DIN1            BIT	P1.2
	D_P1		BIT	P1.3
	DIN2 		BIT	P1.4
	D_P2 		BIT	P1.5
	INIT2           BIT	P1.6
	CCLK2		BIT	P1.7

;---------------------- 4 DIODE ADDRESS STRAPING PINS ------------------
	STRAP1		BIT	P1.3
	STRAP2		BIT	P1.6
	STRAP3		BIT	P1.5
	STRAP4		BIT	P1.4

;---------------------- NON RELOCATIBLE DATA (BANK 3)-------------------
	SBUF_REG        EQU	R2	; R2: Byte recieved
	RX_SUM_ABS	DATA	1BH	; R3: Recieve frame checksum
	RX_SUM		EQU	R3	; R3: Recieve frame checksum
	RX_PTR_ABS	DATA	1CH	; R4: Receive frame pointer
	RX_PTR		EQU	R4	; R4: Receive frame pointer
	TX_PTR_ABS	DATA	1DH	; R5: Transmit frame pointer
	TX_PTR		EQU	R4	; R5: Transmit frame pointer
	TX_SUM		EQU	R6	; R6: Transmit frame checksum
	COMMAND		EQU	R7	; R7: Incomming command

;---------------------- BIT ADDRESSABLE DATA ---------------------------
	TEMP            DATA	2FH

;---------------------- DATA -------------------------------------------
;	DIPADR		DATA	30H	; Address settings of the dipswitches
	ERROR1		DATA	31H	; LSB of the errors RX'ed
	ERROR2		DATA	32H	; MSB of the errors RX'ed
	REG_OFF		DATA	33H	; Register offset
	WR_DATA		DATA	34H	; Data to be written to latch
	RD_DATA		DATA	35H	; Data read from latch
	ERR_1		DATA	36H	; Error data store
	ERR_2		DATA	37H	; Error data store

;---------------------- Frame Contents ---------------------------------
	ADDR_B		EQU	0H	; Address
	COMM_B		EQU	1H	; Command
	OFFST_B		EQU	2H	; Offset
	FRAME_B		EQU	2H	; FPGA: Frame ID
	DATA_B		EQU	3H	; Data
	DATA2_B		EQU	4H	; Second Data byte

;---------------------- COMMAND SET ------------------------------------
	FPGA_CONF1	EQU     01H	; Configure FPGA #1
	FPGA_CONF2	EQU	02H	; Configure FPGA #2
	RDFL		EQU	03H	; Read From Latch
	WRTL		EQU	04H	; Write to Latch
	REPERR		EQU	05H	; Report error count
	FPGA_STA	EQU	06H	; Report FPGA status
	FPGA_RST	EQU	07H	; Reset FPGA's

;---------------------- CONSTANTS --------------------------------------
	LSB		EQU	0	; Least Significant Bit	
	MSB		EQU	7	; Most Significant Bit
	BASE		EQU	1000H	; Latch Base pointer

;---------------------- Interrupt Vector -------------------------------
	ORG	0000H			; RESET VECTOR
	JMP	INIT_SFR
	ORG	0003H			; EXTERNAL INTERRUPT 0
	JMP	INT0_ROUT
	ORG	000BH			; TIMER 0 INTERRUPT
	JMP	T0_INT
	ORG	0013H			; EXTERNAL INTERRUPT 1
	RETI				; Not used
	ORG	001BH			; TIMER 1 INTERUPT
	RETI				; Not used
	ORG	0023H			; UART INTERUPT
	JMP	INT_SER_ROUT

;---------------------- Main Code --------------------------------------
	ORG	200H
INIT_SFR:				; Initialise Special Function Regs
	MOV	PCON,#80H		; Set SMOD(Double board rate)
	MOV	IE,#10010011B		; EN: Interrupts, Serial, T0, XInt0
	MOV	IP,#00010000B		; Priority to the Serial port
	MOV	TCON,#01000001B		; T1-> RUN. INT0-> falling edge trigg.
	MOV	TMOD,#00100000B		; T0: Mode 0; T1: Mode 2
	MOV	SP,#5FH			;
	MOV	SCON,#01000000B		; Serial port= Var. 8-bit uart (Mode 1)
;	MOV	TH1,#255D		; Set UART = 255D
;	MOV	TL1,#255D		; BAUD = 38400/(256 - 255)= 38.4 kB/sec
	MOV	TH1,#0FDH		; DEBUG Baud rate
	MOV	TL1,#0FDH		; DEBUG Baud Rate
	MOV	P1,#0FFH		;
;	MOV	P3,#0FFH		: ?
	MOV	TX_PTR_ABS,#0H		; Clear Transmit pointer
	MOV	RX_PTR_ABS,#0H		; Clear Recieve pointer
	MOV	RX_SUM_ABS,#0H		; Clear Recieve Checksum
	SETB	REN			; Enable serial port reception
	CLR	VAF			; 
    MAIN_LOOP:
	JMP	MAIN_LOOP		; Main program is an infinite loop
;---------------------- Interrupt Routine ------------------------------
T0_INT:					; Timer 0 interrupt routine
	PUSH	ACC			; Prepare
	PUSH	PSW			; Frame end clean-up:
	MOV	RX_PTR_ABS,#0H		; Reset RX_PTR_ABS
	MOV	RX_SUM_ABS,#0H		; Reset RX_SUM_ABS
	CLR	TR0			; Stop Timer 0
	CLR	STRAP4			; DEBUG
	POP	PSW			; Cleanup
	POP	ACC
	RETI
;---------------------- Interrupt Routine ------------------------------
INT0_ROUT:				; External Interrupt 0
	PUSH	ACC			; Prepare
	PUSH	PSW			;
	INC	ERROR1			; Increment first counter
	MOV	A,ERROR1		; Check for
	JNZ	INT0_FIN		;	overflow
	INC	ERROR2			; Increment second counter
    INT0_FIN:
	POP	PSW			; Cleanup
	POP	ACC
	RETI
;---------------------- Interrupt Routine ------------------------------
INT_SER_ROUT:				; Serial Port Interrupt
	PUSH    ACC			; Prepare
	PUSH    PSW			;
	SETB    RS0			; Set resgister bank to bank 3
	SETB    RS1			;
	JB	RI,INT_S_RX		; Rx Interrupt
	JMP	INT_S_TX		; Tx Interrupt
;---------------------- Service Recieve Interrupt ----------------------
  INT_S_RX:
	CLR     RI			; Rx Interrupt
;	MOV	TH0,#253D		; Reload timout register
	MOV	TH0,#080H		; DEBUG
	SETB	TR0			; Start frame timout timer
	MOV     SBUF_REG,SBUF		; Store Incoming Byte
	CJNE	RX_PTR,#ADDR_B,N_ADDR	; If address byte
	CJNE	SBUF_REG,#0H,NOT_BC	; Check for Broadcast
	SETB	BCAST			; Set broadcast flag
	CLR	VAF			; Clear Valid Address flag
	JMP	UPDATE			; Update stats
   NOT_BC:
	CJNE	SBUF_REG,#ADDRESS,NOT_US ;Check Address
	SETB	STRAP4			; DEBUG
	SETB	VAF			; Set "Valid Address found"
	CLR	BCAST			; Clear broadcast flag
	JMP	UPDATE			; Update Stats
   NOT_US:
	CLR	VAF			; Clear "Valid Address Found"
	CLR	BCAST			; Clear broadcast flag
	INC	RX_PTR			; Increment pointer
	JMP	INT_SER_FIN		; Exit
   N_ADDR:
	JB	VAF,COMM		; Is the frame addressed to us?
	JB	BCAST,COMM		; Or a broadcast frame?
	JMP	INT_SER_FIN		; Not: exit
   COMM:
	CJNE	RX_PTR,#COMM_B,N_COMM	; If command byte
	MOV	A,SBUF_REG		; Store Command
	MOV	COMMAND,A
	JMP	UPDATE			; Update stats
   N_COMM:
	CJNE	COMMAND,#FPGA_RST,N_RST ; Command: FPGA_RESET ?
	MOV	A,SBUF_REG		; Must be checksum byte
	CLR	CY			; Clear carry bit
	SUBB	A,RX_SUM		; Subtract calculated from recieved
	JZ	F_RESET			; Continue if correct
	JMP	INT_SER_FIN		; Exit if incorrect
     F_RESET:				; Reset FPGA's
	SETB	D_P1			; Ensure reset 1 line is ready
	SETB	D_P2			; Ensure reset 2 line is ready
	NOP				; Do nothing
	CLR	D_P1			; Begin FPGA 1 reset pulse
	CLR	D_P2			; Begin FPGA 2 reset pulse
	SJMP	$+2			; Delay 4 * 2uS = 8uS
	SJMP	$+2			; Delay
	SJMP	$+2			; Delay
	SJMP	$+2			; Delay
	SETB	D_P1			; End FPGA 1 reset pulse
	SETB	D_P2			; End FPGA 2 reset pulse
       TEST1:
	CLR	F1_READY		; Reset FPGA1 ready flag
	MOV	A,#0FFH			; Load loop counter
       F1_CLEAR_TEST:			; Loop start
	JB      INIT1,F1_CLEAR		; FPGA1 ready to be programmed?
	NOP                             ; Delay
	NOP                             ; Delay
	DJNZ	ACC,F1_CLEAR_TEST	; Test again?
	JMP	TEST2			; Test next FPGA
       F1_CLEAR:			; FPGA1 is ready
	SETB	F1_READY		; Set FPGA1 ready flag
       TEST2:
	CLR	F2_READY		; Reset FPGA2 ready flag
	MOV	A,#0FFH			; Load loop counter
       F2_CLEAR_TEST:			; Loop start
	JB      INIT2,F2_CLEAR		; FPGA2 ready to be programmed?
	NOP                             ; Delay
	NOP                             ; Delay
	DJNZ	ACC,F2_CLEAR_TEST	; Test again?
	JMP	INT_SER_FIN		; Exit
       F2_CLEAR:			; FPGA2 is ready
	SETB	F2_READY		; Set FPGA2 ready flag
	JMP	INT_SER_FIN		; Exit
   N_RST:
	CJNE	COMMAND,#FPGA_CONF1,N_FC1 ;Command: FPGA_CONF_1 ?
	MOV	A,SBUF_REG		; Move DATA into Accumulator
	MOV	TEMP,#8			; Set shift counter
       F1_START:
	CLR	C			; Clear carry bit
	RLC	A               	; Rotate [next] DATA bit into C
	JNC	F1_TX0			; Data bit is a '1' ?
	SETB	DIN1			; Set the data input pin of the FPGA
	JMP	F1_CLK			; Jump to clock data in
       F1_TX0:				; Data bit is a '0'
	CLR	DIN1			; Clear the data input pin of the FPGA
       F1_CLK:
	CLR	CCLK1  			; FPGA clock pulse start
	NOP				; Do Nothing
	SETB	CCLK1			; FPGA clock pulse end
	DJNZ	TEMP,F1_START		; All data bytes shifted ?
	JMP	INT_SER_FIN		; Exit
   N_FC1:
	CJNE	COMMAND,#FPGA_CONF2,N_FC2 ;Command: FPGA_CONF_2 ?
	MOV	A,SBUF_REG		; Move DATA into Accumulator
	MOV	TEMP,#8			; Set shift counter
       F2_START:
	CLR	C			; Clear carry bit
	RLC	A               	; Rotate [next] DATA bit into C
	JNC	F2_TX0			; Data bit is a '1' ?
	SETB	DIN2			; Set the data input pin of the FPGA
	JMP	F2_CLK			; Jump to clock data in
       F2_TX0:				; Data bit is a '0'
	CLR	DIN2			; Clear the data input pin of the FPGA
       F2_CLK:
	CLR	CCLK2  			; FPGA clock pulse start
	NOP				; Do Nothing
	SETB	CCLK2			; FPGA clock pulse end
	DJNZ	TEMP,F2_START		; All data bytes shifted ?
	JMP	INT_SER_FIN		; Exit
   N_FC2:
;	JNB	BCAST,RD_CONT		; If not broadcast: Continue
	JNB	BCAST,N_BC		; If not broadcast: Continue
	JMP	N_OK			; If broadcast: Illegal command
   N_BC:
	CJNE	COMMAND,#RDFL,N_RD	; Command: RDFL ?
	CJNE	RX_PTR,#OFFST_B,RD_CHK	; If Offset byte
	MOV	REG_OFF,SBUF_REG	; Store offset
	JMP	UPDATE
     RD_CHK:
	MOV	A,SBUF_REG		; Must be checksum byte
	CLR	CY			; Clear carry bit
	SUBB	A,RX_SUM		; Subtract calculated from recieved
	JZ	RD_CONT			; Continue if correct
	JMP	INT_SER_FIN		; Exit if incorrect
     RD_CONT:
	MOV	DPTR,#BASE		; Set Base pointer
	MOV	A,REG_OFF		; Add Offset to pointer
	ADD     A,DPL
	MOV     DPL,A
	JNC     $+4
	INC     DPH
	MOVX	A,@DPTR			; Read the latch
	MOV	RD_DATA,A		; Store read value
	JMP	START_TX		; Start reply frame transmission
   N_RD:
	CJNE	COMMAND,#WRTL,N_WR	; Command: WRTL ?
	CJNE	RX_PTR,#OFFST_B,WR_DAT	; If offset byte
	MOV	REG_OFF,SBUF_REG	; Store offset
	JMP	UPDATE
     WR_DAT:
	CJNE	RX_PTR,#DATA_B,WR_CHK	; If data byte
	MOV	WR_DATA,SBUF_REG	; Store data byte
	JMP	UPDATE
     WR_CHK:
	MOV	A,SBUF_REG		; Must be checksum byte
	CLR	CY			; Clear carry bit
	SUBB	A,RX_SUM		; Subtract calculated from recieved
	JZ	WR_CONT			; Continue if correct
	JMP	INT_SER_FIN		; Exit if incorrect
     WR_CONT:
	MOV	DPTR,#BASE		; Set Base pointer
	MOV	A,REG_OFF		; Add Offset to pointer
	ADD     A,DPL
	MOV     DPL,A
	JNC     $+4
	INC     DPH
	MOV	A,WR_DATA		; Get Data to be written
	MOVX	@DPTR,A			; Write Data to the latch.
	JMP	START_TX		; Start reply frame transmission
   N_WR:
	CJNE	COMMAND,#REPERR,N_RE	; Command: REPERR ?
	MOV	A,SBUF_REG		; Must be checksum byte
	CLR	CY			; Clear carry bit
	SUBB	A,RX_SUM		; Subtract calculated from recieved
	JZ	RE_CONT			; Continue if correct
	JMP	INT_SER_FIN		; Exit if incorrect
     RE_CONT:
	CLR	EX0			; Disable ERROR interupt
	MOV	ERR_1,ERROR1		; Save the value of ERROR1
	MOV	ERR_2,ERROR2		; Save the value of ERROR2
	MOV	ERROR1,#0H		; Reset Error counter 1
	MOV	ERROR2,#0H		; Reset Error counter 2
	SETB	EX0			; Enable ERROR interupt
	JMP	START_TX		; Start reply frame transmission
   N_RE:
	CJNE	COMMAND,#FPGA_STA,N_OK	; Command: FPGA_STATUS ?
	MOV	A,SBUF_REG		; Must be checksum byte
	CLR	CY			; Clear carry bit
	SUBB	A,RX_SUM		; Subtract calculated from recieved
	JZ	ST_CONT			; Continue if correct
	JMP	INT_SER_FIN		; Exit if incorrect
     ST_CONT:
	CLR	F1_OK			; Clear Flag 1
	CLR	F2_OK			; Clear flag 2
	JNB	D_P1,NOK		; Check FPGA 1 programmed status
	SETB	F1_OK			; Set flag
	JNB	D_P2,NOK		; Check FPGA 2 programmed status
	SETB	F2_OK			; Set flag
     NOK:
	JMP	START_TX		; Start reply frame transmission
   N_OK:
	; Handle unrecognised command
	JMP	INT_SER_FIN		; Unrecognised command, Exit
   START_TX:
	MOV	SBUF,#ADDRESS		; Start transmission: Address
	MOV	TX_SUM,#ADDRESS		; Update checksum
	MOV	TX_PTR,#ADDR_B		; Set transmit pointer
	CLR	TX_FIN			; Clear transmit finished flag
	JMP	INT_SER_FIN		; Exit
   UPDATE:
	INC	RX_PTR			; Increment pointer
	MOV	A,RX_SUM		; Update checksum
	ADD	A,SBUF_REG
	MOV	RX_SUM,A		; Store checksum
   INT_SER_FIN:
	CLR	STRAP1			; DEBUG
	POP     PSW			; Cleanup
	POP     ACC
	RETI
;---------------------- Service Transmit Interrupt ---------------------
   INT_S_TX:				; Transmit interrupt occured
	CLR     TI			; Reset interupt flag
	SETB	STRAP1			; DEBUG
	JNB	TX_FIN,TX_COM		; Is the transmission finished?
	CLR	STRAP3			; DEBUG
	JMP	INT_SER_FIN		; Exit
   TX_COM:
	CJNE	TX_PTR,#ADDR_B,N_COM	; Next byte: command
	MOV	SBUF,COMMAND		; Send command byte
	MOV	TX_PTR,#COMM_B		; Set transmit pointer
	MOV	A,TX_SUM		; Retrieve Checksum
	ADD	A,COMMAND		; Update Checksum
	MOV	TX_SUM,A		; Store Checksum
	JMP	INT_SER_FIN		; Exit
     N_COM:
	CJNE	COMMAND,#RDFL,T_N_RD	; Command: read from latch
	CJNE	TX_PTR,#COMM_B,T_SUM	; Data byte ?
	SETB	STRAP2			; DEBUG
;	MOV	SBUF,RD_DATA		; Transmit Data
	MOV	SBUF,#0FFH		; Transmit Dummy Data  DEBUG
	MOV	TX_PTR,#DATA_B		; Set transmit pointer
	MOV	A,TX_SUM		; Retrieve Checksum
;	ADD	A,RD_DATA		; Update Checksum
	ADD	A,#0FFH			; Update Checksum DEBUG
	MOV	TX_SUM,A		; Store Checksum
	JMP	INT_SER_FIN		; Exit
     T_N_RD:
	CJNE	COMMAND,#WRTL,T_N_WR	; Command: write to latch
	JMP	T_SUM			; Transmit checksum
     T_N_WR:
	CJNE	COMMAND,#REPERR,T_N_R	; Command: Report errors
	CJNE	TX_PTR,#COMM_B,T_DATA2	; First Data byte?
	MOV	SBUF,ERR_2		; Send first error byte (High byte)
	MOV	TX_PTR,#DATA_B		; Set transmit pointer
	MOV	A,TX_SUM		; Retrieve Checksum
	ADD	A,ERR_2			; Update Checksum
	MOV	TX_SUM,A		; Store Checksum
	JMP	INT_SER_FIN		; Exit
      T_DATA2:
	CJNE	TX_PTR,#DATA_B,T_SUM	; Second Data byte?
;	MOV	SBUF,ERR_1		; Send first error byte (Low byte)
	MOV	SBUF,#01H		; Send dummy error byte DEBUG
	MOV	TX_PTR,#DATA2_B		; Set transmit pointer
	MOV	A,TX_SUM		; Retrieve Checksum
;	ADD	A,ERR_1			; Update Checksum
	ADD	A,#01H			; Update Checksum DEBUG
	MOV	TX_SUM,A		; Store Checksum
	JMP	INT_SER_FIN		; Exit
     T_N_R:
	CJNE	COMMAND,#FPGA_STA,T_ERR	; Command: FPGA STATUS
	CJNE	TX_PTR,#COMM_B,T_SUM	; First Data byte?
;	MOV	SBUF,STATUS		; Send status error byte
	MOV	SBUF,#0FFH		; Send status error byte DEBUG
	MOV	TX_PTR,#DATA_B		; Set transmit pointer
	MOV	A,TX_SUM		; Retrieve Checksum
;	ADD	A,STATUS		; Update Checksum
	ADD	A,#0FFH			; Update Checksum DEBUG
	MOV	TX_SUM,A		; Store Checksum
	JMP	INT_SER_FIN		; Exit
     T_ERR:				; This code should never execute!!!
	; Handle invalid command error
	JMP	INT_SER_FIN		; Exit
     T_SUM:
	CLR	STRAP2			; DEBUG
	SETB	STRAP3			; DEBUG
	MOV	SBUF,TX_SUM		; Transmit Checksum
	SETB	TX_FIN			; Set Transmission finished flag
	JMP	INT_SER_FIN		; Exit
	END

;		;---- Read the DIPSWITCH address, and save it in
;		;      DIPADR 0-3
;	MOV	ACC,#0
;	CLR	T1
;	NOP			;Give it time to stabelize
;	NOP
;	JB	STRAP1,$+5
;	SETB	ACC.0
;	JB	STRAP2,$+5
;	SETB	ACC.1
;	JB	STRAP3,$+5
;	SETB	ACC.2
;	JB	STRAP4,$+5
;	SETB	ACC.3
;	MOV     DIPADR,ACC	;Save the read strap settings in DIPADR
;	SETB	T1
;	CLR	GETADR
;		;---- Finished ----
 ;  F2_NOGETADR:
;	JMP     INT_SER_FIN
;
 ;  F2O_FIN:
;	JMP     INT_SER_FIN
;	END
;	;----- test, set FPGA to 511 pattern -----------
;	MOV	DPTR,#1000H
;	MOV	A,#00000000B
;	MOVX	@DPTR,A
;
;	MOV	DPTR,#1001H
;	MOV	A,#00000000B
;	MOVX	@DPTR,A
;	;----- end test --------------------------------
