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
-- Title      : Testbench for antero ventricular coclear nucleus
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : AVCN_tb.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2018-12-12
-- Last update: 2021-01-13
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY AVCN_tb IS

END AVCN_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF AVCN_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT AVCN IS
        GENERIC (
            NUM_FREQ_CH : INTEGER := 64
        );
        PORT (
            i_clock                 : IN  std_logic;
            i_nreset                : IN  std_logic;
            i_auditory_nerve_spikes : IN  std_logic_vector(((NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            o_phase_locked_spikes   : OUT std_logic_vector((NUM_FREQ_CH - 1) DOWNTO 0)
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------
    -- Component generics
    CONSTANT c_NUM_FREQ_CH  : INTEGER := 64;

    -- Component input ports
    SIGNAL i_clock                 : std_logic := '0';
    SIGNAL i_nreset                : std_logic := '0';
    SIGNAL i_auditory_nerve_spikes : std_logic_vector(((c_NUM_FREQ_CH * 2) - 1) DOWNTO 0) := (OTHERS => '0');
    
    -- Component output ports
    SIGNAL o_phase_locked_spikes   : std_logic_vector((c_NUM_FREQ_CH - 1) DOWNTO 0);

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------
    -- Clock
    CONSTANT c_clock_period     : TIME := 20 ns;

    -- Saving results in a file
    CONSTANT c_absolute_path    : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Testbench/AVCN/Results/Files/"; -- Absolute path to the testbench files
    SIGNAL tb_end_of_simulation : STD_LOGIC := '0'; -- Flag to indicate the end of the simulation
        
    --FILE f_input_pos_spikes     : TEXT OPEN write_mode IS c_absolute_path & "avcn_input_pos_spikes.txt";  -- Input facilitatory spikes filename
    --FILE f_input_neg_spikes     : TEXT OPEN write_mode IS c_absolute_path & "avcn_input_neg_spikes.txt";  -- Input facilitatory spikes filename
    --FILE f_output_spikes        : TEXT OPEN write_mode IS c_absolute_path & "avcn_output_spikes.txt";     -- Input facilitatory spikes filename

    ---------------------------------------------------------------------------
    -- Procedures
    ---------------------------------------------------------------------------
    -- purpose: Generate a single event (one clock cycle spike)
    PROCEDURE pr_event_generator (
        SIGNAL r_generated_spike : out std_logic  -- Output generated event
    ) IS        
        BEGIN  -- procedure pr_event_generator
            r_generated_spike <= '1';
            WAIT FOR c_clock_period;
            r_generated_spike <= '0';
            WAIT FOR c_clock_period;
    END PROCEDURE pr_event_generator;

    -- purpose: Generate a burst of events (one clock cycle spike)
    PROCEDURE pr_event_burst_generator (
        CONSTANT c_num_events_burst     : in integer;
        CONSTANT c_time_between_events  : in integer;
        CONSTANT c_num_bursts           : in integer;
        SIGNAL r_generated_pos_spike    : out std_logic;  -- Output generated event
        SIGNAL r_generated_neg_spike    : out std_logic  -- Output generated event
    ) IS        
        BEGIN  -- procedure pr_event_generator
            FOR v_num_iter IN 0 TO c_num_bursts LOOP
                -- Generate a burst of 10 positive spikes with 10 microseconds of ISI
                FOR v_index IN 0 TO c_num_events_burst LOOP
                    pr_event_generator(r_generated_pos_spike);
                    WAIT FOR c_clock_period * c_time_between_events;  -- 500 clock cycles * 20 ns per clock cycle = 10 us
                END LOOP;
                -- Generate a burst of 10 positive spikes with 10 microseconds of ISI
                FOR v_index IN 0 TO c_num_events_burst LOOP
                    pr_event_generator(r_generated_neg_spike);
                    WAIT FOR c_clock_period * c_time_between_events;  -- 500 clock cycles * 20 ns per clock cycle = 10 us
                END LOOP;
            END LOOP;
    END PROCEDURE pr_event_burst_generator;

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Instantiate the Unit Under Test (UUT)
    ---------------------------------------------------------------------------
    uut : AVCN
        GENERIC MAP (
            NUM_FREQ_CH => c_NUM_FREQ_CH
        )
        PORT MAP (
            i_clock                 => i_clock,
            i_nreset                => i_nreset,
            i_auditory_nerve_spikes => i_auditory_nerve_spikes,
            o_phase_locked_spikes   => o_phase_locked_spikes
        );

    ---------------------------------------------------------------------------
    -- Clocks generation
    ---------------------------------------------------------------------------
    i_clock <= NOT i_clock AFTER c_clock_period / 2;

    ---------------------------------------------------------------------------
    -- Processes
    ---------------------------------------------------------------------------

    -- purpose: Global reset
    -- type   : combinational
    -- inputs : 
    -- outputs: 
    p_initial_reset : PROCESS
    BEGIN
        i_nreset <= '0';
        WAIT FOR c_clock_period * 10;
        i_nreset <= '1';
        WAIT;
    END PROCESS p_initial_reset;

    -- purpose: Set the signals to generate the stimuli
    -- type   : combinational
    -- inputs : 
    -- outputs: 
    GEN_SPIKE_BURST_GENERATOR : FOR I IN 0 TO (c_NUM_FREQ_CH - 1) GENERATE
    BEGIN
        p_stimuli : PROCESS
        BEGIN
            --
            -- Wait until the reset is set to 1 (high active)
            --
            WAIT UNTIL i_nreset = '1';

            --
            -- Clock sync
            --
            -- First, synchronize with the clock signal
            WAIT UNTIL i_clock'EVENT AND i_clock = '1';
            WAIT FOR c_clock_period * 2;

            --
            -- Stimuli generation
            --
            pr_event_burst_generator(5, I*2 + 2, 5, i_auditory_nerve_spikes(I*2), i_auditory_nerve_spikes((I*2) + 1));

            -- Wait forever...
            WAIT;
        END PROCESS p_stimuli;
    END GENERATE GEN_SPIKE_BURST_GENERATOR;

END Behavioral;