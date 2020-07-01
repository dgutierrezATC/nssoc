----------------------------------------------------------------------------------
-- Company: University of Seville
-- Engineer: Daniel Gutierrez-Galan
-- 
-- Create Date: 12.11.2018 16:43:44
-- Design Name: location_neuron_array
-- Module Name: connection_delay - Behavioral
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

ENTITY delay_lines_connection IS
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
END delay_lines_connection;

ARCHITECTURE Behavioral OF delay_lines_connection IS

    --===========================================================================-- 
    --                    Delay line                                             -- 
    --===========================================================================--
    COMPONENT delay_line
        GENERIC (
            TRANSMISSION_TIME : INTEGER := 500; --us
            CLOCK_FREQ : INTEGER := 50000000 --Hz
        );
        PORT (
            i_clock : IN std_logic;
            i_nreset : IN std_logic;
            i_spike_in : IN std_logic;
            o_spike_delayed : OUT std_logic
        );
    END COMPONENT;

    CONSTANT TRANSMISSION_DELAY : INTEGER := (MAX_TIME_DIFF_DETECTION_WINDOW / DELAY_LINES_NUM) + 1; --us

BEGIN
    GEN_DL :
    FOR I IN 0 TO (DELAY_LINES_NUM - 1) GENERATE
        DLX : delay_line
        GENERIC MAP(
            TRANSMISSION_TIME => (TRANSMISSION_DELAY * (I + 1)),
            CLOCK_FREQ => CLOCK_FREQ
        )
        PORT MAP(
            i_clock => i_clock,
            i_nreset => i_nreset,
            i_spike_in => i_spike_in,
            o_spike_delayed => o_spike_delay_lines(I)
        );
    END GENERATE GEN_DL;

END Behavioral;