$NOMR XR NODEBUG
;	PC BASED TESTER embedded controller software
;	Originaly Written by David J. Hosken
;	Modified by T.O'Riley and M.J.Colley 09/96

;---------------------- BIT ADDRESSABLE FLAGS --------------------------
	ONLINE          BIT	20H.0
;	COM8TF          BIT	20H.1	; 8 bit command to follow
	VAF             BIT	20H.2	; Valid Address Found
;	ACTF            BIT	20H.3	; A Command to follow
	GETADR		BIT	20H.4	; Address not set

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
	SBUF_REG        DATA	1AH	;R2
	COM_STAT	DATA	1BH	; R3: Command Status
	POINTER		DATA	1CH	; R4: Frame pointer
	UART_POS        DATA	1DH	;R5
	ADR51_COM       DATA	1EH	;R6
;	ADR_COM         DATA	1FH	; R7 Not used anywhere
	COMMAND		DATA	1FH	; R7 Incomming command

;---------------------- BIT ADDRESSABLE DATA ---------------------------
	TEMP            DATA	2FH
	TEMP1		DATA	2EH
	ADR             DATA	2DH

;---------------------- NON BIT ADDRESSABLE DATA -----------------------
	DIPADR	DATA	30H		;Address settings of the dipswitches
	FLTH1	DATA	31H		;FPGA file size byte 1
	FLTH2	DATA	32H		;FPGA file size byte 2
	FLTH3	DATA	33H		;FPGA file size byte 3
	ERROR1	DATA	34H		;LSB of the errors RX'ed
	ERROR2	DATA	35H		;MSB of the errors RX'ed
	SAVERR	DATA	36H		;Save ERROR2's value

	REG_OFF	DATA	37H		;Register offset

;---------------------- CONSTANTS --------------------------------------
	PCON	DATA	87H
	LSB	EQU	0		; Least Significant Bit	
	MSB	EQU	7		; Most Significant Bit

;---------------------- Communication Status ---------------------------
	IDLE	EQU	0		; No Comms in progress
	VA	EQU	1		; Valid Address recieved
	IA	EQU	2		; Invalid Address recieved
	BA	EQU	3		; Broadcast Address recieved
	CR	EQU	10		; Command recieved
	RF1	EQU	20		; Receiving FPGA_1 code
	RF2	EQU	21		; Receiving FPGA_2 code

;---------------------- COMMAND SET ------------------------------------
	FPGA_CONF1	EQU     01H
	FPGA_CONF2	EQU	02H
	RDFL		EQU	03H
	WRTL		EQU	04H
	REPERR		EQU	05H
	FPGA_OK		EQU	06H	; Check FPGA code
	FPGA_ERR	EQU	07H	; FPGA Error
	

;---------------------- Interrupt Vector -------------------------------
	ORG	0000H			; RESET VECTOR
	JMP	INIT_SFR
	ORG	0003H			; EXTERNAL INTERRUPT 0
	JMP	INT0_ROUT
	ORG	000BH			; TIMER 0 INTERUPT
	RETI
	ORG	0013H			; EXTERNAL INTERRUPT 1
	RETI
	ORG	001BH			; TIMER 1 INTERUPT
	RETI
	ORG	0023H			; UART INTERUPT
	JMP	INT_SER_ROUT

;---------------------- Main Code --------------------------------------
	ORG	200H
INIT_SFR:				; Initialise Special Function Regs
	MOV	PCON,#80H		;Set SMOD(Double board rate)
	MOV	IE,#10010001B		;ENABLE: Serial port, Extrn. int0
					;DISABLE:Timer 1+2, External int 1
	MOV	IP,#00010000B		;Priority to the Serial port
	MOV	TCON,#01000001B		;Set timer 1 RUN bit.
					;Set INT0 = falling edge triggered
	MOV	TMOD,#00100000B		;Timer1 = 8 bit auto-reload timer
					;Timer0 = 8 bit timer
	MOV	SP,#5FH
	MOV	SCON,#01000000B		;Serial port = Var. 8-bit uart (mode1)
	MOV	TH0,#00H		;LOAD COUNTER 0 WITH FFF0
	MOV	TL0,#00H
	MOV	TH1,#255D		;Set UART = 255D
	MOV	TL1,#255D		;BAUD = 38400/(256 - 255)
					;     = 38.4 kB/sec
	MOV	P1,#0FFH
