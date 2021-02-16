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
-- Title      : Coincidence detector neuron array
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : coincidence_detector_neuron_array.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2018-01-13
-- Last update: 2021-01-21
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

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY coincidence_detector_neuron_array IS
    GENERIC (
        COINCIDENCE_DETECTOR_NUM       : INTEGER := 32;      -- Natural integer
        MAX_TIME_DIFF_DETECTION_WINDOW : INTEGER := 700;     -- In microseconds
        TIME_DETECTION_OVERLAP         : INTEGER := 1;       -- In microseconds
        CLOCK_FREQ                     : INTEGER := 50000000 -- In Hz
    );
    PORT (
        i_clock               : IN  STD_LOGIC;
        i_nreset              : IN  STD_LOGIC;
        i_left_spike_stream   : IN  STD_LOGIC_VECTOR((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
        i_right_spike_stream  : IN  STD_LOGIC_VECTOR((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
        o_neurons_coincidence : OUT STD_LOGIC_VECTOR((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0)
    );
END coincidence_detector_neuron_array;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF coincidence_detector_neuron_array IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------
    CONSTANT COINCIDENCE_DETECTION_TIME : INTEGER := (MAX_TIME_DIFF_DETECTION_WINDOW / COINCIDENCE_DETECTOR_NUM) + 1 + TIME_DETECTION_OVERLAP; --us

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    --
    -- Coincidence detector neuron
    --
    COMPONENT coincidence_detector_neuron
        GENERIC (
            TEMPORAL_COINCIDENCE_WINDOW : INTEGER := 100;
            CLOCK_FREQ                  : INTEGER := 50000000
        );
        PORT (
            i_clock             : IN  STD_LOGIC;
            i_nreset            : IN  STD_LOGIC;
            i_left_spike        : IN  STD_LOGIC;
            i_right_spike       : IN  STD_LOGIC;
            o_coincidence_spike : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN  -- architecture Behavioral

    -----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Components instantiation
    ---------------------------------------------------------------------------

    --
    -- Coincidence detector neuron
    --

    GEN_CD : FOR I IN 0 TO (COINCIDENCE_DETECTOR_NUM - 1) GENERATE
        CDNX : coincidence_detector_neuron
            GENERIC MAP (
                TEMPORAL_COINCIDENCE_WINDOW => COINCIDENCE_DETECTION_TIME,
                CLOCK_FREQ                  => CLOCK_FREQ
            )
            PORT MAP (
                i_clock             => i_clock,
                i_nreset            => i_nreset,
                i_left_spike        => i_left_spike_stream(I),
                i_right_spike       => i_right_spike_stream((COINCIDENCE_DETECTOR_NUM - 1) - I),
                o_coincidence_spike => o_neurons_coincidence(I)
            );
    END GENERATE GEN_CD;

END Behavioral;