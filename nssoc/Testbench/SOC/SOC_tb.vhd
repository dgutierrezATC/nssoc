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
-- Title      : Testbench for the spike-based Superior Olivary Complex (SOC) model
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : SOC_tb.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2019-05-01
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
ENTITY SOC_tb IS

END SOC_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF SOC_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
    COMPONENT SOC IS
        GENERIC (
            --// NAS parameters
            g_NAS_NUM_FREQ_CH                : INTEGER := 64;
            --// MSO parameters
            g_MSO_NUM_FREQ_CH                : INTEGER := 4;
            g_MSO_NBITS_NUM_FREQ_CH          : INTEGER := 2;
            g_MSO_START_FREQ_CH              : INTEGER := 30;
            g_MSO_END_FREQ_CH                : INTEGER := 33;
            g_MSO_NUM_ITD_NEURONS            : INTEGER := 16;
            g_MSO_NBITS_NUM_ITD_NEURONS      : INTEGER := 4;
            g_MSO_ITD_MAX_DETECTION_TIME     : INTEGER := 700;     --// In mircoseconds
            g_MSO_ITD_DETECTION_TIME_OVERLAP : INTEGER := 10;      --// In microseconds
            --// LSO PARAMETERS
            --g_LSO_NUM_FREQ_CH              : INTEGER := 27;
            --g_LSO_START_FREQ_CH            : INTEGER := 60;
            --g_LSO_END_FREQ_CH              : INTEGER := 63;
            --// Board parameters
            g_CLOCK_FREQ                     : INTEGER := 50000000 --// In Hz
        );
        PORT (
            --// Clock signal
            i_clock                          : IN  STD_LOGIC;
            --// Reset signal (active low)
            i_nreset                         : IN  STD_LOGIC;
            --// Output spikes from left NAS channel
            i_nas_left_out_spikes            : IN  STD_LOGIC_VECTOR(((g_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            --// Output spikes from right NAS channel
            i_nas_right_out_spikes           : IN  STD_LOGIC_VECTOR(((g_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            --// Output spikes from sMSO model (ALREADY IMPLEMENTED, BUT WITH AER OUTPUT)
            --o_mso_out_spikes               : OUT STD_LOGIC_VECTOR(((g_MSO_NUM_FREQ_CH * g_MSO_NUM_ITD_NEURONS) - 1) DOWNTO 0);
            --// Output spikes from sLSO model (NOT IMPLEMENTED YET)
            --o_lso_out_spikes               : OUT STD_LOGIC_VECTOR(((NUM_FREQ_CH_LSO * 2) - 1) DOWNTO 0)
            --// AER output interface (req & ack active low)
            o_soc_aer_out_data               : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            o_soc_aer_out_req                : OUT STD_LOGIC;
            i_soc_aer_out_ack                : IN  STD_LOGIC
        );
    END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
    ---------------------------------------------------------------------------

    -- Component constants
    CONSTANT c_NAS_NUM_FREQ_CH                : INTEGER := 64;
    CONSTANT c_MSO_NUM_FREQ_CH                : INTEGER := 10;
    CONSTANT c_MSO_NBITS_NUM_FREQ_CH          : INTEGER := 4;
    CONSTANT c_MSO_START_FREQ_CH              : INTEGER := 25;
    CONSTANT c_MSO_END_FREQ_CH                : INTEGER := 34;
    CONSTANT c_MSO_NUM_ITD_NEURONS            : INTEGER := 16;
    CONSTANT c_MSO_NBITS_NUM_ITD_NEURONS      : INTEGER := 4;
    CONSTANT c_MSO_ITD_MAX_DETECTION_TIME     : INTEGER := 700;
    CONSTANT c_MSO_ITD_DETECTION_TIME_OVERLAP : INTEGER := 5;
    CONSTANT c_CLOCK_FREQ                     : INTEGER := 50000000;

    -- Component input ports
    SIGNAL i_clock                            : STD_LOGIC := '0';
    SIGNAL i_nreset                           : STD_LOGIC := '0';
    SIGNAL i_nas_left_out_spikes              : STD_LOGIC_VECTOR(((c_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0) := (OTHERS => '0');
    SIGNAL i_nas_right_out_spikes             : STD_LOGIC_VECTOR(((c_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0) := (OTHERS => '0');
    SIGNAL i_soc_aer_out_ack                  : STD_LOGIC := '1';

    -- Component output ports
    SIGNAL o_mso_out_spikes                   : STD_LOGIC_VECTOR(((c_MSO_NUM_FREQ_CH * c_MSO_NUM_ITD_NEURONS) - 1) DOWNTO 0);
    SIGNAL o_soc_aer_out_data                 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL o_soc_aer_out_req                  : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

    -- Clock
    CONSTANT c_i_clock_period : TIME := 20 ns;

    -- Testbench signals
    SIGNAL tb_end_of_simulation     : STD_LOGIC := '0'; -- Flag to indicate the end of the simulation
    SIGNAL tb_start_of_simulation   : STD_LOGIC := '0'; -- Flag to indicate the begining of the simulation

    -- Testbench files
    CONSTANT c_absolute_path        : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Testbench/SOC/Results/Files/"; -- Absolute path to the testbench files

    FILE tb_input_ts_stimuli_file   : TEXT OPEN READ_MODE  IS c_absolute_path & "pure_tone_fs48000duration1000frequency500amplitude1_3_tss.txt";  -- Input spikes filename
    FILE tb_input_addr_stimuli_file : TEXT OPEN READ_MODE  IS c_absolute_path & "pure_tone_fs48000duration1000frequency500amplitude1_3_addrs.txt";  -- Input spikes filename;
    FILE tb_output_aer_events_file  : TEXT OPEN WRITE_MODE IS c_absolute_path & "pure_tone_fs48000duration1000frequency500amplitude1_3_soc_out.txt";  -- Input spikes filename;

BEGIN

    --// Instantiate the Unit Under Test (UUT)
    uut : SOC
    GENERIC MAP(
        --// NAS parameters
        g_NAS_NUM_FREQ_CH                => c_NAS_NUM_FREQ_CH,
        --// MSO parameters
        g_MSO_NUM_FREQ_CH                => c_MSO_NUM_FREQ_CH,
        g_MSO_NBITS_NUM_FREQ_CH          => c_MSO_NBITS_NUM_FREQ_CH,
        g_MSO_START_FREQ_CH              => c_MSO_START_FREQ_CH,
        g_MSO_END_FREQ_CH                => c_MSO_END_FREQ_CH,
        g_MSO_NUM_ITD_NEURONS            => c_MSO_NUM_ITD_NEURONS,
        g_MSO_NBITS_NUM_ITD_NEURONS      => c_MSO_NBITS_NUM_ITD_NEURONS,
        g_MSO_ITD_MAX_DETECTION_TIME     => c_MSO_ITD_MAX_DETECTION_TIME,
        g_MSO_ITD_DETECTION_TIME_OVERLAP => c_MSO_ITD_DETECTION_TIME_OVERLAP,
        --// LSO PARAMETERS
        --g_LSO_NUM_FREQ_CH              => ,
        --g_LSO_START_FREQ_CH            => ,
        --g_LSO_END_FREQ_CH              => ,
        --// Board parameters
        g_CLOCK_FREQ                     => c_CLOCK_FREQ
    )
    PORT MAP(
        --// Clock signal
        i_clock                          => i_clock,
        --// Reset signal (active low)
        i_nreset                         => i_nreset,
        --// Output spikes from left NAS channel
        i_nas_left_out_spikes            => i_nas_left_out_spikes,
        --// Output spikes from right NAS channel
        i_nas_right_out_spikes           => i_nas_right_out_spikes,
        --// Output spikes from sMSO model (ALREADY IMPLEMENTED, BUT WITH AER OUTPUT)
        --o_mso_out_spikes                 => o_mso_out_spikes,
        --// Output spikes from sLSO model (NOT IMPLEMENTED YET)
        --o_lso_out_spikes               => ,
        --// AER output interface (req & ack active low)
        o_soc_aer_out_data               => o_soc_aer_out_data,
        o_soc_aer_out_req                => o_soc_aer_out_req,
        i_soc_aer_out_ack                => i_soc_aer_out_ack
    );

    ---------------------------------------------------------------------------
    -- Clocks generation
    ---------------------------------------------------------------------------
    i_clock <= NOT i_clock AFTER c_i_clock_period/2;

    -----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    -- purpose: Simulate the AER interface from the receiver
    -- type   : combinational
    -- inputs : o_out_aer_req
    -- outputs: i_out_aer_ack
    i_soc_aer_out_ack <= o_soc_aer_out_req AFTER (c_i_clock_period * 2);

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
        VARIABLE v_ADDR_ILINE   : LINE;
        VARIABLE v_TS_ILINE     : LINE;
        VARIABLE v_ADDR_DATA    : INTEGER;
        VARIABLE v_TS_DATA      : INTEGER;
        VARIABLE v_NEXT_TS_DATA : INTEGER;
        VARIABLE v_TIME_TO_WAIT : INTEGER;
    BEGIN

        -- Wait until the reset is cleared
        WAIT UNTIL tb_start_of_simulation = '1';

        v_TS_DATA := 0;

        REPORT "Starting to read the stimuli file..." SEVERITY NOTE;
        WHILE NOT ENDFILE(tb_input_ts_stimuli_file) LOOP

            --// Read a line
            READLINE(tb_input_ts_stimuli_file, v_TS_ILINE);
            READLINE(tb_input_addr_stimuli_file, v_ADDR_ILINE);

            --// Read value from line
            READ(v_TS_ILINE, v_NEXT_TS_DATA);
            READ(v_ADDR_ILINE, v_ADDR_DATA);

            --// Time to wait from previous TS
            v_TIME_TO_WAIT := v_NEXT_TS_DATA - v_TS_DATA;
            IF (v_TIME_TO_WAIT <= 0) THEN
                --// This means two events arrived almost at the same time
                WAIT FOR c_i_clock_period * 10;
            ELSE
                --// Wait until simulation time reach the next TS
                WAIT FOR (v_TIME_TO_WAIT * 1 us);
            END IF;

            --// Sync before to spike
            WAIT UNTIL i_clock'EVENT AND i_clock = '1';
            WAIT FOR c_i_clock_period * 1;

            --// Fire the spike
            IF (v_ADDR_DATA < (c_NAS_NUM_FREQ_CH * 2)) THEN
                i_nas_left_out_spikes(v_ADDR_DATA) <= '1';
            ELSE
                v_ADDR_DATA := v_ADDR_DATA - (c_NAS_NUM_FREQ_CH * 2);
                i_nas_right_out_spikes(v_ADDR_DATA) <= '1';
            END IF;

            --// Wait for a clock cycle
            WAIT FOR c_i_clock_period;

            --// Clean the spike
            i_nas_left_out_spikes <= (OTHERS => '0');
            i_nas_right_out_spikes <= (OTHERS => '0');

            --// Update last TS
            v_TS_DATA := v_NEXT_TS_DATA;

        END LOOP;

        --
        -- End of the simulation
        --

        -- Notify the end of the simulation
        tb_end_of_simulation <= '1';
        REPORT "End of the simulation." SEVERITY NOTE;
        
        -- Close the files
        file_close(tb_input_addr_stimuli_file);
        file_close(tb_input_ts_stimuli_file);

        -- Wait forever
        WAIT;

    END PROCESS p_stimuli;

    -- purpose: Save out the testbench results into a file
    -- type   : combinational
    -- inputs : 
    -- outputs: 
    save_results_process : PROCESS
        VARIABLE v_OLINE : LINE;
        VARIABLE v_sim_time_str : STRING(1 TO 30); -- 30 chars should be enough
        VARIABLE v_sim_time_len : NATURAL;
        VARIABLE v_out_events_counter : INTEGER := 0;

        VARIABLE v_auditory_model : INTEGER := 0;
        VARIABLE v_xso_type : INTEGER := 0;
        VARIABLE v_event_channel : INTEGER := 0;
        VARIABLE v_event_neuron_id : INTEGER := 0;
        
    BEGIN
        --// Loop while the simulation doesn't finish
        WHILE tb_end_of_simulation = '0' LOOP
            --// Wait until there is a new AER data
            WAIT UNTIL o_soc_aer_out_req = '0';

            --// Take the current simulation time
            v_sim_time_len := TIME'IMAGE(now)'LENGTH;
            v_sim_time_str := (OTHERS => ' ');
            v_sim_time_str(1 TO v_sim_time_len) := TIME'IMAGE(now);

            --// Increase the event counter
            v_out_events_counter := v_out_events_counter + 1;

            --REPORT "Sim time string.......:'" & v_sim_time_str & "'";
            --REPORT "Event address: " & INTEGER'IMAGE(conv_integer(unsigned(aer_data_out)));

            v_auditory_model := conv_integer(unsigned(o_soc_aer_out_data(15 DOWNTO 15)));
            REPORT "Auditory model: " & INTEGER'IMAGE(v_auditory_model);

            v_xso_type := conv_integer(unsigned(o_soc_aer_out_data(14 DOWNTO 14)));
            REPORT "xSO type: " & INTEGER'IMAGE(v_xso_type);

            v_event_neuron_id := conv_integer(unsigned(o_soc_aer_out_data(13 DOWNTO 9)));
            REPORT "Neuron ID: " & INTEGER'IMAGE(v_event_neuron_id);

            v_event_channel := conv_integer(unsigned(o_soc_aer_out_data(7 DOWNTO 1)));
            REPORT "Freq channel: " & INTEGER'IMAGE(v_event_channel);

            REPORT "Output event counter: " & INTEGER'IMAGE(v_out_events_counter);

            --// Write the data into the file
            --// The CSV format should be: address, timestamp, auditory_model, xso_type, neuron_id.

            write(v_OLINE, v_event_channel, right, 1);
            write(v_OLINE, ',', right, 1);

            write(v_OLINE, v_sim_time_str, right, 1);
            write(v_OLINE, ',', right, 1);

            write(v_OLINE, v_auditory_model, right, 1);
            write(v_OLINE, ',', right, 1);

            write(v_OLINE, v_xso_type, right, 1);
            write(v_OLINE, ',', right, 1);

            write(v_OLINE, v_event_neuron_id, right, 1);

            writeline(tb_output_aer_events_file, v_OLINE);
        END LOOP;

        file_close(tb_output_aer_events_file);

        WAIT;

    END PROCESS save_results_process;
END Behavioral;