;	MOV	P3,#0FFH		: ?
	MOV	DIPADR,#06H		;At initialization all boards have the
	CLR	GETADR			; same address   --- WAS SETB GETADR
	CLR	ONLINE			; Default to Off Line
	MOV	UART_POS,#0		; ?
	SETB	REN			;Enable serial port reception
;	CLR	VAF
;	CLR	ACTF
;	CLR	COM8TF
	MOV	COM_STAT,#0		; Clear Comms status to IDLE
    MAIN_LOOP:
	JMP   MAIN_LOOP			; Main program is an infinite loop

;---------------------- Interrupt Routine ------------------------------
INT0_ROUT:				; External Interrupt 0
	PUSH	ACC
	PUSH	PSW
	INC	ERROR1
	MOV	A,ERROR1
	JNZ	INT0_FIN
	INC	ERROR2
    INT0_FIN:
	POP	PSW
	POP	ACC
	RETI

;---------------------- Interrupt Routine ------------------------------
INT_SER_ROUT:				; Serial Port Interrupt
	PUSH    ACC
	PUSH    PSW
	SETB    RS0			;Set resgister bank to bank 3
	SETB    RS1
	JB	TI,INT_S_TX		; Tx Interrupt: Jmp to INT_S_TX
	JMP	INT_S_RX		; Rx Interrupt: Jmp to INT_S_RX
   INT_S_TX:				; Transmit interrupt occured
	CLR     TI
	JB      VAF,$+6                 ;IS VAF FLAG SET?
	LJMP    INT_SER_FIN             ; NO  - Exit
	MOV	ACC,70			; YES - Delay 200 uS (For PC) ????
   INT_STX_LOOP:
	DJNZ	ACC,INT_STX_LOOP
	JMP     COM_JMP_ROUT		;Jmp to the COM_JMP_ROUT
   INT_S_RX:
	CLR     RI
	MOV     R2,SBUF                 ;SBUF --> R2
	CJNE	R4,#00H,BYTE_1		; If byte 0
	CJNE	R2,DIPADR,NOT_FOR_US	; Check Address
	SETB	VAF			; Set "Valid Address found"
	LJMP	UPDATE			; Update Stats
   BYTE_1:
	JB	VAF,$+6			; Is the frame for us?
	LJMP    INT_SER_FIN             ; NO  - Exit
	CJNE	R4,#01H,PROC_DATA	; If byte 1
	MOV	R7,R2			; Store Command
	LJMP	UPDATE			; Update stats
   PROC_DATA:
	CJNE	R7,FPGA_CONF1,N_FC1	; Command: FPGA_CONF_1 ?
	;Process config
	LJMP	UPDATE			; Update stats
   N_FC1:
	CJNE	R7,FPGA_CONF2,N_FC2	; Command: FPGA_CONF_2 ?
	;Process Config 
	LJMP	UPDATE			; Update stats
   N_FC2:
	CJNE	R7,RDFL,N_RL		; Command: RDFL ?
	CJNE	R4,#02H,N_OFFSET	; Offset byte ?
	MOV	REG_OFF,R2		; Store offset
	LJMP	UPDATE
     N_OFFSET:
	MOV

   NOT_FOR_US:
	CLR	VAF			; Clear "Valid Address Found"
	INC	R4			; Increment pointer
	LJMP	INT_SER_FIN		; Exit
   UPDATE:
	INC	R4			; Increment pointer
	; Store checksum here !!!
	LJMP	INT_SER_FIN		; Exit 	







   INT_S_PROC:				; Process Data		
	CJNE	R7,WRTL
	CJNE	R4,

					;IS VALLID ADR FOUND SET
	JB      VAF,INT_S_VAF           ; YES - Jmp to INT_S_VAF

					;WAS A SYNCH BYTE RX'ed
	CJNE    R2,#0FH,$+6             ; NO  - Continue
	LJMP    INT_S_0F                ; YES - Jmp to INT_S_0F

					;WAS A ADR COM TO FOLLOW RX'ed
	JB      ACTF,INT_S_ADR          ; YES - Jmp to INT_S_ADR
	CLR	ACTF
	JMP     INT_SER_FIN             ; NO  - Return

   INT_S_VAF:                           ;VALID ADR FOUND
	JMP     COM_JMP_ROUT

   INT_S_NAC:
	SETB    ACTF
	JMP     INT_SER_FIN

   INT_S_ADR:
	CLR     ACTF                    ;Clear ACTF
	MOV     A,R2
	ANL     A,#0FH
					;IS THE PRESENT BYTE ADR'ed TO US?
	CJNE    A,DIPADR,INT_S_NOA      ; NO  - Jmp to INT_S_NOA
	SETB    VAF                     ; YES - Set Valid Adress Found bit
	MOV     UART_POS,#0             ;Clear UART_POS
	MOV     COM4,R2
	ANL     COM4,#0F0H              ;WAS A CTF(COMMAND TO FOLLOW) BYTE RX'ed
	CJNE    R3,#CTF,INT_S_NCTF      ; NO  - Jmp to INT_S_NCTF ( No CTF)
	SETB    COM8TF                  ; YES - Set WAIT_COM8
	JMP     INT_SER_FIN             ;Return from interupt

   INT_S_NOA:                           ;NOt Adressed to us
	JMP     INT_SER_FIN

   INT_S_NCTF:                          ;No Command To Follow
	CLR     COM8TF
	JMP     COM_JMP_ROUT
   INT_SER_FIN:
	POP     PSW
	POP     ACC
	RETI

