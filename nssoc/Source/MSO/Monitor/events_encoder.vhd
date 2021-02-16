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
-- Title      : Events encoder
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : events_encoder.vhd
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
ENTITY events_encoder IS
	GENERIC (
		N_EVENTS          : INTEGER := 16; -- Max number of input event IDs (from 0 to 15): NUM_NEURONS_JEFFRESS_MODEL
		NBITS_ADDRESS     : INTEGER := 4   -- Log2(N_EVENTS)
	);
	PORT ( 
		i_clock           : IN  STD_LOGIC;
		i_reset           : IN  STD_LOGIC;
		i_in_events       : IN  STD_LOGIC_VECTOR ((N_EVENTS-1) DOWNTO 0);
		o_out_address     : OUT STD_LOGIC_VECTOR ((NBITS_ADDRESS-1) DOWNTO 0);
		o_new_out_address : OUT STD_LOGIC
	);
    END events_encoder;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF events_encoder IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------


    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    BEGIN  -- architecture Behavioral

        -----------------------------------------------------------------------------
        -- Processes
        -----------------------------------------------------------------------------

        -- purpose: Encode the input data
        -- type   : combinational
        -- inputs : i_in_events
        -- outputs: o_out_address, o_new_out_address
        main_process: PROCESS (i_in_events)
        BEGIN
            FOR i IN 0 TO (N_EVENTS-1) LOOP
                IF (i_in_events(i) = '1') THEN -- We can do this because we are sure we only will get 1 spike at the same time
                    o_out_address     <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, o_out_address'LENGTH));
                    o_new_out_address <= '1';
                    EXIT;
                ELSE
                    o_new_out_address <= '0';
                    o_out_address     <= (OTHERS => '0');
                END IF;
            END LOOP;
        END PROCESS main_process;

END Behavioral;

