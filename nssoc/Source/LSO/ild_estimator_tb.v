`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:02:54 02/26/2019
// Design Name:   AER_HOLDER_AND_FIRE
// Module Name:   D:/Proyectos/Universidad/AER/COFNET/NAS_2017/NAS_asic/Base_project/Sources/AER_HOLDER_AND_FIRE_tb.v
// Project Name:  NASIC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: AER_HOLDER_AND_FIRE
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ild_estimator_tb;

	// Inputs
	reg CLK;
	reg RST;
	reg SPIKES_IN_UP;
	reg SPIKES_IN_UN;
	reg SPIKES_IN_YP;
	reg SPIKES_IN_YN;

	// Outputs
	wire SPIKES_OUT_P;
	wire SPIKES_OUT_N;
	
	// Constants

	// Instantiate the Unit Under Test (UUT)
	ild_estimator uut (
		.CLK(CLK), 
		.RST(RST), 
		.SPIKES_IN_UP(SPIKES_IN_UP),
		.SPIKES_IN_UN(SPIKES_IN_UN),
		.SPIKES_IN_YP(SPIKES_IN_YP),
		.SPIKES_IN_YN(SPIKES_IN_YN), 
		.SPIKES_OUT_P(SPIKES_OUT_P),
		.SPIKES_OUT_N(SPIKES_OUT_N)
	);
    
	initial begin
		// Initialize Inputs
		CLK = 0;
		RST = 0;
		SPIKES_IN_UP = 0;
		SPIKES_IN_UN = 0;
		SPIKES_IN_YP = 0;
		SPIKES_IN_YN = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
        ////////////////////
        // U+
        ////////////////////
        
		// Initial reset
        RST = 1;
        #80;
        RST = 0;
        
        // Nothing is held
        // UP arrives
        SPIKES_IN_UP = 1;
        #40;
        SPIKES_IN_UP = 0;
        
        #80;
        
        // UP held
        // UP arrives
        SPIKES_IN_UP = 1;
        #40;
        SPIKES_IN_UP = 0;
        
        #80;
        
        // UP held
        // UN arrives
        SPIKES_IN_UN = 1;
        #40;
        SPIKES_IN_UN = 0;
        
        #80;
        
        // Nothing held
        // UP arrives
        SPIKES_IN_UP = 1;
        #40;
        SPIKES_IN_UP = 0;
        
        #80;
        
        // UP held
        // YP arrives
        SPIKES_IN_YP = 1;
        #40;
        SPIKES_IN_YP = 0;
        
        #80;
        
        // Nothing held
        // UP arrives
        SPIKES_IN_UP = 1;
        #40;
        SPIKES_IN_UP = 0;
        
        #80;
        
        // UP held
        // YN arrives
        SPIKES_IN_YN = 1;
        #40;
        SPIKES_IN_YN = 0;
        
        #80;
        
        $display ("U+ test finished\n");
        //$stop;
        
        ////////////////////
        // U-
        ////////////////////
        
        // Initial reset
        RST = 1;
        #80;
        RST = 0;
        
        // Nothing is held
        // UN arrives
        SPIKES_IN_UN = 1;
        #40;
        SPIKES_IN_UN = 0;
        
        #80;
        
        // UN held
        // UP arrives
        SPIKES_IN_UP = 1;
        #40;
        SPIKES_IN_UP = 0;
        
        #80;
        
        // Nothing is held
        // UN arrives
        SPIKES_IN_UN = 1;
        #40;
        SPIKES_IN_UN = 0;
        
        #80;
        
        // UN held
        // UN arrives
        SPIKES_IN_UN = 1;
        #40;
        SPIKES_IN_UN = 0;
        
        #80;
        
        // UN held
        // YN arrives
        SPIKES_IN_YN = 1;
        #40;
        SPIKES_IN_YN = 0;
        
        #80;
        
        // Nothing is held
        // UN arrives
        SPIKES_IN_UN = 1;
        #40;
        SPIKES_IN_UN = 0;
        
        #80;
        
        // UN held
        // YP arrives
        SPIKES_IN_YP = 1;
        #40;
        SPIKES_IN_YP = 0;
        
        #80;
        
        $display ("U- test finished\n");
        //$stop;
        
        ////////////////////
        // Y+
        ////////////////////
        // Initial reset
        
        RST = 1;
        #80;
        RST = 0;
        
        // Nothing is held
        // YP arrives
        SPIKES_IN_YP = 1;
        #40;
        SPIKES_IN_YP = 0;
        
        #80;
        
        // YP held
        // YP arrives
        SPIKES_IN_YP = 1;
        #40;
        SPIKES_IN_YP = 0;
        
        #80;
        
        // YP held
        // YN arrives
        SPIKES_IN_YN = 1;
        #40;
        SPIKES_IN_YN = 0;
        
        #80;
        
        // Nothing is held
        // YP arrives
        SPIKES_IN_YP = 1;
        #40;
        SPIKES_IN_YP = 0;
        
        #80;
        
        // YP held
        // UP arrives
        SPIKES_IN_UP = 1;
        #40;
        SPIKES_IN_UP = 0;
        
        #80;
        
        // Nothing is held
        // YP arrives
        SPIKES_IN_YP = 1;
        #40;
        SPIKES_IN_YP = 0;
        
        #80;
        
        // YP held
        // UN arrives
        SPIKES_IN_UN = 1;
        #40;
        SPIKES_IN_UN = 0;
        
        #80;
        
        $display ("Y+ test finished\n");
        //$stop;
        
        ////////////////////
        // Y-
        ////////////////////
        // Initial reset
        RST = 1;
        #80;
        RST = 0;
        
        // Nothing is held
        // YN arrives
        SPIKES_IN_YN = 1;
        #40;
        SPIKES_IN_YN = 0;
        
        #80;
        
        // YN held
        // YN arrives
        SPIKES_IN_YN = 1;
        #40;
        SPIKES_IN_YN = 0;
        
        #80;
        
        // YN held
        // YP arrives
        SPIKES_IN_YP = 1;
        #40;
        SPIKES_IN_YP = 0;
        
        #80;
        
        // Nothing is held
        // YN arrives
        SPIKES_IN_YN = 1;
        #40;
        SPIKES_IN_YN = 0;
        
        #80;
        
        // YN held
        // UN arrives
        SPIKES_IN_UN = 1;
        #40;
        SPIKES_IN_UN = 0;
        
        #80;
        
        // Nothing is held
        // YN arrives
        SPIKES_IN_YN = 1;
        #40;
        SPIKES_IN_YN = 0;
        
        #80;
        
        // YN held
        // UP arrives
        SPIKES_IN_UP = 1;
        #40;
        SPIKES_IN_UP = 0;
        
        #80;
        
        $display ("Y- test finished\n");
        $finish;
	end
    
    // Clock generation
    always #20 CLK = !CLK;
          
endmodule
