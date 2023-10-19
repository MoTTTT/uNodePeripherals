
/* +++=>>> * %n  Edition: %v  Last changed: %f  By: %w */
/* ETHERNET.C  Edition: 12  Last changed: 8-Aug-94,13:22:48  By: HARRY */
/* +++=>>> '%l' */
/* Currently extracted for edit by: '***_NOBODY_***' */
/*
    ETHERNET.C -- Ethernet Link Layer for USNET

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
#include "ethernet.h"

extern struct NET nets[];
extern const int confsiz;
extern struct NETCONF netconf[];
extern const struct NETDATA netdata[];
extern struct CONNECT connblo[];
extern PTABLE *const Ptable[];
extern PTABLE ARP_T;


/* ===========================================================================
   Ethernet write routine.  If we don't have the target Ethernet address, we
   send an ARP message and wait for the address.  Creates an Ethernet header
   and calls the lower level write.  As the Ethernet header is 14 bytes long,
   there is an extra 2 bytes in front for 32-bit processors.  Returns:
	success: number of characters sent
	error:   -1
*/

static int writE(int conno, PTABLE **protoc, MESS *mess)
{
    int i1, netno, confix;
    unsigned short us1, *sp;
    struct Ehdr *ehdrp;
    MESS *mp;

/* If there is a protocol path, we pick up the configuration index of the 
   target from the connection block.  If that is invalid, we either have 
   connected to an unconfigured host with a passive open, or we are sending
   out a broadcast.  Then the Ethernet address is in the connection block.

   If there is no protocol path, the argument conno is directly the 
   configuration index.  If that is valid, we are relaying to that host.
   If that is invalid, we are sending a message back to the originator, and
   pick up the Ethernet address from the "from" field. */

    if (protoc)
    {
	confix = connblo[conno].confix;
	netno = connblo[conno].netno;
	sp = (unsigned short *)&connblo[conno].hereid;
	goto lab1;
    }
    else
    {
	confix = conno;
    	if (confix < confsiz)
            netno = netconf[confix].netno;
	else
	{
	    netno = mess->netno;
	    sp = (unsigned short *)((char *)mess + MESSH_SZ + Eid_SZ);
	    goto lab1;
	}
    }

/* If we don't have the target host's address we use ARP to get it.  This
   is of course skipped if we talk to an unconfigured host. */

    sp = (unsigned short *)&netconf[confix].Eaddr;
    if (sp[0] == 0 && sp[1] == 0 && sp[2] == 0)
    {
	if ((mp = Ngetbuf()) == 0)
	    return NE_NOBUFS;
	mp->offset = MESSH_SZ + Ehdr_SZ;
	ARP_T.writE(confix, 0, mp);
    	ehdrp = (struct Ehdr *)((char *)mp + MESSH_SZ);
	memset((char *)&ehdrp->to, 0xff, Eid_SZ);
	memcpy((char *)&ehdrp->from, (char *)&nets[netno].id, Eid_SZ);
    	ehdrp->type = ET_ARP;
	mp->offset = MESSH_SZ;
	i1 = nets[netno].protoc[1]->writE(netno, 0, mp);
	if (i1 == 0)
            WAITFOR(mp->offset==MESSH_SZ+LHDRSZ, SIG_WN(netno),
		nets[netno].tout, i1);
	Nrelbuf(mp);
	WAITFOR(sp[0]|sp[1]|sp[2], SIG_ARP, ET_TOUT, i1);
	if (i1)
	    return NE_TIMEOUT;
    }

lab1:
    if (mess == 0)	/* phony write from open to force ARP */
	return 1;
    mess->offset = MESSH_SZ;
    ehdrp = (struct Ehdr *)((char *)mess + MESSH_SZ);
    memcpy((char *)&ehdrp->to, (char *)sp, Eid_SZ);
    memcpy((char *)&ehdrp->from, (char *)&nets[netno].id, Eid_SZ);
    if (protoc)
    	ehdrp->type = (protoc-1)[0]->Eprotoc;
    us1 = mess->id;
    i1 = nets[netno].protoc[1]->writE(netno, 0, mess);
    if (i1 != 0 || us1 <= bWACK)
        return i1;
    WAITFOR(mess->offset==MESSH_SZ+LHDRSZ, SIG_WN(netno), nets[netno].tout, i1);
    return 1;
}


