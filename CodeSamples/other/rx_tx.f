/****************************************************************************/
/*                  Master Controller 87C552                                */
/*                  J.Du Preez '92                                          */
/****************************************************************************/

#pragma ROM( COMPACT )
#pragma CODE
																								 /* assembly mnemonics list */
#include <reg552.h>
#include <stdio.h>		
#include <intrins.h>
#include <string.h>
#include <sio552.h>
#include <n3inc.c>

unsigned char pos;
unsigned char idata TX[2];
unsigned char idata receive[1];
unsigned char idata COMP1[] = { 0xDC, 0x10 };
unsigned char idata COMP2[] = { 0xDF, 0x8A };
unsigned char idata Error[] = { "E" };

/************************* SERIAL COMMUNICATION ****************************/

SerCom( )	interrupt 4			// RS-232 interrupt
{
	if( RI == 1 )
	{
		TX[pos] = S0BUF;
		pos++;
	}
	RI = 0;
}

/***************************** INITIALIZATION ********************************/

init( )						// initialize 87C552
{
	ES0 = 1;				// enable serial port interrupt
	EX1 = 1;				// enable external interrupt1
	IT1 = 1;				// falling edge triggered
	init_lcd( );				// initialize lcd display
	init_sio0( );				// initialize RS-232 port
	sio1_init( 0x50 );			// initialize I2C bus	
	SLAVE_R_flag = 0;			// 
	set_sio1_slave( receive, 1 );		// setup I2C to receive 9 bytes
}

/******************************* MAIN FUNCTION *******************************/

main( )
{
	unsigned int ptr;
 
	init( );
	while( 1 )
	{	
		while( !SLAVE_R_flag );
		SLAVE_R_flag = 0;
		set_lcd( LINE_1 );
		printf( "%c", receive[0] );
		ptr = receive[0];
		switch( ptr )
		{
			case 'F':
				io_stream = RS232;
				putchar( 0x0 );
				putchar( 0xDC );
				putchar( 0x10 );
				io_stream = LCD_COMMAND;
				pos = 0;
				while( pos != 2 );
				ptr = strncmp( TX, COMP1, 2 );
				if( ptr == 0 )
				{ 
					set_lcd( LINE_2 );
					printf( "%c     ", receive[0] );
					set_sio1_master( 0x52, 1, receive );
					break;
				}
				else
				{
					set_lcd( LINE_2 );
					printf( "ERROR" );
					set_sio1_master( 0x52, 1, Error );
					break;
				}
			case 'O':
				io_stream = RS232;
				putchar( 0x0 );
				putchar( 0xDF );
				putchar( 0x8A );
				io_stream = LCD_COMMAND;
				pos = 0;
				while( pos != 2 );
				ptr = strncmp( TX, COMP2, 2 );
				if( ptr == 0 )
				{ 
					set_lcd( LINE_2 );
					printf( "%c     ", receive[0] );
					set_sio1_master( 0x52, 1, receive );
					break;
				}
				else
				{
					set_lcd( LINE_2 );
					printf( "ERROR" );
					set_sio1_master( 0x52, 1, Error );
					break;
				}
			default:	
				set_lcd( LINE_2 );
				printf( "ERROR" );
				set_sio1_master( 0x52, 1, Error );
		}
	}
}

/********************************* END **************************************/