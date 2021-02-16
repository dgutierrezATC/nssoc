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
-- Title      : Testbench for the MSO events monitor
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : mso_events_monitor_top_tb.vhd
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
ENTITY mso_events_monitor_top_tb IS

END mso_events_monitor_top_tb;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE behavior OF mso_events_monitor_top_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT mso_events_monitor_top
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
    -- UUT signals declaration
    ---------------------------------------------------------------------------

    -- Component constants
    CONSTANT c_START_FREQ_CHANNEL     : INTEGER := 60;
    CONSTANT c_END_FREQ_CHANNEL       : INTEGER := 63;
    CONSTANT c_NUM_FREQ_CHANNEL       : INTEGER := 4;
    CONSTANT c_NBITS_NUM_FREQ_CHANNEL : INTEGER := 2;
    CONSTANT c_NUM_ITD_NEURONS        : INTEGER := 16;
    CONSTANT c_NBITS_NUM_ITD_NEURONS  : INTEGER := 4;
    CONSTANT c_NBITS_ITD_NET_OUT      : INTEGER := 64;
    CONSTANT c_SUBMODULES_FIFO_DEPTH  : INTEGER := 32;
    CONSTANT c_AER_OUT_FIFO_DEPTH     : INTEGER := 64;

    -- Component input ports
    SIGNAL i_clock             : STD_LOGIC := '0';
    SIGNAL i_reset             : STD_LOGIC := '0';
	SIGNAL i_mso_output_spikes : STD_LOGIC_VECTOR((c_NBITS_ITD_NET_OUT - 1) DOWNTO 0) := (OTHERS => '0');
	signal i_out_aer_ack       : STD_LOGIC := '1';

    --Component outputs ports
    SIGNAL o_out_aer_event     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL o_out_aer_req       : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Clock
    CONSTANT c_i_clock_period    : TIME := 10 ns;

    -- Saving results in a file
    --CONSTANT c_absolute_path      : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Testbench/MSO/Monitor/Results/Files/"; -- Absolute path to the testbench files
    SIGNAL tb_start_of_simulation : STD_LOGIC := '0'; -- Flag to indicate the begining of the simulation
    SIGNAL tb_end_of_simulation   : STD_LOGIC := '0'; -- Flag to indicate the end of the simulation
        
    --FILE f_input_spikes     : TEXT OPEN write_mode IS c_absolute_path & "mso_events_monitor_module_tb_input_spikes.txt";  -- Input spikes filename
    --FILE f_output_spikes    : TEXT OPEN write_mode IS c_absolute_path & "mso_events_monitor_module_tb_output_spikes.txt"; -- Output spikes filename

    ---------------------------------------------------------------------------
    -- Procedures
    ---------------------------------------------------------------------------
    
    -- purpose: Generate a single event (one clock cycle spike)
    PROCEDURE pr_event_generator (
        CONSTANT c_clock_period    : IN  TIME;      -- Clock period of the simulation
        SIGNAL   r_generated_spike : OUT STD_LOGIC  -- Output generated event 
    ) IS        
        BEGIN  -- procedure pr_event_generator
            r_generated_spike <= '1';
            WAIT FOR c_clock_period;
            r_generated_spike <= '0';
            WAIT FOR c_clock_period;
    END PROCEDURE pr_event_generator;

    -- purpose: Generate a set of events to be monitored
    PROCEDURE pr_event_burst_generator (
        CONSTANT c_clock_period        : IN  TIME;       -- Clock period of the simulation
        CONSTANT c_num_events_burst    : IN  INTEGER;
        CONSTANT c_time_between_events : IN  INTEGER;
        CONSTANT c_num_burst           : IN  INTEGER;
        SIGNAL r_generated_spike       : OUT STD_LOGIC_VECTOR((c_NBITS_ITD_NET_OUT - 1) DOWNTO 0)  -- Output generated event
    ) IS
        BEGIN  -- procedure pr_event_generator
            FOR v_num_burst IN 0 TO (c_num_burst - 1) LOOP
                FOR i IN 0 TO (c_num_events_burst-1) LOOP
                    -- Set the flag to read a element from FIFO
                    r_generated_spike <= STD_LOGIC_VECTOR(TO_UNSIGNED(2 ** i, r_generated_spike'LENGTH));
                    REPORT "Reading events from FIFO.";
                    WAIT FOR c_clock_period;
                    r_generated_spike <= (OTHERS => '0');
                    -- Wait some time
                    WAIT FOR c_clock_period * c_time_between_events;
                END LOOP;
            END LOOP;
    END PROCEDURE pr_event_burst_generator;

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Instantiate the Unit Under Test (UUT)
    ---------------------------------------------------------------------------
    uut : mso_events_monitor_top
        GENERIC MAP (
            START_FREQ_CHANNEL     => c_START_FREQ_CHANNEL,
            END_FREQ_CHANNEL       => c_END_FREQ_CHANNEL,
            NUM_FREQ_CHANNEL       => c_NUM_FREQ_CHANNEL,
            NBITS_NUM_FREQ_CHANNEL => c_NBITS_NUM_FREQ_CHANNEL,
            NUM_ITD_NEURONS        => c_NUM_ITD_NEURONS,
            NBITS_NUM_ITD_NEURONS  => c_NBITS_NUM_ITD_NEURONS,
            NBITS_ITD_NET_OUT      => c_NBITS_ITD_NET_OUT,
            SUBMODULES_FIFO_DEPTH  => c_SUBMODULES_FIFO_DEPTH,
            AER_OUT_FIFO_DEPTH     => c_AER_OUT_FIFO_DEPTH
        )
        PORT MAP (
            i_clock                => i_clock,
            i_reset                => i_reset,
            i_mso_output_spikes    => i_mso_output_spikes,
            o_out_aer_event        => o_out_aer_event,
            o_out_aer_req          => o_out_aer_req,
            i_out_aer_ack          => i_out_aer_ack
        );

    ---------------------------------------------------------------------------
    -- Clocks generation
    ---------------------------------------------------------------------------
    i_clock <= NOT i_clock AFTER c_i_clock_period/2;

    -----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    -- purpose: Initial reset process
    -- type   :
    -- inputs : 
    -- outputs: 
    p_initial_reset : PROCESS
    BEGIN
        --
        -- First reset
        --

        -- Report the module is under reset
        REPORT "Initial reset..." SEVERITY NOTE;

        -- Start reset
        i_reset <= '0';
        -- Hold it for 1 us
        WAIT FOR 1 us;

        -- Clear reset
        i_reset <= '1';

        -- Report the reset has been clear
        REPORT "Reset cleared!" SEVERITY NOTE;

        -- Wait for a few clock cycles
        wait for c_i_clock_period*10;

        -- Set the begining of the testbench flag to 1
        tb_start_of_simulation <= '1';
        REPORT "Starting the testbench..." SEVERITY NOTE;

        -- Wait forever
        WAIT;
    END PROCESS p_initial_reset;

    -- purpose: Set the signals to generate the stimuli
    -- type   : combinational
    -- inputs : 
    -- outputs: 
    p_stimuli : PROCESS
    BEGIN
--
        -- Wait until the end of the reset;
        --
        WAIT UNTIL tb_start_of_simulation = '1';

        --
        -- Idle
        --
        WAIT FOR 2 us;

        --
        -- Sync
        --

        -- Report the testbench is being sync with the clock
        REPORT "Sync..." SEVERITY NOTE;

        wait until i_clock'event and i_clock = '1';
        wait for c_i_clock_period*10;


        --
        -- First case
        --

        -- Call the procedure to produce the event burst
        pr_event_burst_generator(c_i_clock_period, c_NBITS_ITD_NET_OUT, 5, 5, i_mso_output_spikes);

        --
        -- Idle
        --
        wait for c_i_clock_period * 1000;

        --
        -- End of the simulation
        --

        -- Notify the end of the simulation
        tb_end_of_simulation <= '1';
        REPORT "End of the simulation." SEVERITY NOTE;

        -- Wait forever
        WAIT;
    END PROCESS p_stimuli;

    -- purpose: Simulate the AER interface from the receiver
    -- type   : combinational
    -- inputs : o_out_aer_req
    -- outputs: i_out_aer_ack
    i_out_aer_ack <= o_out_aer_req AFTER c_i_clock_period * 20;

    -- purpose: Show the output AER data
    -- type   : combinational
    -- inputs : o_out_aer_req
    -- outputs: -
    PROCESS (o_out_aer_req)
    BEGIN
        IF (o_out_aer_req'EVENT AND o_out_aer_req = '0') THEN
            REPORT "Event address: " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(o_out_aer_event(13 DOWNTO 8))));
        END IF;
    END PROCESS;

END;