;*********************************************************************
;            JUMPS TO THE ROUTINE POINTED TO BY COM4,COM8
;*********************************************************************
;COM_JMP_ROUT:
;					;ARE WE ONLINE?
;	JNB     ONLINE,COMJ_OF          ; NO  - Jmp to COMJ_OF
;					; YES
;					;WAS A Command To Follow byte TX'ed
;	CJNE    R3,#CTF,COMJ_COM4       ; NO  - jmp to COMJ_COM4
;	JMP     COMJ_COM8               ; YES - jmp to COMJ_COM8
;
;  COMJ_OF:
;	CJNE    R3,#ON_STR,COMJ_NS
;	JMP     ON_STR_ROUT
;
;  COMJ_NS:
;	CLR     VAF
;	MOV     A,#TOL
;	ORL     A,DIPADR
;	MOV     SBUF,A
;	JMP     INT_SER_FIN
;
;  COMJ_COM4:
;	CJNE    R3,#ON_STR,$+6 		;Jump to the next option
;	LJMP    ON_STR_ROUT
;
;	CJNE    R3,#FPGA_CONF1,$+6 	;Jump to the next option
;	LJMP	FPGA_C1R		;Jump to FPGA1's config. routine.
;
;	CJNE	R3,#FPGA_CONF2,$+6	;Jump to the next option
;	LJMP	FPGA_C2R		;Jump to FPGA1's Config for "test".
;
;	CJNE    R3,#OFLINE,$+6		;Jump to the next compare
;	LJMP    OFLINE_ROUT
;
;	CJNE    R3,#RDFL,$+6		;Jump to the next option
;	LJMP    RDFL_ROUT
;
;	CJNE    R3,#WRTL,$+6		;Jump to the next option
;	LJMP    WRTL_ROUT               ;Jump to the WRite To Latch routine
;
;	CJNE    R3,#REPERR,$+6		;Jump to the next option
;	LJMP    REPERR_ROUT             ;Jump to the REPort ERRor routine
;
;	CLR	VAF			;The 8051 has recieved an unknown command
;	JMP 	INT_SER_FIN		; do nothing!
;
;  COMJ_COM8:
;
;	CLR	VAF			;The 8051 has recieved an unknown command
;	JMP 	INT_SER_FIN		; do nothing!

