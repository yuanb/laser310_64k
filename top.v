`timescale 1ns / 1ps

//RAM decoding
//Addr = A15 - A11
//A15 = Addr<4>, A14 = Addr<3>, A13 = Addr<2>, A12 = Addr<1>, A11 = Addr<0>
//AddrIO = A7,A6,A5,A4
module top(/*Input*/Addr, AddrIO, WR_N, RD_N, MREQ_N, IORQ_N, clk, RESET_N, D1D0, /*Output*/ RAM_A1514, RAM_CS_N, RAM_OE_N, RAM_WE_N, bank, /*Led*/ led1, led2);

	input wire[4:0] Addr;
	input wire[3:0] AddrIO;
	input wire WR_N;
	input wire RD_N;
	input wire MREQ_N;
	input wire IORQ_N;
	input wire clk;
	input wire RESET_N;
	input wire [1:0] D1D0;
	
	output wire[1:0] RAM_A1514;	
	output wire RAM_CS_N;
	output wire RAM_OE_N;
	output wire RAM_WE_N;
	
	output wire led1;
	output wire led2;
	
	output reg[1:0] bank;
	
	//RAM decoding
	//Laser 310 - Expension RAM B800h
	//B800h = 1011 1000 0000 0000
	//BFFFh = 1011 1111 1111 1111
	//C000h = 1100 0000 0000 0000
	//FFFFh = 1111 1111 1111 1111
	//Mask = 1111 1000 0000 0000
	//A15,A14,A13,A12,A11 range: [10111,11111] = [17,1F]
	always @(posedge clk or negedge RESET_N)
	begin
		if (~RESET_N)
			bank = 2'b01;
		else
			begin
				if (IORQ_N == 1'b0 && MREQ_N == 1'b1 && WR_N==1'b0 && RD_N==1'b1 && AddrIO == 4'b0111)
					bank = D1D0;
			end
	end
	
	//TODO, move the following to always block
	
	// Laser 310 64K bank 0,1 -> RAM page 0, page 1 -> RAM 17:0000h-07FFh, 18-1f: 4000h-7FFFh 
	// Laser 310 64K bank 0,2 -> RAM page 0, page 2 -> RAM 17:0000h-07FFh, 18-1f: 8000h-7FFFh
	// Laser 310 64K bank 0,3 => RAM page 0, page 3 -> RAM 17:0000h-07FFh, 18-1f: C000h-7FFFh			
	//4000:0100 0000 0000 0000 + 0,7 on high bits -> 01000, 01111
	//8000:1000 0000 0000 0000 + 0,7 on high bits -> 10000, 10111
	//C000:1100 0000 0000 0000 = 0,7 on high bits -> 11000, 11111
	assign RAM_A1514 =(Addr == 5'b1011_1) ? 2'b00 : 
							(bank == 2'b01) ? 2'b01 : 
							(bank == 2'b10) ? 2'b10 :
							(bank == 2'b11) ? 2'b11 : 2'b01;

	//RAM_CS_N is low if : 1. /MREQ; 2. Valid Addr;	3. WR and RD are valid; 4. MREQ and IORQ are valid.
	assign RAM_CS_N = (MREQ_N==1'b0 && 
							(Addr>=5'b1011_1 && Addr<=5'b1111_1) && /*validLaser310Space*/
							((WR_N==0 & RD_N==1) | (WR_N==1 & RD_N==0)) && /*validWRRD*/
							((MREQ_N==0 & IORQ_N==1) | (MREQ_N==1 & IORQ_N==0))) /*validMREQIORQ*/
							? 1'b0 : 1'b1;
	
	assign RAM_OE_N = (RAM_CS_N==0 && WR_N==1) ? 1'b0 : 1'b1;
	assign RAM_WE_N = (RAM_CS_N==0 && WR_N==0) ? 1'b0 : 1'b1;

	assign led1 = !RAM_CS_N;
	assign led2 = !RAM_WE_N;

endmodule
