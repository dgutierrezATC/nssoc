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
-- Title      : Testbench for OpenNas_TOP_Cascade_MONO_64ch with the SOC model
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : NAS_SOC_top_tb.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2019-07-24
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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY NAS_SOC_top_tb IS

END NAS_SOC_top_tb;

-------------------------------------------------------------------------------
-- Architectures
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF NAS_SOC_top_tb IS

    -------------------------------------------------------------------------------
    -- Component declaration for the unit under test (UUT)
    -------------------------------------------------------------------------------
	COMPONENT NAS_SOC_top IS
		--GENERIC (
		--    g_ENABLE_SOUND_SOURCE_LOC : INTEGER := 0
		--);
		PORT (
			-- Clock and reset
			i_sys_clock : IN  STD_LOGIC;
			i_sys_reset : IN  STD_LOGIC;
			-- Input interface
			i_I2S_sd    : IN  STD_LOGIC;
			i_I2S_sck   : IN  STD_LOGIC;
			i_I2S_ws    : IN  STD_LOGIC;
			-- Output interface
			o_AER_data  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			o_AER_req   : OUT STD_LOGIC;
			i_AER_ack   : IN  STD_LOGIC
		);
	END COMPONENT;

    ---------------------------------------------------------------------------
    -- UUT signals declaration
	---------------------------------------------------------------------------
	
	-- Component generics

	-- Component input ports
	SIGNAL i_sys_clock : STD_LOGIC := '0';
	SIGNAL i_sys_reset : STD_LOGIC := '0';
	SIGNAL i_I2S_sd    : STD_LOGIC := '0';
	SIGNAL i_I2S_sck   : STD_LOGIC := '0';
	SIGNAL i_I2S_ws    : STD_LOGIC := '0';
	SIGNAL i_AER_ack   : STD_LOGIC := '1';

	-- Component output ports
	SIGNAL o_AER_req   : STD_LOGIC;
	SIGNAL o_AER_data  : STD_LOGIC_VECTOR(15 DOWNTO 0);

	---------------------------------------------------------------------------
    -- Testbench signals declaration
    ---------------------------------------------------------------------------

	-- Clock
	CONSTANT c_sys_clock_period : TIME := 20.83 ns;

	-- Constants
	CONSTANT c_I2S_sck_num_sys_clock_cycles : INTEGER := 8;

	-- Testbench signals
	SIGNAL tb_start_stimuli : STD_LOGIC := '0';
	SIGNAL tb_end_stimuli   : STD_LOGIC := '0';

	-- Testbench files
	TYPE t_integer_file IS FILE OF INTEGER;

	CONSTANT c_tb_absolute_path         : STRING := "D:/Universidad/Repositorios/GitHub/Doctorado/nssoc/nssoc/Examples/NAS_SSOC/NAS_I2S_64ch_mono_12att_monitor_ztex/testbench/"; -- Absolute path to the testbench files

	FILE tb_input_left_samples_file  : t_integer_file OPEN read_mode IS c_tb_absolute_path & "stimuli/sin_96e3fs_0_5d_1000a_500Hz_left.bin";
	FILE tb_input_right_samples_file : t_integer_file OPEN read_mode IS c_tb_absolute_path & "stimuli/sin_96e3fs_0_5d_1000a_500Hz_right.bin";

	FILE tb_output_NAS_SOC_aer_events_file : TEXT OPEN write_mode IS c_tb_absolute_path & "results/nas_soc_out_events_test.txt";