;*********************************************************************
;                   LOOK FOR THE ONLINE MSG
;*********************************************************************
ON_STR_ROUT:

	CJNE    R5,#0,L4O_1?
	MOV     A,#SNDTX
	ORL     A,DIPADR
	MOV     SBUF,A
	INC     R5
	JMP     INT_SER_FIN

   L4O_1?:
	CJNE    R5,#1,L4O_2?            ;The TX int is trigered for the
	INC     R5                      ; SNDTX signal that was sent
	JMP     INT_SER_FIN

   L4O_2?:
	MOV     A,R5
	CPL     A

	MOV     DPTR,#ONLINE_STRING     ;Get the start adr. of ONLINE_STRING in the DPTR
	MOV     A,R5                    ;R5 = UART_POS = number of correct bytes RX'ed in ONLINE_STRING
	DEC     A
	DEC     A                       ;Adjust A from 2-62 to 0-60
	MOVC    A,@A + DPTR
					;HAS A CORRECT CHAR FOR THE ONLINE_STRING BEEN RX'ed
	CJNE    A,SBUF_REG,L4O_FAIL     ; NO  - Reset the values for LOOK_4_ONLINE_ROUT
	INC     R5                      ; YES - INC the number of correct bytes RX'ed of ONLINE_STRING
					;HAS THE WHOLE ONLINE_STRING BEEN RX'ed
	CJNE    R5,#ONLINE_LGH,L4O_NFIN ; NO  - Exit routine
	SETB    ONLINE                  ; YES - Set ONLINE flag
	CLR     VAF                     ;Comunication finished, clear VAF
	MOV     A,#CONM                 ;TX a connection made byte to the PC
	ORL     A,DIPADR                ;Mov the current adr into the ADR51
	MOV     SBUF,A
	JMP     L4O_FIN

   L4O_NFIN:                            ;The whole ONLINE_STRING has not
	CLR     ONLINE                  ; yet been RX'ed
	JMP     L4O_FIN

   L4O_FAIL:                            ;A wronge byte was RX'ed in the
	CLR     ONLINE                  ; incomming reception for the
	CLR     VAF                     ; online string.
	JMP     L4O_FIN

   L4O_FIN:
	JMP     INT_SER_FIN

;*********************************************************************
;                   RECEIVING FPGA1 CONFIGURATION
;*********************************************************************
FPGA_C1R:
					;WAS THE FPGA_CONF1 BYTE RX'ed?
	CJNE    R5,#0,F4O_1?		; NO  - Continue
					; YES -
	SETB	D_P1
	NOP
	CLR	D_P1			; DONE MODE, clear D_P1 bit = reset FPGA1
	SJMP	$+2			;Delay 4 * 2uS = 8uS
	SJMP	$+2
	SJMP	$+2
	SJMP	$+2
	SETB	D_P1

	MOV	A,#0FFH			;Use ACC as loop counter
     F1C1_LOOP:                         ;IS INIT = 1 (FPGA ready to be programmed)
	JB      INIT1,F1_CON2  		; YES - goto F1_CON2 and TX the SNDTX byte to the PC
	NOP                             ; NO  - Delay with 2 NOP's
	NOP				;HAS THE INIT PIN BEEN TESTED FOR 256*6 uS?
	DJNZ	ACC,F1C1_LOOP		; NO  - Jmp to F1C1_LOOP and test the INIT pin again
	CLR	VAF			; YES - Clear the VAF bit and
	JMP     INT_SER_FIN		;        exit from serial int. routine

    F1_CON2:
	MOV     A,#SNDTX                ;TX a SNDTX byte
	ORL     A,DIPADR		;Get present address
	MOV     SBUF,A			;Tx ADR51_COM
	INC     R5			;Inc. TX pointer R5
	JMP     INT_SER_FIN

   F4O_1?:
	CJNE    R5,#1,F4O_2?            ;The TX int is trigered for the
	INC     R5                      ; SNDTX signal that was sent
	JMP     INT_SER_FIN

   F4O_2?:
	CJNE    R5,#2,F4O_3?            ;The first RX'ed lenth byte
	INC     R5                      ; was RX'ed
	MOV	FLTH1,R2		;Save the RX'ed first lenth byte
	JMP     INT_SER_FIN

   F4O_3?:
	CJNE    R5,#3,F4O_4?            ;The second RX'ed lenth byte
	INC     R5                      ; was RX'ed
	MOV	FLTH2,R2		;Save the RX'ed second lenth byte
	JMP     INT_SER_FIN

   F4O_4?:
	CJNE    R5,#4,F4O_5?            ;The third RX'ed lenth byte
	INC     R5                      ; was RX'ed
	MOV	FLTH3,R2		;Save the RX'ed first lenth byte
	JMP     INT_SER_FIN

   F4O_5?:
	CJNE	R5,#5,F4O_6?
	MOV	A,R2			;Move the RX'ed byte into ACC
	MOV	TEMP,#8
    F1_START:
	CLR	C
	RLC	A               	;Get next bit to be TX'ed
	JNC	F1_TX0			;MUST A 0 OR A 1 BE TX'ed
		;------- TX a '1'-------
	SETB	DIN1			;Set the data input pin of the FPGA
	JMP	F1_CON3

    F1_TX0:	;------- TX a '0'-------
	CLR	DIN1			;Clear the data input pin of the FPGA

    F1_CON3:
	CLR	CCLK1  			;Clear the FPGA CCLK input
	NOP
	SETB	CCLK1			;Clock the data into the FPGA
					;HAVE ALL 8 BITS ALREADY BEEN TX'ed
	DJNZ	TEMP,F1_START		; NO  - Tx the next bit
					; YES - Continue
		;----- DEC FLTH3 - 1 -------
	MOV     A,FLTH1
	JZ	F1_RSTFLTH1
	DEC	FLTH1
	JMP	F4O_FIN
    F1_RSTFLTH1:
	MOV	FLTH1,#0FFH
	MOV     A,FLTH2
	JZ	F1_RSTFLTH2
	DEC	FLTH2
	JMP	F4O_FIN
    F1_RSTFLTH2:
	MOV	FLTH2,#0FFH
	MOV	A,FLTH3
	JZ	F1_TX_RXOK
	DEC	FLTH3
	JMP	F4O_FIN

    F1_TX_RXOK:
	MOV     A,#RXOK                 ;TX a RXOK ADR51_COM byte
	ORL     A,DIPADR		;Get present address
					;DID FPGA CONFIRM CONFIGURATION?
	JNB	D_P1,$+5		; NO  - Dont TX RXOK
	MOV     SBUF,A			; YES - Tx ADR51_COM(RXOK)
	INC	R5
	JMP     INT_SER_FIN

   F4O_6?:
	CJNE    R5,#6,F4O_FIN           ;The TX int is trigered for the
	CLR     VAF                      ; SNDTX signal that was sent
	;----- test, set FPGA to 511 pattern -----------
	MOV	DPTR,#1000H
	MOV	A,#00000000B
	MOVX	@DPTR,A

	MOV	DPTR,#1001H
	MOV	A,#00000000B
	MOVX	@DPTR,A
	;----- end test --------------------------------
	JMP     INT_SER_FIN

   F4O_FIN:
	JMP     INT_SER_FIN


