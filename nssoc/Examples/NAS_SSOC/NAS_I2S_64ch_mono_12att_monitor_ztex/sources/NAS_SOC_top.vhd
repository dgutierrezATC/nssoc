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
-- Title      : NAS & SOC top module
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : NAS_SOC_top.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2019-08-27
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
ENTITY NAS_SOC_top IS
    --Generic (
    --    g_ENABLE_SOUND_SOURCE_LOC : INTEGER := 0
    --);
    PORT (
        -- Clock and reset
        i_sys_clock : IN  STD_LOGIC;
        i_sys_reset : IN  STD_LOGIC;
        -- Input interface
        i_I2S_sd    : IN  STD_LOGIC;
        i_I2S_sck   : IN  STD_LOGIC;
        i_I2S_ws    : IN  STD_LOGIC;
        -- Output interface
        o_AER_data  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        o_AER_req   : OUT STD_LOGIC;
        i_AER_ack   : IN  STD_LOGIC
    );
END NAS_SOC_top;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF NAS_SOC_top IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------
    CONSTANT c_NAS_NUM_FREQ_CH                : INTEGER := 64;
    CONSTANT c_MSO_START_FREQ_CH              : INTEGER := 25;
    CONSTANT c_MSO_END_FREQ_CH                : INTEGER := 34;
    CONSTANT c_MSO_NUM_FREQ_CH                : INTEGER := 10;
    CONSTANT C_MSO_NBITS_NUM_FREQ_CH          : INTEGER := 4;
    CONSTANT c_MSO_NUM_ITD_NEURONS            : INTEGER := 16;
    CONSTANT c_MSO_NBITS_NUM_ITD_NEURONS      : INTEGER := 4;
    CONSTANT c_MSO_ITD_MAX_DETECTION_TIME     : INTEGER := 700;
    CONSTANT c_MSO_ITD_DETECTION_TIME_OVERLAP : INTEGER := 5;
    CONSTANT c_CLOCK_FREQ                     : INTEGER := 48000000;
    
    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------
    SIGNAL w_nas_raw_output_spikes_left  : STD_LOGIC_VECTOR(((c_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
    SIGNAL w_nas_raw_output_spikes_right : STD_LOGIC_VECTOR(((c_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);

    SIGNAL w_mso_raw_output_spikes : STD_LOGIC_VECTOR(((c_MSO_NUM_FREQ_CH * c_MSO_NUM_ITD_NEURONS) - 1) DOWNTO 0);

    SIGNAL w_SOC_AER_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL w_SOC_AER_req  : STD_LOGIC;
    SIGNAL w_SOC_AER_ack  : STD_LOGIC;

    SIGNAL w_NAS_AER_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL w_NAS_AER_req  : STD_LOGIC;
    SIGNAL w_NAS_AER_ack  : STD_LOGIC;

    SIGNAL w_merger_OUT_AER_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL w_merger_OUT_AER_req  : STD_LOGIC;
    SIGNAL w_merger_OUT_AER_ack  : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    --
    -- NAS
    --
    COMPONENT OpenNas_Cascade_STEREO_64ch IS
        PORT (
            clock                : IN  STD_LOGIC;
            rst_ext              : IN  STD_LOGIC;
            --//I2S Bus
            i2s_bclk             : IN  STD_LOGIC;
            i2s_d_in             : IN  STD_LOGIC;
            i2s_lr               : IN  STD_LOGIC;
            --//Output raw spikes
            nas_spikes_out_left  : OUT STD_LOGIC_VECTOR(((c_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            nas_spikes_out_rigth : OUT STD_LOGIC_VECTOR(((c_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            --//AER Output
            AER_DATA_OUT         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            AER_REQ              : OUT STD_LOGIC;
            AER_ACK              : IN  STD_LOGIC
        );
    END COMPONENT;

    --
    -- SOC- 
    --
    COMPONENT SOC IS
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
    END COMPONENT;

    --
    -- AER audio out merger
    --
    COMPONENT AER_audio_out_merger IS
        PORT (
            --// Clock and external reset button-----------------
            i_clock            : IN  STD_LOGIC;
            i_nreset           : IN  STD_LOGIC;
            --// INPUT interfaces-------------------------------
            --// NAS AER interface
            i_nas_aer_out_data : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            i_nas_aer_out_req  : IN  STD_LOGIC;
            o_nas_aer_out_ack  : OUT STD_LOGIC;
            --// SOC AER interface
            i_soc_aer_out_data : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            i_soc_aer_out_req  : IN  STD_LOGIC;
            o_soc_aer_out_ack  : OUT STD_LOGIC;
            --// OUTPUT interface--------------------------------
            --// Auditory AER interface
            o_aer_out_data     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            o_aer_out_req      : OUT STD_LOGIC;
            i_aer_out_ack      : IN  STD_LOGIC
        );
    END COMPONENT;

BEGIN
    --//======================================================
    --// Components instantiation
    --//======================================================

    --//==============
    --// NAS
    --//==============
    U_NAS : OpenNas_Cascade_STEREO_64ch
        PORT MAP (
            clock                => i_sys_clock,
            rst_ext              => i_sys_reset,
            i2s_bclk             => i_I2S_sck,
            i2s_d_in             => i_I2S_sd,
            i2s_lr               => i_I2S_ws,
            nas_spikes_out_left  => w_nas_raw_output_spikes_left,
            nas_spikes_out_rigth => w_nas_raw_output_spikes_right,
            AER_DATA_OUT         => w_NAS_AER_data,
            AER_REQ              => w_NAS_AER_req,
            AER_ACK              => w_NAS_AER_ack
        );

    --//=========================
    --//----------SOC------------ 
    --//=========================
    U_SOC : SOC
        GENERIC MAP (
            --// NAS parameters
            g_NAS_NUM_FREQ_CH                => c_NAS_NUM_FREQ_CH,
            --// MSO parameters
            g_MSO_NUM_FREQ_CH                => c_MSO_NUM_FREQ_CH,
            g_MSO_NBITS_NUM_FREQ_CH          => C_MSO_NBITS_NUM_FREQ_CH,
            g_MSO_START_FREQ_CH              => c_MSO_START_FREQ_CH,
            g_MSO_END_FREQ_CH                => c_MSO_END_FREQ_CH,
            g_MSO_NUM_ITD_NEURONS            => c_MSO_NUM_ITD_NEURONS,
            g_MSO_NBITS_NUM_ITD_NEURONS      => c_MSO_NBITS_NUM_ITD_NEURONS,
            g_MSO_ITD_MAX_DETECTION_TIME     => c_MSO_ITD_MAX_DETECTION_TIME,
            g_MSO_ITD_DETECTION_TIME_OVERLAP => c_MSO_ITD_DETECTION_TIME_OVERLAP,
            --// LSO PARAMETERS
            --g_LSO_NUM_FREQ_CH              => ,
            --g_LSO_START_FREQ_CH            => ,
            --g_LSO_END_FREQ_CH              => ,
            --// Board parameters
            g_CLOCK_FREQ                     => c_CLOCK_FREQ
        )
        PORT MAP (
            --// Clock signal
            i_clock                          => i_sys_clock,
            --// Reset signal (active low)
            i_nreset                         => i_sys_reset,
            --// Output spikes from left NAS channel
            i_nas_left_out_spikes            => w_nas_raw_output_spikes_left,
            --// Output spikes from right NAS channel
            i_nas_right_out_spikes           => w_nas_raw_output_spikes_right,
            --// Output spikes from sMSO model (ALREADY IMPLEMENTED, BUT WITH AER OUTPUT)
            --o_mso_out_spikes                 => w_mso_raw_output_spikes,
            --// Output spikes from sLSO model (NOT IMPLEMENTED YET)
            --o_lso_out_spikes               => ,
            --// AER output interface (req & ack active low)
            o_soc_aer_out_data               => w_SOC_AER_data,
            o_soc_aer_out_req                => w_SOC_AER_req,
            i_soc_aer_out_ack                => w_SOC_AER_ack
        );

    --//=========================
    --//--AER audio out merger-- 
    --//=========================
    U_NAS_SOC_AER_out_merger : AER_audio_out_merger
        PORT MAP (
            --// Clock and external reset button-----------------
            i_clock            => i_sys_clock,
            i_nreset           => i_sys_reset,
            --// AER interface from NAS
            i_nas_aer_out_data => w_NAS_AER_data,
            i_nas_aer_out_req  => w_NAS_AER_req,
            o_nas_aer_out_ack  => w_NAS_AER_ack,
            --// AER interface from SOC
            i_soc_aer_out_data => w_SOC_AER_data,
            i_soc_aer_out_req  => w_SOC_AER_req,
            o_soc_aer_out_ack  => w_SOC_AER_ack,
            --// Output AER interface
            o_aer_out_data     => w_merger_OUT_AER_data,
            o_aer_out_req      => w_merger_OUT_AER_req,
            i_aer_out_ack      => w_merger_OUT_AER_ack
        );

    --//==============
    --// Assignations
    --//==============
    o_AER_data           <= w_merger_OUT_AER_data;
    o_AER_req            <= w_merger_OUT_AER_req;
    w_merger_OUT_AER_ack <= i_AER_ack;

END Behavioral;