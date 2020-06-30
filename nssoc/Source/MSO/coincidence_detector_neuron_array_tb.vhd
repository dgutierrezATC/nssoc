----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.09.2018 11:13:57
-- Design Name: 
-- Module Name: location_neuron_array_tb - Behavioral
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

USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY coincidence_detector_neuron_array_tb IS
END coincidence_detector_neuron_array_tb;

ARCHITECTURE Behavioral OF coincidence_detector_neuron_array_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT coincidence_detector_neuron_array IS
        GENERIC (
            COINCIDENCE_DETECTOR_NUM : INTEGER := 32;
            MAX_TIME_DIFF_DETECTION_WINDOW : INTEGER := 700;
            TIME_DETECTION_OVERLAP : INTEGER := 1;
            CLOCK_FREQ : INTEGER := 50000000
        );
        PORT (
            i_clock : IN std_logic;
            i_nreset : IN std_logic;
            i_left_spike_stream : IN std_logic_vector(4 DOWNTO 0);
            i_right_spike_stream : IN std_logic_vector(4 DOWNTO 0);
            o_neurons_coincidence : OUT std_logic_vector(4 DOWNTO 0)
        );
    END COMPONENT;

    --Constants
    CONSTANT clock_period : TIME := 20 ns;

    CONSTANT delay_next_spike : TIME := 1ms;
    --signal phase_delay : time := 250 ns;

    --Inputs
    SIGNAL i_clock : std_logic := '0';
    SIGNAL i_nreset : std_logic := '0';
    SIGNAL i_left_spike_stream : std_logic_vector(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL i_right_spike_stream : std_logic_vector(4 DOWNTO 0) := (OTHERS => '0');
    --Outputs
    SIGNAL o_neurons_coincidence : std_logic_vector(4 DOWNTO 0);

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : coincidence_detector_neuron_array
    GENERIC MAP(
        COINCIDENCE_DETECTOR_NUM => 5,
        MAX_TIME_DIFF_DETECTION_WINDOW => 700,
        TIME_DETECTION_OVERLAP => 1,
        CLOCK_FREQ => 50000000
    )
    PORT MAP(
        i_clock => i_clock,
        i_nreset => i_nreset,
        i_left_spike_stream => i_left_spike_stream,
        i_right_spike_stream => i_right_spike_stream,
        o_neurons_coincidence => o_neurons_coincidence
    );

    --Clock generation
    i_clock <= NOT i_clock AFTER clock_period/2;

    --Stimulus process
    stim_proc : PROCESS
    BEGIN
        --Start reset
        i_nreset <= '0';
        WAIT FOR clock_period;
        i_nreset <= '1';
        WAIT FOR 1 ms;
        --Finish reset

        --------------------------------------------
        --First case: single spike
        --------------------------------------------
        --Fire left spike
        i_left_spike_stream <= "00100";
        WAIT FOR clock_period;
        i_left_spike_stream <= "00000";
        --Wait a few nanoseconds
        WAIT FOR 500 ns;
        --Fire right spike
        i_right_spike_stream <= "00100";
        WAIT FOR clock_period;
        i_right_spike_stream <= "00000";
        --Wait
        WAIT FOR clock_period * 10000;

    END PROCESS;

END Behavioral;