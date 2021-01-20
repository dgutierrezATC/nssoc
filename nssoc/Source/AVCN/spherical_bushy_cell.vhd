--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright (c) 2020  Daniel Gutierrez Galan                               //
--//                                                                             //
--//    This file is part of NSSOC project.                                      //
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
-- Title      : Spherical bushy cell of the AVCN
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : spherical_bushy_cell.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2018-12-12
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

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY spherical_bushy_cell IS
    PORT (
        i_clock              : IN  std_logic;
        i_nreset             : IN  std_logic;
        i_pos_spike          : IN  std_logic;
        i_neg_spike          : IN  std_logic;
        o_phase_locked_spike : OUT std_logic
    );
END spherical_bushy_cell;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF spherical_bushy_cell IS
    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------
    SIGNAL r_last_spike_polarity : std_logic;
    SIGNAL r_zero_cross          : std_logic;

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

BEGIN  -- architecture Behavioral

    -----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    -- purpose: Zero crossing detection
    -- type   : sequential
    -- inputs : i_clock, i_nreset
    -- outputs: r_zero_cross
    p_zero_crossing_detection : PROCESS (i_clock, i_nreset)
    BEGIN
        IF i_nreset = '0' THEN
            r_zero_cross <= '0';
        ELSE
            IF rising_edge(i_clock) THEN
                IF (i_neg_spike = '1') AND (r_last_spike_polarity = '1') THEN
                    r_zero_cross <= '1';
                ELSE
                    r_zero_cross <= '0';
                END IF;
            ELSE

            END IF;
        END IF;

    END PROCESS p_zero_crossing_detection;

    -- purpose: Store the polarity of the last event
    -- type   : sequential
    -- inputs : i_clock, i_nreset
    -- outputs: r_last_spike_polarity
    spike_polarity_update : PROCESS (i_clock, i_nreset)
    BEGIN
        IF i_nreset = '0' THEN
            r_last_spike_polarity <= '0';
        ELSE
            IF rising_edge(i_clock) THEN
                IF i_pos_spike = '1' THEN
                    r_last_spike_polarity <= '1';
                ELSIF i_neg_spike = '1' THEN
                    r_last_spike_polarity <= '0';
                ELSE

                END IF;
            ELSE

            END IF;
        END IF;
    END PROCESS spike_polarity_update;

    -----------------------------------------------------------------------------
    -- Output assign
    -----------------------------------------------------------------------------
    o_phase_locked_spike <= r_zero_cross;

END Behavioral;