/* ===========================================================================
   Screen an arrived Ethernet message.  Give it to indicated higher level.
   Returns:
	-3  call write
	-2  no further action
	-1  error occured
	n   please enter in queue number n
*/

static int screen(MESS *mess)
{
    int i1, nxtlev;
    struct Ehdr *ehdrp;

    ehdrp = (struct Ehdr *)((char *)mess + mess->offset);
    for (nxtlev=0; Ptable[nxtlev]; nxtlev++)
	if (ehdrp->type == Ptable[nxtlev]->Eprotoc)
	    goto lab3;
    return -1;
lab3:
    for (i1=0; i1<confsiz; i1++)
    	if (memcmp((char *)&netconf[i1].Eaddr, (char *)&ehdrp->from, 6) == 0)
	    break;
    mess->confix = i1;
    mess->offset += Ehdr_SZ;
    i1 = Ptable[nxtlev]->screen(mess);
    if (i1 == -3)
	writE(mess->confix, 0, mess);
    return i1;
}


/* ==========================================================================
   Receive routine.  This waits until the screener has queued a coming
   message for the particular connection.  As the Ethernet header is 14 bytes
   long, we insert an extra 2 bytes in front for 32-bit processors.  Returns:
	error:    -1
 	success:  message address
 */

static MESS *reaD(int conno, PTABLE **protoc)
{
    int i1;
    MESS *mess;
    register struct CONNECT *conp;
    
    conp = &connblo[conno];
    WAITFOR(conp->first || (conp->rxstat & S_EOF), SIG_RC(conno),
	conp->rxtout, i1);
    if (!conp->first)
	goto err1;
    BLOCKPREE();
    MESS_OUT(conp, mess);
    RESUMEPREE();
    mess->offset = Ehdr_SZ + MESSH_SZ;
    return mess;
err1:
    return 0;
}


/* ===========================================================================
   Initialize the Ethernet level for a network.  Calls the driver
   initialization.  Returns
	success: 1
	error:   -1
*/

static int init(int netno, PTABLE **protoc, char *params)
{
    int i1;
    struct NET *netp;
    
    netp = &nets[netno];
    nets[netno].id = netdata[netp->confix].Eaddr;
    i1 = protoc[1]->init(netno, protoc+1, params);
    if (i1 < 0)
	return i1;
    netconf[netp->confix].Eaddr = nets[netno].id;
    netp->sndoff = MESSH_SZ + Eid_SZ;
    netp->tout = ET_TOUT;
    netp->maxblo = ET_MAXLEN <= MAXBUF - MESSH_SZ ? ET_MAXLEN :
	MAXBUF - MESSH_SZ;
    return i1;
}


/* ===========================================================================
   Shut down an Ethernet network.  Calls the driver shutdown.
*/

static void shut(int netno, PTABLE **protoc)
{
    protoc[1]->shut(netno, protoc+1);
}


/* ===========================================================================
   Open a connection.  We then perform a dummy write in case the remote host
   is a neighbor and the hardware address is not known.  Write will do the
   needed ARP.  Returns:
	success: 1
	error:   -1
*/

static int opeN(int conno, PTABLE **protoc, int flags)
{
    int i1, i2;

    i1 = protoc[1]->opeN(conno, protoc+1, flags);
    if (i1 < 0)
	return i1;
    connblo[conno].maxdat = ET_MAXLEN <= MAXBUF - MESSH_SZ ? 
	ET_MAXLEN : MAXBUF - MESSH_SZ;
    connblo[conno].doffset = MESSH_SZ + LHDRSZ;
    i2 = connblo[conno].confix;
    if (i2 >= confsiz)
	return 1;
    i2 = netconf[i2].nexthix;
    i1 = writE(i2, 0, 0);
    connblo[conno].hereid = netconf[i2].Eaddr;
    return i1;
}


/* ===========================================================================
   Close a connection at the Ethernet level.  We call the driver level close.
*/

static void closE(int conno, PTABLE **protoc)
{
    protoc[1]->closE(conno, protoc+1);
}


/* ===========================================================================
   Protocol table for Ethernet. */

PTABLE Ethernet_T = {"Ethernet", init, shut, screen, opeN, closE,
    reaD, writE, ET_IP, LHDRSZ};

