
/* +++=>>> * %n  Edition: %v  Last changed: %f  By: %w */
/* TCP.C  Edition: 11  Last changed: 29-Aug-94,12:56:50  By: HARRY */
/* +++=>>> '%l' */
/* Currently extracted for edit by: '***_NOBODY_***' */
/*
    TCP.C -- Transport Control Protocol for USNET

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

#define IP_TCP 6		/* protocol number */
#define MAXDAT 536		/* default maximum data */
#define MAXWACK 3		/* maximum messages in the wait for ACK queue */
#define MAXFUT 5		/* maximum messages in the future queue */
#define MAXCDEL 10000		/* maximum delay in close */

#define CLOSEWIN() (conp->ninque > 1 || Nfirstbuf == 0)

struct Thdr {				/* TCP header */
    unsigned short myport;		/* source port */
    unsigned short herport;		/* dest port */
    unsigned long seqno;		/* sequence number */
    unsigned long ackno;		/* acknowledgement number */
    unsigned char hdrlen;		/* tcp header length in high 4 bits */
    unsigned char flags;		/* message flags, see below */
    unsigned short window;		/* window */
    unsigned short chksum;		/* checksum */
    unsigned short urgp;		/* urgent pointer */
};
#define Thdr_SZ 20		/* size of header */
#define ESTABLISHED   1		/* state machine states, see handbook */
#define FINWAIT_1     2
#define FINWAIT_2     3
#define CLOSED_WAIT   4
#define TIMEWAIT      5
#define LAST_ACK      6
#define CLOSED        7
#define SYN_SENT      8
#define SYN_RECEIVED  9
#define LISTEN       16
#define FIN 1			/* message flag bits, see handbook */
#define SYN 2
#define RST 4
#define PSH 8
#define ACK 0x10
#define URG 0x20

extern struct NETCONF netconf[];
extern struct NET nets[];
extern struct CONNECT connblo[];
extern const int confsiz;
extern MESS *Nfirstbuf;
extern int Nclocktick;


/* ===========================================================================
   Write routine.  Creates a header.  If the host's window is too small, waits.
   Adds the message to ACK wait list.  Calls lower-level write.  Returns:
	success: number of characters sent
	waiting for ACK: 0
	error:   -1
*/