;*********************************************************************
;                   RECEIVING FPGA2 CONFIGURATION
;*********************************************************************
FPGA_C2R:
					;WAS THE FPGA_CONF2 BYTE RX'ed?
	CJNE    R5,#0,F2O_1?		; NO  - Continue
					; YES -
	SETB	D_P2
	NOP
	CLR	D_P2			; DONE MODE, clear D_P2 bit = reset FPGA1
	SJMP	$+2			;Delay 4 * 2uS = 8uS
	SJMP	$+2
	SJMP	$+2
	SJMP	$+2
	SETB	D_P2

	MOV	A,#0FFH			;Use ACC as loop counter
F2C1_LOOP:                              ;IS INIT = 1 (FPGA ready to be programmed)
	JB      INIT2,F2_CON2  		; YES - goto F2_CON2 and TX the SNDTX byte to the PC
	NOP                             ; NO  - Delay with 2 NOP's
	NOP				;HAS THE INIT PIN BEEN TESTED FOR 256*6 uS?
	DJNZ	ACC,F2C1_LOOP		; NO  - Jmp to F2C1_LOOP and test the INIT pin again
	CLR	VAF			; YES - Clear the VAF bit and
	JMP     INT_SER_FIN		;        exit from serial int. routine

    F2_CON2:
	MOV     A,#SNDTX                ;TX a SNDTX byte
	ORL     A,DIPADR		;Get present address
	MOV     SBUF,A			;Tx ADR51_COM
	INC     R5			;Inc. TX pointer R5
	JMP     INT_SER_FIN

   F2O_1?:
	CJNE    R5,#1,F2O_2?            ;The TX int is trigered for the
	INC     R5                      ; SNDTX signal that was sent
	JMP     INT_SER_FIN

   F2O_2?:
	CJNE    R5,#2,F2O_3?            ;The first RX'ed lenth byte
	INC     R5                      ; was RX'ed
	MOV	FLTH1,R2		;Save the RX'ed first lenth byte
	JMP     INT_SER_FIN

   F2O_3?:
	CJNE    R5,#3,F2O_4?            ;The second RX'ed lenth byte
	INC     R5                      ; was RX'ed
	MOV	FLTH2,R2		;Save the RX'ed second lenth byte
	JMP     INT_SER_FIN

   F2O_4?:
	CJNE    R5,#4,F2O_5?            ;The third RX'ed lenth byte
	INC     R5                      ; was RX'ed
	MOV	FLTH3,R2		;Save the RX'ed first lenth byte
	JMP     INT_SER_FIN

   F2O_5?:
	CJNE	R5,#5,F2O_6?
	MOV	A,R2			;Move the RX'ed byte into ACC
	MOV	TEMP,#8
    F2_START:
	CLR	C
	RLC	A               	;Get next bit to be TX'ed
	JNC	F2_TX0			;MUST A 0 OR A 1 BE TX'ed
		;------- TX a '1'-------
	SETB	DIN2			;Set the data input pin of the FPGA
	JMP	F2_CON3

    F2_TX0:	;------- TX a '0'-------
	CLR	DIN2			;Clear the data input pin of the FPGA

    F2_CON3:
	CLR	CCLK2  			;Clear the FPGA CCLK input
	NOP
	SETB	CCLK2			;Clock the data into the FPGA
					;HAVE ALL 8 BITS ALREADY BEEN TX'ed
	DJNZ	TEMP,F2_START		; NO  - Tx the next bit
					; YES - Continue
		;----- DEC FLTH3 - 1 -------
	MOV     A,FLTH1
	JZ	F2_RSTFLTH1
	DEC	FLTH1
	JMP	F2O_FIN
    F2_RSTFLTH1:
	MOV	FLTH1,#0FFH
	MOV     A,FLTH2
	JZ	F2_RSTFLTH2
	DEC	FLTH2
	JMP	F2O_FIN
    F2_RSTFLTH2:
	MOV	FLTH2,#0FFH
	MOV	A,FLTH3
	JZ	F2_TX_RXOK
	DEC	FLTH3
	JMP	F2O_FIN

    F2_TX_RXOK:
	MOV     A,#RXOK                 ;TX a RXOK ADR51_COM byte
	ORL     A,DIPADR		;Get present address
					;DID FPGA CONFIRM CONFIGURATION?
	JNB	D_P2,$+5		; NO  - Dont TX RXOK
	MOV     SBUF,A			; YES - Tx ADR51_COM(RXOK)
	INC	R5
	JNB	GETADR,F2_NOGETADR


		;---- Read the DIPSWITCH address, and save it in
		;      DIPADR 0-3
	MOV	ACC,#0
	CLR	T1
	NOP			;Give it time to stabelize
	NOP
	JB	STRAP1,$+5
	SETB	ACC.0
	JB	STRAP2,$+5
	SETB	ACC.1
	JB	STRAP3,$+5
	SETB	ACC.2
	JB	STRAP4,$+5
	SETB	ACC.3
	MOV     DIPADR,ACC	;Save the read strap settings in DIPADR
	SETB	T1
	CLR	GETADR
		;---- Finished ----
   F2_NOGETADR:
	JMP     INT_SER_FIN

   F2O_6?:
	CJNE    R5,#6,F2O_FIN           ;The TX int is trigered for the
	CLR     VAF                      ; SNDTX signal that was sent
	JMP     INT_SER_FIN

   F2O_FIN:
	JMP     INT_SER_FIN


