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
-- Created    : 2019-07-29
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
ENTITY mso_events_monitor_top IS
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
END mso_events_monitor_top;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF mso_events_monitor_top IS

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------

    --
    -- MSO monitor modules signals
    --
    TYPE t_array_stdlogicvector IS ARRAY (0 TO (NUM_FREQ_CHANNEL - 1)) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL mso_monitor_modules_output                : t_array_stdlogicvector;
    SIGNAL mso_monitor_modules_read_from_fifos       : STD_LOGIC_VECTOR((NUM_FREQ_CHANNEL - 1) DOWNTO 0);
    SIGNAL mso_monitor_modules_read_from_fifos_index : STD_LOGIC_VECTOR((NBITS_NUM_FREQ_CHANNEL-1) DOWNTO 0); --CUIDADO, depdende del numero de canales --> log2(numchannels)
    SIGNAL mso_monitor_modules_empty_fifo_flags      : STD_LOGIC_VECTOR((NUM_FREQ_CHANNEL - 1) DOWNTO 0);
    SIGNAL mso_monitor_modules_full_fifo_flags       : STD_LOGIC_VECTOR((NUM_FREQ_CHANNEL - 1) DOWNTO 0);

    --
    -- Arbiter signals
    --
    SIGNAL inverted_mso_monitor_modules_empty_fifo_flags : STD_LOGIC_VECTOR((NUM_FREQ_CHANNEL - 1) DOWNTO 0);
    
    SIGNAL arbiter_grant_read_from_fifo                  : STD_LOGIC_VECTOR((NUM_FREQ_CHANNEL - 1) DOWNTO 0);
    
    --
    -- Out FIFO signals
    --
    SIGNAL aer_out_fifo_wr_en : STD_LOGIC;
    SIGNAL aer_out_fifo_full  : STD_LOGIC;
    SIGNAL aer_out_fifo_rd_en : STD_LOGIC;
    SIGNAL aer_out_fifo_empty : STD_LOGIC;

    SIGNAL aer_out_fifo_data_to_write : STD_LOGIC_VECTOR(15 downto 0);
    SIGNAL aer_out_fifo_data_to_read  : STD_LOGIC_VECTOR(15 downto 0);
    
    -- Encoder signal
    SIGNAL encoder_new_out_event_available : STD_LOGIC;
    
    -- AER output interface
    SIGNAL aer_out_if_busy               : STD_LOGIC;
    SIGNAL aer_out_if_busy_inverted      : STD_LOGIC;
    SIGNAL aer_out_if_new_aer_in         : STD_LOGIC;
	SIGNAL aer_out_if_new_aer_in_latched : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    --
    -- MSO events monitor module
    --
    COMPONENT mso_events_monitor_module IS
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
    END COMPONENT;

    --
    -- Arbiter
    --
    COMPONENT rrarbiter IS
        GENERIC (
            CNT   : INTEGER := 4
        );
        PORT (
            clk   : IN  STD_LOGIC;
            rst_n : IN  STD_LOGIC;
            req   : IN  STD_LOGIC_VECTOR(CNT - 1 DOWNTO 0);
            ack   : IN  STD_LOGIC;
            grant : OUT STD_LOGIC_VECTOR(CNT - 1 DOWNTO 0)
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
            i_rst_sync : IN  STD_LOGIC;
            i_clk      : IN  STD_LOGIC;
            -- FIFO Write Interface
            i_wr_en    : IN  STD_LOGIC;
            i_wr_data  : IN  STD_LOGIC_VECTOR(g_WIDTH - 1 DOWNTO 0);
            o_full     : OUT STD_LOGIC;
            -- FIFO Read Interface
            i_rd_en    : IN  STD_LOGIC;
            o_rd_data  : OUT STD_LOGIC_VECTOR(g_WIDTH - 1 DOWNTO 0);
            o_empty    : OUT STD_LOGIC
        );
    END COMPONENT module_fifo_regs_no_flags;

    --
    -- Events encoder
    --
    COMPONENT events_encoder IS
        GENERIC (
            N_EVENTS          : INTEGER := 4;
            NBITS_ADDRESS     : INTEGER := 2
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
    -- AER output interface
    --
    COMPONENT aer_if_out IS
        PORT (
            i_nreset     : IN  STD_LOGIC;
            i_clock      : IN  STD_LOGIC;
            i_ack        : IN  STD_LOGIC;
            i_aer_in     : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
            i_new_aer_in : IN  STD_LOGIC;
            o_req        : OUT STD_LOGIC;
            o_aer_out    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            o_busy       : OUT STD_LOGIC
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
    -- MSO events monitor generator
    --
    mso_monitor_modules_read_from_fifos <= arbiter_grant_read_from_fifo AND (NOT mso_monitor_modules_empty_fifo_flags);
    
    GEN_MSO_MONITOR_MODULES : FOR I IN 0 TO (NUM_FREQ_CHANNEL - 1) GENERATE
        U_MSO_MONITOR_MODULE : mso_events_monitor_module
            GENERIC MAP(
                NDETECTOR_NEURONS       => NUM_ITD_NEURONS,
                NBITS_NDETECTOR_NEURONS => NBITS_NUM_ITD_NEURONS,
                FIFO_DEPTH              => SUBMODULES_FIFO_DEPTH,
                CHANNEL_VAL             => (START_FREQ_CHANNEL + I)
            )
            PORT MAP(
                i_clock                 => i_clock,
                i_reset                 => i_reset,
                i_in_mso_spikes         => i_mso_output_spikes(((NUM_ITD_NEURONS - 1) + (NUM_ITD_NEURONS * I)) DOWNTO (I * NUM_ITD_NEURONS)),
                i_read_aer_event        => mso_monitor_modules_read_from_fifos(I),
                o_out_aer_event         => mso_monitor_modules_output(I),
                o_no_aer_events         => mso_monitor_modules_empty_fifo_flags(I),
                o_full_aer_events       => mso_monitor_modules_full_fifo_flags(I) -- use this flag for disable the input spikes
            );
    END GENERATE GEN_MSO_MONITOR_MODULES;

    --
    -- Events monitor arbiter
    --
    inverted_mso_monitor_modules_empty_fifo_flags <= NOT mso_monitor_modules_empty_fifo_flags;
    aer_out_if_busy_inverted                      <= NOT aer_out_if_busy;
	
    U_Monitors_Arbiter : rrarbiter
        GENERIC MAP (
            CNT   => NUM_FREQ_CHANNEL
        )
        PORT MAP (
            clk   => i_clock,
            rst_n => i_reset,
            req   => inverted_mso_monitor_modules_empty_fifo_flags,
            ack   => '1',
            grant => arbiter_grant_read_from_fifo
        );

    --
    -- FIFO memory
    --
    aer_out_fifo_wr_en <= encoder_new_out_event_available AND (NOT aer_out_fifo_full);
    aer_out_fifo_rd_en <= (NOT aer_out_if_busy) AND (NOT aer_out_fifo_empty);

    aer_out_fifo_data_to_write <= mso_monitor_modules_output(TO_INTEGER(UNSIGNED(mso_monitor_modules_read_from_fifos_index)));

    U_output_fifo : module_fifo_regs_no_flags
        GENERIC MAP (
            g_WIDTH    => 16,
            g_DEPTH    => AER_OUT_FIFO_DEPTH
        )
        PORT MAP (
            i_rst_sync => i_reset,
            i_clk      => i_clock,
            -- FIFO Write Interface
            i_wr_en    => aer_out_fifo_wr_en, 
            i_wr_data  => aer_out_fifo_data_to_write,
            o_full     => aer_out_fifo_full,
            -- FIFO Read Interface
            i_rd_en    => aer_out_fifo_rd_en,
            o_rd_data  => aer_out_fifo_data_to_read,
            o_empty    => aer_out_fifo_empty
        );

    --
    -- Events Encoders
    --
    U_encoder : events_encoder
        GENERIC MAP (
            N_EVENTS          => NUM_FREQ_CHANNEL,
            NBITS_ADDRESS     => NBITS_NUM_FREQ_CHANNEL
        )
        PORT MAP (
            i_clock           => i_clock,
            i_reset           => i_reset,
            i_in_events       => mso_monitor_modules_read_from_fifos,
            o_out_address     => mso_monitor_modules_read_from_fifos_index,
            o_new_out_address => encoder_new_out_event_available
        );


    --
    -- AER out interface
    --
	aer_out_if_new_aer_in <= (NOT aer_out_if_busy) AND (NOT aer_out_fifo_empty);
    
    PROCESS(i_clock, i_reset)
    BEGIN
        IF(i_reset = '0') THEN
            aer_out_if_new_aer_in_latched <= '0';
        ELSE
            IF(rising_edge(i_clock)) THEN
                aer_out_if_new_aer_in_latched <= aer_out_if_new_aer_in;
            ELSE
                
            END IF;
        END IF;
    END PROCESS;

    U_aer_if_out: aer_if_out
        PORT MAP (
            i_nreset     => i_reset,
            i_clock      => i_clock,
            i_ack        => i_out_aer_ack,
            i_aer_in     => aer_out_fifo_data_to_read,
            i_new_aer_in => aer_out_if_new_aer_in,
            o_req        => o_out_aer_req,
            o_aer_out    => o_out_aer_event,
            o_busy       => aer_out_if_busy
        );

END Behavioral;