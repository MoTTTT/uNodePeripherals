
/* +++=>>> * %n  Edition: %v  Last changed: %f  By: %w */
/* SOCKET.H  Edition: 2  Last changed: 1-Mar-94,10:09:12  By: HARRY */
/* +++=>>> '%l' */
/* Currently extracted for edit by: '***_NOBODY_***' */
/*
    SOCKET.H -- BSD Socket Definitions for USNET

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

/* protocol family */

#define	PF_INET		2		/* TCP/IP and related */
#define	AF_INET		2		/* TCP/IP and related */

/* socket types */

#define	SOCK_STREAM	1		/* stream socket */
#define	SOCK_DGRAM	2		/* datagram socket */
#define	SOCK_RAW	3		/* raw-protocol interface */

/* options for getsockopt() and setsockopt() */

#define	SOL_SOCKET	0xffff		/* options for socket level */

#define	SO_DEBUG	0x0001		/* turn on debugging info recording */
#define	SO_REUSEADDR	0x0004		/* allow local address reuse */
#define	SO_KEEPALIVE	0x0008		/* keep connections alive */
#define	SO_DONTROUTE	0x0010		/* just use interface addresses */
#define	SO_BROADCAST	0x0020		/* permit sending of broadcast msgs */
#define	SO_LINGER	0x0080		/* linger on close if data present */
#define	SO_OOBINLINE	0x0100		/* leave received OOB data in line */
#define	SO_SNDBUF	0x1001		/* send buffer size */
#define	SO_RCVBUF	0x1002		/* receive buffer size */
#define	SO_ERROR	0x1007		/* get error status and clear */
#define	SO_TYPE		0x1008		/* get socket type */

/* structures */

struct sockaddr {		/* generic socket address */
    unsigned short sa_family;		/* address family */
    char sa_data[14];			/* up to 14 bytes of direct address */
};
struct in_addr {		/* Internet address */
    unsigned long s_addr;
};
struct sockaddr_in {		/* Internet socket address */
    short sin_family;			/* why signed here ? */
    unsigned short sin_port;
    struct in_addr sin_addr;
    char sin_zero[8];
};

struct iovec {			/* address and length */
    char *iov_base;			/* base */
    int iov_len;			/* size */
};
struct msghdr { 		/* Message header for recvmsg and sendmsg. */
    char *msg_name;			/* optional address */
    int	msg_namelen;			/* size of address */
    struct iovec *msg_iov;		/* scatter/gather array */
    int	msg_iovlen;			/* # elements in msg_iov */
    char *msg_accrights;		/* access rights sent/received */
    int	msg_accrightslen;
};

struct hostent {		/* structure for gethostbyname */
	char *h_name;			/* official name of host */
	char **h_aliases;		/* alias list */
	int h_addrtype;			/* host address type */
	int h_length;			/* length of address */
	char **h_addr_list;		/* list of addresses from name server */
#define	h_addr h_addr_list[0]		/* address, for backward compatiblity */
};

struct servent {		/* structure for getservbyname */
	char *s_name;			/* official service name */
	char **s_aliases;		/* alias list */
	int s_port;			/* port # */
	char *s_proto;			/* protocol to use */
};

#define	SINT sizeof(int)
#define	FD_SET(n, p)	((p)->fds_bits[(n)/SINT] |= (1 << ((n) % SINT)))
#define	FD_CLR(n, p)	((p)->fds_bits[(n)/SINT] &= ~(1 << ((n) % SINT)))
#define	FD_ISSET(n, p)	((p)->fds_bits[(n)/SINT] & (1 << ((n) % SINT)))
#define	FD_ZERO(p)	memset((void *)(p), 0, sizeof (*(p)))

#define	FD_SETSIZE 256
typedef struct fd_set {		/* Bit mask for select() */
    long fds_bits[FD_SETSIZE/32];
} fd_set;

struct timeval {		/* Timeout format for select() */
    long tv_sec;			/* seconds */
    long tv_usec;			/* microseconds */
};

/* function prototypes */

/* If the following definitions cause trouble, delete them and use directly the
   forms Nread(), Nwrite(), closesocket() for your sockets. */

#if 0
#define read(s, buff, len) Nread(s, buff, len)
#define write(s, buff, len) Nwrite(s, buff, len)
#define close(s) closesocket(s)
#endif

/* If you use select for other purposes, rename the following to Nselect. */

int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds,
    struct timeval *timeout);

int accept(int s, struct sockaddr *name, int namelen);
int bind(int s, struct sockaddr *name, int namelen);
int connect(int s, struct sockaddr *name, int namelen);
int getsockname(int s, struct sockaddr *name, int *namelen);
int getsockopt(int s, int level, int optname, char *optval, int *optlen);
int setsockopt(int s, int level, int optname, char *optval, int optlen);
int listen(int s, int backlog);
int recv(int s, char *buf, int len, int flags);
int recvfrom(int s, char *buf, int len, int flags, struct sockaddr *from,
    int *fromlen);
int recvmsg(int s, struct msghdr *msg, int flags);
int send(int s, char *buf, int len, int flags);
int sendto(int s, char *buf, int len, int flags, struct sockaddr *to,
    int tolen);
int sendmsg(int s, struct msghdr *msg, int flags);
int shutdown(int s, int how);
int socket(int domain, int type, int protocol);
int closesocket(int conno);
struct hostent *gethostbyname_r(char *hnp, struct hostent *result,
    char *buffer, int buflen, int *h_errnop);
