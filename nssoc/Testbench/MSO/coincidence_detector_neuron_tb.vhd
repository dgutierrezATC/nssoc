----------------------------------------------------------------------------------
-- Company: University of Seville
-- Engineer: Daniel Gutierrez-Galan
-- 
-- Create Date: 10.09.2018 23:43:32
-- Design Name: location_neuron_array
-- Module Name: simple_location_neuron_tb - Behavioral
-- Project Name: SoundSourceLocation (SSL)
-- Target Devices: FPGA ZTEX 2.13
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

ENTITY coincidence_detector_neuron_tb IS
END coincidence_detector_neuron_tb;

ARCHITECTURE Behavioral OF coincidence_detector_neuron_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT coincidence_detector_neuron IS
        GENERIC (
            TEMPORAL_COINCIDENCE_WINDOW : INTEGER := 10; --us
            CLOCK_FREQ : INTEGER := 50000000 --Hz
        ); --In nanoseconds
        PORT (
            i_clock : IN std_logic;
            i_nreset : IN std_logic;
            i_left_spike : IN std_logic;
            i_right_spike : IN std_logic;
            o_coincidence_spike : OUT std_logic);
    END COMPONENT;

    --Constants
    CONSTANT clock_period : TIME := 20 ns;

    --Inputs
    SIGNAL i_clock : std_logic := '0';
    SIGNAL i_nreset : std_logic := '0';
    SIGNAL i_left_spike : std_logic := '0';
    SIGNAL i_right_spike : std_logic := '0';
    --Outputs
    SIGNAL o_coincidence_spike : std_logic;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : coincidence_detector_neuron
    GENERIC MAP(
        TEMPORAL_COINCIDENCE_WINDOW => 10,
        CLOCK_FREQ => 50000000
    )
    PORT MAP(
        i_clock => i_clock,
        i_nreset => i_nreset,
        i_left_spike => i_left_spike,
        i_right_spike => i_right_spike,
        o_coincidence_spike => o_coincidence_spike
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
        --First case: only fire left spike
        --------------------------------------------
        --Fire left spike
        i_left_spike <= '1';
        WAIT FOR clock_period;
        i_left_spike <= '0';
        --Wait
        WAIT FOR clock_period * 11000;

        --------------------------------------------
        --Second case: fire left and right spike in time-interval
        --------------------------------------------	   
        --Fire left spike
        i_left_spike <= '1';
        WAIT FOR clock_period;
        i_left_spike <= '0';
        --Wait
        WAIT FOR clock_period * 5;
        --Fire right spike
        i_right_spike <= '1';
        WAIT FOR clock_period;
        i_right_spike <= '0';
        --Wait
        WAIT FOR clock_period * 1000;

        --------------------------------------------
        --Third case: only fire right spike
        --------------------------------------------
        --Fire right spike
        i_right_spike <= '1';
        WAIT FOR clock_period;
        i_right_spike <= '0';
        --Wait
        WAIT FOR clock_period * 11000;

        --------------------------------------------
        --Fourth case: fire left and right spike at the same moment
        --------------------------------------------	   
        --Fire left spike
        i_left_spike <= '1';
        i_right_spike <= '1';
        WAIT FOR clock_period;
        i_left_spike <= '0';
        i_right_spike <= '0';
        WAIT FOR clock_period;

        --Wait
        WAIT FOR clock_period * 1000;

    END PROCESS;

END Behavioral;