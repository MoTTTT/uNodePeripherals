
/* +++=>>> * %n  Edition: %v  Last changed: %f  By: %w */
/* NE2000.C  Edition: 9  Last changed: 12-Aug-94,9:25:02  By: HARRY */
/* +++=>>> '%l' */
/* Currently extracted for edit by: '***_NOBODY_***' */
/*
    NE2000.C -- Novell Standard Ethernet Driver for USNET

    Copyright (C) 1993 By
    United States Software Corporation
    14215 N.W. Science Park Drive
    Portland, Oregon 97229

    This software is furnished under a license and may be used
    and copied only in accordance with the terms of such license
    and with the inclusion of the above copyright notice.
    This software or any other copies thereof may not be provided
    or otherwise made available to any other person.  No title to
    and ownership of the software is hereby transferred.

    The information in this software is subject to change without 
    notice and should not be construed as a commitment by United
    States Software Corporation.
*/

#include <string.h>
#include "net.h"
#include "local.h"
#include "support.h"
#include "driver.h"
#include "ethernet.h"
#define RO 0x00			/* offset to registers */
#include "ns8390.h"

#define SM_TSTART_PG 0x40	/* First page of TX buffer */
#define SM_RSTART_PG 0x46	/* Starting page of RX ring */
#define SM_RSTOP_PG 0x80	/* Last page +1 of RX ring */
#define SHAPAGE 256		/* shared memory page size */
#define MAXSIZ (MAXBUF - MESSH_SZ)

extern struct CONNECT connblo[];
extern struct NET nets[];
extern int event[];


/* ==========================================================================
   C level interrupt handler for Ethernet.  Called from a stub, registers are
   saved.  Returns to the interrupt stub.  Queues the arrived message into
   the arrive queue of the network block.  We pad the Ethernet header with an
   extra 2 bytes for 32-bit machines.  */

static void irhan(int netno)
{
    int status, i2;
    unsigned int tport, len;
    unsigned char start, next;
    short *spt;
    MESS *mess;
    struct NET *netp;

/* get and clear interrupt status */

    netp = &nets[netno];
    tport = netp->port;
    _outb(tport+CMDR, MSK_PG0);
    status = _inb(tport+ISR);
    _outb(tport+ISR, status);

/* receive interrupt, we have one or more messages */

    if (status & (MSK_PRX+MSK_RXE))
    {
        for ( ; ; _outb(tport+BNRY, next-1))
        {
	    _outb(tport+CMDR, MSK_PG1+MSK_STA+MSK_RD2);
	    next = _inb(tport+CURR);
	    _outb(tport+CMDR, MSK_PG0+MSK_STA+MSK_RD2);
	    start = _inb(tport+BNRY) + 1;
	    if (start >= SM_RSTOP_PG)
	        start = SM_RSTART_PG;
	    if (start == next)
	        break;
	    _outb(tport+RBCR0, 4);
	    _outb(tport+RBCR1, 0);
	    _outb(tport+RSAR0, 0);
	    _outb(tport+RSAR1, start);
	    _outb(tport+CMDR, MSK_PG0+MSK_RRE+MSK_STA);
	    i2 = _inw(tport+DATAPORT);
	    len = _inw(tport+DATAPORT);
	    next = i2 >> 8;
	    if (next >= SM_RSTOP_PG || next < SM_RSTART_PG) 
	    {
	        netp->err[0]++;
	        _outb(tport+BNRY, start-1);
	        break;
	    }
	    if ((i2 & SMK_PRX) == 0)
	    {
	        if (i2 & SMK_CRC) netp->err[3]++;
	        if (i2 & SMK_FAE) netp->err[4]++;
	        if (i2 & SMK_FO)
		    netp->err[5]++;
	        if (i2 & SMK_MPA) netp->err[6]++;
	        continue;
	    }
	    len -= 4;
	    if (len > MAXBUF - MESSH_SZ)
	    {
	        netp->err[1]++;
	        continue;
	    }
	    if (QUEUE_FULL(netp, arrive))
		continue;
    
/* Copy into a buffer, queue for dispatching. */
    
	    if ((mess = NgetbufIR()) == 0)
	        continue;
   	    mess->mlen = len + MESSH_SZ;
   	    mess->offset = MESSH_SZ;
 	    spt = (short *)((char *)mess + MESSH_SZ);
	    if (next != SM_RSTART_PG && next < start)
	    {
	        i2 = (SM_RSTOP_PG - start) * SHAPAGE - 4;
	        _outb(tport+RBCR0, 0xfc);
	        _outb(tport+RBCR1, (i2>>8));
	        _outb(tport+CMDR, MSK_RRE+MSK_PG0+MSK_STA);
	        len -= i2;
 	        BLOCKIN(spt, tport+DATAPORT, i2);
	        _outb(tport+RSAR1, SM_RSTART_PG);
	    }
	    _outb(tport+RBCR0, (len&0xff));
	    _outb(tport+RBCR1, (len>>8));
	    _outb(tport+CMDR, MSK_PG0+MSK_RRE+MSK_STA);
 	    BLOCKIN(spt, tport+DATAPORT, len);
    
   	    mess->netno = netno;
	    QUEUE_IN(netp, arrive, mess);
	    WAITNOMORE_IR(SIG_RN(netno));
        }
    }

/* transmit interrupt, send out the next message from the departure queue */

    if (status & (MSK_PTX+MSK_TXE))
    {
lab6:	if (QUEUE_EMPTY(netp, depart))
	    netp->hwflags = 0;
	else
	{
	    QUEUE_OUT(netp, depart, mess);
	    if (mess->offset != netno)
		goto lab6;
	    netp->bufbas = mess;
            len = mess->mlen - MESSH_SZ;
            spt = (short *)((char *)mess + MESSH_SZ);
            if (len < ET_MINLEN) len = ET_MINLEN;
            _outb(tport+TBCR0, (len&0xff));
            _outb(tport+TBCR1, (len>>8));
            _outb(tport+CMDR, MSK_RD2+MSK_STA);
            _outb(tport+RBCR0, (len&0xff));
            _outb(tport+RBCR1, (len>>8));
            _outb(tport+RSAR0, 0);
            _outb(tport+RSAR1, SM_TSTART_PG);
            _outb(tport+CMDR, MSK_PG0+MSK_RWR+MSK_STA);
            BLOCKOUT(spt, tport+DATAPORT, len);
            _outb(tport+TPSR, SM_TSTART_PG);
            _outb(tport+CMDR, MSK_TXP+MSK_RD2+MSK_STA);
            mess->offset = MESSH_SZ + LHDRSZ;
	    if (mess->id <= bWACK)
	    {
	        if (mess->id == bRELEASE)
		{
		    mess->id = bALLOC;
		    NrelbufIR(mess);
		}
	    }
	    else
	        WAITNOMORE_IR(SIG_WN(netno));
	}
    }
}


