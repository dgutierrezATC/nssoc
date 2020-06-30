----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.04.2019 13:26:44
-- Design Name: 
-- Module Name: LSO - Behavioral
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

ENTITY LSO IS
    GENERIC (
        NUM_FREQ_CH : INTEGER := 14
    );
    PORT (
        i_clock : IN std_logic;
        i_reset : IN std_logic;
        i_left_avcn_spikes : IN std_logic_vector(((NUM_FREQ_CH * 2) - 1) DOWNTO 0);
        i_right_avcn_spikes : IN std_logic_vector(((NUM_FREQ_CH * 2) - 1) DOWNTO 0);
        o_ild_out_spikes : OUT std_logic_vector(((NUM_FREQ_CH * 2) - 1) DOWNTO 0)
    );
END LSO;

ARCHITECTURE Behavioral OF LSO IS

    --====================================================--
    -- Level difference estimator
    --====================================================--

    COMPONENT ild_estimator IS
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            SPIKES_IN_UP : IN STD_LOGIC;
            SPIKES_IN_UN : IN STD_LOGIC;
            SPIKES_IN_YP : IN STD_LOGIC;
            SPIKES_IN_YN : IN STD_LOGIC;
            SPIKES_OUT_P : OUT STD_LOGIC;
            SPIKES_OUT_N : OUT STD_LOGIC
        );
    END COMPONENT;
    --====================================================--
    -- Constants
    --====================================================--

    --====================================================--
    -- Signals
    --====================================================--

BEGIN

    --====================================================--
    -- 
    --====================================================--
    GEN_ILD :
    FOR I IN 0 TO (NUM_FREQ_CH - 1) GENERATE
        ILDX : ild_estimator
        PORT MAP(
            CLK => i_clock,
            RST => i_reset,
            SPIKES_IN_UP => i_left_avcn_spikes(I * 2),
            SPIKES_IN_UN => i_left_avcn_spikes((I * 2) + 1),
            SPIKES_IN_YP => i_right_avcn_spikes(I * 2),
            SPIKES_IN_YN => i_right_avcn_spikes((I * 2) + 1),
            SPIKES_OUT_P => o_ild_out_spikes(I * 2),
            SPIKES_OUT_N => o_ild_out_spikes((I * 2) + 1)
        );
    END GENERATE GEN_ILD;

END Behavioral;