static int writE(int conno, PTABLE **protoc, MESS *mess)
{
    int i1, tlen, hlen, hdroff;
    short *sp;
    unsigned long ul1, ul2;
    struct NET *netp;
    register struct CONNECT *conp;
    register struct Thdr *thdrp;
    struct { short s[2]; unsigned char Iadd1[Iid_SZ], Iadd2[Iid_SZ]; } pseudo;
#define pseudo_SZ 12

/* preparations, check of previous error */

    conp = &connblo[conno];
    if (conp->rxstat & S_NOACK)
	return NE_PROTO;
    netp = &nets[conp->netno];
    hlen = Thdr_SZ;
    hdroff = mess->offset;

/* If high bit of mlen set, it's a control message, size 0.  Control bits in
   txstat can also define a control message. */

    if (mess->mlen & 0x8000)
    {
	thdrp = (struct Thdr *)((char *)mess + hdroff);
	thdrp->flags = (unsigned char)mess->mlen;
        mess->mlen = hdroff + Thdr_SZ;
    }
    else
    {
	mess->offset = hdroff = hdroff - Thdr_SZ;
	thdrp = (struct Thdr *)((char *)mess + hdroff);
	thdrp->flags = ACK;
        if (conp->txstat & S_PSH)
        {
	    thdrp->flags |= PSH;
	    conp->txstat &= ~S_PSH;
	}
        if (conp->txstat & S_FIN)
        {
	    thdrp->flags |= FIN;
	    conp->txstat &= ~S_FIN;
    	    conp->state = conp->rxstat & S_EOF ? LAST_ACK : FINWAIT_1;
	}
    }
    thdrp->urgp = 0;

/* if SYN, put in maximum block size */

    if (thdrp->flags & SYN)
    {
    	hlen += 4;
        mess->mlen = hdroff + Thdr_SZ + 4;
	sp = (short *)((char *)mess + hdroff + Thdr_SZ);
	i1 = netp->maxblo - hdroff + MESSH_SZ + LHDRSZ - Thdr_SZ;
	*sp++ = NC2(0x0204), *sp = NC2(i1);
	conp->txtout = netp->tout;
	conp->txave = netp->tout << 2;
	conp->txvar = netp->tout;
    }

/* put in header length, port numbers, start on the checksum */

    thdrp->hdrlen = (hlen << 4) >> 2;
    i1 = conp->myport;
    thdrp->myport = NC2(i1);
    i1 = conp->herport;
    thdrp->herport = NC2(i1);
    pseudo.s[0] = NC2(IP_TCP);
    tlen = mess->mlen - hdroff;
    if (tlen & 1)
        *((char *)thdrp + tlen) = 0;
    pseudo.s[1] = NC2(tlen);
    *(struct Iid *)&pseudo.Iadd1 = conp->confix < confsiz ?
	netconf[conp->confix].Iaddr : conp->heriid;
    *(long *)&pseudo.Iadd2 = *(long *)&netconf[netp->confix].Iaddr;
    thdrp->chksum = Nchksum((unsigned short *)&pseudo, pseudo_SZ>>1);

/* If this is a data message and the flow control window is shut, or there
   are too many messages in the wait-for-ACK queue, we need to wait.
   If the window will not open, we'll still proceed, because an ACK that
   opens the window could be lost. */

    tlen -= hlen;
    if (tlen)
    {
	ul1 = conp->txseq + tlen;
	ul2 = netp->tout * 16;
	WAITFOR(conp->nwacks < MAXWACK, SIG_CC(conno), ul2, i1);
	if (i1)
	{
#if NTRACE >= 1
	    Nprintf("TX WACK queue %d\n", conp->nwacks);
#endif
	    return NE_TIMEOUT;
	}
	ul2 >>= 1;
	WAITFOR((long)(conp->ackno + conp->window - ul1) > 0, SIG_CC(conno),
	    ul2, i1);
    }

/* put in sequence numbers, window size, finish the checksum */

    ul1 = conp->txseq;
    ul1 = NC4(ul1);
    thdrp->seqno = ul1;
    conp->ackdseq = ul1 = conp->seqtoack;
    ul1 = NC4(ul1);
    thdrp->ackno = ul1;
    conp->sendack = 0;
    i1 = conp->maxdat * 3;
    if (CLOSEWIN())
	i1 = 0;
    conp->mywindow = i1;
    thdrp->window = NC2(i1);
    thdrp->chksum = ~Nchksum((unsigned short *)thdrp, (tlen+hlen+1)/2);

#if NTRACE >= 2
    ul1 = thdrp->seqno;
    ul1 = NC4(ul1);
    ul2 = thdrp->ackno;
    ul2 = NC4(ul2);
    Nprintf("TX %ld C%d/%x ST%d DL%d W%u/%u SQ%lx AK%lx %x\n", TimeMS(), conno,
	conp->myport, conp->state, tlen, conp->mywindow, conp->window,
	ul1, ul2, thdrp->flags);
#endif

/* FIN or SYN counts as 1 in the sequence number. */

    if (thdrp->flags & (FIN | SYN))
	tlen++;

/* We set retry count, timeout, add message to "wait for ack" queue */

    if (tlen)
    {
	mess->conno = 0;		/* used as retry count */
	if (mess->id != bALLOC)
	    Npanic("wack q");
	mess->id = bWACK;
        mess->next = 0;
	BLOCKPREE();
        conp->wackl = conp->wackl->next = mess;
	conp->nwacks++;
	RESUMEPREE();
    	mess->timems = TimeMS();
    }

/* bump transmit sequence number, call low-level transmit */

    if (tlen)
        conp->txseq += tlen;
    i1 = protoc[1]->writE(conno, protoc+1, mess);
    if (tlen)
	return 0;
    return i1;
}


