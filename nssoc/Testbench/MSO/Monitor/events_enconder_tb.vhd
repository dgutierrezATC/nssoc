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
-- File       : events_encoder_tb.vhd
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
ENTITY events_encoder_tb IS

END events_encoder_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE behavior OF events_encoder_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
	COMPONENT events_encoder
		GENERIC (
			N_EVENTS          : INTEGER := 16; 
			NBITS_ADDRESS     : INTEGER := 4
		);
		PORT (
			i_clock           : IN  STD_LOGIC;
			i_reset           : IN  STD_LOGIC;
			i_in_events       : IN  STD_LOGIC_VECTOR((N_EVENTS-1) downto 0);
			o_out_address     : OUT STD_LOGIC_VECTOR((NBITS_ADDRESS-1) downto 0);
			o_new_out_address : OUT STD_LOGIC
		);
	END COMPONENT;
    
    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

	-- Component constants
	CONSTANT c_N_EVENTS      : INTEGER := 32; 
	CONSTANT c_NBITS_ADDRESS : INTEGER := 5;

	-- Component input ports
	SIGNAL i_clock           : STD_LOGIC := '0';
	SIGNAL i_reset           : STD_LOGIC := '0';
	SIGNAL i_in_events       : STD_LOGIC_VECTOR((c_N_EVENTS-1) downto 0) := (others => '0');

	-- Component output ports
	SIGNAL o_out_address     : STD_LOGIC_VECTOR((c_NBITS_ADDRESS-1) downto 0);
	SIGNAL o_new_out_address : STD_LOGIC;

	---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------
	
	-- Clock
	CONSTANT c_i_clock_period  : TIME := 20 NS;
 
BEGIN  -- architecture Behavioral

	---------------------------------------------------------------------------
	-- Instantiate the Unit Under Test (UUT)
	---------------------------------------------------------------------------
	uut: events_encoder 
		GENERIC MAP (
			N_EVENTS          => c_N_EVENTS, 
			NBITS_ADDRESS     => c_NBITS_ADDRESS
		)
		PORT MAP (
			i_clock           => i_clock,
			i_reset           => i_reset,
			i_in_events       => i_in_events,
			o_out_address     => o_out_address,
			o_new_out_address => o_new_out_address
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
        -- First case: set to 1 each bit
		--
		REPORT "Starting the first testbench case..." SEVERITY NOTE;

		FOR i IN 0 TO (c_N_EVENTS-1) LOOP
			REPORT "Generating event..." SEVERITY NOTE;
			i_in_events <= STD_LOGIC_VECTOR(TO_UNSIGNED(2**i, i_in_events'LENGTH));
			WAIT FOR c_i_clock_period;
			i_in_events <= (OTHERS => '0');

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
