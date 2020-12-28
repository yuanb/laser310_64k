`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:47:40 12/11/2020
// Design Name:   top
// Module Name:   C:/dev/cpld_learning/vzdos138/vzdos138_tb.v
// Project Name:  vzdos138
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ram64k_tb;

	// Inputs
	reg [4:0] Addr;
	reg WR_N;
	reg RD_N;
	reg MREQ_N;

	// Outputs
	wire RAM_CS_N;
	wire RAM_OE_N;
	wire RAM_WE_N;
	
	reg[39:0] error_msg = "Good!";
	 
	// Instantiate the Unit Under Test (UUT)
	top uut (
		/*Input*/
		.Addr(Addr), 
		.WR_N(WR_N),
		.RD_N(RD_N),
		.MREQ_N(MREQ_N),
		/*Output*/
		.RAM_CS_N(RAM_CS_N), 
		.RAM_OE_N(RAM_OE_N),
		.RAM_WE_N(RAM_WE_N)
	);

	initial begin
		//1. Invalid Addr,
		Addr = 5'b00111;
		WR_N = 0;
		RD_N = 1;
		MREQ_N = 1;

		//2. Valid Addr, /MREQ
		#100;
		Addr = 5'b10111;
		MREQ_N = 0;

		//3. Invalid Addr,		
		#100;
		Addr = 5'b10110;
		MREQ_N = 0;
		
		//4. Valid Addr, !MREQ_N
		#100;
		Addr = 5'b10111;
		MREQ_N = 1;
		
		//5. Valid Addr, !/WR
		#100;
		Addr = 5'b11000;
		MREQ_N = 0;
		WR_N = 1;
		RD_N = 0;
		
		//6. Addr, !MREQ_N
		#100;
		MREQ_N = 1;
		
		//7. Last Addr, /WR, /MREQ
		#100;
		Addr = 5'b11111;
		MREQ_N = 0;
		WR_N = 0;
		RD_N = 1;
		
		//8. Last Addr, !/WR, /MREQ
		#100;
		Addr = 5'b11111;
		MREQ_N = 0;
		WR_N = 1;
		RD_N = 0;
		//Expcet /CS, /RD
		
		//9. Valid Addr, valid /MREQ, invalid WR, RD, 
		#100;
		Addr = 5'b10111;
		MREQ_N = 0;
		WR_N = 1;
		RD_N = 1;
		#1;
		if (RAM_CS_N !== 1) $display("Test9, invalid RAM_CS_N output");
		error_msg = "Error";
		//Expect !/CS

		//10. Valid Addr, valid /MREQ, invalid WR, RD, 
		#100;
		Addr = 5'b10111;
		MREQ_N = 0;
		WR_N = 0;
		RD_N = 0;
		#1;
		if (RAM_CS_N !== 1) $display("Test10, invalid RAM_CS_N output");		
		//Expect !/CS

	end
      
endmodule

