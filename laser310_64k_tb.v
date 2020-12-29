`timescale 1ns / 1ns

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
	reg [3:0] AddrIO;	//A7 - A4,
	reg WR_N;
	reg RD_N;
	reg MREQ_N;
	reg IORQ_N;
	reg [1:0] D1D0;

	// Outputs
	wire [1:0] RAM_A1514;
	wire RAM_CS_N;
	wire RAM_OE_N;
	wire RAM_WE_N;
	wire led1;
	wire led2;
	
	reg[95:0] testcase = "Test#1......";
	reg[39:0] error_msg = "Good!";
	 
	// Instantiate the Unit Under Test (UUT)
	top uut (
		/*Input*/
		.Addr(Addr), 
		.AddrIO(AddrIO),
		.WR_N(WR_N),
		.RD_N(RD_N),
		.MREQ_N(MREQ_N),
		.IORQ_N(IORQ_N),
		.D1D0(D1D0),
		
		/*Output*/
		.RAM_A1514(RAM_A1514),
		.RAM_CS_N(RAM_CS_N), 
		.RAM_OE_N(RAM_OE_N),
		.RAM_WE_N(RAM_WE_N),
		.led1(led1),
		.led2(led2)
	);

	initial begin
		//Test1. Invalid RD/WR
		Addr = 5'bxxxxx;
		AddrIO = 4'bxxxx;
		WR_N = 1;
		RD_N = 1;
		MREQ_N = 0;
		IORQ_N = 1;
		D1D0 = 2'bxx;
		testcase = "1. RD=WR    ";
		#1;
		if (RAM_CS_N !== 1)
			begin
				$display("Test1, RAM_CS_N is not 1 (RD=WR=1)");
				error_msg = "Error";
			end
		else
			#99;
			WR_N = 0;
			RD_N = 0;
			#1;
			if (RAM_CS_N !== 1)
				begin
					$display("Test1, RAM_CS_N is not 1(RD=WR=0)");
					error_msg = "Error";				
				end
			else
				#99
				WR_N = 1;
				RD_N = 1;
				#1;
				if (RAM_CS_N !== 1)
					begin
						$display("Test1, RAM_CS_N is not 1(RD=WR=0 to RD=WR=1)");
						error_msg = "Error";						
					end
				else
					error_msg = "Good!";

		//Test2. Invalid MREQ/IORQ
		#100;
		Addr = 5'bxxxxx;
		AddrIO = 4'bxxxx;
		WR_N = 0;
		RD_N = 1;
		MREQ_N = 1;
		IORQ_N = 1;
		D1D0 = 2'bxx;
		testcase = "2. MREQ=IREQ";
		if (RAM_CS_N !== 1)
			begin
				$display("Test2, RAM_CS_N is not 1 (MREQ=IREQ=1)");
				error_msg = "Error";
			end
		else
			#99;
			MREQ_N = 0;
			IORQ_N = 0;
			#1;
			if (RAM_CS_N !== 1)
				begin
					$display("Test2, RAM_CS_N is not 1(MREQ=IREQ=0)");
					error_msg = "Error";				
				end
			else
				#99;
				MREQ_N = 1;
				IORQ_N = 1;
				#1;
				if (RAM_CS_N !== 1)
					begin
					$display("Test2, RAM_CS_N is not 1(MREQ=IREQ=0 to MREQ=IREQ=1)");
					error_msg = "Error";						
					end
				else
					error_msg = "Good!";
		
		//Test3. B8xxH write access
		#99;
		Addr = 5'b10111;
		AddrIO = 4'bxxxx;
		WR_N = 0;
		RD_N = 1;
		MREQ_N = 0;
		IORQ_N = 1;
		D1D0 = 2'bxx;
		testcase = "3. B8xxH /WR";
		#1;
		if (RAM_CS_N !== 0 || RAM_WE_N !== 0 || RAM_OE_N !== 1 || RAM_A1514 !== 2'b00)
			begin
				$display("Test3, invalid output");
				error_msg = "Error";
			end
		else
			error_msg = "Good!";
		
		//Test4. B8xxH read access
		#99;
		Addr = 5'b10111;
		AddrIO = 4'bxxxx;
		WR_N = 1;
		RD_N = 0;
		MREQ_N = 0;
		IORQ_N = 1;
		D1D0 = 2'bxx;
		testcase = "4. B8xxH /RD";
		#1;
		if (RAM_CS_N !== 0 || RAM_WE_N !== 1 || RAM_OE_N !== 0 || RAM_A1514 !== 2'b00)
			begin
				$display("Test4, invalid output");
				error_msg = "Error";
			end
		else
			error_msg = "Good!";
			
		//Test5. B7xxH, read access
		#99;
		Addr = 5'b10110;
		AddrIO = 4'bxxxx;
		WR_N = 1;
		RD_N = 0;
		MREQ_N = 0;
		IORQ_N = 1;
		D1D0 = 2'bxx;
		testcase = "5. B7xxH /RD";
		#1;
		if (RAM_CS_N !== 1)
			begin
				$display("Test5, invalid output");
				error_msg = "Error";
			end
		else
			error_msg = "Good!";
			
		//Test6. C000H, read access
		#99;
		Addr = 5'b11000;
		AddrIO = 4'bxxxx;
		WR_N = 1;
		RD_N = 0;
		MREQ_N = 0;
		IORQ_N = 1;
		D1D0 = 2'bxx;
		testcase = "6. C000H /RD";
		#1;
		if (RAM_CS_N !==0 || RAM_WE_N !== 1 || RAM_OE_N !== 0 || RAM_A1514 !== 2'b01)
			begin
				$display("Test6, failed, expceting !CS, WE, !OE, A15A14= 01.");
				error_msg = "Error";
			end
		else
			error_msg = "Good!";
			
		//Test7. FFFFH, read access
		#100;
		Addr = 5'b11111;
		AddrIO = 4'bxxxx;
		WR_N = 1;
		RD_N = 0;
		MREQ_N = 0;
		IORQ_N = 1;
		D1D0 = 2'bxx;
		testcase = "7. FFFFH /RD";
		if (RAM_CS_N !==0 || RAM_WE_N !== 1 || RAM_OE_N !== 0 || RAM_A1514 !== 2'b01)
			begin
				$display("Test7, failed, expceting !CS, WE, !OE, A15A14= 01.");
				error_msg = "Error";
			end
		else
			error_msg = "Good!";
			
		//Test8. FFFFH, then B800H read access
		#100;
		Addr = 5'b11111;
		AddrIO = 4'bxxxx;
		WR_N = 1;
		RD_N = 0;
		MREQ_N = 0;
		IORQ_N = 1;
		D1D0 = 2'bxx;
		testcase = "8. FFFFH /RD";
		if (RAM_CS_N !==0 || RAM_WE_N !== 1 || RAM_OE_N !== 0 || RAM_A1514 !== 2'b01)
			begin
				$display("Test8, failed, expceting !CS, WE, !OE, A15A14= 01.");
				error_msg = "Error";
			end
		else
			#99;
			Addr = 5'b10111;
			#1;
			if (RAM_CS_N !== 0 || RAM_WE_N !== 1 || RAM_OE_N !== 0 || RAM_A1514 !== 2'b00)
				begin
					$display("Test8, invalid output");
					error_msg = "Error";
				end
			else
				error_msg = "Good!";
				
		//Test9. Switch to bank 0 and 1
		
		//Test10. Switch to bank 2
		
		//Test11. Switch to bank 3
			
		//End
		#100;
	end
      
endmodule

