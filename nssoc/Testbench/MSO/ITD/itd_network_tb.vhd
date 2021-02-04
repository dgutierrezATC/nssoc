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
-- Created    : 2018-11-13
-- Last update: 2021-01-23
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
ENTITY itd_network_tb IS

END itd_network_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF itd_network_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT itd_network IS
        GENERIC (
            NUM_NEURONS             : INTEGER := 32;
            MAX_DETECTION_TIME      : INTEGER := 700;
            DETECTION_OVERLAP       : INTEGER := 1;
            CLOCK_FREQ              : INTEGER := 50000000
        );
        PORT (
            i_clock                 : IN  STD_LOGIC;
            i_nreset                : IN  STD_LOGIC;
            i_left_ch_spike         : IN  STD_LOGIC;
            i_right_ch_spike        : IN  STD_LOGIC;
            o_sound_source_position : OUT STD_LOGIC_VECTOR((NUM_NEURONS - 1) DOWNTO 0)
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

    -- Component constants
    CONSTANT c_NUM_NEURONS        : INTEGER := 16;
    CONSTANT c_MAX_DETECTION_TIME : INTEGER := 700;
    CONSTANT c_DETECTION_OVERLAP  : INTEGER := 1;
    CONSTANT c_CLOCK_FREQ         : INTEGER := 50000000;

    -- Component input ports
    SIGNAL i_clock          : STD_LOGIC := '0';
    SIGNAL i_nreset         : STD_LOGIC := '0';
    SIGNAL i_left_ch_spike  : STD_LOGIC := '0';
    SIGNAL i_right_ch_spike : STD_LOGIC := '0';

    -- Component output ports
    SIGNAL o_sound_source_position : STD_LOGIC_VECTOR((c_NUM_NEURONS - 1) DOWNTO 0);

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Clock
    CONSTANT c_i_clock_period : TIME := 20 ns;

    -- Saving results in a file
    CONSTANT c_absolute_path      : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Testbench/MSO/ITD/Results/Files/"; -- Absolute path to the testbench files
    SIGNAL tb_end_of_simulation   : STD_LOGIC := '0'; -- Flag to indicate the end of the simulation
    SIGNAL tb_start_of_simulation : STD_LOGIC := '0'; -- Flag to indicate the begining of the simulation
        
    FILE f_input_spikes     : TEXT OPEN write_mode IS c_absolute_path & "itd_network_tb_input_spikes.txt";  -- Input spikes filename
    FILE f_output_spikes    : TEXT OPEN write_mode IS c_absolute_path & "itd_network_tb_output_spikes.txt"; -- Output spikes filename

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

    -- purpose: Generate a stereo burst of events (one clock cycle spike)
    PROCEDURE pr_event_burst_generator (
        CONSTANT c_clock_period         : IN  TIME;       -- Clock period of the simulation
        CONSTANT c_num_events_burst     : IN  INTEGER;
        CONSTANT c_time_between_events  : IN  INTEGER;
        CONSTANT c_time_difference      : IN  INTEGER;
        CONSTANT c_generation_order     : IN  INTEGER;    -- 0 means first left; 1 means first right
        SIGNAL r_generated_spike_left   : OUT STD_LOGIC;  -- Output generated event
        SIGNAL r_generated_spike_right  : OUT STD_LOGIC   -- Output generated event
    ) IS        
        BEGIN  -- procedure pr_event_generator
            -- Generate a burst of 10 positive spikes with 10 microseconds of ISI
            FOR v_index IN 0 TO c_num_events_burst LOOP
                if c_generation_order = 0 then
                    pr_event_generator(c_clock_period, r_generated_spike_left);
                else
                    pr_event_generator(c_clock_period, r_generated_spike_right);
                end if;
                
                -- Wait for the time difference
                WAIT FOR c_clock_period * c_time_difference;

                if c_generation_order = 0 then
                    pr_event_generator(c_clock_period, r_generated_spike_right);
                else
                    pr_event_generator(c_clock_period, r_generated_spike_left);
                end if;

                WAIT FOR c_clock_period * c_time_between_events;  -- 500 clock cycles * 20 ns per clock cycle = 10 us
            END LOOP;
    END PROCEDURE pr_event_burst_generator;

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Instantiate the Unit Under Test (UUT)
    ---------------------------------------------------------------------------
    uut : itd_network
        GENERIC MAP (
            NUM_NEURONS             => c_NUM_NEURONS,
            MAX_DETECTION_TIME      => c_MAX_DETECTION_TIME,
            DETECTION_OVERLAP       => c_DETECTION_OVERLAP,
            CLOCK_FREQ              => c_CLOCK_FREQ
        )
        PORT MAP (
            i_clock                 => i_clock,
            i_nreset                => i_nreset,
            i_left_ch_spike         => i_left_ch_spike,
            i_right_ch_spike        => i_right_ch_spike,
            o_sound_source_position => o_sound_source_position
        );

    ---------------------------------------------------------------------------
    -- Clocks generation
    ---------------------------------------------------------------------------
    i_clock <= NOT i_clock AFTER c_i_clock_period/2;

    -----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    -- purpose: Set the signals to generate the stimuli
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
        i_nreset <= '0';
        -- Hold it for 1 us
        WAIT FOR 1 us;

        -- Clear reset
        i_nreset <= '1';

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
        VARIABLE v_delta_t : INTEGER := 0; -- In clock cycles
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
        -- First case: the time difference start at 710 microseconds (first left, then right)
        -- and goes down until 0 microseconds
        --

        -- Set the delta_t value to 700 us (in number of clock cycles)
        v_delta_t := 35000;

        -- Set the loop
        WHILE (v_delta_t >= 0) LOOP
            pr_event_burst_generator(c_i_clock_period, 5, 50000, v_delta_t, 0, i_left_ch_spike, i_right_ch_spike);
            v_delta_t := v_delta_t - 250;
        END LOOP;

        --
        -- Second case: fire left and right spike within time-interval (time difference of a few nanoseconds)
        -- 

        -- Set the delta_t value to 700 us (in number of clock cycles)
        v_delta_t := 0;

        -- Set the loop
            WHILE (v_delta_t <= 35000) LOOP
            pr_event_burst_generator(c_i_clock_period, 5, 50000, v_delta_t, 1, i_left_ch_spike, i_right_ch_spike);
            v_delta_t := v_delta_t + 250;
        END LOOP;

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

    -- purpose: Saving out the input spikes
    -- type   : sequential
    -- inputs : i_clock, i_nreset, i_left_ch_spike, i_right_ch_spike
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
            if i_left_ch_spike = '1' or i_right_ch_spike = '1' then
                sim_time_len_v := time'image(now)'length;
                sim_time_str_v := (others => ' ');
                sim_time_str_v(1 to sim_time_len_v) := time'image(now);

                if i_left_ch_spike = '1' then
                    v_event_address := 0;
                elsif i_right_ch_spike = '1' then
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
    -- inputs : i_clock, i_nreset, o_sound_source_position
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
            for v_index IN 0 TO (c_NUM_NEURONS-1) LOOP
                if o_sound_source_position(v_index) = '1' then
                    sim_time_len_v := time'image(now)'length;
                    sim_time_str_v := (others => ' ');
                    sim_time_str_v(1 to sim_time_len_v) := time'image(now);
                    events_counter := events_counter + 1;
                    
                    report "Output event timestamp.......:'" & sim_time_str_v & "'";
                    report "Output event counter: " & integer'image(events_counter);

                    write(v_OLINE, v_index);
                    write(v_OLINE, ';', right, 1);
                    write(v_OLINE, sim_time_str_v, right, 1);
                    writeline(f_output_spikes, v_OLINE);
                end if;
            end loop;
        end if;
    end process p_saving_output_spikes;

END Behavioral;