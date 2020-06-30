----------------------------------------------------------------------------------
-- Company: University of Seville
-- Engineer: Daniel Gutierrez-Galan
-- 
-- Create Date: 10.12.2018 15:18:32
-- Design Name: location_neuron_array
-- Module Name: coincidence_counter_tb - Behavioral
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

ENTITY coincidence_counter_tb IS
END coincidence_counter_tb;

ARCHITECTURE Behavioral OF coincidence_counter_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT coincidence_counter IS
        GENERIC (INTEGRATION_PERIOD : INTEGER := 5000000); --In nanoseconds
        PORT (
            i_clock : IN std_logic;
            i_reset : IN std_logic;
            i_spike_in : IN std_logic;
            o_spikes_count : OUT std_logic_vector(7 DOWNTO 0));
    END COMPONENT;

    --Constants
    CONSTANT clock_period : TIME := 20 ns;

    --Inputs
    SIGNAL i_clock : std_logic := '0';
    SIGNAL i_reset : std_logic := '0';
    SIGNAL i_spike_in : std_logic := '0';

    --Outputs
    SIGNAL o_spikes_count : std_logic_vector(7 DOWNTO 0);

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : coincidence_counter
    GENERIC MAP(INTEGRATION_PERIOD => 5000000)
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_spike_in => i_spike_in,
        o_spikes_count => o_spikes_count
    );

    --Clock generation
    i_clock <= NOT i_clock AFTER clock_period/2;
    --Stimulus process
    stim_proc : PROCESS
    BEGIN
        --Start reset
        i_reset <= '0';
        WAIT FOR clock_period * 2;
        i_reset <= '1';
        WAIT FOR 1 ms;
        --Finish reset
        --------------------------------------------
        --First case: only one spike fired
        --------------------------------------------
        --Fire left spike
        i_spike_in <= '1';
        WAIT FOR clock_period;
        i_spike_in <= '0';
        --Wait
        WAIT FOR 10 ms;

        --------------------------------------------
        --Second case: no spikes fired
        --------------------------------------------	   
        --Wait
        WAIT FOR 5 ms;

        --------------------------------------------
        --Third case: several spikes fired
        --------------------------------------------
        --Fire right spike
        i_spike_in <= '1';
        WAIT FOR clock_period;
        i_spike_in <= '0';
        --Wait
        WAIT FOR 1 ms;
        i_spike_in <= '1';
        WAIT FOR clock_period;
        i_spike_in <= '0';
        WAIT FOR 10 ms;

    END PROCESS;

END Behavioral;