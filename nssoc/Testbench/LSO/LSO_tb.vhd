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
-- Title      : Testbench for the Lateral Superior Olivar (LSO) model
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : LSO_tb.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2019-04-30
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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY LSO_tb IS

END LSO_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF LSO_tb IS

	-------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT LSO IS
        GENERIC (
            NUM_FREQ_CH     : INTEGER := 5;
            NUM_NET_NEURONS : INTEGER := 1
        );
        PORT (
            i_clock             : IN  STD_LOGIC;
            i_nreset            : IN  STD_LOGIC;
            i_left_avcn_spikes  : IN  STD_LOGIC_VECTOR(((NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            i_right_avcn_spikes : IN  STD_LOGIC_VECTOR(((NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            o_ild_out_spikes    : OUT STD_LOGIC_VECTOR(((NUM_FREQ_CH * NUM_NET_NEURONS * 2) - 1) DOWNTO 0)
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
	---------------------------------------------------------------------------

    -- Component constants
    CONSTANT c_NUM_FREQ_CH     : INTEGER := 2;
    CONSTANT c_NUM_NET_NEURONS : INTEGER := 1;

    -- Component input ports
    SIGNAL i_clock             : STD_LOGIC := '0';
    SIGNAL i_nreset            : STD_LOGIC := '0';
    SIGNAL i_left_avcn_spikes  : STD_LOGIC_VECTOR(((c_NUM_FREQ_CH * 2) - 1) DOWNTO 0) := (OTHERS => '0');
    SIGNAL i_right_avcn_spikes : STD_LOGIC_VECTOR(((c_NUM_FREQ_CH * 2) - 1) DOWNTO 0) := (OTHERS => '0');

    -- Component output ports
    SIGNAL o_ild_out_spikes : STD_LOGIC_VECTOR(((c_NUM_FREQ_CH * c_NUM_NET_NEURONS * 2) - 1) DOWNTO 0);

	---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Clock
    CONSTANT c_i_clock_period : TIME := 20 ns;

   

    CONSTANT c_START_FREQ_CH : INTEGER := 24;

    --Testbench parameters
    CONSTANT c_NAS_NUM_FREQ_CH : INTEGER := 64;
    CONSTANT c_NAS_MONO_STEREO : INTEGER := 1;
    CONSTANT c_NAS_POLARITY_TYPE : INTEGER := 2;

    --Testbench signals
    SIGNAL tb_start_stimuli : STD_LOGIC := '0';
    SIGNAL tb_end_stimuli : STD_LOGIC := '0';

    --Testbench files
    FILE tb_input_ts_stimuli_file : text;
    FILE tb_input_addr_stimuli_file : text;
    FILE tb_output_aer_events_file : text;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : LSO
    GENERIC MAP(
        NUM_FREQ_CH => c_NUM_FREQ_CH
    )
    PORT MAP(
        i_clock => i_clock,
        i_nreset => i_nreset,
        i_left_avcn_spikes => i_left_avcn_spikes,
        i_right_avcn_spikes => i_right_avcn_spikes,
        o_ild_out_spikes => o_ild_out_spikes
    );

    --Clock generation
    i_clock <= NOT i_clock AFTER c_i_clock_period/2;
    --Reset process
    reset_process : PROCESS
    BEGIN
        --Start reset
        i_nreset <= '0';
        WAIT FOR 1 ms;
        i_nreset <= '1';
        WAIT FOR 1 ms;
        --Finish reset

        --Enable flag for starting the simulation
        tb_start_stimuli <= '1';

        WAIT;

    END PROCESS;

    stimuli_process : PROCESS
        VARIABLE v_ADDR_ILINE : LINE;
        VARIABLE v_TS_ILINE : LINE;
        VARIABLE v_ADDR_DATA : INTEGER;
        VARIABLE v_ADDR_EVENT : INTEGER;
        VARIABLE v_TS_DATA : INTEGER;
        VARIABLE v_NEXT_TS_DATA : INTEGER;
        VARIABLE v_TIME_TO_WAIT : INTEGER;
    BEGIN
        --// Open files in read mode
        file_open(tb_input_addr_stimuli_file, "D:/Proyectos/Universidad/Doctorado/BCBT2018/Projects/Source_location_model_NAS/LSO/Testbench/addr_test_ild.txt", read_mode);
        file_open(tb_input_ts_stimuli_file, "D:/Proyectos/Universidad/Doctorado/BCBT2018/Projects/Source_location_model_NAS/LSO/Testbench/ts_test_ild.txt", read_mode);

        v_TS_DATA := 0;

        WHILE NOT endfile(tb_input_ts_stimuli_file) LOOP
            --// Read a line
            readline(tb_input_ts_stimuli_file, v_TS_ILINE);
            readline(tb_input_addr_stimuli_file, v_ADDR_ILINE);

            --// Read value from line
            read(v_TS_ILINE, v_NEXT_TS_DATA);
            read(v_ADDR_ILINE, v_ADDR_DATA);

            --// Time to wait from previous TS
            v_TIME_TO_WAIT := v_NEXT_TS_DATA - v_TS_DATA;
            IF (v_TIME_TO_WAIT <= 0) THEN
                --// This means two events arrived almost at the same time
                WAIT FOR c_i_clock_period * 10;
            ELSE
                --// Wait until simulation time reach the next TS
                WAIT FOR (v_TIME_TO_WAIT * 1 us);
            END IF;

            --// Fire the spike
            v_ADDR_EVENT := v_ADDR_DATA - (c_START_FREQ_CH * 2);
            IF (v_ADDR_DATA < (c_NAS_NUM_FREQ_CH * 2)) THEN
                i_left_avcn_spikes(v_ADDR_EVENT) <= '1';
            ELSE
                v_ADDR_EVENT := v_ADDR_EVENT - (c_NAS_NUM_FREQ_CH * 2);
                i_right_avcn_spikes(v_ADDR_EVENT) <= '1';
            END IF;

            --// Wait for a clock cycle
            WAIT FOR c_i_clock_period;

            --// Clean the spike
            i_left_avcn_spikes <= (OTHERS => '0');
            i_right_avcn_spikes <= (OTHERS => '0');

            --// Update last TS
            v_TS_DATA := v_NEXT_TS_DATA;

        END LOOP;

        tb_end_stimuli <= '1';

        file_close(tb_input_addr_stimuli_file);
        file_close(tb_input_ts_stimuli_file);

        WAIT;

    END PROCESS stimuli_process;
    save_results_process : PROCESS
        VARIABLE v_OLINE : LINE;
        VARIABLE v_sim_time_str : STRING(1 TO 30); -- 30 chars should be enough
        VARIABLE v_sim_time_len : NATURAL;
        VARIABLE v_out_events_counter : INTEGER := 0;

        VARIABLE v_event_channel : INTEGER := 0;
        VARIABLE v_event_itd_neuron : INTEGER := 0;

    BEGIN
        --// Open RESULTS file in write mode
        file_open(tb_output_aer_events_file, "D:/Proyectos/Universidad/Doctorado/BCBT2018/Projects/Source_location_model_NAS/LSO/Testbench/aerout_test_ild.txt", write_mode);

        --// Loop while the simulation doesn't finish
        WHILE tb_end_stimuli = '0' LOOP
            --// Wait until there is a new AER data
            WAIT UNTIL i_clock'EVENT AND i_clock = '1';

            --// Take the current simulation time
            v_sim_time_len := TIME'image(now)'length;
            v_sim_time_str := (OTHERS => ' ');
            v_sim_time_str(1 TO v_sim_time_len) := TIME'image(now);

            --// Increase the event counter
            v_out_events_counter := v_out_events_counter + 1;

            --REPORT "Sim time string.......:'" & v_sim_time_str & "'";
            --REPORT "Event address: " & INTEGER'image(conv_integer(unsigned(aer_data_out)));

            FOR II IN 0 TO ((c_NUM_FREQ_CH * c_NAS_POLARITY_TYPE) - 1) LOOP
                IF (o_ild_out_spikes(II) = '1') THEN
                    v_event_channel := II;

                    REPORT "Output event counter: " & INTEGER'image(v_out_events_counter);

                    write(v_OLINE, v_event_channel, right, 1);
                    write(v_OLINE, ',', right, 1);

                    write(v_OLINE, v_sim_time_str, right, 1);

                    writeline(tb_output_aer_events_file, v_OLINE);
                ELSE

                END IF;
            END LOOP;
        END LOOP;

        file_close(tb_output_aer_events_file);

        WAIT;

    END PROCESS save_results_process;
END Behavioral;