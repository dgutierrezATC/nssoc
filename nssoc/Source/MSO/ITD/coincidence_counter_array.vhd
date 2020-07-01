----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.12.2018 15:44:21
-- Design Name: 
-- Module Name: coincidence_counter_array - Behavioral
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

ENTITY coincidence_counter_array IS
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
END coincidence_counter_array;

ARCHITECTURE Behavioral OF coincidence_counter_array IS

    --===========================================================================-- 
    --                    Coincidence counter                                             -- 
    --===========================================================================--
    COMPONENT coincidence_counter
        GENERIC (
            INTEGRATION_PERIOD : INTEGER := 5000000
        );
        PORT (
            i_clock : IN STD_LOGIC;
            i_reset : IN STD_LOGIC;
            i_spike_in : IN STD_LOGIC;
            o_spikes_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    --===========================================================================-- 
    --                    Coincidence counter                                             -- 
    --===========================================================================--
    CC_neuron0 : coincidence_counter
    GENERIC MAP(
        INTEGRATION_PERIOD => 10000000
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_spike_in => i_coincidence_detectors_spikes(0),
        o_spikes_count => o_coincidence_counter0_val
    );

    --===========================================================================-- 
    --                    Coincidence counter                                             -- 
    --===========================================================================--
    CC_neuron1 : coincidence_counter
    GENERIC MAP(
        INTEGRATION_PERIOD => 10000000
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_spike_in => i_coincidence_detectors_spikes(1),
        o_spikes_count => o_coincidence_counter1_val
    );

    --===========================================================================-- 
    --                    Coincidence counter                                             -- 
    --===========================================================================--
    CC_neuron2 : coincidence_counter
    GENERIC MAP(
        INTEGRATION_PERIOD => 10000000
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_spike_in => i_coincidence_detectors_spikes(2),
        o_spikes_count => o_coincidence_counter2_val
    );

    --===========================================================================-- 
    --                    Coincidence counter                                             -- 
    --===========================================================================--
    CC_neuron3 : coincidence_counter
    GENERIC MAP(
        INTEGRATION_PERIOD => 10000000
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_spike_in => i_coincidence_detectors_spikes(3),
        o_spikes_count => o_coincidence_counter3_val
    );

    --===========================================================================-- 
    --                    Coincidence counter                                             -- 
    --===========================================================================--
    CC_neuron4 : coincidence_counter
    GENERIC MAP(
        INTEGRATION_PERIOD => 10000000
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_spike_in => i_coincidence_detectors_spikes(4),
        o_spikes_count => o_coincidence_counter4_val
    );

END Behavioral;