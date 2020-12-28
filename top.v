`timescale 1ns / 1ps

//RAM decoding
//Addr = A15 - A11
//A15 = Addr<4>, A14 = Addr<3>, A13 = Addr<2>, A12 = Addr<1>, A11 = Addr<0>
module top(/*Input*/ Addr, WR_N, RD_N, MREQ_N, /*Output*/ RAM_CS_N, RAM_OE_N, RAM_WE_N, /*Led*/ led1, led2);

	input wire[4:0] Addr;
	input wire WR_N;
	input wire RD_N;
	input wire MREQ_N;
	
	output wire RAM_CS_N;
	output wire RAM_OE_N;
	output wire RAM_WE_N;
	
	output wire led1;
	output wire led2;
	
	//RAM decoding
	//Laser 310 - Expension RAM B800h
	//B800h = 1011 1000 0000 0000
	//FFFFh = 1111 1111 1111 1111
	//Mask = 1111 1000 0000 0000
	//A15,A14,A13,A12,A11 range: [10111,11111] = [17,1F]

	//RAM_CS_N is low if : 1. /MREQ; 2. Valid Addr;	3. WR and RD are valid.
	assign RAM_CS_N = (MREQ_N==1'b0 && (Addr>=5'b1_0111 && Addr<=5'b1_1111)==1'b1 && ((WR_N==0 & RD_N==1) | (WR_N==1 & RD_N==0)) ) ? 1'b0 : 1'b1; 
	assign RAM_OE_N = (RAM_CS_N==0 && WR_N==1) ? 1'b0 : 1'b1;
	assign RAM_WE_N = (RAM_CS_N==0 && WR_N==0) ? 1'b0 : 1'b1;

	assign led1 = !RAM_CS_N;
	assign led2 = !RAM_WE_N;

endmodule
