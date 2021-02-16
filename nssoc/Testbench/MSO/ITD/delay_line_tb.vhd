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
-- Title      : Testbench for the delay line of the Jeffress model
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : delay_line_tb.vhd
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
ENTITY delay_line_tb IS

END delay_line_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF delay_line_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT delay_line IS
        GENERIC (
            TRANSMISSION_TIME : INTEGER := 1;       -- In microseconds
            CLOCK_FREQ        : INTEGER := 50000000 -- In Hz
        );
        PORT (
            i_clock           : IN  STD_LOGIC;
            i_nreset          : IN  STD_LOGIC;
            i_spike_in        : IN  STD_LOGIC;
            o_spike_delayed   : OUT STD_LOGIC
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

    -- Component constants
    CONSTANT g_TRANSMISSION_TIME : INTEGER := 1000;
    CONSTANT g_CLOCK_FREQ        : INTEGER := 50000000;

    -- Comopnent input ports
    SIGNAL i_clock    : STD_LOGIC := '0';
    SIGNAL i_nreset   : STD_LOGIC := '0';
    SIGNAL i_spike_in : STD_LOGIC := '0';

    -- Component output ports
    SIGNAL o_spike_delayed : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Clock
    CONSTANT c_i_clock_period : TIME := 20 ns;

    -- Saving results in a file
    CONSTANT c_absolute_path    : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Testbench/MSO/ITD/Results/Files/"; -- Absolute path to the testbench files
    SIGNAL tb_end_of_simulation : STD_LOGIC := '0'; -- Flag to indicate the end of the simulation
        
    FILE f_input_spikes     : TEXT OPEN write_mode IS c_absolute_path & "delay_line_tb_input_spikes.txt";  -- Input spikes filename
    FILE f_output_spikes    : TEXT OPEN write_mode IS c_absolute_path & "delay_line_tb_output_spikes.txt"; -- Output spikes filename

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
    uut : delay_line
        GENERIC MAP (
            TRANSMISSION_TIME => g_TRANSMISSION_TIME,
            CLOCK_FREQ        => g_CLOCK_FREQ
        )
        PORT MAP (
            i_clock           => i_clock,
            i_nreset          => i_nreset,
            i_spike_in        => i_spike_in,
            o_spike_delayed   => o_spike_delayed
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
        -- Single input spike
        --

        -- Report the begining of this experiment
        REPORT "Single input spike test started." SEVERITY NOTE;

        -- Fire the spike
        i_spike_in <= '1';
        WAIT FOR c_i_clock_period;
        i_spike_in <= '0';

        -- Wait until the spike is released
        wait for g_TRANSMISSION_TIME * 1 us;

        -- Report the end of this experiment
        REPORT "Single input spike test finished." SEVERITY NOTE;

        --
        -- Sync again
        --
        wait until i_clock'event and i_clock = '1';
        wait for c_i_clock_period*10;

        --
        -- Idle
        --
        wait for c_i_clock_period * 1000;

        --
        -- Spike burst with fixed firing rate
        --

        -- Report the begining of this experiment
        REPORT "Spike burst test started." SEVERITY NOTE;

        -- ISI value in terms of clock cycles:
        --     - If a 700 Hz signal is desired, the period of that signal
        --       is calculated as T = 1 / 700 Hz = 0.00142857142
        --     - Therefore, if the clock period is 20 ns, then the number
        --       of clock cycles is T / clock_period = 0.00142857142 / 20e-9
        --       = 71428.571 ~= 71429 clock cycles
        pr_event_burst_generator(c_i_clock_period, 10, 71429, i_spike_in);

        -- Report the end of this experiment
        REPORT "Spike burst test finished." SEVERITY NOTE;

        --
        -- End of the simulation
        --

        -- Notify the end of the simulation
        tb_end_of_simulation <= '1';
        REPORT "End of the simulation." SEVERITY NOTE;

        -- Wait forever
        WAIT;

    END PROCESS p_stimuli;

    -- purpose: Saving out the input spikes
    -- type   : sequential
    -- inputs : i_clock, i_nreset, i_spike_in
    -- outputs: 
    p_saving_input_spikes: process (i_clock, i_nreset) is
        variable v_OLINE        : line;
        variable sim_time_str_v : string(1 to 30);  -- 30 chars should be enough
        variable sim_time_len_v : natural;
        variable events_counter : integer := 0;
    begin  -- process p_saving_input_spikes
        if i_nreset = '0' then          -- asynchronous reset (active low)
            
        elsif tb_end_of_simulation = '1' then
            file_close(f_input_spikes);
        elsif i_clock'event and i_clock = '1' then  -- rising clock edge
            if i_spike_in = '1' then
                sim_time_len_v := time'image(now)'length;
                sim_time_str_v := (others => ' ');
                sim_time_str_v(1 to sim_time_len_v) := time'image(now);
                events_counter := events_counter + 1;
                
                report "Input event timestamp.......:'" & sim_time_str_v & "'";
                report "Input event counter: " & integer'image(events_counter);

                write(v_OLINE, events_counter);
                write(v_OLINE, ';', right, 1);
                write(v_OLINE, sim_time_str_v, right, 1);
                writeline(f_input_spikes, v_OLINE);
            end if;
        end if;
    end process p_saving_input_spikes;

    -- purpose: Saving out the output spikes
    -- type   : sequential
    -- inputs : i_clock, i_nreset, o_spike_delayed
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
            if o_spike_delayed = '1' then
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