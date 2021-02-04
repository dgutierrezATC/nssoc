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
-- Title      : Medial Superior Olivar (MSO) model
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : MSO.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2018-11-27
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

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY MSO IS
    GENERIC (
        NUM_FREQ_CH          : INTEGER := 5;
        NUM_NET_NEURONS      : INTEGER := 16;
        MAX_DETECTION_TIME   : INTEGER := 700;
        DETECTION_OVERLAPING : INTEGER := 1;
        CLOCK_FREQ           : INTEGER := 50000000
    );
    PORT (
        i_clock              : IN  STD_LOGIC;
        i_nreset             : IN  STD_LOGIC;
        i_left_avcn_spikes   : IN  STD_LOGIC_VECTOR((NUM_FREQ_CH - 1) DOWNTO 0);
        i_right_avcn_spikes  : IN  STD_LOGIC_VECTOR((NUM_FREQ_CH - 1) DOWNTO 0);
        o_itd_out_spikes     : OUT STD_LOGIC_VECTOR(((NUM_FREQ_CH * NUM_NET_NEURONS) - 1) DOWNTO 0)
    );
END MSO;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF MSO IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    --
    -- ITD network
    --
    COMPONENT itd_network IS
        GENERIC (
            NUM_NEURONS             : INTEGER := 32;
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
    END COMPONENT;

BEGIN  -- architecture Behavioral

    -----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Components instantiation
    ---------------------------------------------------------------------------

    --
    -- ITD network
    --
    GEN_ITD : FOR I IN 0 TO (NUM_FREQ_CH - 1) GENERATE
        ITDX : itd_network
            GENERIC MAP(
                NUM_NEURONS             => NUM_NET_NEURONS,
                MAX_DETECTION_TIME      => MAX_DETECTION_TIME,
                DETECTION_OVERLAP       => DETECTION_OVERLAPING,
                CLOCK_FREQ              => CLOCK_FREQ
            )
            PORT MAP(
                i_clock                 => i_clock,
                i_nreset                => i_nreset,
                i_left_ch_spike         => i_left_avcn_spikes(I),
                i_right_ch_spike        => i_right_avcn_spikes(I),
                o_sound_source_position => o_itd_out_spikes(((NUM_NET_NEURONS * (I + 1)) - 1) DOWNTO (NUM_NET_NEURONS * I))
            );
    END GENERATE GEN_ITD;

END Behavioral;