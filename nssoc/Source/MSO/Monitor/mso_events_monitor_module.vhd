----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:38:42 06/13/2019 
-- Design Name: 
-- Module Name:    events_monitor_top - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY mso_events_monitor_module IS
    GENERIC (
        NDETECTOR_NEURONS : INTEGER := 16;
        NBITS_NDETECTOR_NEURONS : INTEGER := 4;
        FIFO_DEPTH : INTEGER := 32;
        CHANNEL_VAL : INTEGER := 1
    );
    PORT (
        i_clock : IN STD_LOGIC;
        i_reset : IN STD_LOGIC;
        i_in_mso_spikes : IN STD_LOGIC_VECTOR ((NDETECTOR_NEURONS - 1) DOWNTO 0);
        i_read_aer_event : IN STD_LOGIC;
        o_out_aer_event : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        o_no_aer_events : OUT STD_LOGIC;
        o_full_aer_events : OUT STD_LOGIC
    );
END mso_events_monitor_module;

ARCHITECTURE Behavioral OF mso_events_monitor_module IS

    COMPONENT events_encoder IS
        GENERIC (
            N_EVENTS : INTEGER := 16;
            NBITS_ADDRESS : INTEGER := 4
        );
        PORT (
            i_clock : IN STD_LOGIC;
            i_reset : IN STD_LOGIC;
            i_in_events : IN STD_LOGIC_VECTOR ((N_EVENTS - 1) DOWNTO 0);
            o_out_address : OUT STD_LOGIC_VECTOR ((NBITS_ADDRESS - 1) DOWNTO 0);
            o_new_out_address : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT module_fifo_regs_no_flags IS
        GENERIC (
            g_WIDTH : NATURAL := 16;
            g_DEPTH : INTEGER := 32
        );
        PORT (
            i_rst_sync : IN std_logic;
            i_clk : IN std_logic;
            -- FIFO Write Interface
            i_wr_en : IN std_logic;
            i_wr_data : IN std_logic_vector(g_WIDTH - 1 DOWNTO 0);
            o_full : OUT std_logic;
            -- FIFO Read Interface
            i_rd_en : IN std_logic;
            o_rd_data : OUT std_logic_vector(g_WIDTH - 1 DOWNTO 0);
            o_empty : OUT std_logic
        );
    END COMPONENT module_fifo_regs_no_flags;

    COMPONENT events_mask IS
        GENERIC (
            NBITS_ADDRESS : INTEGER := 4;
            CHANNEL_VAL : INTEGER := 1
        );
        PORT (
            i_input_address : IN STD_LOGIC_VECTOR ((NBITS_ADDRESS - 1) DOWNTO 0);
            o_output_masked_aer : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL ec_output_address : std_logic_vector(3 DOWNTO 0);
    SIGNAL ec_new_output_address : std_logic;

    SIGNAL em_aer_data : std_logic_vector(3 DOWNTO 0);

BEGIN
    -----------------------------------------------------------------
    -- Events Encoders
    -----------------------------------------------------------------
    U_encoder : events_encoder
    GENERIC MAP(
        N_EVENTS => NDETECTOR_NEURONS,
        NBITS_ADDRESS => NBITS_NDETECTOR_NEURONS
    )
    PORT MAP(
        i_clock => i_clock,
        i_reset => i_reset,
        i_in_events => i_in_mso_spikes,
        o_out_address => ec_output_address,
        o_new_out_address => ec_new_output_address
    );

    -----------------------------------------------------------------
    -- FIFO memory
    -----------------------------------------------------------------
    MODULE_FIFO_REGS_NO_FLAGS_INST : module_fifo_regs_no_flags
    GENERIC MAP(
        g_WIDTH => NBITS_NDETECTOR_NEURONS,
        g_DEPTH => FIFO_DEPTH
    )
    PORT MAP(
        i_rst_sync => i_reset,
        i_clk => i_clock,
        -- FIFO Write Interface
        i_wr_en => ec_new_output_address,
        i_wr_data => ec_output_address,
        o_full => o_full_aer_events,
        -- FIFO Read Interface
        i_rd_en => i_read_aer_event,
        o_rd_data => em_aer_data,
        o_empty => o_no_aer_events
    );

    -----------------------------------------------------------------
    -- Events masks
    -----------------------------------------------------------------

    U_mask : events_mask
    GENERIC MAP(
        NBITS_ADDRESS => NBITS_NDETECTOR_NEURONS,
        CHANNEL_VAL => CHANNEL_VAL
    )
    PORT MAP(
        i_input_address => em_aer_data,
        o_output_masked_aer => o_out_aer_event
    );

END Behavioral;