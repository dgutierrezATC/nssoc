----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:39:08 27/12/2019
-- Design Name: 
-- Module Name:    frequency_detector - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY frequency_detector is
    PORT (
        i_clock : IN STD_LOGIC;
        i_reset : IN STD_LOGIC;
        i_freq_div_iandg : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        i_freq_div_sgen : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_max_freq_detect : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
        i_conf_sgen : IN STD_LOGIC;
        i_input_pos_spike : IN STD_LOGIC;
        i_input_neg_spike : IN STD_LOGIC;
        o_output_spike : OUT STD_LOGIC
    );
END frequency_detector;

ARCHITECTURE Behavioral OF frequency_detector is

    SIGNAL r_n_i_reset : STD_LOGIC;

    SIGNAL w_input_spike : STD_LOGIC;

    SIGNAL w_iandg_pos_out_spike : STD_LOGIC;
    SIGNAL w_iandg_neg_out_spike : STD_LOGIC;

    SIGNAL w_sgen_pos_out_spike : STD_LOGIC;
    SIGNAL w_sgen_neg_out_spike : STD_LOGIC;
    SIGNAL w_sgen_out_spikes : STD_LOGIC;


    COMPONENT Spike_Int_n_Gen_BW IS
        GENERIC (
            GL          : INTEGER := 12; 
            SAT         : INTEGER := 2047
        );
        PORT ( 
            clk         : in  STD_LOGIC;
            rst         : in  STD_LOGIC;
            freq_div    : in  STD_LOGIC_VECTOR(7 downto 0);
            spike_in_p  : in  STD_LOGIC;
            spike_in_n  : in  STD_LOGIC;
            spike_out_p : out STD_LOGIC;
            spike_out_n : out STD_LOGIC
        );
    END COMPONENT;

    COMPONENT AER_DIF IS
        PORT ( 
            CLK          : in  STD_LOGIC;
            RST          : in  STD_LOGIC;
            SPIKES_IN_UP : in  STD_LOGIC;
            SPIKES_IN_UN : in  STD_LOGIC;
            SPIKES_IN_YP : in  STD_LOGIC;
            SPIKES_IN_YN : in  STD_LOGIC;
            SPIKES_OUT_P : out STD_LOGIC;
            SPIKES_OUT_N : out STD_LOGIC
        );
    END COMPONENT;

    COMPONENT Spikes_Gen_signed_BW IS
        GENERIC (
            GL : in INTEGER := 10
        );
        PORT ( 
            CLK      : in  STD_LOGIC;
            RST      : in  STD_LOGIC;
            FREQ_DIV : in  STD_LOGIC_VECTOR(15 downto 0);
            DATA_IN  : in  STD_LOGIC_VECTOR((GL-1) downto 0);
            WR       : in  STD_LOGIC;
            SPIKE_P  : out STD_LOGIC;
            SPIKE_N  : out STD_LOGIC
        );
    END COMPONENT;

BEGIN

    r_n_i_reset <= NOT i_reset;

    w_input_spike <= i_input_pos_spike XOR i_input_neg_spike;
    U_integrate_and_generate : Spike_Int_n_Gen_BW
        GENERIC MAP (
            GL => 4,
            SAT => 8
        )
        PORT MAP (
            clk => i_clock,
            rst => i_reset,
            freq_div => i_freq_div_iandg,
            spike_in_p => w_input_spike,
            spike_in_n => w_sgen_out_spikes,
            spike_out_p => w_iandg_pos_out_spike,
            spike_out_n => w_iandg_neg_out_spike
        );

    U_aer_diff : AER_DIF
        PORT ( 
            CLK => i_clock,
            RST => r_n_i_reset,
            SPIKES_IN_UP => ,
            SPIKES_IN_UN => ,
            SPIKES_IN_YP => ,
            SPIKES_IN_YN => ,
            SPIKES_OUT_P => ,
            SPIKES_OUT_N => 
        );

    w_sgen_out_spikes <= w_sgen_pos_out_spike XOR w_sgen_neg_out_spike;
    U_sgen : Spikes_Gen_signed_BW
        GENERIC MAP (
            GL => 17
        )
        PORT MAP ( 
            CLK => i_clock,
            RST => i_reset,
            FREQ_DIV => i_freq_div_sgen,
            DATA_IN => i_max_freq_detect,
            WR => i_conf_sgen,
            SPIKE_P => w_sgen_pos_out_spike,
            SPIKE_N => w_sgen_neg_out_spike
        );

END Behavioral;