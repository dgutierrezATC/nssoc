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
-- Title      : Testbench for spherical bushy cell of the AVCN model
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : spherical_bushy_cell_tb.vhd
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
ENTITY spherical_bushy_cell_tb IS

END spherical_bushy_cell_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF spherical_bushy_cell_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT spherical_bushy_cell IS
        PORT (
            i_clock              : IN  STD_LOGIC;
            i_nreset             : IN  STD_LOGIC;
            i_pos_spike          : IN  STD_LOGIC;
            i_neg_spike          : IN  STD_LOGIC;
            o_phase_locked_spike : OUT STD_LOGIC
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

    -- Component generics

    -- Component input ports
    SIGNAL i_clock     : STD_LOGIC := '0';
    SIGNAL i_nreset    : STD_LOGIC := '0';
    SIGNAL i_pos_spike : STD_LOGIC := '0';
    SIGNAL i_neg_spike : STD_LOGIC := '0';

    -- Component output ports
    SIGNAL o_phase_locked_spike : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Clock
    CONSTANT c_clock_period     : TIME := 20 ns;

    -- Saving results in a file
    CONSTANT c_absolute_path    : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Testbench/AVCN/Results/Files/"; -- Absolute path to the testbench files
    SIGNAL tb_end_of_simulation : STD_LOGIC := '0'; -- Flag to indicate the end of the simulation
    
    FILE f_input_pos_spikes     : TEXT OPEN write_mode IS c_absolute_path & "sbc_input_pos_spikes.txt";  -- Input facilitatory spikes filename
    FILE f_input_neg_spikes     : TEXT OPEN write_mode IS c_absolute_path & "sbc_input_neg_spikes.txt";  -- Input facilitatory spikes filename
    FILE f_output_spikes        : TEXT OPEN write_mode IS c_absolute_path & "sbc_output_spikes.txt";     -- Input facilitatory spikes filename

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Instantiate the Unit Under Test (UUT)
    ---------------------------------------------------------------------------
    uut : spherical_bushy_cell
        PORT MAP (
            i_clock              => i_clock,
            i_nreset             => i_nreset,
            i_pos_spike          => i_pos_spike,
            i_neg_spike          => i_neg_spike,
            o_phase_locked_spike => o_phase_locked_spike
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
    p_stimuli : PROCESS
        VARIABLE v_num_iter : INTEGER := 0;
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

        -- Then, generate a burst of both positive and negative spikes
        WHILE(v_num_iter < 10) LOOP
            -- Generate a burst of 10 positive spikes with 10 microseconds of ISI
            FOR v_index IN 0 TO 10 LOOP
                i_pos_spike <= '1';
                WAIT FOR c_clock_period;
                i_pos_spike <= '0';
                WAIT FOR c_clock_period * 2;  -- 500 clock cycles * 20 ns per clock cycle = 10 us
            END LOOP;
            -- Generate a burst of 10 positive spikes with 10 microseconds of ISI
            FOR v_index IN 0 TO 10 LOOP
                i_neg_spike <= '1';
                WAIT FOR c_clock_period;
                i_neg_spike <= '0';
                WAIT FOR c_clock_period * 2;  -- 500 clock cycles * 20 ns per clock cycle = 10 us
            END LOOP;

            v_num_iter := v_num_iter + 1;

        END LOOP;

        -- Indicate the end of the simulation
        tb_end_of_simulation <= '1';
        REPORT "End of the delta_t simulation" SEVERITY NOTE;

        -- Wait forever...
        WAIT;

    END PROCESS p_stimuli;

    -- purpose: Saving out the input positive spikes
    -- type   : sequential
    -- inputs : i_clock, i_nreset, i_pos_spike
    -- outputs: 
    p_saving_input_positive_spikes: process (i_clock, i_nreset) is
        variable v_OLINE        : line;
        variable sim_time_str_v : string(1 to 30);  -- 30 chars should be enough
        variable sim_time_len_v : natural;
        variable events_counter : integer := 0;
    begin  -- process p_saving_input_positive_spikes
        if i_nreset = '0' then          -- asynchronous reset (active low)
            
        elsif tb_end_of_simulation = '1' then
            file_close(f_input_pos_spikes);
        elsif i_clock'event and i_clock = '1' then  -- rising clock edge
            if i_pos_spike = '1' then
                sim_time_len_v := time'image(now)'length;
                sim_time_str_v := (others => ' ');
                sim_time_str_v(1 to sim_time_len_v) := time'image(now);
                events_counter := events_counter + 1;
                
                report "Input positive event timestamp.......:'" & sim_time_str_v & "'";
                report "Input positive event counter: " & integer'image(events_counter);

                write(v_OLINE, events_counter);
                write(v_OLINE, ';', right, 1);
                write(v_OLINE, sim_time_str_v, right, 1);
                writeline(f_input_pos_spikes, v_OLINE);
            end if;
        end if;
    end process p_saving_input_positive_spikes;

    -- purpose: Saving out the input negative spikes
    -- type   : sequential
    -- inputs : i_clock, i_nreset, i_neg_spike
    -- outputs: 
    p_saving_input_negative_spikes: process (i_clock, i_nreset) is
        variable v_OLINE        : line;
        variable sim_time_str_v : string(1 to 30);  -- 30 chars should be enough
        variable sim_time_len_v : natural;
        variable events_counter : integer := 0;
    begin  -- process p_saving_input_negative_spikes
        if i_nreset = '0' then          -- asynchronous reset (active low)
            
        elsif tb_end_of_simulation = '1' then
            file_close(f_input_neg_spikes);
        elsif i_clock'event and i_clock = '1' then  -- rising clock edge
            if i_neg_spike = '1' then
                sim_time_len_v := time'image(now)'length;
                sim_time_str_v := (others => ' ');
                sim_time_str_v(1 to sim_time_len_v) := time'image(now);
                events_counter := events_counter + 1;
                
                report "Input negative event timestamp.......:'" & sim_time_str_v & "'";
                report "Input negative event counter: " & integer'image(events_counter);

                write(v_OLINE, events_counter);
                write(v_OLINE, ';', right, 1);
                write(v_OLINE, sim_time_str_v, right, 1);
                writeline(f_input_neg_spikes, v_OLINE);
            end if;
        end if;
    end process p_saving_input_negative_spikes;

    -- purpose: Saving out the output spikes
    -- type   : sequential
    -- inputs : i_clock, i_nreset, o_phase_locked_spike
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
            if o_phase_locked_spike = '1' then
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