/* ===========================================================================
   Screening function, checks if the coming message is for this host. 
   Searches the connection tables for one that is open for the right
   port.  Return:
	-5  processed, check future queue
	-4  do not release
        -2  processed, no further action, free message
	-1  message rejected
	n   please enter in queue number n
*/

static int screen(MESS *mess)
{
    int i1, stat, status, netno, confix, conno, portno, herport, tlen, hlen;
    unsigned long ul1, ul2, ul3;
    unsigned short us1;
    char *cp, *cp2;
    PTABLE **ppp;
    register struct Thdr *thdrp;
    register struct CONNECT *conp;
    MESS *mp, *mp2;
    struct { short s[2]; unsigned char Iadd1[Iid_SZ], Iadd2[Iid_SZ]; } pseudo;

/* prepare by loading variables */

    netno = mess->netno;
    thdrp = (struct Thdr *)((char *)mess + mess->offset);
    portno = thdrp->herport;
    portno = NC2(portno);
    herport = thdrp->myport;
    herport = NC2(herport);

/* find the connection block */

    for (conno=0; conno<NCONNS; conno++)
    {
	conp = &connblo[conno];
	if ( (conp->txstat & S_OPEN) == 0)
	    continue;
	confix = conp->confix;
	if (confix < confsiz)
	    if (conp->netno != netno)
		continue;
	if (conp->state != LISTEN)
	    if (mess->confix != confix) continue;
	if (conp->state != SYN_SENT && conp->state != LISTEN)
	    if (conp->herport != herport)
		continue;
	if (conp->myport == portno)
	    goto lab1;
    }
    goto err1;

/* check the message, checksum, flags */

lab1:
    tlen = mess->mlen - mess->offset;
    if (tlen & 1)
        *((char *)thdrp + tlen) = 0;
    us1 = thdrp->chksum;
    pseudo.s[0] = NC2(IP_TCP);
    pseudo.s[1] = NC2(tlen);
    memcpy((char *)&pseudo.Iadd1, (char*)mess+mess->conno, 2*Iid_SZ);
    thdrp->chksum = Nchksum((unsigned short *)&pseudo, pseudo_SZ>>1);
    if ((unsigned short)~Nchksum((unsigned short *)thdrp, (tlen+1)/2) != us1)
	goto err1;
    thdrp->chksum = us1;
    if (conp->state == LISTEN && (thdrp->flags & SYN) == 0)
	goto err1;

/* get variables from the header */

    hlen = (thdrp->hdrlen >> 4) << 2; 
    tlen -= hlen;
    us1 = NC2(thdrp->window);
    ul1 = thdrp->seqno;
    ul1 = NC4(ul1);
    ul2 = thdrp->ackno;
    ul2 = NC4(ul2);
#if NTRACE >= 3
    Nprintf("SC %ld C%d/%x ST%d DL%d W%u/%u SQ%lx AK%lx %x\n", TimeMS(), conno,
	conp->myport, conp->state, tlen, conp->mywindow, us1,
	ul1, ul2, thdrp->flags);
#endif

/* if not SYN, check sequence number.  If not right, we still accept "future"
   messages that are slightly out of order, we enter them into the future
   queue.  If FIN is not set in the message and the connection is in the
   established state, we proceed to send an ACK with a zero window and the old
   (expected) sequence number. */

    status = conno;
    if (!(thdrp->flags & (SYN|RST)) && conp->state != SYN_SENT)
    {
	if (conp->rxseq - ul1 < MAXBUF && ul1 + tlen - conp->rxseq < MAXBUF)
	{
	    if ((i1 = conp->rxseq - ul1) > 0)	/* remove duplicated bytes */
	    {
	        cp = (char *)thdrp + hlen;
		cp2 = cp + i1;
	        mess->mlen -= i1;
		ul1 += i1;
	        i1 = tlen = tlen - i1;
		if (tlen <= 0)
		    goto err5;
		while (i1--)
		    *cp++ = *cp2++;
	    }
	    goto inseq;
	}
	if (conp->rxseq - ul1 < 8*MAXBUF)
	    goto err2;
	if (ul1 - conp->rxseq >= 8*MAXBUF)
	    goto err1;
	mp2 = (MESS *)&conp->future; 
	for (i1=0,mp=mp2->next; mp; mp2=mp,mp=mp->next,i1++)
	{
	    ul3 = ((struct Thdr *)((char *)mp + mp->offset))->seqno;
	    ul3 = NC4(ul3);
	    if (ul3 == ul1 && mp->mlen == mess->mlen)
		goto err1;
	    if (ul3 > ul1)
		break;
	}
	if (i1 >= MAXFUT)
	{
#if NTRACE >= 3
	    Nprintf("FU discard\n");
#endif
	    goto err1;
	}
#if NTRACE >= 3
	Nprintf("FU queued\n");
#endif
	mess->next = mp;
	mp2->next = mess;
	if ((thdrp->flags & FIN) || conp->state != ESTABLISHED)
	    goto err4;
	tlen = conp->rxseq - ul1;	/* no rxseq update */
	if (mp)				/* no window update unless last */
	    us1 = conp->window;
	status = -4;
    }
inseq:
    conp->window = us1;		/* update window in proper order */

/* here handle the control options, in practice maximum block size */

    for (cp=(char *)mess+mess->offset+Thdr_SZ;
	cp<(char *)mess+mess->offset+hlen;
	cp+=cp[1])
    {
        switch (cp[0])
        {
        default:
	    break;
        case 2:
            i1 = NC2(*(short *)(cp+2));
	    stat = nets[netno].maxblo - mess->offset +
		MESSH_SZ + LHDRSZ - Thdr_SZ;
	    conp->maxdat = i1 <= stat ? i1 : stat;
        }
    }

/* if this is an ACK, we remove from the "wait for ack" queue all messages
   up to this ACK sequence number.  The connection block ackno is updated 
   only when the ACK is actually used.  This ensures that out-of-order ACK's
   will not leave ackno to an old value. */

    if (thdrp->flags & ACK)
    {
        while ((mp = conp->wackf) != 0)
        {
	    ul3 = ((struct Thdr *)((char *)mp + mess->offset))->seqno;
	    ul3 = ul2 - NC4(ul3);
	    if (ul3 >= 8*MAXBUF || ul3 == 0)
	        break;
	    if (mp->id != bWACK)
	        Npanic("wack rem");

/* Adjust timeout if there were no retransmissions.  We use the van Jacobson
   formula.
   If there was 1 retransmission, we make no changes to timeout.  If there
   were more than 1, we take the doubled txtout as the new txave.
*/
	    if (mp->conno == 0)	
	    {
	        ul3 = TimeMS() - mp->timems + Nclocktick;
		if (ul3 > MAXTXTOUT)
		    goto lab7;
		ul3 -= conp->txave / 8;
		conp->txave += ul3;
		if ((long)conp->txave < 0)
		    conp->txave = 40;
		if ((long)ul3 < 0)
		    ul3 = -ul3;
		ul3 -= conp->txvar / 4;
		conp->txvar += ul3;
		if (conp->txvar < 10)
		    conp->txvar = 10;
	        conp->txtout = (conp->txave / 8) + (conp->txvar / 2);
	    }
	    else if (mp->conno > 1 && conp->state == ESTABLISHED)
	    {
		conp->txtout <<= mp->conno - 1;
		conp->txave = conp->txtout << 2;
		conp->txvar = conp->txtout;
	    }
lab7:	    mp->id = bALLOC;
	    BLOCKPREE();
            if ((conp->wackf = mp->next) == 0)
	        conp->wackl = (MESS *)&conp->wackf;
	    conp->nwacks--;
	    RESUMEPREE();
	    if (((struct Thdr *)((char *)mp + mess->offset))->flags & FIN)
	    {
		if (conp->state == FINWAIT_1)
		    conp->state = FINWAIT_2;
		else if (conp->state == LAST_ACK)
		    conp->state = CLOSED;
	    }
	    Nrelbuf(mp);
    	    conp->ackno = ul2;
        }
    }

/* process message depending on the state of the connection */

    switch (stat = conp->state)
    {
    case SYN_RECEIVED:
	if ((thdrp->flags & ACK) == 0)
	    goto err1;
    	conp->state = ESTABLISHED;
    case ESTABLISHED:
    case FINWAIT_1:
    case FINWAIT_2:
	if (thdrp->flags & SYN)
	    goto err2;
	if (thdrp->flags & RST)
	{
    	    conp->state = CLOSED;
	    mess->mlen = 0x8000 | SYN;
	    writE(conno, conp->protoc, mess);
    	    conp->state = SYN_SENT;
	    goto err4;
        }
	if (thdrp->flags & FIN)
	{
    	    conp->rxstat |= S_EOF;
	    if (stat == FINWAIT_2)
	        conp->state = TIMEWAIT;
	    else if (stat == FINWAIT_1)
	        conp->state = LAST_ACK;
	}

/* we combine any messages that arrive too quickly to read at once */

	if (tlen && status >= 0 && conp->first)
	{
	    mp = conp->last;
	    if (mp->mlen + tlen <= MAXBUF)
	    {
		memcpy((char *)mp+mp->mlen, (char *)thdrp+hlen, tlen);
		mp->mlen += tlen;
		mess->conno = conno;
		status = -5;
	    }
	}

/* Here we need to ack.  The rules are:
    - If the window just closed, we'll send the ACK right NOW, but we don't
      ACK this message.  (Future messages take this course.)
    - If the window is open, or the other host has sent an EOF, we request
      that this message be ACK'd.
*/
	i1 = tlen + (thdrp->flags & FIN);
	if (i1)	
	{
    	    conp->rxseq = ul1 + i1;
    	    if (conp->rxstat & S_EOF)
	    {
	        conp->sendack = 1;
		conp->seqtoack = conp->rxseq;
	    }
	    else if (CLOSEWIN())
	    {
		if (conp->mywindow)
	        {
	            conp->sendack = 1;
	            if ((mp = Ngetbuf()) == 0)
	 	        goto lab6;
    	            mp->mlen = 0x8000 | ACK;
    	            mp->netno = mess->netno;
	            mp->offset = mess->offset;
		    mp->id = bRELEASE;
    	            if (writE(conno, conp->protoc, mp))
			Nrelbuf(mp);
		}
	    }
        }

/* If there is data the network task will queue the message for the connection
   for reading.  Signaling here may or may not be necessary, but should do no
   harm.  */

lab6:	if (tlen)
	{
    	    WAITNOMORE(SIG_CC(conno));
	    return status;
	}
	break;
    case CLOSED_WAIT:
	conp->state = CLOSED;
	break;
    case LISTEN:		/* this is passive open finding a partner */
	if (thdrp->flags & SYN)
	{
	    conp->seqtoack = conp->rxseq = ul1 + 1;
   	    conp->state = SYN_RECEIVED;
    	    conp->herport = NC2(thdrp->myport);
	    conp->heriid = *(struct Iid *)&pseudo.Iadd1;
    	    conp->hereid = *(struct Eid *)((char *)mess + nets[netno].sndoff);
    	    conp->confix = mess->confix;
    	    conp->netno = netno;
	    conp->doffset = mess->offset + Thdr_SZ;;
	    for (ppp=conp->protoc; *ppp; ppp++) 
	    {
		if (*ppp == nets[netno].protoc[0])
		    break;
	    }
	    ppp[0] = nets[netno].protoc[0];
	    ppp[1] = nets[netno].protoc[1];
	    mess->mlen = 0x8000 | SYN | ACK;
	    writE(conno, conp->protoc, mess);
	    goto err4;
	}
	break;
    case SYN_SENT:
	if (thdrp->flags & ACK)
	{
	    conp->txseq = ul2;
	    if (thdrp->flags & SYN)
	    {
	        conp->seqtoack = conp->rxseq = ul1 + 1;
    	        conp->state = ESTABLISHED;
	        mess->mlen = 0x8000 | ACK;
	    }
	    else
	        mess->mlen = 0x8000 | RST;
	    writE(conno, conp->protoc, mess);
	}
	else if (thdrp->flags & SYN)
	{
	    conp->txseq = 100;
	    conp->seqtoack = conp->rxseq = ul1 + 1;
	    mess->mlen = 0x8000 | ACK | SYN;
	    writE(conno, conp->protoc, mess);
    	    conp->state = SYN_RECEIVED;
	    goto err4;
	}
	break;
    }
    WAITNOMORE(SIG_CC(conno));
    return -2;
err2:
    conp->sendack = 1;
err1:
    return -1;
err4:
    return -4;
err5:
    mess->conno = conno;
    return -5;
}


