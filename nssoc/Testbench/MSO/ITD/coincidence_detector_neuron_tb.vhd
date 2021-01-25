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
-- File       : coincidence_detector_neuron_tb.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2018-09-10
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
ENTITY coincidence_detector_neuron_tb IS

END coincidence_detector_neuron_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF coincidence_detector_neuron_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT coincidence_detector_neuron IS
        GENERIC (
            TEMPORAL_COINCIDENCE_WINDOW : INTEGER := 10;      -- In microseconds
            CLOCK_FREQ                  : INTEGER := 50000000 -- In Hz
        );
        PORT (
            i_clock             : IN  STD_LOGIC;
            i_nreset            : IN  STD_LOGIC;
            i_left_spike        : IN  STD_LOGIC;
            i_right_spike       : IN  STD_LOGIC;
            o_coincidence_spike : OUT STD_LOGIC
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

    -- Component constants
    CONSTANT c_TEMPORAL_COINCIDENCE_WINDOW : INTEGER := 10;
    CONSTANT c_CLOCK_FREQ                  : INTEGER := 50000000;

    -- Component input ports
    SIGNAL i_clock                         : STD_LOGIC := '0';
    SIGNAL i_nreset                        : STD_LOGIC := '0';
    SIGNAL i_left_spike                    : STD_LOGIC := '0';
    SIGNAL i_right_spike                   : STD_LOGIC := '0';

    -- Component output ports
    SIGNAL o_coincidence_spike             : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Clock
    CONSTANT c_i_clock_period : TIME := 20 ns;

    -- Saving results in a file
    CONSTANT c_absolute_path    : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Testbench/MSO/ITD/Results/Files/"; -- Absolute path to the testbench files
    SIGNAL tb_end_of_simulation : STD_LOGIC := '0'; -- Flag to indicate the end of the simulation
        
    FILE f_input_spikes     : TEXT OPEN write_mode IS c_absolute_path & "coincidence_detector_neuron_tb_input_spikes.txt";  -- Input spikes filename
    FILE f_output_spikes    : TEXT OPEN write_mode IS c_absolute_path & "coincidence_detector_neuron_tb_output_spikes.txt"; -- Output spikes filename

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

    -- purpose: Generate a burst of events (one clock cycle spike)
    PROCEDURE pr_event_burst_generator (
        CONSTANT c_clock_period         : IN  TIME;      -- Clock period of the simulation
        CONSTANT c_num_events_burst     : IN  INTEGER;   -- Number of events to be generated within the burst
        CONSTANT c_time_between_events  : IN  INTEGER;   -- Inter-Spike Interval (ISI) in number of clock cycles
        SIGNAL   r_generated_spike      : OUT STD_LOGIC  -- Output generated event
    ) IS        
        BEGIN  -- procedure pr_event_generator
            -- Use a for loop for generating the burst
            FOR v_index IN 0 TO c_num_events_burst LOOP
                pr_event_generator(c_clock_period, r_generated_spike);
                WAIT FOR c_clock_period * c_time_between_events;  -- Eg.: 500 clock cycles * 20 ns per clock cycle = 10 us
            END LOOP;
    END PROCEDURE pr_event_burst_generator;

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Instantiate the Unit Under Test (UUT)
    ---------------------------------------------------------------------------
    uut : coincidence_detector_neuron
        GENERIC MAP (
            TEMPORAL_COINCIDENCE_WINDOW => c_TEMPORAL_COINCIDENCE_WINDOW,
            CLOCK_FREQ                  => c_CLOCK_FREQ
        )
        PORT MAP (
            i_clock                     => i_clock,
            i_nreset                    => i_nreset,
            i_left_spike                => i_left_spike,
            i_right_spike               => i_right_spike,
            o_coincidence_spike         => o_coincidence_spike
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

        wait until i_clock'event and i_clock = '1';
        wait for c_i_clock_period*10;


        --
        -- First case: only fire left spike
        --

        -- Fire left spike
        pr_event_generator(c_i_clock_period, i_left_spike);

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
        pr_event_generator(c_i_clock_period, i_left_spike);

        -- Wait
        WAIT FOR c_i_clock_period * v_delta_t;

        -- Fire right spike
        pr_event_generator(c_i_clock_period, i_right_spike);

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
        pr_event_generator(c_i_clock_period, i_right_spike);

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
        i_left_spike  <= '1';
        i_right_spike <= '1';

        WAIT FOR c_i_clock_period;

        i_left_spike  <= '0';
        i_right_spike <= '0';

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

    END PROCESS;

    -- purpose: Saving out the input spikes
    -- type   : sequential
    -- inputs : i_clock, i_nreset, i_left_spike, i_right_spike
    -- outputs: 
    p_saving_input_spikes: process (i_clock, i_nreset) is
        variable v_OLINE        : line;
        variable sim_time_str_v : string(1 to 30);  -- 30 chars should be enough
        variable sim_time_len_v : natural;
        variable events_counter : integer := 0;
        variable v_event_address: integer := 0;
    begin  -- process p_saving_input_spikes
        if i_nreset = '0' then          -- asynchronous reset (active low)
            
        elsif tb_end_of_simulation = '1' then
            file_close(f_input_spikes);
        elsif i_clock'event and i_clock = '1' then  -- rising clock edge
            if i_left_spike = '1' or i_right_spike = '1' then
                sim_time_len_v := time'image(now)'length;
                sim_time_str_v := (others => ' ');
                sim_time_str_v(1 to sim_time_len_v) := time'image(now);

                if i_left_spike = '1' then
                    v_event_address := 0;
                elsif i_right_spike = '1' then
                    v_event_address := 1;
                else
                    v_event_address := -1;
                end if;

                events_counter := events_counter + 1;
                
                report "Input event timestamp.......:'" & sim_time_str_v & "'";
                report "Input event counter: " & integer'image(events_counter);

                write(v_OLINE, v_event_address);
                write(v_OLINE, ';', right, 1);
                write(v_OLINE, sim_time_str_v, right, 1);
                writeline(f_input_spikes, v_OLINE);
            end if;
        end if;
    end process p_saving_input_spikes;

    -- purpose: Saving out the output spikes
    -- type   : sequential
    -- inputs : i_clock, i_nreset, o_coincidence_spike
    -- outputs: 
    p_saving_output_spikes: process (i_clock, i_nreset) is
        variable v_OLINE        : line;
        variable sim_time_str_v : string(1 to 30);  -- 30 chars should be enough
        variable sim_time_len_v : natural;
        variable events_counter : integer := 0;
    begin  -- process p_saving_output_spikes
        if i_nreset = '0' then          -- asynchronous reset (active low)
            
        elsif tb_end_of_simulation = '1' then
            file_close(f_output_spikes);
        elsif i_clock'event and i_clock = '1' then  -- rising clock edge
            if o_coincidence_spike = '1' then
                sim_time_len_v := time'image(now)'length;
                sim_time_str_v := (others => ' ');
                sim_time_str_v(1 to sim_time_len_v) := time'image(now);
                events_counter := events_counter + 1;
                
                report "Output event timestamp.......:'" & sim_time_str_v & "'";
                report "Output event counter: " & integer'image(events_counter);

                write(v_OLINE, events_counter);
                write(v_OLINE, ';', right, 1);
                write(v_OLINE, sim_time_str_v, right, 1);
                writeline(f_output_spikes, v_OLINE);
            end if;
        end if;
    end process p_saving_output_spikes;

END Behavioral;