/* ==========================================================================
   Transmit routine.  If the transmitter is idle, starts the transmission and
   returns.  Otherwise adds message to the departure queue; the interrupt
   handler will trasmit it.  Returns:
	error:    -1
 	success:  0
 */

static int writE(int conno, PTABLE **protoc, MESS *mess)
{
    int tport, i1, len, netno, stat;
    short *spt;
    struct NET *netp;

    netno = protoc ? connblo[conno].netno : conno;
    netp = &nets[netno];
    tport = netp->port;
    mess->offset = mess->netno;

    BLOCKPREE();
    _outb(tport+IMR, 0x00);			/* disable interrupts */
    if (netp->hwflags)
    {
        QUEUE_IN(netp, depart, mess);
        RESUMEPREE();
	stat = 0;
    }
    else
    {
	netp->hwflags = 1;
        RESUMEPREE();
	netp->bufbas = mess;
        len = mess->mlen - MESSH_SZ;
        spt = (short *)((char *)mess + MESSH_SZ);
        if (len < ET_MINLEN) len = ET_MINLEN;
        _outb(tport+TBCR0, (len&0xff));
        _outb(tport+TBCR1, (len>>8));
        _outb(tport+CMDR, MSK_RD2+MSK_STA);
        _outb(tport+RBCR0, (len&0xff));
        _outb(tport+RBCR1, (len>>8));
        _outb(tport+RSAR0, 0);
        _outb(tport+RSAR1, SM_TSTART_PG);
        _outb(tport+CMDR, MSK_PG0+MSK_RWR+MSK_STA);
        BLOCKOUT(spt, tport+DATAPORT, len);
        _outb(tport+TPSR, SM_TSTART_PG);
        _outb(tport+CMDR, MSK_TXP+MSK_RD2+MSK_STA);
	stat = 1;
    }
    _outb(tport+IMR, 0x1f);			/* enable interrupts */
    return stat;
}
    

/* ==========================================================================
   Open a connection.  If the monitoring flag is on, we set the controller to
   accept all messages, otherwise just broadcasts and our own messages.
 */

static int opeN(int conno, PTABLE **protoc, int flag)
{
    struct NET *netp;

    (void)protoc;
    netp = &nets[connblo[conno].netno];
    if (flag & S_MON)
	_outb(netp->port+RCR, MSK_PRO|MSK_AB|MSK_AR);
    return 0;
}