/* ===========================================================================
   Read routine.  Calls the lower level read.  If successfull, checks the
   header.  If good, gives the caller the message.  Returns:
	success: message address
	error:   0
*/

static MESS *reaD(int conno, PTABLE **protoc)
{
    int hdroff, len;
    unsigned long ul1, ul2;
    MESS *mp;
    register struct Thdr *thdrp;
    register struct CONNECT *conp;

    conp = &connblo[conno];
/* call low-level read */
    mp = protoc[1]->reaD(conno, protoc+1);
    if (mp == 0)
	return 0;
/* get some variables */
    hdroff = mp->offset;
    thdrp = (struct Thdr *)((char *)mp + hdroff);
    conp->herport = NC2(thdrp->myport);
    len = (thdrp->hdrlen >> 4) << 2; 
    mp->offset = hdroff + len;
    ul2 = thdrp->ackno;
    ul2 = NC4(ul2);
    ul1 = thdrp->seqno;
    ul1 = NC4(ul1);
    len = mp->mlen - mp->offset;
/* If this is not ACK'd yet we'll ask the network task to do that.
   Also if a closed window opens, we'll ask for an ACK.
*/
    if ((long)(ul1 + len - conp->seqtoack) > 0)
    {
        conp->seqtoack = ul1 + len;
	if (conp->first == 0)
	    goto ask;
    }
    if (!CLOSEWIN() && conp->mywindow == 0)
    {
ask:	conp->sendack = 1;
	nets[mp->netno].worktodo = 1;
	WAITNOMORE_IR(SIG_RN(mp->netno));
    }
#if NTRACE >= 2
    Nprintf("RX %ld C%d/%x ST%d DL%d SQ%lx AK%lx %x\n", TimeMS(), conno,
	conp->myport, conp->state, len, ul1, ul2, thdrp->flags);
#endif
    return mp;
}


