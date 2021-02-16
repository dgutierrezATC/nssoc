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
-- Title      : Testbench for the MSO events monitor module
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : mso_events_monitor_module_tb.vhd
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
ENTITY mso_events_monitor_module_tb IS

END mso_events_monitor_module_tb;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE behavior OF mso_events_monitor_module_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT mso_events_monitor_module
        GENERIC (
            NDETECTOR_NEURONS       : INTEGER := 16;
            NBITS_NDETECTOR_NEURONS : INTEGER := 4;
            FIFO_DEPTH              : INTEGER := 32;
            CHANNEL_VAL             : INTEGER := 1
        );
        PORT (
            i_clock           : IN  STD_LOGIC;
            i_reset           : IN  STD_LOGIC;
            i_in_mso_spikes   : IN  STD_LOGIC_VECTOR ((NDETECTOR_NEURONS - 1) DOWNTO 0);
            i_read_aer_event  : IN  STD_LOGIC;
            o_out_aer_event   : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            o_no_aer_events   : OUT STD_LOGIC;
            o_full_aer_events : OUT STD_LOGIC
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

    -- Component constants
    CONSTANT c_NDETECTOR_NEURONS       : INTEGER := 32;
    CONSTANT c_NBITS_NDETECTOR_NEURONS : INTEGER := 5;
    CONSTANT c_FIFO_DEPTH              : INTEGER := 32;
    CONSTANT c_CHANNEL_VAL             : INTEGER := 1;

    -- Component input ports
    SIGNAL i_clock          : STD_LOGIC := '0';
    SIGNAL i_reset          : STD_LOGIC := '0';
    SIGNAL i_in_mso_spikes  : STD_LOGIC_VECTOR((c_NDETECTOR_NEURONS - 1) DOWNTO 0) := (OTHERS => '0');
    SIGNAL i_read_aer_event : STD_LOGIC := '0';

    -- Component output ports
    SIGNAL o_out_aer_event   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL o_no_aer_events   : STD_LOGIC;
    SIGNAL o_full_aer_events : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Clock
    CONSTANT c_i_clock_period : TIME := 20 ns;

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

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Instantiate the Unit Under Test (UUT)
    ---------------------------------------------------------------------------
    uut : mso_events_monitor_module
        GENERIC MAP (
            NDETECTOR_NEURONS       => c_NDETECTOR_NEURONS,
            NBITS_NDETECTOR_NEURONS => c_NBITS_NDETECTOR_NEURONS,
            FIFO_DEPTH              => c_FIFO_DEPTH,
            CHANNEL_VAL             => c_CHANNEL_VAL
        )
        PORT MAP (
            i_clock           => i_clock,
            i_reset           => i_reset,
            i_in_mso_spikes   => i_in_mso_spikes,
            i_read_aer_event  => i_read_aer_event,
            o_out_aer_event   => o_out_aer_event,
            o_no_aer_events   => o_no_aer_events,
            o_full_aer_events => o_full_aer_events
        );

    ---------------------------------------------------------------------------
    -- Clocks generation
    ---------------------------------------------------------------------------
    i_clock <= NOT i_clock AFTER c_i_clock_period/2;

    -----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    -- purpose: Set the signals to generate the stimuli
    -- type   : combinational
    -- inputs : 
    -- outputs: 
    p_stimuli : PROCESS
        VARIABLE v_delta_t : INTEGER := 0; -- In clock cycles
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
        -- Generate single spikes from all the possible addresses, store in the FIFO memory
        -- and finally read all of them
        --
        FOR i IN 0 TO (c_NDETECTOR_NEURONS-1) LOOP
            -- Generate a single pulse
            i_in_mso_spikes <= STD_LOGIC_VECTOR(TO_UNSIGNED(2 ** i, i_in_mso_spikes'LENGTH));
            REPORT "Event fired by neuron: " & INTEGER'IMAGE(i);
            WAIT FOR c_i_clock_period;
            i_in_mso_spikes <= (OTHERS => '0');
            -- Wait some time
            WAIT FOR c_i_clock_period * 5;
        END LOOP;

        -- Wait for some clock cycles
        WAIT FOR c_i_clock_period * 20;

        -- Then, start reading from the FIFO memory until it gets empty
        FOR i IN 0 TO (c_NDETECTOR_NEURONS-1) LOOP
            -- Set the flag to read a element from FIFO
            i_read_aer_event <= '1';
            REPORT "Reading events from FIFO.";
            WAIT FOR c_i_clock_period;
            i_read_aer_event <= '0';
            -- Wait some time
            WAIT FOR c_i_clock_period * 10;
        END LOOP;

        --
        -- Generate single spikes from all the possible addresses, store in the FIFO memory
        -- until the fifo gets full
        --
        FOR i IN 0 TO (c_FIFO_DEPTH + 10) LOOP
            -- Generate a single pulse
            i_in_mso_spikes <= STD_LOGIC_VECTOR(TO_UNSIGNED(2, i_in_mso_spikes'LENGTH));
            REPORT "Event fired by neuron: " & INTEGER'IMAGE(i);
            WAIT FOR c_i_clock_period;
            i_in_mso_spikes <= (OTHERS => '0');
            -- Wait some time
            WAIT FOR c_i_clock_period * 5;
        END LOOP;

        --
        -- Generate a burst of spike where two neurons fire at the same time, and check the
        -- value stored in the FIFO memory
        --

        -- Reset for clearing everything

        -- Report the module is under reset
        REPORT "Reset..." SEVERITY NOTE;

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

        FOR i IN 0 TO (c_NDETECTOR_NEURONS-2) LOOP
            -- Generate a single pulse
            i_in_mso_spikes <= STD_LOGIC_VECTOR(TO_UNSIGNED((2 ** i) + 1, i_in_mso_spikes'LENGTH));
            REPORT "Event fired by neuron: " & INTEGER'IMAGE(i);
            WAIT FOR c_i_clock_period;
            i_in_mso_spikes <= (OTHERS => '0');
            -- Wait some time
            WAIT FOR c_i_clock_period * 5;
        END LOOP;

        -- Wait for some clock cycles
        WAIT FOR c_i_clock_period * 20;

        -- Then, start reading from the FIFO memory until it gets empty
        FOR i IN 0 TO (c_NDETECTOR_NEURONS-1) LOOP
            -- Set the flag to read a element from FIFO
            i_read_aer_event <= '1';
            REPORT "Reading events from FIFO.";
            WAIT FOR c_i_clock_period;
            i_read_aer_event <= '0';
            -- Wait some time
            WAIT FOR c_i_clock_period * 10;
        END LOOP;

        --
        -- End of the simulation
        --

        -- Notify the end of the simulation
        tb_end_of_simulation <= '1';
        REPORT "End of the simulation." SEVERITY NOTE;

        -- Wait forever
        WAIT;

    END PROCESS;

    PROCESS (o_out_aer_event, o_no_aer_events)
    BEGIN
        IF (o_no_aer_events = '0') THEN
            REPORT "Event address: " & INTEGER'image(to_integer(unsigned(o_out_aer_event(13 DOWNTO 8))));
        END IF;
    END PROCESS;

END;