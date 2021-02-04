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
-- File       : mso_events_monitor_top.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2019-05-01
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
ENTITY SOC IS
    GENERIC (
        --// NAS parameters
        g_NAS_NUM_FREQ_CH                : INTEGER := 64;
        --// MSO parameters
        g_MSO_NUM_FREQ_CH                : INTEGER := 4;
        g_MSO_NBITS_NUM_FREQ_CH          : INTEGER := 2;
        g_MSO_START_FREQ_CH              : INTEGER := 30;
        g_MSO_END_FREQ_CH                : INTEGER := 33;
        g_MSO_NUM_ITD_NEURONS            : INTEGER := 16;
        g_MSO_NBITS_NUM_ITD_NEURONS      : INTEGER := 4;
        g_MSO_ITD_MAX_DETECTION_TIME     : INTEGER := 700;     --// In mircoseconds
        g_MSO_ITD_DETECTION_TIME_OVERLAP : INTEGER := 10;      --// In microseconds
        --// LSO PARAMETERS
        --g_LSO_NUM_FREQ_CH              : INTEGER := 27;
        --g_LSO_START_FREQ_CH            : INTEGER := 60;
        --g_LSO_END_FREQ_CH              : INTEGER := 63;
        --// Board parameters
        g_CLOCK_FREQ                     : INTEGER := 50000000 --// In Hz
    );
    PORT (
        --// Clock signal
        i_clock                          : IN  STD_LOGIC;
        --// Reset signal (active low)
        i_nreset                         : IN  STD_LOGIC;
        --// Output spikes from left NAS channel
        i_nas_left_out_spikes            : IN  STD_LOGIC_VECTOR(((g_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
        --// Output spikes from right NAS channel
        i_nas_right_out_spikes           : IN  STD_LOGIC_VECTOR(((g_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
        --// Output spikes from sMSO model (ALREADY IMPLEMENTED, BUT WITH AER OUTPUT)
        --o_mso_out_spikes                 : OUT STD_LOGIC_VECTOR(((g_MSO_NUM_FREQ_CH * g_MSO_NUM_ITD_NEURONS) - 1) DOWNTO 0);
        --// Output spikes from sLSO model (NOT IMPLEMENTED YET)
        --o_lso_out_spikes               : OUT STD_LOGIC_VECTOR(((NUM_FREQ_CH_LSO * 2) - 1) DOWNTO 0)
        --// AER output interface (req & ack active low)
        o_soc_aer_out_data               : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        o_soc_aer_out_req                : OUT STD_LOGIC;
        i_soc_aer_out_ack                : IN  STD_LOGIC
    );
END SOC;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF SOC IS

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------
    
    --
    -- MSO signals
    --

    -- Constants

    CONSTANT c_mso_monitor_nbits_itd_net_out : INTEGER := g_MSO_NUM_ITD_NEURONS * g_MSO_NUM_FREQ_CH;

    -- Signals
    SIGNAL left_non_phase_locked_spikes  : STD_LOGIC_VECTOR(((g_MSO_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
    SIGNAL right_non_phase_locked_spikes : STD_LOGIC_VECTOR(((g_MSO_NUM_FREQ_CH * 2) - 1) DOWNTO 0);

    SIGNAL left_phase_locked_spikes  : STD_LOGIC_VECTOR((g_MSO_NUM_FREQ_CH) - 1 DOWNTO 0);
    SIGNAL right_phase_locked_spikes : STD_LOGIC_VECTOR((g_MSO_NUM_FREQ_CH) - 1 DOWNTO 0);

    SIGNAL itd_out_spikes : STD_LOGIC_VECTOR(((g_MSO_NUM_FREQ_CH * g_MSO_NUM_ITD_NEURONS) - 1) DOWNTO 0);

    --
    -- LSO signals
    --

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- MSO-related modules
    ---------------------------------------------------------------------------

    --
    -- AVCN
    --
    COMPONENT AVCN IS
        GENERIC (
            NUM_FREQ_CH             : INTEGER := 4
        );
        PORT (
            i_clock                 : IN  STD_LOGIC;
            i_nreset                : IN  STD_LOGIC;
            i_auditory_nerve_spikes : IN  STD_LOGIC_VECTOR(((NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            o_phase_locked_spikes   : OUT STD_LOGIC_VECTOR((NUM_FREQ_CH - 1) DOWNTO 0)
        );
    END COMPONENT;

    --
    -- MSO
    --
    COMPONENT MSO IS
        GENERIC (
            NUM_FREQ_CH          : INTEGER := 4;
            NUM_NET_NEURONS      : INTEGER := 16;
            MAX_DETECTION_TIME   : INTEGER := 700;
            DETECTION_OVERLAPING : INTEGER := 1;
            CLOCK_FREQ           : INTEGER := 50000000 -- In Hz
        );
        PORT (
            i_clock              : IN  STD_LOGIC;
            i_nreset             : IN  STD_LOGIC;
            i_left_avcn_spikes   : IN  STD_LOGIC_VECTOR((NUM_FREQ_CH - 1) DOWNTO 0);
            i_right_avcn_spikes  : IN  STD_LOGIC_VECTOR((NUM_FREQ_CH - 1) DOWNTO 0);
            o_itd_out_spikes     : OUT STD_LOGIC_VECTOR(((NUM_FREQ_CH * NUM_NET_NEURONS) - 1) DOWNTO 0)
        );
    END COMPONENT;

    --
    -- MSO monitor
    --
    COMPONENT mso_events_monitor_top IS
        GENERIC (
            START_FREQ_CHANNEL     : INTEGER := 60;
            END_FREQ_CHANNEL       : INTEGER := 63;
            NUM_FREQ_CHANNEL       : INTEGER := 4;
            NBITS_NUM_FREQ_CHANNEL : INTEGER := 2;
            NUM_ITD_NEURONS        : INTEGER := 16;
            NBITS_NUM_ITD_NEURONS  : INTEGER := 4;
            NBITS_ITD_NET_OUT      : INTEGER := 64;
            SUBMODULES_FIFO_DEPTH  : INTEGER := 32;
            AER_OUT_FIFO_DEPTH     : INTEGER := 64
        );
        PORT (
            i_clock                : IN  STD_LOGIC;
            i_reset                : IN  STD_LOGIC;
            i_mso_output_spikes    : IN  STD_LOGIC_VECTOR ((NBITS_ITD_NET_OUT - 1) DOWNTO 0);
            o_out_aer_event        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            o_out_aer_req          : OUT STD_LOGIC;
            i_out_aer_ack          : IN  STD_LOGIC
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- LSO-related modules
    ---------------------------------------------------------------------------

    --
    -- LSO
    --

    --
    -- LSO monitor
    --

    ---------------------------------------------------------------------------
    -- Output-related modules
    ---------------------------------------------------------------------------

    --
    -- Merger
    --

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Components instantiation
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- MSO-related modules
    ---------------------------------------------------------------------------

    --
    -- AVCN
    --

    -- Left AVCN
    left_non_phase_locked_spikes <= i_nas_left_out_spikes(((g_MSO_END_FREQ_CH * 2) + 1) DOWNTO ((g_MSO_START_FREQ_CH * 2)));

    U_AVCN_left : AVCN
        GENERIC MAP (
            NUM_FREQ_CH             => g_MSO_NUM_FREQ_CH
        )
        PORT MAP (
            i_clock                 => i_clock,
            i_nreset                => i_nreset,
            i_auditory_nerve_spikes => left_non_phase_locked_spikes,
            o_phase_locked_spikes   => left_phase_locked_spikes
        );

    -- Right AVCN
    right_non_phase_locked_spikes <= i_nas_right_out_spikes(((g_MSO_END_FREQ_CH * 2) + 1) DOWNTO ((g_MSO_START_FREQ_CH * 2)));

    U_AVCN_right : AVCN
        GENERIC MAP (
            NUM_FREQ_CH             => g_MSO_NUM_FREQ_CH
        )
        PORT MAP (
            i_clock                 => i_clock,
            i_nreset                => i_nreset,
            i_auditory_nerve_spikes => right_non_phase_locked_spikes,
            o_phase_locked_spikes   => right_phase_locked_spikes
        );

    --
    -- MSO
    --

    --o_mso_out_spikes <= itd_out_spikes;

    U_MSO : MSO
        GENERIC MAP (
            NUM_FREQ_CH          => g_MSO_NUM_FREQ_CH,
            NUM_NET_NEURONS      => g_MSO_NUM_ITD_NEURONS,
            MAX_DETECTION_TIME   => g_MSO_ITD_MAX_DETECTION_TIME,
            DETECTION_OVERLAPING => g_MSO_ITD_DETECTION_TIME_OVERLAP,
            CLOCK_FREQ           => g_CLOCK_FREQ
        )
        PORT MAP (
            i_clock              => i_clock,
            i_nreset             => i_nreset,
            i_left_avcn_spikes   => left_phase_locked_spikes,
            i_right_avcn_spikes  => right_phase_locked_spikes,
            o_itd_out_spikes     => itd_out_spikes
        );

    --
    -- MSO monitor
    --
    U_MSO_monitor : mso_events_monitor_top
        GENERIC MAP (
            START_FREQ_CHANNEL     => g_MSO_START_FREQ_CH,
            END_FREQ_CHANNEL       => g_MSO_END_FREQ_CH,
            NUM_FREQ_CHANNEL       => g_MSO_NUM_FREQ_CH,
            NBITS_NUM_FREQ_CHANNEL => g_MSO_NBITS_NUM_FREQ_CH,
            NUM_ITD_NEURONS        => g_MSO_NUM_ITD_NEURONS,
            NBITS_NUM_ITD_NEURONS  => g_MSO_NBITS_NUM_ITD_NEURONS,
            NBITS_ITD_NET_OUT      => c_mso_monitor_nbits_itd_net_out,
            SUBMODULES_FIFO_DEPTH  => 32,
            AER_OUT_FIFO_DEPTH     => 64
        )
        PORT MAP (
            i_clock                => i_clock,
            i_reset                => i_nreset,
            i_mso_output_spikes    => itd_out_spikes,
            o_out_aer_event        => o_soc_aer_out_data,
            o_out_aer_req          => o_soc_aer_out_req,
            i_out_aer_ack          => i_soc_aer_out_ack
        );

    ---------------------------------------------------------------------------
    -- LSO-related modules
    ---------------------------------------------------------------------------

    --
    -- LSO
    --


    --
    -- LSO monitor
    --


    ---------------------------------------------------------------------------
    -- Output-related modules
    ---------------------------------------------------------------------------

    --
    -- Merger
    --

END Behavioral;