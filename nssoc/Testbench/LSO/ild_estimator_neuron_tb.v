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

module ild_estimator_neuron_tb;

	// Inputs
	reg CLK;
	reg RST;
	reg SET;

	// Outputs
	wire HOLD_PULSE;

	// Instantiate the Unit Under Test (UUT)
	ild_estimator_neuron uut (
		.CLK(CLK), 
		.RST(RST), 
		.SET(SET), 
		.HOLD_PULSE(HOLD_PULSE)
	);
    
	initial begin
		// Initialize Inputs
		CLK = 0;
		RST = 0;
		SET = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
        RST <= 1;
        SET <= 0;
        #100;
        
        RST <= 0;
        SET <= 1;
        #100;
        
        RST <= 1;
        SET <= 1;
        #100;
        
        RST <= 0;
        SET <= 1;
        #1000;
	end
    
    // Clock generation
    always #20 CLK = !CLK;
    
    // Signals test
    always @(posedge CLK)
    begin    
    
    end
          
endmodule