/* ==========================================================================
   Close the connection. */

static void closE(int conno, PTABLE **protoc)
{
    struct NET *netp;

    (void)conno, (void)protoc;
    netp = &nets[connblo[conno].netno];
    if (connblo[conno].txstat & S_MON)
        _outb(netp->port+RCR, MSK_AB);
}


/* ==========================================================================
   Configure and start up the Ethernet interface.  We process the user-level
   text parameters and store the values into the net table.  We take the
   address from the Ethernet board, and set up the board.  Then we store the
   interrupt address and enable the interrupt.  Returns:
	error:    -1
 	success:   0
 */

static int init(int netno, PTABLE **protoc, char *params)
{
    int i1, i2, tport;
    short *spt;
    char *cp1, par[16], val[16];
    struct NET *netp;

    netp = &nets[netno];
    for (cp1=params; *cp1; )
    {
	Nsscanf(cp1, "%[^=]=%s %n", par, val, &i1);
	cp1 += i1;
	if (strcmp(par, "IRNO") == 0)
	    Nsscanf(val, "%i", &netp->irno[0]);
	else if (strcmp(par, "PORT") == 0)
	    Nsscanf(val, "%i", &netp->port);
    }
    i1 = protoc[1]->init(netno, protoc+1, params);
    if (i1 < 0)
	return i1;
    tport = netp->port;
    netp->bps = 10000000;

    i1 = _inb(tport+RESET); 			/* reset the board */
    _outb(tport+RESET, i1);
    _outb(tport+CMDR, MSK_PG0);
    for (i2=0; i2<1000; i2++);			/* delay */
    _outb(tport+ISR, 0xff);			/* clear and mask interrupts */
    _outb(tport+IMR, 0);
    _outb(tport+DCR, MSK_WTS+MSK_BMS+MSK_FT10);	/* configure */

    spt = (short *)&netp->id;			/* get address from board */
    if ((spt[0] | spt[1] | spt[2]) == 0)	/* unless configured */
    {
        _outb(tport+RBCR0, 2*Eid_SZ);
        _outb(tport+RBCR1, 0);
        _outb(tport+RSAR0, 0);
        _outb(tport+RSAR1, 0);
        _outb(tport+CMDR, MSK_PG0+MSK_RRE+MSK_STA);
        for (i1=0; i1<Eid_SZ; i1++)
	    netp->id.c[i1] = _inb(tport+DATAPORT);
    }

    _outb(tport+CMDR, MSK_PG1+MSK_RD2);		/* initial physical addr */
    for (i1=0; i1<Eid_SZ; i1++)
	_outb(tport+PAR+i1, netp->id.c[i1]);
    for (i1=0; i1<MARsize; i1++)		/* clear multicast */
	_outb(tport+MAR+i1, 0);
    _outb(tport+CURR, SM_RSTART_PG);		/* current RX page */

    _outb(tport+CMDR, MSK_PG0+MSK_RD2);
    _outb(tport+PSTART, SM_RSTART_PG);
    _outb(tport+BNRY, SM_RSTART_PG-1);
    _outb(tport+PSTOP, SM_RSTOP_PG);
    _outb(tport+IMR, 0x1f);			/* enable interrupts */
    _outb(tport+RCR, MSK_MON);			/* disable the rxer */
    _outb(tport+TCR, 0);			/* normal operation */

    _outb(tport+CMDR, MSK_STA+MSK_RD2);		/* put 8390 on line */
    _outb(tport+RCR, MSK_AB);			/* accept broadcast */

    IRinstall(netp->irno[0], netno, irhan);
#if NTRACE >= 1
    Nprintf("NE2000 %02x%02x%02x%02x%02x%02x IR%d P%x\n", netp->id.c[0],
	netp->id.c[1], netp->id.c[2], netp->id.c[3], netp->id.c[4],
	netp->id.c[5], netp->irno[0], tport); 
#endif
    return 0;
}


/* ==========================================================================
   Shut down the Ethernet interface.  Restores original IRQ, mask and vector.
   Turns off the controller. */

static void shut(int netno, PTABLE **protoc)
{
    struct NET *netp;

    netp = &nets[netno];
    IRrestore(netp->irno[0]);
    _outb(netp->port+CMDR, MSK_STP + MSK_RD2);
    protoc[1]->shut(netno, protoc+1);
}


/* ===========================================================================
   Protocol table for the driver. */

PTABLE NE2000_T = {"NE2000", init, shut, 0, opeN, closE, 0,
    writE, 0, MESSH_SZ};

