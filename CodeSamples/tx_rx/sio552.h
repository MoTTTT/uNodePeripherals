/************************************************************************/
/*		SIO552.H : Header file  				*/
/*		J.DU Preez '92						*/
/************************************************************************/
extern		char			NUMBYTMST;
extern		bit			SLAVE_R_flag;
void		set_sio1_master		( unsigned char addr, 
					  unsigned char length, 
					  char idata *d_ptr );
void		sio1_init		( char own_slave_addr );
void		set_sio1_slave		( char idata *d_ptr,
					  unsigned char length );