;*********************************************************************
;               CLEAR THE ONLINE BIT OF THE TESTER
;*********************************************************************
OFLINE_ROUT:

	MOV     A,#TOL
	ORL     A,DIPADR
	MOV     SBUF,A

	CLR     ONLINE
	CLR     VAF
	MOV	R5,#0
	JMP     INT_SER_FIN

;*********************************************************************
;                   READ DATA FROM LATCH (1000H + OFFSET)
;*********************************************************************
RDFL_ROUT:
				;WAS THE RDFL BYTE RX'ed?
	CJNE    R5,#0,RDFL_1?	; NO  - Continue
	MOV     A,#SNDTX	; YES -
	ORL     A,DIPADR
	MOV     SBUF,A
	INC	R5
	JMP     INT_SER_FIN

   RDFL_1?:
	CJNE    R5,#1,RDFL_2?	;The TX int is trigered for the
	INC     R5		;SNDTX signal that was sent
	JMP     INT_SER_FIN

   RDFL_2?:
	CJNE    R5,#2,RDFL_3?	;RX the offset to 1000H for the adr. of
	INC     R5              ; the latch that has to be read.
	MOV	A,R2		;Save it in ACC
	MOV	DPTR,#1000H
	ADD     A,DPL           ;Inc DPTR to point to the right latch adr.
	MOV     DPL,A		;Save DPL
	JNC     $+4             ; in the RAM
	INC     DPH
	MOVX	A,@DPTR		;Read the latch

	MOV     SBUF,A 		;Tx the latch data to the PC
	JMP     INT_SER_FIN

   RDFL_3?:
	CLR	VAF		;The TX int is trigered for the
	JMP	INT_SER_FIN	; LATCH data that was sent

