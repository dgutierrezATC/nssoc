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
-- Title      : Testbench for OpenNas_TOP_Cascade_MONO_64ch with AVCN
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : OpenNas_TOP_Cascade_MONO_64ch_tb.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2021-01-14
-- Last update: 2021-01-14
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
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY OpenNas_TOP_Cascade_MONO_64ch_tb IS

END OpenNas_TOP_Cascade_MONO_64ch_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF OpenNas_TOP_Cascade_MONO_64ch_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT OpenNas_Cascade_MONO_64ch IS
        PORT (
            -- Clock and reset
            clock        : IN STD_LOGIC;
            rst_ext      : IN STD_LOGIC;
            -- Input I2S interface
            i2s_d_in     : IN STD_LOGIC;
            i2s_bclk     : IN STD_LOGIC;
            i2s_lr       : IN STD_LOGIC;
            -- Output AER interface
            AER_DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            AER_REQ      : OUT STD_LOGIC;
            AER_ACK      : IN  STD_LOGIC
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

    -- Component generics

    -- Component input ports
    SIGNAL clock        : STD_LOGIC := '0';
    SIGNAL rst_ext      : STD_LOGIC := '0';
    SIGNAL i2s_d_in     : STD_LOGIC := '0';
    SIGNAL i2s_bclk     : STD_LOGIC := '0';
    SIGNAL i2s_lr       : STD_LOGIC := '0';
    SIGNAL AER_ACK      : STD_LOGIC := '1';

    -- Component output ports
    SIGNAL AER_REQ      : STD_LOGIC;
    SIGNAL AER_DATA_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Data types
    TYPE t_integer_file IS FILE OF INTEGER;

    -- Clock
    CONSTANT c_clock_period : TIME := 20 ns;

    -- I2S clock divider
    CONSTANT c_I2S_sck_num_sys_clock_cycles : INTEGER := 8;

    -- Stimuli signals
    SIGNAL tb_start_stimuli : STD_LOGIC := '0';
    SIGNAL tb_end_stimuli   : STD_LOGIC := '0';

    -- Testbench files
    CONSTANT c_tb_absolute_path        : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Examples/NAS_AVCN/NAS_I2S_64ch_mono_12att_monitor/testbench/";
    FILE tb_input_left_samples_file    : t_integer_file OPEN read_mode IS c_tb_absolute_path & "stimuli/left.bin";
    FILE tb_input_right_samples_file   : t_integer_file OPEN read_mode IS c_tb_absolute_path & "stimuli/left.bin";
    FILE tb_output_NAS_aer_events_file : text OPEN write_mode IS c_tb_absolute_path & "results/nas_events.txt";

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Instantiate the Unit Under Test (UUT)
    ---------------------------------------------------------------------------
    uut : OpenNas_Cascade_MONO_64ch
    PORT MAP(
        -- Clock and reset
        clock        => clock,
        rst_ext      => rst_ext,
        -- Input I2S interface
        i2s_bclk     => i2s_bclk,
        i2s_d_in     => i2s_d_in,
        i2s_lr       => i2s_lr,
        -- Output AER interface
        AER_DATA_OUT => AER_DATA_OUT,
        AER_REQ      => AER_REQ,
        AER_ACK      => AER_ACK
    );

    ---------------------------------------------------------------------------
    -- Clocks generation
    ---------------------------------------------------------------------------
    
    --
    -- Main clock
    --
    clock <= NOT clock AFTER c_clock_period / 2;

    --
    -- I2S sck generation
    --
    p_i2s_bclk_generation_process : PROCESS (clock, rst_ext)
        VARIABLE v_internal_counter : INTEGER := 0;
    BEGIN
        IF (rst_ext = '0') THEN
            v_internal_counter := 0;
            i2s_bclk <= '0';
        ELSE
            IF (clock'event AND clock = '1') THEN
                IF (v_internal_counter = c_I2S_sck_num_sys_clock_cycles) THEN
                    v_internal_counter := 0;
                    i2s_bclk <= NOT i2s_bclk;
                ELSE
                    v_internal_counter := v_internal_counter + 1;
                    i2s_bclk <= i2s_bclk;
                END IF;
            ELSE

            END IF;
        END IF;
    END PROCESS p_i2s_bclk_generation_process;

    --//======================
    --// I2S ws generation
    --//======================
    I2S_ws_generation_process : PROCESS (i2s_bclk, rst_ext)
        VARIABLE v_internal_counter : INTEGER := 0;
    BEGIN
        IF (rst_ext = '0') THEN
            v_internal_counter := 0;
            i2s_lr <= '0';
        ELSE
            IF (i2s_bclk'event AND i2s_bclk = '0') THEN
                IF (v_internal_counter = 31) THEN
                    v_internal_counter := 0;
                    i2s_lr <= NOT i2s_lr;
                ELSE
                    v_internal_counter := v_internal_counter + 1;
                    i2s_lr <= i2s_lr;
                END IF;
            ELSE

            END IF;
        END IF;
    END PROCESS I2S_ws_generation_process;

    --//======================
    --// Reset process
    --//======================
    reset_process : PROCESS
    BEGIN
        --//Start reset
        rst_ext <= '0';
        WAIT FOR 1 us;
        rst_ext <= '1';
        WAIT FOR 10 us;
        --//Finish reset

        --// Synchronize with the I2S ws signal
        WAIT UNTIL i2s_lr'event AND i2s_lr = '0';
        WAIT UNTIL i2s_lr'event AND i2s_lr = '1';
        WAIT UNTIL i2s_lr'event AND i2s_lr = '0';

        --Enable flag for starting the simulation
        tb_start_stimuli <= '1';

        WAIT;

    END PROCESS;

    --//======================
    --// Save results process
    --//======================
    save_results_process : PROCESS
        --// Line variables for writing out into the textfile
        VARIABLE v_OLINE_NAS : line;
        --// String variable for getting the timestamp
        VARIABLE v_sim_time_str : STRING(1 TO 30); -- 30 chars should be enough
        VARIABLE v_sim_time_len : NATURAL;
        --// Events counter
        VARIABLE v_out_events_counter_NAS : INTEGER := 0;
        --// Fields of the HPU AER format for an audio event
        VARIABLE v_event_address : INTEGER := 0;

    BEGIN
        --// Open NAS RESULTS file in write mode
        --file_open(tb_output_NAS_aer_events_file, "D:/Proyectos/Universidad/GitHub/IIT_repos_NAS_iCub_integration/NAS_iCub/code/hdl/testbench/simulation_results/NAS_results.txt", write_mode);

        --// Loop while the simulation doesn't finish
        WHILE tb_end_stimuli = '0' LOOP
            --// Wait until there is a new AER data
            WAIT UNTIL AER_ACK = '0';

            --// Take the current simulation time
            v_sim_time_len := TIME'image(now)'length;
            v_sim_time_str := (OTHERS => ' ');
            v_sim_time_str(1 TO v_sim_time_len) := TIME'image(now);
            REPORT "Sim time string.......:'" & v_sim_time_str & "'";

            --// Take the event source: 0 left; 1 right
            v_event_address := conv_integer(unsigned(AER_DATA_OUT));
            REPORT "Event address: " & INTEGER'image(v_event_address);

            --// Increase the event counter
            v_out_events_counter_NAS := v_out_events_counter_NAS + 1;
            --// Print output events counter
            REPORT "Output event counter NAS: " & INTEGER'image(v_out_events_counter_NAS);

            --// Writing the event source: left or right
            write(v_OLINE_NAS, v_event_address, right, 1);
            write(v_OLINE_NAS, ',', right, 1);
            --// Writing the timestamp
            write(v_OLINE_NAS, v_sim_time_str, right, 1);

            --// Writing the line into the output text file
            writeline(tb_output_NAS_aer_events_file, v_OLINE_NAS);

        END LOOP;

        --// Close NAS RESULTS file
        file_close(tb_output_NAS_aer_events_file);

        WAIT;

    END PROCESS save_results_process;

    --======================
    -- AER ack update (should be from external device)
    --======================
    AER_ACK <= AER_REQ AFTER c_clock_period * 2;

    --======================
    -- stimuli process
    --======================

    stimuli_process : PROCESS
        --// Variable for storing the readed audio sample
        VARIABLE v_audio_sample : INTEGER := 0;
        --// Variable for storing the readed audio sample in a binary vector
        VARIABLE v_i2s_audio_sample : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        --// Open the sample files to be readed
        --file_open(tb_input_left_samples_file, "D:/Proyectos/Universidad/GitHub/IIT_repos_NAS_iCub_integration/NAS_iCub/code/hdl/testbench/stimuli_data/left.bin");
        --file_open(tb_input_right_samples_file, "D:/Proyectos/Universidad/GitHub/IIT_repos_NAS_iCub_integration/NAS_iCub/code/hdl/testbench/stimuli_data/right.bin");

        --// Wait until the start stimuli flag is enabled
        WAIT UNTIL tb_start_stimuli = '1';

        --// Wait until ws clock is 0 for starting with a left sample
        WAIT UNTIL i2s_lr = '0';

        --// Wait until falling edge of sck clock to start sending bits
        WAIT UNTIL i2s_bclk'event AND i2s_bclk = '0';
        --// While there are data in either left or right sample files
        WHILE (NOT endfile(tb_input_left_samples_file)) OR (NOT endfile(tb_input_right_samples_file)) LOOP
            --// Check if it is left or right sample
            IF (i2s_lr = '0') THEN
                --// Read value from left sample file
                read(tb_input_left_samples_file, v_audio_sample);
            ELSE
                --// Read value from right sample file
                read(tb_input_right_samples_file, v_audio_sample);
            END IF;

            --// Convert the integer value to std logic vector (32 bits)
            v_i2s_audio_sample(31 DOWNTO 0) := conv_std_logic_vector(v_audio_sample, 32);

            --// For each falling edge of I2S sck clock, transmit a bit
            FOR j IN 31 DOWNTO 0 LOOP
                i2s_d_in <= v_i2s_audio_sample(j);
                WAIT UNTIL i2s_bclk'event AND i2s_bclk = '0';
            END LOOP;

        END LOOP;

        --// When there is no more data in one of those files, the testbench has finished
        tb_end_stimuli <= '1';

        --// Report the end of the simulation
        REPORT "End of the simulation!" SEVERITY NOTE;
        --// Close the sample files
        file_close(tb_input_left_samples_file);
        file_close(tb_input_right_samples_file);

        WAIT;

    END PROCESS;
END Behavioral;