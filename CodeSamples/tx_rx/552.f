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
unsigned char idata PC_M552[1];
unsigned char idata I2C_M552[1];
unsigned char idata Error[6] = { "ERROR" };
unsigned char idata Ok[3] = { "OK" }; 

/************************* SERIAL COMMUNICATION ****************************/

SerCom( )	interrupt 4			// RS-232 interrupt
{
	if( RI == 1 )
	{
		PC_M552[pos] = S0BUF;
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
	sio1_init( 0x52 );			// initialize I2C bus	
	SLAVE_R_flag = 0;			// 
	set_sio1_slave( I2C_M552, 1 );		// setup I2C to receive 9 bytes
}

/******************************* MAIN FUNCTION *******************************/

main( )
{
	int ptr, ptr1;

	init( );
	while( 1 )
	{	
		pos = 0;
		while( pos != 1 );
		set_lcd( LINE_1 );
		printf( "%c", PC_M552[0] );
		set_sio1_master( 0x50, 1, PC_M552 );
		while( !SLAVE_R_flag );
		SLAVE_R_flag = 0;
		set_lcd( LINE_2 );
		printf( "%c", I2C_M552[0] );
		ptr1 = strncmp( I2C_M552, PC_M552, 1 );
		if( ptr1 == 0 )
		{ 
			io_stream = RS232;
			printf( "\n\r%s", Ok );
			io_stream = LCD_COMMAND;
		}
		else
		{
			io_stream = RS232;
			printf( "\n\r%s", Error );
			io_stream = LCD_COMMAND;
			
		}
	}
}

/********************************* END **************************************/