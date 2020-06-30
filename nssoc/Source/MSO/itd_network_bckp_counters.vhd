----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2018 16:08:18
-- Design Name: 
-- Module Name: itd_network - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY itd_network IS
    GENERIC (
        NUM_NEURONS : INTEGER := 5
    );
    PORT (
        i_clock : IN std_logic;
        i_reset : IN std_logic;
        i_left_ch_spike : IN std_logic;
        i_right_ch_spike : IN std_logic;
        o_sound_source_position_0 : OUT std_logic_vector(7 DOWNTO 0);
        o_sound_source_position_1 : OUT std_logic_vector(7 DOWNTO 0);
        o_sound_source_position_2 : OUT std_logic_vector(7 DOWNTO 0);
        o_sound_source_position_3 : OUT std_logic_vector(7 DOWNTO 0);
        o_sound_source_position_4 : OUT std_logic_vector(7 DOWNTO 0)
    );
END itd_network;

ARCHITECTURE Behavioral OF itd_network IS

    --====================================================--
    -- Delay-lines
    --====================================================--
    COMPONENT delay_lines_connection
        GENERIC (
            DELAY_LINES_NUM : INTEGER := 5
        );
        PORT (
            i_clock : IN std_logic;
            i_reset : IN std_logic;
            i_spike_in : IN std_logic;
            o_spike_delay_lines : OUT std_logic_vector((DELAY_LINES_NUM - 1) DOWNTO 0)
        );
    END COMPONENT;

    --====================================================--
    -- Coincidence detectors array
    --====================================================--
    COMPONENT coincidence_detector_neuron_array
        GENERIC (
            COINCIDENCE_DETECTOR_NUM : INTEGER := 5
        );
        PORT (
            i_clock : IN std_logic;
            i_reset : IN std_logic;
            i_left_spike_stream : IN std_logic_vector((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
            i_right_spike_stream : IN std_logic_vector((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
            o_neurons_coincidence : OUT std_logic_vector((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0)
        );
    END COMPONENT;

    --====================================================--
    -- Coincidence counters
    --====================================================--
    COMPONENT coincidence_counter_array
        GENERIC (
            COINCIDENCE_COUNTER_NUM : INTEGER := 5
        );
        PORT (
            i_clock : IN STD_LOGIC;
            i_reset : IN STD_LOGIC;
            i_coincidence_detectors_spikes : IN std_logic_vector((COINCIDENCE_COUNTER_NUM - 1) DOWNTO 0);
            o_coincidence_counter0_val : OUT std_logic_vector(7 DOWNTO 0);
            o_coincidence_counter1_val : OUT std_logic_vector(7 DOWNTO 0);
            o_coincidence_counter2_val : OUT std_logic_vector(7 DOWNTO 0);
            o_coincidence_counter3_val : OUT std_logic_vector(7 DOWNTO 0);
            o_coincidence_counter4_val : OUT std_logic_vector(7 DOWNTO 0)
        );
    END COMPONENT;

    --====================================================--
    -- Constants
    --====================================================--

    --====================================================--
    -- Signals
    --====================================================--

    SIGNAL dl_left_delayed_spikes : std_logic_vector((NUM_NEURONS - 1) DOWNTO 0);
    SIGNAL dl_right_delayed_spikes : std_logic_vector((NUM_NEURONS - 1) DOWNTO 0);
    SIGNAL cd_out_spikes : std_logic_vector((NUM_NEURONS - 1) DOWNTO 0);

BEGIN

    --====================================================--
    -- Delay-lines from left AVCN
    --====================================================--
    DL_left : delay_lines_connection
    GENERIC MAP(
        DELAY_LINES_NUM => NUM_NEURONS
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_spike_in => i_left_ch_spike,
        o_spike_delay_lines => dl_left_delayed_spikes
    );

    --====================================================--
    -- Delay-lines from right AVCN
    --====================================================--
    DL_right : delay_lines_connection
    GENERIC MAP(
        DELAY_LINES_NUM => NUM_NEURONS
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_spike_in => i_right_ch_spike,
        o_spike_delay_lines => dl_right_delayed_spikes
    );

    --====================================================--
    -- Coincidence detectors
    --====================================================--
    CDN_array : coincidence_detector_neuron_array
    GENERIC MAP(
        COINCIDENCE_DETECTOR_NUM => NUM_NEURONS
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_left_spike_stream => dl_left_delayed_spikes,
        i_right_spike_stream => dl_right_delayed_spikes,
        o_neurons_coincidence => cd_out_spikes
    );

    --====================================================--
    -- Coincidence counters
    --====================================================--
    CC_array : coincidence_counter_array
    GENERIC MAP(
        COINCIDENCE_COUNTER_NUM => NUM_NEURONS
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_coincidence_detectors_spikes => cd_out_spikes,
        o_coincidence_counter0_val => o_sound_source_position_0,
        o_coincidence_counter1_val => o_sound_source_position_1,
        o_coincidence_counter2_val => o_sound_source_position_2,
        o_coincidence_counter3_val => o_sound_source_position_3,
        o_coincidence_counter4_val => o_sound_source_position_4
    );

END Behavioral;