/* ===========================================================================
   Open function. Initialize connection table, call next level. */

static int opeN(int conno, PTABLE **protoc, int flags)
{
    int i1;
    MESS *mess;
    register struct CONNECT *conp;

    conp = &connblo[conno];

/* passive open */

    if (conp->herport == 0)
    {
	conp->txseq = 100;
        conp->rxtout = TOUT_PASSIVE;
	conp->state = LISTEN;
	conp->maxdat = MAXDAT;
	if (flags & S_NOWA)
	    return 0;
    }

/* active open */

    else
    {
	i1 = protoc[1]->opeN(conno, protoc+1, flags);
	if (i1 < 0)
	    return i1;
	if ((mess = Ngetbuf()) == 0)
	    return NE_NOBUFS;
	conp->maxdat = MAXDAT;
	conp->rxtout = nets[conp->netno].tout * 32;
	conp->txseq = conp->ackno = 100;
	conp->state = SYN_SENT;
	mess->mlen = 0x8000 | SYN;
    	mess->netno = conp->netno;
	mess->offset = conp->doffset;
	conp->maxdat -= Thdr_SZ;
	conp->doffset += Thdr_SZ;
	writE(conno, protoc, mess);
    }

/* active open waits for answer */

    WAITFOR(conp->state==ESTABLISHED, SIG_CC(conno), conp->rxtout, i1);
    if (i1)
    {
#if NTRACE >= 1
    	Nprintf("OP C%d/%x S%d timeout\n", conno, conp->myport, conp->state);
#endif
	if ((mess = conp->wackf) != 0)		/* clean WACK queue */
	{
	    mess->id = bALLOC;
	    Nrelbuf(mess);
	}
	return NE_TIMEOUT;
    }
    conp->rxtout = nets[conp->netno].tout * 8;
    return 1;
}


