----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.05.2019 10:29:23
-- Design Name: 
-- Module Name: SOC_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY SOC_tb IS
    --  Port ( );
END SOC_tb;

ARCHITECTURE Behavioral OF SOC_tb IS

    COMPONENT SOC IS
        GENERIC (
            --// NAS parameters
            g_NAS_NUM_FREQ_CH : INTEGER := 64;
            --// MSO parameters
            g_MSO_NUM_FREQ_CH : INTEGER := 4;
            g_MSO_START_FREQ_CH : INTEGER := 30;
            g_MSO_END_FREQ_CH : INTEGER := 33;
            g_MSO_NUM_ITD_NEURONS : INTEGER := 16;
            g_MSO_ITD_MAX_DETECTION_TIME : INTEGER := 700; --// in mircoseconds
            g_MSO_ITD_DETECTION_TIME_OVERLAP : INTEGER := 10; --// in microseconds
            --// LSO PARAMETERS
            --g_LSO_NUM_FREQ_CH : INTEGER := 27;
            --g_LSO_START_FREQ_CH : INTEGER := 60;
            --g_LSO_END_FREQ_CH : INTEGER := 63;
            --// Board parameters
            g_CLOCK_FREQ : INTEGER := 50000000 --// in Hz
        );
        PORT (
            --// Clock signal
            i_clock : IN std_logic;
            --// Reset signal (active low)
            i_nreset : IN std_logic;
            --// Output spikes from left NAS channel
            i_nas_left_out_spikes : IN std_logic_vector(((g_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            --// Output spikes from right NAS channel
            i_nas_right_out_spikes : IN std_logic_vector(((g_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            --// Output spikes from sMSO model (ALREADY IMPLEMENTED, BUT WITH AER OUTPUT)
            o_mso_out_spikes : OUT std_logic_vector(((g_MSO_NUM_FREQ_CH * g_MSO_NUM_ITD_NEURONS) - 1) DOWNTO 0);
            --// Output spikes from sLSO model (NOT IMPLEMENTED YET)
            --o_lso_out_spikes : OUT std_logic_vector(((NUM_FREQ_CH_LSO * 2) - 1) DOWNTO 0)
            --// AER output interface (req & ack active low)
            o_soc_aer_out_data : OUT std_logic_vector(15 DOWNTO 0);
            o_soc_aer_out_req : OUT std_logic;
            i_soc_aer_out_ack : IN std_logic
        );
    END COMPONENT;

    --// Data types

    --// Constants
    CONSTANT c_i_clock_period : TIME := 20 ns;

    CONSTANT c_NAS_NUM_FREQ_CH : INTEGER := 64;
    CONSTANT c_MSO_NUM_FREQ_CH : INTEGER := 4;
    CONSTANT c_MSO_START_FREQ_CH : INTEGER := 30;
    CONSTANT c_MSO_END_FREQ_CH : INTEGER := 33;
    CONSTANT c_MSO_NUM_ITD_NEURONS : INTEGER := 16;
    CONSTANT c_MSO_ITD_MAX_DETECTION_TIME : INTEGER := 700;
    CONSTANT c_MSO_ITD_DETECTION_TIME_OVERLAP : INTEGER := 10;
    CONSTANT c_CLOCK_FREQ : INTEGER := 50000000;

    --// Inputs
    SIGNAL i_clock : std_logic := '0';
    SIGNAL i_nreset : std_logic := '0';
    SIGNAL i_nas_left_out_spikes : std_logic_vector(((c_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0) := (OTHERS => '0');
    SIGNAL i_nas_right_out_spikes : std_logic_vector(((c_NAS_NUM_FREQ_CH * 2) - 1) DOWNTO 0) := (OTHERS => '0');
    SIGNAL i_soc_aer_out_ack : std_logic := '1';

    --// Outputs
    SIGNAL o_mso_out_spikes : std_logic_vector(((c_MSO_NUM_FREQ_CH * c_MSO_NUM_ITD_NEURONS) - 1) DOWNTO 0);
    SIGNAL o_soc_aer_out_data : std_logic_vector(15 DOWNTO 0);
    SIGNAL o_soc_aer_out_req : std_logic;

    --// Testbench signals
    SIGNAL tb_start_stimuli : std_logic := '0';
    SIGNAL tb_end_stimuli : std_logic := '0';

    --/ Testbench files
    FILE tb_input_ts_stimuli_file : text;
    FILE tb_input_addr_stimuli_file : text;
    FILE tb_output_aer_events_file : text;

BEGIN

    --// Instantiate the Unit Under Test (UUT)
    uut : SOC
    GENERIC MAP(
        --// NAS parameters
        g_NAS_NUM_FREQ_CH => c_NAS_NUM_FREQ_CH,
        --// MSO parameters
        g_MSO_NUM_FREQ_CH => c_MSO_NUM_FREQ_CH,
        g_MSO_START_FREQ_CH => c_MSO_START_FREQ_CH,
        g_MSO_END_FREQ_CH => c_MSO_END_FREQ_CH,
        g_MSO_NUM_ITD_NEURONS => c_MSO_NUM_ITD_NEURONS,
        g_MSO_ITD_MAX_DETECTION_TIME => c_MSO_ITD_MAX_DETECTION_TIME,
        g_MSO_ITD_DETECTION_TIME_OVERLAP => c_MSO_ITD_DETECTION_TIME_OVERLAP,
        --// LSO PARAMETERS
        --g_LSO_NUM_FREQ_CH => ,
        --g_LSO_START_FREQ_CH => ,
        --g_LSO_END_FREQ_CH => ,
        --// Board parameters
        g_CLOCK_FREQ => c_CLOCK_FREQ
    )
    PORT MAP(
        --// Clock signal
        i_clock => i_clock,
        --// Reset signal (active low)
        i_nreset => i_nreset,
        --// Output spikes from left NAS channel
        i_nas_left_out_spikes => i_nas_left_out_spikes,
        --// Output spikes from right NAS channel
        i_nas_right_out_spikes => i_nas_right_out_spikes,
        --// Output spikes from sMSO model (ALREADY IMPLEMENTED, BUT WITH AER OUTPUT)
        o_mso_out_spikes => o_mso_out_spikes,
        --// Output spikes from sLSO model (NOT IMPLEMENTED YET)
        --o_lso_out_spikes => ,
        --// AER output interface (req & ack active low)
        o_soc_aer_out_data => o_soc_aer_out_data,
        o_soc_aer_out_req => o_soc_aer_out_req,
        i_soc_aer_out_ack => i_soc_aer_out_ack
    );

    --Clock generation
    i_clock <= NOT i_clock AFTER c_i_clock_period/2;

    i_soc_aer_out_ack <= o_soc_aer_out_req AFTER (c_i_clock_period * 2);

    --Rset process
    reset_process : PROCESS
    BEGIN
        --Start reset
        i_nreset <= '0';
        WAIT FOR 1 us;
        i_nreset <= '1';
        WAIT FOR 10 us;
        --Finish reset

        --Enable flag for starting the simulation
        tb_start_stimuli <= '1';

        WAIT;

    END PROCESS;

    save_results_process : PROCESS
        VARIABLE v_OLINE : LINE;
        VARIABLE v_sim_time_str : STRING(1 TO 30); -- 30 chars should be enough
        VARIABLE v_sim_time_len : NATURAL;
        VARIABLE v_out_events_counter : INTEGER := 0;

        VARIABLE v_event_channel : INTEGER := 0;
        VARIABLE v_event_itd_neuron : INTEGER := 0;
        
    BEGIN
        --// Open RESULTS file in write mode
        file_open(tb_output_aer_events_file, "D:/Proyectos/Universidad/Doctorado/BCBT2018/Projects/Source_location_model_NAS/SOC/Testbench/aer_out_500Hz_center_left_right_64ch_ste_cas_36tt.txt", write_mode);

        --// Loop while the simulation doesn't finish
        WHILE tb_end_stimuli = '0' LOOP
            --// Wait until there is a new AER data
            WAIT UNTIL o_soc_aer_out_req = '0';

            --// Take the current simulation time
            v_sim_time_len := TIME'image(now)'length;
            v_sim_time_str := (OTHERS => ' ');
            v_sim_time_str(1 TO v_sim_time_len) := TIME'image(now);

            --// Increase the event counter
            v_out_events_counter := v_out_events_counter + 1;

            --REPORT "Sim time string.......:'" & v_sim_time_str & "'";
            --REPORT "Event address: " & INTEGER'image(conv_integer(unsigned(aer_data_out)));

            v_event_channel := conv_integer(unsigned(o_soc_aer_out_data(6 downto 1)));
            REPORT "Freq channel: " & INTEGER'image(v_event_channel);

            v_event_itd_neuron := conv_integer(unsigned(o_soc_aer_out_data(13 downto 8)));
            REPORT "ITD neuron ID: " & INTEGER'image(v_event_itd_neuron);

            REPORT "Output event counter: " & INTEGER'image(v_out_events_counter);

            write(v_OLINE, v_event_channel, right, 1);
            write(v_OLINE, ',', right, 1);

            write(v_OLINE, v_event_itd_neuron, right, 1);
            write(v_OLINE, ',', right, 1);

            write(v_OLINE, v_sim_time_str, right, 1);

            writeline(tb_output_aer_events_file, v_OLINE);
        END LOOP;

        file_close(tb_output_aer_events_file);

        WAIT;

    END PROCESS save_results_process;

    stimuli_process : PROCESS
        VARIABLE v_ADDR_ILINE : LINE;
        VARIABLE v_TS_ILINE : LINE;
        VARIABLE v_ADDR_DATA : INTEGER;
        VARIABLE v_TS_DATA : INTEGER;
        VARIABLE v_NEXT_TS_DATA : INTEGER;
        VARIABLE v_TIME_TO_WAIT : INTEGER;
    BEGIN
        --// Open files in read mode
        file_open(tb_input_addr_stimuli_file, "D:/Proyectos/Universidad/Doctorado/BCBT2018/Projects/Source_location_model_NAS/SOC/Testbench/addr_500Hz_center_left_right_64ch_ste_cas_36tt.txt", read_mode);
        file_open(tb_input_ts_stimuli_file, "D:/Proyectos/Universidad/Doctorado/BCBT2018/Projects/Source_location_model_NAS/SOC/Testbench/ts_500Hz_center_left_right_64ch_ste_cas_36tt.txt", read_mode);

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

        tb_end_stimuli <= '1';

        file_close(tb_input_addr_stimuli_file);
        file_close(tb_input_ts_stimuli_file);

        WAIT;

    END PROCESS stimuli_process;
END Behavioral;