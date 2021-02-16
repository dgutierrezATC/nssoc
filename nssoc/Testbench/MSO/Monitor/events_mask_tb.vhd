--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright (c) 2020  Daniel Gutierrez Galan                               //
--//                                                                             //
--//    This file is part of NSSOC.                                              //
--//                                                                             //
--//    NSSOC is free software: you can redistribute it and/or modify            //
--//    it under the terms of the GNU General Public License as published by     //
--//    the Free Software Foundation, either version 3 of the License, or        //
--//    (at your option) any later version.                                      //
--//                                                                             //
--//    NSSOC is distributed in the hope that it will be useful,                 //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
--//    GNU General Public License for more details.                             //
--//                                                                             //
--//    You should have received a copy of the GNU General Public License        //
--//    along with NSSOC. If not, see <http://www.gnu.org/licenses/>.            //
--//                                                                             //
--/////////////////////////////////////////////////////////////////////////////////

-------------------------------------------------------------------------------
-- Title      : Antero ventricular coclear nucleus
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : events_mask.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2019-06-13
-- Last update: 2021-01-13
-- Platform   : any
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Main module
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-20  1.0      dgutierrez	Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Libraries
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY events_mask_tb IS
END events_mask_tb;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE behavior OF events_mask_tb IS 
 
    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
	COMPONENT events_mask
		GENERIC (
			NBITS_ADDRESS       : INTEGER := 4;
			CHANNEL_VAL         : INTEGER := 1
		);
		PORT (
			i_input_address     : IN  STD_LOGIC_VECTOR((NBITS_ADDRESS-1) DOWNTO 0);
			o_output_masked_aer : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;
	
	---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

	-- Component constants
	CONSTANT c_NBITS_ADDRESS   : INTEGER := 5;
	CONSTANT c_CHANNEL_VAL     : INTEGER := 33;

	-- Component input ports
	SIGNAL i_clock             : STD_LOGIC := '0';
	SIGNAL i_reset             : STD_LOGIC := '0';
	SIGNAL i_input_address     : STD_LOGIC_VECTOR((c_NBITS_ADDRESS-1) downto 0) := (others => '0');

	-- Component output ports
	SIGNAL o_output_masked_aer : STD_LOGIC_VECTOR(15 downto 0);

	---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------
	
	-- Clock
	CONSTANT c_i_clock_period  : TIME := 20 NS;
 
BEGIN  -- architecture Behavioral

	---------------------------------------------------------------------------
	-- Instantiate the Unit Under Test (UUT)
	---------------------------------------------------------------------------
	uut: events_mask 
		GENERIC MAP (
			NBITS_ADDRESS       => c_NBITS_ADDRESS,
			CHANNEL_VAL         => c_CHANNEL_VAL
		)
		PORT MAP (
			i_input_address     => i_input_address,
			o_output_masked_aer => o_output_masked_aer
		);

    ---------------------------------------------------------------------------
    -- Clocks generation
    ---------------------------------------------------------------------------
    i_clock <= NOT i_clock AFTER c_i_clock_period/2;


	-----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    -- purpose: Set the signals to generate the stimuli
    -- type   : combinational
    -- inputs : 
    -- outputs: 
    p_stimuli : PROCESS
	BEGIN		
		--
        -- First reset
        --

        -- Report the module is under reset
        REPORT "Initial reset..." SEVERITY NOTE;

        -- Start reset
        i_reset <= '0';
        -- Hold it for 1 us
        WAIT FOR 1 us;

        -- Clear reset
        i_reset <= '1';

        -- Report the reset has been clear
        REPORT "Reset cleared!" SEVERITY NOTE;

        --
        -- Idle
        --
        WAIT FOR 2 us;

        --
        -- Sync
        --

        -- Report the testbench is being sync with the clock
        REPORT "Sync..." SEVERITY NOTE;

        WAIT UNTIL i_clock'EVENT AND i_clock = '1';
        WAIT FOR c_i_clock_period*10;

		--
        -- First case: generate 16 addresses
		--
		FOR i IN 0 TO ((2**c_NBITS_ADDRESS) - 1) LOOP
			i_input_address <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, i_input_address'LENGTH));
			WAIT FOR c_i_clock_period*10;
		END LOOP;

		--
        -- End of the simulation
        --

        -- Notify the end of the simulation
        REPORT "End of the simulation." SEVERITY NOTE;

        -- Wait forever
		WAIT;

	END PROCESS p_stimuli;

END;
