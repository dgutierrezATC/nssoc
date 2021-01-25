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
-- File       : coincidence_detector_neuron.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2018-11-13
-- Last update: 2021-01-23
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

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY itd_network IS
    GENERIC (
        NUM_NEURONS             : INTEGER := 16;
        MAX_DETECTION_TIME      : INTEGER := 700;
        DETECTION_OVERLAP       : INTEGER := 1;
        CLOCK_FREQ              : INTEGER := 50000000
    );
    PORT (
        i_clock                 : IN  STD_LOGIC;
        i_nreset                : IN  STD_LOGIC;
        i_left_ch_spike         : IN  STD_LOGIC;
        i_right_ch_spike        : IN  STD_LOGIC;
        o_sound_source_position : OUT STD_LOGIC_VECTOR((NUM_NEURONS - 1) DOWNTO 0)
    );
END itd_network;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF itd_network IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------
    SIGNAL dl_left_delayed_spikes  : STD_LOGIC_VECTOR((NUM_NEURONS - 1) DOWNTO 0);
    SIGNAL dl_right_delayed_spikes : STD_LOGIC_VECTOR((NUM_NEURONS - 1) DOWNTO 0);

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    --
    -- Delay-lines
    --
    COMPONENT delay_lines_connection
        GENERIC (
            DELAY_LINES_NUM                : INTEGER := 32;
            MAX_TIME_DIFF_DETECTION_WINDOW : INTEGER := 700;
            CLOCK_FREQ                     : INTEGER := 50000000
        );
        PORT (
            i_clock                        : IN  STD_LOGIC;
            i_nreset                       : IN  STD_LOGIC;
            i_spike_in                     : IN  STD_LOGIC;
            o_spike_delay_lines            : OUT STD_LOGIC_VECTOR((DELAY_LINES_NUM - 1) DOWNTO 0)
        );
    END COMPONENT;

    --
    -- Coincidence detectors array
    --
    COMPONENT coincidence_detector_neuron_array
        GENERIC (
            COINCIDENCE_DETECTOR_NUM       : INTEGER := 32;
            MAX_TIME_DIFF_DETECTION_WINDOW : INTEGER := 700;
            TIME_DETECTION_OVERLAP         : INTEGER := 1;
            CLOCK_FREQ                     : INTEGER := 50000000
        );
        PORT (
            i_clock                        : IN  STD_LOGIC;
            i_nreset                       : IN  STD_LOGIC;
            i_left_spike_stream            : IN  STD_LOGIC_VECTOR((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
            i_right_spike_stream           : IN  STD_LOGIC_VECTOR((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
            o_neurons_coincidence          : OUT STD_LOGIC_VECTOR((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0)
        );
    END COMPONENT;

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Components instantiation
    ---------------------------------------------------------------------------

    --
    -- Delay-lines from left AVCN
    --
    DL_left : delay_lines_connection
        GENERIC MAP (
            DELAY_LINES_NUM                => NUM_NEURONS,
            MAX_TIME_DIFF_DETECTION_WINDOW => MAX_DETECTION_TIME,
            CLOCK_FREQ                     => CLOCK_FREQ
        )
        PORT MAP (
            i_clock                        => i_clock,
            i_nreset                       => i_nreset,
            i_spike_in                     => i_left_ch_spike,
            o_spike_delay_lines            => dl_left_delayed_spikes
        );

    --
    -- Delay-lines from right AVCN
    --
    DL_right : delay_lines_connection
        GENERIC MAP (
            DELAY_LINES_NUM                => NUM_NEURONS,
            MAX_TIME_DIFF_DETECTION_WINDOW => MAX_DETECTION_TIME,
            CLOCK_FREQ                     => CLOCK_FREQ
        )
        PORT MAP (
            i_clock                        => i_clock,
            i_nreset                       => i_nreset,
            i_spike_in                     => i_right_ch_spike,
            o_spike_delay_lines            => dl_right_delayed_spikes
        );

    --
    -- Coincidence detectors
    --
    CDN_array : coincidence_detector_neuron_array
        GENERIC MAP(
            COINCIDENCE_DETECTOR_NUM       => NUM_NEURONS,
            MAX_TIME_DIFF_DETECTION_WINDOW => MAX_DETECTION_TIME,
            TIME_DETECTION_OVERLAP         => DETECTION_OVERLAP,
            CLOCK_FREQ                     => CLOCK_FREQ
        )
        PORT MAP(
            i_clock                        => i_clock,
            i_nreset                       => i_nreset,
            i_left_spike_stream            => dl_left_delayed_spikes,
            i_right_spike_stream           => dl_right_delayed_spikes,
            o_neurons_coincidence          => o_sound_source_position
        );

END Behavioral;