----------------------------------------------------------------------------------
-- Company: University of Seville
-- Engineer: Daniel Gutierrez-Galan
-- 
-- Create Date: 12.11.2018 17:17:32
-- Design Name: connection_delay
-- Module Name: connection_delay_tb - Behavioral
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

ENTITY delay_lines_connection_tb IS
END delay_lines_connection_tb;

ARCHITECTURE Behavioral OF delay_lines_connection_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT delay_lines_connection IS
        GENERIC (
            DELAY_LINES_NUM : INTEGER := 32;
            MAX_TIME_DIFF_DETECTION_WINDOW : INTEGER := 700; --us
            CLOCK_FREQ : INTEGER := 50000000
        );
        PORT (
            i_clock : IN std_logic;
            i_nreset : IN std_logic;
            i_spike_in : IN std_logic;
            o_spike_delay_lines : OUT std_logic_vector((DELAY_LINES_NUM - 1) DOWNTO 0)
        );
    END COMPONENT;

    --Constants
    CONSTANT clock_period : TIME := 20 ns;

    --Inputs
    SIGNAL i_clock : std_logic := '0';
    SIGNAL i_nreset : std_logic := '0';
    SIGNAL i_spike_in : std_logic := '0';
    --Outputs
    SIGNAL o_spike_delay_lines : std_logic_vector(4 DOWNTO 0);

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : delay_lines_connection
    GENERIC MAP(
        DELAY_LINES_NUM => 5,
        MAX_TIME_DIFF_DETECTION_WINDOW => 700,
        CLOCK_FREQ => 50000000
    )
    PORT MAP(
        i_clock => i_clock,
        i_nreset => i_nreset,
        i_spike_in => i_spike_in,
        o_spike_delay_lines => o_spike_delay_lines
    );

    --Clock generation
    i_clock <= NOT i_clock AFTER clock_period/2;

    --Stimulus process
    stim_proc : PROCESS
    BEGIN
        --Start reset
        i_nreset <= '0';
        WAIT FOR 1 ms;
        i_nreset <= '1';
        WAIT FOR 1 ms;
        --Finish reset

        --------------------------------------------
        --First case: single spike
        --------------------------------------------
        --Fire left spike
        i_spike_in <= '1';
        WAIT FOR clock_period;
        i_spike_in <= '0';
        --Wait
        WAIT FOR 10 ms;

    END PROCESS;

END Behavioral;