----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.1.2018 15:24:47
-- Design Name: 
-- Module Name: coincidence_detector_neuron_array - Behavioral
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
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
ENTITY coincidence_detector_neuron_array IS
    GENERIC (
        COINCIDENCE_DETECTOR_NUM : INTEGER := 32;
        MAX_TIME_DIFF_DETECTION_WINDOW : INTEGER := 700;
        TIME_DETECTION_OVERLAP : INTEGER := 1;
        CLOCK_FREQ : INTEGER := 50000000
    );
    PORT (
        i_clock : IN std_logic;
        i_nreset : IN std_logic;
        i_left_spike_stream : IN std_logic_vector((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
        i_right_spike_stream : IN std_logic_vector((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0);
        o_neurons_coincidence : OUT std_logic_vector((COINCIDENCE_DETECTOR_NUM - 1) DOWNTO 0)
    );
END coincidence_detector_neuron_array;

ARCHITECTURE Behavioral OF coincidence_detector_neuron_array IS

    --Simple coincidence detector neuron component
    COMPONENT coincidence_detector_neuron
        GENERIC (
            TEMPORAL_COINCIDENCE_WINDOW : INTEGER := 100; --us
            CLOCK_FREQ : INTEGER := 50000000 --Hz
        );
        PORT (
            i_clock : IN std_logic;
            i_nreset : IN std_logic;
            i_left_spike : IN std_logic;
            i_right_spike : IN std_logic;
            o_coincidence_spike : OUT std_logic
        );
    END COMPONENT;

    CONSTANT COINCIDENCE_DETECTION_TIME : INTEGER := (MAX_TIME_DIFF_DETECTION_WINDOW / COINCIDENCE_DETECTOR_NUM) + 1 + TIME_DETECTION_OVERLAP; --us

BEGIN

    GEN_CD :
    FOR I IN 0 TO (COINCIDENCE_DETECTOR_NUM - 1) GENERATE
        CDNX : coincidence_detector_neuron
        GENERIC MAP(
            TEMPORAL_COINCIDENCE_WINDOW => COINCIDENCE_DETECTION_TIME,
            CLOCK_FREQ => CLOCK_FREQ
        )
        PORT MAP(
            i_clock => i_clock,
            i_nreset => i_nreset,
            i_left_spike => i_left_spike_stream(I),
            i_right_spike => i_right_spike_stream((COINCIDENCE_DETECTOR_NUM - 1) - I),
            o_coincidence_spike => o_neurons_coincidence(I)
        );
    END GENERATE GEN_CD;

END Behavioral;