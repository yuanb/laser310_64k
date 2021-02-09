`timescale 1ns / 1ns

module ram64k_tb;

	// Inputs
	reg [4:0] Addr;
	reg [3:0] AddrIO;	//A7 - A4,
	reg WR_N;
	reg RD_N;
	reg MREQ_N;
	reg IORQ_N;
	reg clk;
	reg RESET_N;
	reg [1:0] D1D0;

	// Outputs
	wire [1:0] RAM_A1514;
	wire RAM_CS_N;
	wire RAM_OE_N;
	wire RAM_WE_N;
	wire [1:0] bank;
	wire led1;
	wire led2;
	
	reg[95:0] testcase = "RESET_N     ";
	reg[39:0] error_msg = "Good!";
	
	parameter CLOCK_PERIOD = 20;
	 
	// Instantiate the Unit Under Test (UUT)
	top uut (
		/*Input*/
		.Addr(Addr), 
		.AddrIO(AddrIO),
		.WR_N(WR_N),
		.RD_N(RD_N),
		.MREQ_N(MREQ_N),
		.IORQ_N(IORQ_N),
		.clk(clk),
		.RESET_N(RESET_N),
		.D1D0(D1D0),
		
		/*Output*/
		.RAM_A1514(RAM_A1514),
		.RAM_CS_N(RAM_CS_N), 
		.RAM_OE_N(RAM_OE_N),
		.RAM_WE_N(RAM_WE_N),
		.bank(bank),
		.led1(led1),
		.led2(led2)
	);

   always  
		#(CLOCK_PERIOD/2)  clk = !clk; 
 
	initial begin
		//Test0. RESET	
		RESET_N = 0;
		clk = 0;
		#50;
		RESET_N = 1;
		
		if (RAM_CS_N !== 1'bx || bank !== 2'b01)
			begin
				$display("Test0, failed, RAM_CS_N is not 1 || bank is not 2'b01");
				error_msg = "Error";
			end
		else
			error_msg = "Good!";		

		//Test1. Invalid RD/WR
		#50;
		Addr = 5'b10111;
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
				$display("Test1, failed, RAM_CS_N is not 1 (RD=WR=1)");
				error_msg = "Error";
			end
		else
			begin
				#50;
				WR_N = 0;
				RD_N = 0;
				if (RAM_CS_N !== 1)
					begin
						$display("Test1, RAM_CS_N is not 1(RD=WR=0)");
						error_msg = "Error";				
					end
				else
					begin
						#50
						WR_N = 1;
						RD_N = 1;
						if (RAM_CS_N !== 1)
							begin
								$display("Test1, RAM_CS_N is not 1(RD=WR=0 to RD=WR=1)");
								error_msg = "Error";						
							end
						else
							error_msg = "Good!";
					end
			end

		//Test2. Invalid MREQ/IORQ
		#50;
		Addr = 5'b10111;
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
			begin
				#50;
				MREQ_N = 0;
				IORQ_N = 0;
				if (RAM_CS_N !== 1)
					begin
						$display("Test2, RAM_CS_N is not 1(MREQ=IREQ=0)");
						error_msg = "Error";				
					end
				else
					begin
						#50;
						MREQ_N = 1;
						IORQ_N = 1;
						if (RAM_CS_N !== 1)
							begin
								$display("Test2, RAM_CS_N is not 1(MREQ=IREQ=0 to MREQ=IREQ=1)");
								error_msg = "Error";						
							end
						else
							error_msg = "Good!";
					end
			end
		
		//Test3. B8xxH write access
		#50;
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
		#49;
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
		#49;
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
		#49;
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
				$display("Test6, failed, expceting !CS, WE, !OE, A15A14= 2'b01.");
				error_msg = "Error";
			end
		else
			error_msg = "Good!";
			
		//Test7. FFFFH, read access
		#50;
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
				$display("Test7, failed, expceting !CS, WE, !OE, A15A14= 2'b01.");
				error_msg = "Error";
			end
		else
			error_msg = "Good!";
			
		//Test8. FFFFH, then B800H read access
		#50;
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
				$display("Test8, failed, expceting !CS, WE, !OE, A15A14= 2'b01.");
				error_msg = "Error";
			end
		else
			begin
				#49;
				Addr = 5'b10111;
				#1;
				if (RAM_CS_N !== 0 || RAM_WE_N !== 1 || RAM_OE_N !== 0 || RAM_A1514 !== 2'b00)
					begin
						$display("Test8, invalid output");
						error_msg = "Error";
					end
				else
					error_msg = "Good!";
			end
				
		//Test9. C000H Switch to bank 2
		#49;
		Addr = 5'b11000;
		AddrIO = 4'b0111;
		#(CLOCK_PERIOD/2);
		WR_N = 0;
		RD_N = 1;
		MREQ_N = 1;
		IORQ_N = 0;
		D1D0 = 2'b10;
		#(CLOCK_PERIOD/2);
		WR_N = 1;
		RD_N = 0;
		MREQ_N = 0;
		IORQ_N = 1;
		D1D0 = 2'bxxx;
		testcase = "9. BANK2 /RD";
		#1;
		if (RAM_CS_N !==0 || RAM_WE_N !== 1 || RAM_OE_N !== 0 || RAM_A1514 !== 2'b10)
			begin
				$display("Test9, failed, expceting !CS, WE, !OE, A15A14= 2'b10.");
				error_msg = "Error";
			end
		else
			error_msg = "Good!";
		
		
		//Test10. Switch to bank 2
		
		//Test11. Switch to bank 3
			
		//End
		#50;
		testcase = "END.        ";
	end
      
endmodule

