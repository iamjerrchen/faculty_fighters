//io_handler.c
#include "io_handler.h"
#include <stdio.h>

void IO_init(void)
{
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
	*otg_hpi_r = 1;
	*otg_hpi_w = 1;
	*otg_hpi_address = 0;
	*otg_hpi_data = 0;
	// Reset OTG chip
	*otg_hpi_cs = 0;
	*otg_hpi_reset = 0;
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
}

void IO_write(alt_u8 Address, alt_u16 Data)
{
//*************************************************************************//
//									TASK								   //
//*************************************************************************//
//							Write this function							   //
//*************************************************************************//
	// set address and data "MAR/MDR"
	*otg_hpi_address = Address;
	*otg_hpi_data = Data;

	*otg_hpi_cs = 0; // select the chip
	*otg_hpi_w = 0; // Tell hpi to write
	usleep(500); // wait for it to finish

	*otg_hpi_w = 1; // turn off write operation
	*otg_hpi_cs = 1; // unselect chip
}

alt_u16 IO_read(alt_u8 Address)
{
	alt_u16 temp;
//*************************************************************************//
//									TASK								   //
//*************************************************************************//
//							Write this function							   //
//*************************************************************************//
	//printf("%x\n",temp);
	*otg_hpi_address = Address;

	*otg_hpi_cs = 0; // select chip
	*otg_hpi_r = 0; // tell hpi to read from address provided, fill hpi_data
	usleep(500); // wait for operation to finish
	temp = *otg_hpi_data;
	*otg_hpi_r = 1; // turn off read operation
	*otg_hpi_cs = 1; // unselect chip
	return temp;
}
