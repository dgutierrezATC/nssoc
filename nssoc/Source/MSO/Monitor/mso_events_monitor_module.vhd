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
-- File       : mso_events_monitor_module.vhd
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

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY mso_events_monitor_module IS
    GENERIC (
        NDETECTOR_NEURONS       : INTEGER := 16;
        NBITS_NDETECTOR_NEURONS : INTEGER := 4;
        FIFO_DEPTH              : INTEGER := 32;
        CHANNEL_VAL             : INTEGER := 1
    );
    PORT (
        i_clock                 : IN  STD_LOGIC;
        i_reset                 : IN  STD_LOGIC;
        i_in_mso_spikes         : IN  STD_LOGIC_VECTOR ((NDETECTOR_NEURONS - 1) DOWNTO 0);
        i_read_aer_event        : IN  STD_LOGIC;
        o_out_aer_event         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        o_no_aer_events         : OUT STD_LOGIC;
        o_full_aer_events       : OUT STD_LOGIC
    );
END mso_events_monitor_module;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF mso_events_monitor_module IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------
    SIGNAL ec_output_address     : STD_LOGIC_VECTOR((NBITS_NDETECTOR_NEURONS-1) DOWNTO 0);
    SIGNAL ec_new_output_address : STD_LOGIC;

    SIGNAL em_aer_data           : STD_LOGIC_VECTOR((NBITS_NDETECTOR_NEURONS-1) DOWNTO 0);

    SIGNAL ef_write_enable       : STD_LOGIC;
    SIGNAL ef_fifo_full          : STD_LOGIC;
    SIGNAL ef_read_enable        : STD_LOGIC;
    SIGNAL ef_fifo_empty         : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    --
    -- Events encoder
    --
    COMPONENT events_encoder IS
        GENERIC (
            N_EVENTS          : INTEGER := 16;
            NBITS_ADDRESS     : INTEGER := 4
        );
        PORT (
            i_clock           : IN  STD_LOGIC;
            i_reset           : IN  STD_LOGIC;
            i_in_events       : IN  STD_LOGIC_VECTOR ((N_EVENTS - 1) DOWNTO 0);
            o_out_address     : OUT STD_LOGIC_VECTOR ((NBITS_ADDRESS - 1) DOWNTO 0);
            o_new_out_address : OUT STD_LOGIC
        );
    END COMPONENT;

    --
    -- FIFO memory
    --
    COMPONENT module_fifo_regs_no_flags IS
        GENERIC (
            g_WIDTH    : NATURAL := 16;
            g_DEPTH    : INTEGER := 32
        );
        PORT (
            i_rst_sync : IN std_logic;
            i_clk      : IN std_logic;
            -- FIFO Write Interface
            i_wr_en    : IN std_logic;
            i_wr_data  : IN std_logic_vector(g_WIDTH - 1 DOWNTO 0);
            o_full : OUT std_logic;
            -- FIFO Read Interface
            i_rd_en    : IN std_logic;
            o_rd_data  : OUT std_logic_vector(g_WIDTH - 1 DOWNTO 0);
            o_empty    : OUT std_logic
        );
    END COMPONENT module_fifo_regs_no_flags;

    --
    -- Events mask
    --
    COMPONENT events_mask IS
        GENERIC (
            NBITS_ADDRESS       : INTEGER := 4;
            CHANNEL_VAL         : INTEGER := 1
        );
        PORT (
            i_input_address     : IN STD_LOGIC_VECTOR ((NBITS_ADDRESS - 1) DOWNTO 0);
            o_output_masked_aer : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
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
    -- Events Encoders
    --
    U_encoder : events_encoder
        GENERIC MAP (
            N_EVENTS          => NDETECTOR_NEURONS,
            NBITS_ADDRESS     => NBITS_NDETECTOR_NEURONS
        )
        PORT MAP (
            i_clock           => i_clock,
            i_reset           => i_reset,
            i_in_events       => i_in_mso_spikes,
            o_out_address     => ec_output_address,
            o_new_out_address => ec_new_output_address
        );

    --
    -- FIFO memory
    --

    ef_write_enable <= ec_new_output_address AND (NOT ef_fifo_full);
    ef_read_enable  <= i_read_aer_event AND (NOT ef_fifo_empty);

    MODULE_FIFO_REGS_NO_FLAGS_INST : module_fifo_regs_no_flags
        GENERIC MAP (
            g_WIDTH    => NBITS_NDETECTOR_NEURONS,
            g_DEPTH    => FIFO_DEPTH
        )
        PORT MAP (
            i_rst_sync => i_reset,
            i_clk      => i_clock,
            -- FIFO Write Interface
            i_wr_en    => ef_write_enable, --ec_new_output_address,
            i_wr_data  => ec_output_address,
            o_full     => ef_fifo_full,
            -- FIFO Read Interface
            i_rd_en    => ef_read_enable, --i_read_aer_event,
            o_rd_data  => em_aer_data,
            o_empty    => ef_fifo_empty
        );

    --
    -- Events masks
    --
    U_mask : events_mask
        GENERIC MAP (
            NBITS_ADDRESS       => NBITS_NDETECTOR_NEURONS,
            CHANNEL_VAL         => CHANNEL_VAL
        )
        PORT MAP (
            i_input_address     => em_aer_data,
            o_output_masked_aer => o_out_aer_event
        );
    
    -----------------------------------------------------------------------------
    -- Output assign
    -----------------------------------------------------------------------------
    o_no_aer_events   <= ef_fifo_empty;
    o_full_aer_events <= ef_fifo_full;

END Behavioral;