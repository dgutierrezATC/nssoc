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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY coincidence_detector_neuron_array_tb IS

END coincidence_detector_neuron_array_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF coincidence_detector_neuron_array_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT coincidence_detector_neuron_array IS
        GENERIC (
            COINCIDENCE_DETECTOR_NUM       : INTEGER := 32;
            MAX_TIME_DIFF_DETECTION_WINDOW : INTEGER := 700;
            TIME_DETECTION_OVERLAP         : INTEGER := 1;
            CLOCK_FREQ                     : INTEGER := 50000000
        );
        PORT (
            i_clock               : IN  STD_LOGIC;
            i_nreset              : IN  STD_LOGIC;
            i_left_spike_stream   : IN  STD_LOGIC_VECTOR((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
            i_right_spike_stream  : IN  STD_LOGIC_VECTOR((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
            o_neurons_coincidence : OUT STD_LOGIC_VECTOR((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0)
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

    -- Component constants
    CONSTANT c_COINCIDENCE_DETECTOR_NUM       : INTEGER := 16;        -- Natural integer
    CONSTANT c_MAX_TIME_DIFF_DETECTION_WINDOW : INTEGER := 700;      -- In microseconds
    CONSTANT c_TIME_DETECTION_OVERLAP         : INTEGER := 1;        -- In microseconds
    CONSTANT c_CLOCK_FREQ                     : INTEGER := 50000000; -- In Hz

    -- Component input ports
    SIGNAL i_clock              : STD_LOGIC := '0';
    SIGNAL i_nreset             : STD_LOGIC := '0';
    SIGNAL i_left_spike_stream  : STD_LOGIC_VECTOR((c_COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0) := (OTHERS => '0');
    SIGNAL i_right_spike_stream : STD_LOGIC_VECTOR((c_COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0) := (OTHERS => '0');

    -- Component output ports
    SIGNAL o_neurons_coincidence : STD_LOGIC_VECTOR((c_COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Clock
    CONSTANT c_i_clock_period : TIME := 20 ns;

    -- Saving results in a file
    CONSTANT c_absolute_path    : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Testbench/MSO/ITD/Results/Files/"; -- Absolute path to the testbench files
    SIGNAL tb_end_of_simulation : STD_LOGIC := '0'; -- Flag to indicate the end of the simulation
        
    FILE f_input_spikes     : TEXT OPEN write_mode IS c_absolute_path & "coincidence_detector_neuron_array_tb_input_spikes.txt";  -- Input spikes filename
    FILE f_output_spikes    : TEXT OPEN write_mode IS c_absolute_path & "coincidence_detector_neuron_array_tb_output_spikes.txt"; -- Output spikes filename

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
    uut : coincidence_detector_neuron_array
        GENERIC MAP (
            COINCIDENCE_DETECTOR_NUM       => c_COINCIDENCE_DETECTOR_NUM,
            MAX_TIME_DIFF_DETECTION_WINDOW => c_MAX_TIME_DIFF_DETECTION_WINDOW,
            TIME_DETECTION_OVERLAP         => c_TIME_DETECTION_OVERLAP,
            CLOCK_FREQ                     => c_CLOCK_FREQ
        )
        PORT MAP (
            i_clock               => i_clock,
            i_nreset              => i_nreset,
            i_left_spike_stream   => i_left_spike_stream,
            i_right_spike_stream  => i_right_spike_stream,
            o_neurons_coincidence => o_neurons_coincidence
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
        i_nreset <= '0';
        -- Hold it for 1 us
        WAIT FOR 1 us;

        -- Clear reset
        i_nreset <= '1';

        -- Report the reset has been clear
        REPORT "Reset cleared!" SEVERITY NOTE;

        --
        -- Idle
        --
        WAIT FOR 2 us;

        --
        -- Sync
        --

        -- Report the testbench is being sync with the clock
        REPORT "Sync..." SEVERITY NOTE;

        WAIT UNTIL i_clock'EVENT AND i_clock = '1';
        WAIT FOR c_i_clock_period*10;


        --
        -- First case: only fire left spike
        --

        -- Fire left spike
        pr_event_generator(c_i_clock_period, i_left_spike_stream(2));

        -- Wait at least TEMPORAL_COINCIDENCE_WINDOW: c_TEMPORAL_COINCIDENCE_WINDOW / c_i_clock_period 
        WAIT FOR c_i_clock_period * 500;

        --
        -- Idle
        --
        wait for c_i_clock_period * 1000;

        --
        -- Second case: fire left and right spike within time-interval (time difference of a few nanoseconds)
        -- 

        -- Set the delta_t value
        v_delta_t := 5;

        -- Fire left spike
        pr_event_generator(c_i_clock_period, i_left_spike_stream(0));

        -- Wait
        WAIT FOR c_i_clock_period * v_delta_t;

        -- Fire right spike
        pr_event_generator(c_i_clock_period, i_right_spike_stream(c_COINCIDENCE_DETECTOR_NUM-1));

        -- Wait at least TEMPORAL_COINCIDENCE_WINDOW
        WAIT FOR c_i_clock_period * 500;

        --
        -- Idle
        --
        wait for c_i_clock_period * 1000;

        --
        -- Third case: only fire right spike
        --

        -- Fire right spike
        pr_event_generator(c_i_clock_period, i_right_spike_stream(c_COINCIDENCE_DETECTOR_NUM-1));

        -- Wait at least TEMPORAL_COINCIDENCE_WINDOW
        WAIT FOR c_i_clock_period * 500;

        --
        -- Idle
        --
        wait for c_i_clock_period * 1000;

        --
        -- Fourth case: fire left and right spike at the same moment
        --

        -- Fire left spike
        i_left_spike_stream(0)  <= '1';
        i_right_spike_stream(c_COINCIDENCE_DETECTOR_NUM-1) <= '1';

        WAIT FOR c_i_clock_period;

        i_left_spike_stream(0)  <= '0';
        i_right_spike_stream(c_COINCIDENCE_DETECTOR_NUM-1) <= '0';

        WAIT FOR c_i_clock_period;

        -- Wait at least TEMPORAL_COINCIDENCE_WINDOW
        WAIT FOR c_i_clock_period * 500;

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

END Behavioral;