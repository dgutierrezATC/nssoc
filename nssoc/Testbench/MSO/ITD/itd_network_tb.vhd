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

ENTITY itd_network_tb IS
END itd_network_tb;

ARCHITECTURE Behavioral OF itd_network_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT itd_network IS
        GENERIC (
            NUM_NEURONS : INTEGER := 32;
            MAX_DETECTION_TIME : INTEGER := 700;
            DETECTION_OVERLAP : INTEGER := 1;
            CLOCK_FREQ : INTEGER := 50000000
        );
        PORT (
            i_clock : IN std_logic;
            i_nreset : IN std_logic;
            i_left_ch_spike : IN std_logic;
            i_right_ch_spike : IN std_logic;
            o_sound_source_position : OUT std_logic_vector((NUM_NEURONS - 1) DOWNTO 0)
        );
    END COMPONENT;

    --Constants
    CONSTANT clock_period : TIME := 20 ns;

    --Inputs
    SIGNAL i_clock : std_logic := '0';
    SIGNAL i_nreset : std_logic := '0';
    SIGNAL i_left_ch_spike : std_logic := '0';
    SIGNAL i_right_ch_spike : std_logic := '0';
    --Outputs
    SIGNAL o_sound_source_position : std_logic_vector(15 DOWNTO 0);

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : itd_network
    GENERIC MAP(
        NUM_NEURONS => 16,
        MAX_DETECTION_TIME => 700,
        DETECTION_OVERLAP => 1,
        CLOCK_FREQ => 50000000
    )
    PORT MAP(
        i_clock => i_clock,
        i_nreset => i_nreset,
        i_left_ch_spike => i_left_ch_spike,
        i_right_ch_spike => i_right_ch_spike,
        o_sound_source_position => o_sound_source_position
    );

    --Clock generation
    i_clock <= NOT i_clock AFTER clock_period/2;
    --    --=======================================================--
    --    --Simple tb
    --    --=======================================================--
    --    --Stimulus process
    --    stim_proc: process
    --	begin
    --	   --Start reset
    --	   i_nreset <= '0';
    --	   wait for clock_period*2;
    --	   i_nreset <= '1';
    --	   wait for clock_period*2;
    --	   --Finish reset

    --	   --------------------------------------------
    --	   --First case: single spike
    --	   --------------------------------------------
    --	   --Fire left spike
    --	   i_left_ch_spike <= '1';
    --	   wait for clock_period;
    --	   i_left_ch_spike <= '0';
    --	   --Wait a few nanoseconds
    --	   wait for 100 ns;
    --	   --Fire right spike
    --	   i_right_ch_spike <= '1';
    --	   wait for clock_period;
    --	   i_right_ch_spike <= '0';
    --	   --Wait
    --	   wait for clock_period*10000;

    --    end process;

    --    --=======================================================--
    --    --End Simple tb
    --    --=======================================================--
    --    --=======================================================--
    --    --Complex tb
    --    --=======================================================--

    --Reset process
    reset_proc : PROCESS
    BEGIN
        --Start reset
        i_nreset <= '0';
        WAIT FOR clock_period;
        i_nreset <= '1';
        WAIT;
        --Finish reset
    END PROCESS;

    --Spikes generator	
    spikes_gen : PROCESS
        VARIABLE t_del : TIME := 710 us;
    BEGIN
        WAIT UNTIL i_nreset = '1';

        WAIT FOR 1 ms;

        WHILE (t_del >= 1 us) LOOP
            i_right_ch_spike <= '1';
            WAIT FOR clock_period;
            i_right_ch_spike <= '0';
            WAIT FOR t_del;
            i_left_ch_spike <= '1';
            WAIT FOR clock_period;
            i_left_ch_spike <= '0';
            WAIT FOR 10 us;
            t_del := t_del - 5 us;
            WAIT FOR 1 ms;
        END LOOP;

        t_del := 1 us;

        WHILE (t_del <= 700 us) LOOP
            i_left_ch_spike <= '1';
            WAIT FOR clock_period;
            i_left_ch_spike <= '0';
            WAIT FOR t_del;
            i_right_ch_spike <= '1';
            WAIT FOR clock_period;
            i_right_ch_spike <= '0';
            WAIT FOR 10 us;
            t_del := t_del + 5 us;
            WAIT FOR 1 ms;
        END LOOP;
    END PROCESS;

    --    --=======================================================--
    --    --End Complex tb
    --    --=======================================================--

END Behavioral;