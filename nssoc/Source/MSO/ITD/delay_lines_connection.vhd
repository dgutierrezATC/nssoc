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
-- Title      : Delay line of the Jeffress model
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : delay_line_connection.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2018-11-12
-- Last update: 2021-01-22
-- Platform   : any
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY delay_lines_connection IS
    GENERIC (
        DELAY_LINES_NUM                : INTEGER := 16;      -- Natural integer
        MAX_TIME_DIFF_DETECTION_WINDOW : INTEGER := 700;     -- In microseconds
        CLOCK_FREQ                     : INTEGER := 50000000 -- In Hz
    );
    PORT (
        i_clock             : IN STD_LOGIC;
        i_nreset            : IN STD_LOGIC;
        i_spike_in          : IN STD_LOGIC;
        o_spike_delay_lines : OUT STD_LOGIC_VECTOR((DELAY_LINES_NUM - 1) DOWNTO 0)
    );
END delay_lines_connection;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF delay_lines_connection IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------
    CONSTANT TRANSMISSION_DELAY : INTEGER := (MAX_TIME_DIFF_DETECTION_WINDOW / DELAY_LINES_NUM) + 1; --us

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------


    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------


    --
    -- Delay line
    --
    COMPONENT delay_line
        GENERIC (
            TRANSMISSION_TIME : INTEGER := 500;     -- In microseconds
            CLOCK_FREQ        : INTEGER := 50000000 -- In Hz
        );
        PORT (
            i_clock         : IN  STD_LOGIC;
            i_nreset        : IN  STD_LOGIC;
            i_spike_in      : IN  STD_LOGIC;
            o_spike_delayed : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Components instantiation
    ---------------------------------------------------------------------------

    --
    -- Delay line
    --
    GEN_DL : FOR I IN 0 TO (DELAY_LINES_NUM - 1) GENERATE
        DLX : delay_line
            GENERIC MAP (
                TRANSMISSION_TIME => (TRANSMISSION_DELAY * (I + 1)),
                CLOCK_FREQ        => CLOCK_FREQ
            )
            PORT MAP (
                i_clock           => i_clock,
                i_nreset          => i_nreset,
                i_spike_in        => i_spike_in,
                o_spike_delayed   => o_spike_delay_lines(I)
            );
    END GENERATE GEN_DL;

END Behavioral;