/* ===========================================================================
   Close function.  Send FIN.  Call next level. */

static void closE(int conno, PTABLE **protoc)
{
    int i1;
    unsigned long ul1;
    MESS *mp, *nmess;
    PTABLE **ppp;
    register struct CONNECT *conp;

    conp = &connblo[conno];

/* send the close message */

    if (conp->state == ESTABLISHED)
    {
    	if ((mp = Ngetbuf()) == 0)
	    goto lab6;
    	mp->mlen = 0x8000 | FIN | ACK;
        for (i1=0,ppp=protoc+1; *ppp; ppp++)
            i1 += ppp[0]->hdrsiz;
        mp->offset = i1;
    	mp->netno = conp->netno;
    	conp->state = conp->rxstat & S_EOF ? LAST_ACK : FINWAIT_1;
    	if (writE(conno, conp->protoc, mp))
	    Nrelbuf(mp);
    }

/* delay while waiting for proper response sequence */

lab6:
    ul1 = conp->txtout * 4;
    if (ul1 > MAXCDEL)
	ul1 = MAXCDEL;
#if NTRACE >= 2
        Nprintf("CL %ld C%d/%x delay %ld ms\n", TimeMS(), conno, conp->myport,
	    ul1);
#endif
    ul1 += TimeMS();
    while ((long)(TimeMS() - ul1) < 0)
	YIELD();
    if (conp->state != CLOSED && conp->state != TIMEWAIT)
    {
	conp->rxstat |= S_NOACK;
#if NTRACE >= 1
        Nprintf("CL %ld C%d/%x state S%d\n", TimeMS(), conno, conp->myport,
	    conp->state);
#endif
    }
    conp->state = CLOSED;
    protoc[1]->closE(conno, protoc+1);

/* get rid of possible messages in wait-for-ack and future queues */

    for (mp=conp->wackf; mp; )
    {
	nmess = mp->next;
	if (mp->id != bWACK)
	    Npanic("close wack");
	if (mp->mlen > conp->doffset)
	    conp->rxstat |= S_NOACK;
	mp->id = bALLOC;
	Nrelbuf(mp);
	mp = nmess;
    }
    for (mp=conp->future; mp; )
    {
	nmess = mp->next;
	Nrelbuf(mp);
	mp = nmess;
    }
}