;*********************************************************************
;                   WRITE DATA TO LATCH (1000H + OFFSET)
;*********************************************************************
WRTL_ROUT:

	CJNE    R5,#0,WRL_1?		;TX the SNDTX byte to the PC
	MOV     A,#SNDTX
	ORL     A,DIPADR
	MOV     SBUF,A
	INC     R5
	JMP     INT_SER_FIN

   WRL_1?:
	CJNE    R5,#1,WRL_2?            ;The TX int is trigered for the
	INC     R5                      ; SNDTX signal that was sent
	JMP     INT_SER_FIN

   WRL_2?:
	CJNE    R5,#2,WRL_3?            ;RX the offset to 1000H for the adr. of
	INC     R5                      ; the latch that has to be written to.
	MOV	FLTH1,R2	        	;Save it in FLTH1
	JMP     INT_SER_FIN

   WRL_3?:
	CJNE    R5,#3,WRL_4?
	INC     R5
	MOV	DPTR,#1000H
	MOV	A,FLTH1		;Get the offset to 1000H in ACC
	ADD     A,DPL           ;Inc DPTR to point to the right latch adr.
	MOV     DPL,A		;Save DPL
	JNC     $+4             ; in the RAM
	INC     DPH
	MOV	A,R2   		;Get the latch data in ACC.
	MOVX	@DPTR,A		;Write the data to the latch.
		;------ TX the RXOK reply to the PC ----------
	MOV     A,#RXOK
	ORL     A,DIPADR
	MOV     SBUF,A
	JMP     INT_SER_FIN

   WRL_4?:
	CLR     VAF                      ; RXOK signal that was sent
	JMP     INT_SER_FIN

;*********************************************************************
;               REP THE ERROR COUNT TO THE PC
;*********************************************************************
REPERR_ROUT:
					;WAS THE REPERR BYTE RX'ed?
	CJNE    R5,#0,REPERR_1?		; NO  - Continue
	MOV     A,#DTF			; YES -
	ORL     A,DIPADR
	MOV     SBUF,A
	INC	R5
	JMP     INT_SER_FIN

    REPERR_1?:
	CJNE    R5,#1,REPERR_2?
	INC     R5
	CLR	EX0		;Disable ERROR interupt
	MOV	SAVERR,ERROR2	;Save the value of ERROR2 until it is TX'ed
	MOV	A,ERROR1	;Tx ERROR1
	MOV	ERROR1,#0
	MOV	ERROR2,#0
	SETB	EX0		;Enable ERROR interupt again
	MOV	SBUF,A
	JMP     INT_SER_FIN

    REPERR_2?:
	CJNE    R5,#2,REPERR_3?
	INC     R5
	MOV	A,SAVERR	;TX the saved ERROR2, that is in SAVERR
	MOV	SBUF,A
	JMP     INT_SER_FIN     ; again.

    REPERR_3?:
	CLR	VAF                     ;The TX int is trigered for the
	JMP     INT_SER_FIN             ; ERROR2 byte that were sent


	END