BEGIN  -- architecture Behavioral

	---------------------------------------------------------------------------
	-- Instantiate the Unit Under Test (UUT)
	---------------------------------------------------------------------------
	uut : NAS_SOC_top
		PORT MAP (
			--// Clock and reset
			i_sys_clock => i_sys_clock,
			i_sys_reset => i_sys_reset,
			--// Input I2S interface
			i_I2S_sd    => i_I2S_sd,
			i_I2S_sck   => i_I2S_sck,
			i_I2S_ws    => i_I2S_ws,
			--// Output AER interface
			o_AER_data  => o_AER_data,
			o_AER_req   => o_AER_req,
			i_AER_ack   => i_AER_ack
		);

    ---------------------------------------------------------------------------
    -- Clocks generation
	---------------------------------------------------------------------------
	
	--
	-- Main clock
	--
	i_sys_clock <= NOT i_sys_clock AFTER c_sys_clock_period/2;

    --
    -- I2S sck generation
    --
	p_I2S_sck_generation_process : PROCESS (i_sys_clock, i_sys_reset)
		VARIABLE v_internal_counter : INTEGER := 0;
	BEGIN
		IF (i_sys_reset = '0') THEN
			v_internal_counter := 0;
			i_I2S_sck          <= '0';
		ELSE
			IF (i_sys_clock'EVENT AND i_sys_clock = '1') THEN
				IF (v_internal_counter = c_I2S_sck_num_sys_clock_cycles) THEN
					v_internal_counter := 0;
					i_I2S_sck          <= NOT i_I2S_sck;
				ELSE
					v_internal_counter := v_internal_counter + 1;
					i_I2S_sck          <= i_I2S_sck;
				END IF;
			ELSE

			END IF;
		END IF;
	END PROCESS p_I2S_sck_generation_process;

	--
	-- I2S ws generation
	--
	p_I2S_ws_generation_process : PROCESS (i_I2S_sck, i_sys_reset)
		VARIABLE v_internal_counter : INTEGER := 0;
	BEGIN
		IF (i_sys_reset = '0') THEN
			v_internal_counter := 0;
			i_I2S_ws           <= '0';
		ELSE
			IF (i_I2S_sck'event AND i_I2S_sck = '0') THEN
				IF (v_internal_counter = 31) THEN
					v_internal_counter := 0;
					i_I2S_ws           <= NOT i_I2S_ws;
				ELSE
					v_internal_counter := v_internal_counter + 1;
					i_I2S_ws           <= i_I2S_ws;
				END IF;
			ELSE

			END IF;
		END IF;
	END PROCESS p_I2S_ws_generation_process;

	-----------------------------------------------------------------------------
    -- Processes
	-----------------------------------------------------------------------------


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
        i_sys_reset <= '0';
        -- Hold it for 1 us
        WAIT FOR 1 us;

        -- Clear reset
        i_sys_reset <= '1';

        -- Report the reset has been clear
        REPORT "Reset cleared!" SEVERITY NOTE;

        -- Wait for a few clock cycles
		wait for c_sys_clock_period*10;
		
		-- Synchronize with the I2S ws signal
		WAIT UNTIL i_I2S_ws'event AND i_I2S_ws = '0';
        WAIT UNTIL i_I2S_ws'event AND i_I2S_ws = '1';
        WAIT UNTIL i_I2S_ws'event AND i_I2S_ws = '0';

        -- Set the begining of the testbench flag to 1
        tb_start_stimuli <= '1';
        REPORT "Starting the testbench..." SEVERITY NOTE;

        -- Wait forever
        WAIT;
	END PROCESS p_initial_reset;
	
	-- purpose: Simulate the AER interface from the receiver
    -- type   : combinational
    -- inputs : o_out_aer_req
    -- outputs: i_out_aer_ack
    i_AER_ack <= o_AER_req AFTER (c_sys_clock_period * 2);



    -- purpose: Set the signals to generate the stimuli
    -- type   : combinational
    -- inputs : 
    -- outputs: 
	p_stimuli : PROCESS
		-- Variable for storing the readed audio sample
		VARIABLE v_audio_sample : INTEGER := 0;
		-- Variable for storing the readed audio sample in a binary vector
		VARIABLE v_i2s_audio_sample : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	BEGIN

		-- Wait until the start stimuli flag is enabled
		WAIT UNTIL tb_start_stimuli = '1';

		-- Wait until ws clock is 0 for starting with a left sample
		WAIT UNTIL i_I2S_ws = '0';

		-- Wait until falling edge of sck clock to start sending bits
		WAIT UNTIL i_I2S_sck'event AND i_I2S_sck = '0';
		
		-- While there are data in either left or right sample files
		WHILE (NOT endfile(tb_input_left_samples_file)) OR (NOT endfile(tb_input_right_samples_file)) LOOP
			-- Check if it is left or right sample
			IF (i_I2S_ws = '0') THEN
				-- Read value from left sample file
				read(tb_input_left_samples_file, v_audio_sample);
			ELSE
				-- Read value from right sample file
				read(tb_input_right_samples_file, v_audio_sample);
			END IF;

			-- Convert the integer value to std logic vector (32 bits)
			v_i2s_audio_sample(31 DOWNTO 0) := conv_std_logic_vector(v_audio_sample, 32);

			-- For each falling edge of I2S sck clock, transmit a bit
			FOR j IN 31 DOWNTO 0 LOOP
				i_I2S_sd <= v_i2s_audio_sample(j);
				WAIT UNTIL i_I2S_sck'event AND i_I2S_sck = '0';
			END LOOP;

		END LOOP;

		-- When there is no more data in one of those files, the testbench has finished
		tb_end_stimuli <= '1';

		-- Report the end of the simulation
		REPORT "End of the simulation!" SEVERITY NOTE;

		-- Close the sample files
		file_close(tb_input_left_samples_file);
		file_close(tb_input_right_samples_file);

		WAIT;

	END PROCESS p_stimuli;

    -- purpose: Save out the testbench results into a file
    -- type   : combinational
    -- inputs : 
    -- outputs: 
	p_save_results : PROCESS
		-- Line variable for writing out into the textfile
		VARIABLE v_OLINE_AER                 : LINE;
		-- String variable for getting the timestamp
		VARIABLE v_sim_time_str              : STRING(1 TO 30); -- 30 chars should be enough
		VARIABLE v_sim_time_len              : NATURAL;
		-- Events counter
		VARIABLE v_out_events_counter_NAS    : INTEGER := 0;
		VARIABLE v_out_events_counter_SOC    : INTEGER := 0;
		VARIABLE v_out_events_counter_global : INTEGER := 0;
		-- Fields of the AER format for an audio event
		VARIABLE v_event_model_type          : INTEGER := 0;
		VARIABLE v_event_xso_type            : INTEGER := 0;
		VARIABLE v_event_neuron_id           : INTEGER := 0;
		VARIABLE v_event_lr                  : INTEGER := 0;
		VARIABLE v_event_freq_channel        : INTEGER := 0;
		VARIABLE v_event_polarity            : INTEGER := 0;

	BEGIN
		
		-- Loop while the simulation doesn't finish
		WHILE tb_end_stimuli = '0' LOOP
			-- Wait until there is a new AER data
			WAIT UNTIL i_AER_ack = '0';

			-- Increment the global event counter
			v_out_events_counter_global := v_out_events_counter_global + 1;

			-- Take the current simulation time
			v_sim_time_len := TIME'image(now)'length;
			v_sim_time_str := (OTHERS => ' ');
			v_sim_time_str(1 TO v_sim_time_len) := TIME'image(now);
			REPORT "Sim time string.......:'" & v_sim_time_str & "'";

			-- Take the event model type: 0 NAS; 1 SOC
			v_event_model_type := conv_integer(unsigned(o_AER_data(15 DOWNTO 15)));
			REPORT "Event model type: " & INTEGER'image(v_event_model_type);

			-- Take the event model type: 0 MSO; 1 LSO
			v_event_xso_type := conv_integer(unsigned(o_AER_data(14 DOWNTO 14)));
			REPORT "Event xSO type: " & INTEGER'image(v_event_xso_type);

			-- Take the event neurond ID: max 5 bits [0, (2^5) - 1]
			v_event_neuron_id := conv_integer(unsigned(o_AER_data(13 DOWNTO 9)));
			REPORT "Event from neuron ID: " & INTEGER'image(v_event_neuron_id);

			-- Take the event source: 0 left; 1 right
			v_event_lr := conv_integer(unsigned(o_AER_data(8 DOWNTO 8)));
			REPORT "Event source ear: " & INTEGER'image(v_event_lr);

			-- Take the event freq channel ID
			v_event_freq_channel := conv_integer(unsigned(o_AER_data(7 DOWNTO 1)));
			REPORT "Event from freq channel: " & INTEGER'image(v_event_freq_channel);

			-- Take the event polarity
			v_event_polarity := conv_integer(unsigned(o_AER_data(0 DOWNTO 0)));
			REPORT "Event polarity: " & INTEGER'image(v_event_polarity);

			-- Depending on the event model type
			IF (v_event_model_type = 0) THEN
				-- Increase the event counter
				v_out_events_counter_NAS := v_out_events_counter_NAS + 1;
				-- Print output events counter
				REPORT "Output event counter NAS: " & INTEGER'image(v_out_events_counter_NAS);

				-- Writing the event address ( lr + freq_channel + polarity)
				write(v_OLINE_AER, conv_integer(unsigned(o_AER_data(8 DOWNTO 0))), right, 1);
				write(v_OLINE_AER, ',', right, 1);

				-- Writing the timestamp
				write(v_OLINE_AER, v_sim_time_str, right, 1);
				write(v_OLINE_AER, ',', right, 1);
				
				-- Writing the event auditory model
				write(v_OLINE_AER, 0, right, 1);
				write(v_OLINE_AER, ',', right, 1);

				-- Writing the event xso type
				write(v_OLINE_AER, 0, right, 1);
				write(v_OLINE_AER, ',', right, 1);

				-- Writing the event neuron id
				write(v_OLINE_AER, 0, right, 1);

				-- Writing the line into the output text file
				writeline(tb_output_NAS_SOC_aer_events_file, v_OLINE_AER);

			ELSIF (v_event_model_type = 1) THEN
				-- Increase the event counter
				v_out_events_counter_SOC := v_out_events_counter_SOC + 1;
				-- Print output events counter
				REPORT "Output event counter SOC: " & INTEGER'image(v_out_events_counter_SOC);

				-- Writing the event freq channel
				write(v_OLINE_AER, v_event_freq_channel, right, 1);
				write(v_OLINE_AER, ',', right, 1);

				-- Writing the timestamp
				write(v_OLINE_AER, v_sim_time_str, right, 1);
				write(v_OLINE_AER, ',', right, 1);

				-- Writing the event auditory model
				write(v_OLINE_AER, v_event_model_type, right, 1);
				write(v_OLINE_AER, ',', right, 1);

				-- Writing the event xso type
				write(v_OLINE_AER, v_event_xso_type, right, 1);
				write(v_OLINE_AER, ',', right, 1);

				-- Writing the event neuron id
				write(v_OLINE_AER, v_event_neuron_id, right, 1);

				-- Writing the line into the output text file
				writeline(tb_output_NAS_SOC_aer_events_file, v_OLINE_AER);
			ELSE
				-- TODO! For LSO model
			END IF;

		END LOOP;

		-- Close NAS SOC RESULTS file
		file_close(tb_output_NAS_SOC_aer_events_file);

		WAIT;

	END PROCESS p_save_results;

END Behavioral;