/* ===========================================================================
   Protocol table for TCP. */

PTABLE TCP_T = {"TCP", 0, 0, screen, opeN, closE, reaD, writE,
    IP_TCP, Thdr_SZ};

"" with " ([y] or n)  (y or [n]) Çhit space to continue not found: "Çok to replace? (y or [n])  	error in bad hex valuebad '\' codemissing '='missing ';'bad hex valuebad AV valuebad AW valuebad AX valuebad AF typebad commandno macro namebad commandmacro nesting too deepMacro name: Macro file: ÇControl C to stop\NL\EMno such macrono such macro-ÇCreate    Get       Insert    List     ÇSaveMacro Other illegal command  some text lostÅŠ €ô  (‰–´=  ‹Øÿ· ÿ· FÚPš    ƒÄÀuë,ÿFøƒ~ø}‹Føº÷ê‹Øƒ¿À u´é.GÄ^ß&€? téiÿ¸Pÿvôÿvòš    ƒÄ÷ØÀ@‰FöÄ^ò&€?*uéª ÇFşÿ 3ÿé ‹Çº ÷ê‹Øö‡ tëzÿvôÿvò‹Çº ÷ê‹Øÿ· ÿ·  š    ƒÄÀtëU€~Ú*t‹Çº ÷ê‹ØŠ‡ ´ ;Føtë9‹Çº ÷ê‹ØŠ‡ :Fşs'‹Çº ÷ê‹ØŠ‡ ´ ‰Fş‰~ú‹Çº ÷ê‹ØŠ‡ ´ ‰FøG;>  }éjÿ~úÿ uéNÇFü  ë‹FüºŒ ÷ê‹ØŠ‡ ˜Àuë	ÿFüƒ~ü|âƒ~üu¸v Pš    YY‹FüºŒ ÷ê Œ^ì‰Fê¸Œ P3ÀPÿvìÿvêAœÌ ÇëÏÜVÇØÇ¾ÇšÇÇ{ÇiÇSÏ5VÇ2Ç.ÇÎæVÆÜÆÃÎ¡VÆ™Æ•ÆˆÎjVÍ»VÅ²Å®Å€ÅSÅ0Å,ÅÄúÄöÄŞÄÚÄÃÄ¿Ä´Ä¡Ä‘ÌxVÄoÄkÄI  š    ƒÄÄ^ê&Æ3ÿ‹F‹V
‰Fô‰Vòé‘ FÚŒVğ‰FîëÄ^òÿFò&ŠÄ^î&ˆ</uëÿFîÄ^ò&€? ußÄ^î&Æ ÇFş  ëG‹^ş±Óãÿ·+ ÿ·) FÚPš    ƒÄÀu$‹^ş±Óã‹‡+ ‹—) ‹ß±ÓãÄvêó&‰DD&‰TBë	ÿFşƒ~ş|³ƒ~şuéBGÄ^ò&€? técÿ‹Fêj ÿvìP¸a P¹ š    Ä^ê¡_ ‹] &‰Gh&‰Wf~øÿ tV‹Føº÷ê‹Ø‹‡Ä‹—Â‹ß±ÓãÄvêó&‰DD&‰TBGƒ~ö téÖ ë%‹Føº÷ê‹Ø‹‡È‹—Æ‹ß±ÓãÄvêó&‰DD&‰TBÄ^êŠFø&ˆGÄ^êŠFú&ˆG÷F€ t ¸Œ Pÿvÿvÿvìÿvêš    ƒÄ
Ä^ê&ÆG ‹Fì‹VêƒÂ,Ä^ê&‰G2&‰W0‹Fì‹VêƒÂ4Ä^ê&‰G:&‰W8Ä^ê‹F&‰GbÄ^ê‹F&‰Gdÿv‹FêB ÿvìPÿvüÄ^ê&Ä_B&ÿ_ƒÄ‰Fşƒ~ş }Ä^ê&Æ ‹Fşë‹FüëùÄ^ê&Æ ¸õÿëí_^‹å]ËU‹ìƒìV‹vƒşr¸öÿé£ ‹ÆºŒ ÷ê Œ^ô‰FòÄ^ò&öuëßÄ^ò&€ÿt‹FòB ÿvôPVÄ^ò&Ä_B&ÿ_ƒÄÄ^ò&‹G.&‹W,‰Fü‰Vúë)Ä^ú&‹G&‹‰Fø‰Vöÿvüÿvúš    YY‹Fø‹Vö‰Fü‰Vú‹FúFüuÏÄ^ò&öGt¸òÿë3À‰FşÄ^ò&Æ ‹FşéZÿ^‹å]ËU‹ìƒì
VW‹~ƒÿr¸öÿéÖ ‹ÇºŒ ÷ê Œ^ø‰FöÄ^ö&ötÄ^ö‹F&Gv=üvëĞš    ‰Vü‰FúÂu¸ñÿë¿Ä^ö&ŠGvÄ^ú&ˆGÿvÿv
ÿvÄ^ö‹Fú&GvÿvüPš    ƒÄ
Ä^ö‹F&GvÄ^ú&‰GÄ^ö&ŠGÄ^ú&ˆG
ÿvüÿvú‹FöB ÿvøPWÄ^ö&Ä_B&ÿ_"ƒÄ
‰Fşƒ~ş tÿvüÿvúš    YY3öëVšf  YFƒş|ó‹Fşé'ÿ_^‹å]ËU‹ìƒì
VW