-------------------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY module_fifo_regs_no_flags_tb IS
END module_fifo_regs_no_flags_tb;

ARCHITECTURE behave OF module_fifo_regs_no_flags_tb IS

    CONSTANT c_DEPTH : INTEGER := 4;
    CONSTANT c_WIDTH : INTEGER := 8;

    SIGNAL r_RESET : std_logic := '0';
    SIGNAL r_CLOCK : std_logic := '0';
    SIGNAL r_WR_EN : std_logic := '0';
    SIGNAL r_WR_DATA : std_logic_vector(c_WIDTH - 1 DOWNTO 0) := X"A5";
    SIGNAL w_FULL : std_logic;
    SIGNAL r_RD_EN : std_logic := '0';
    SIGNAL w_RD_DATA : std_logic_vector(c_WIDTH - 1 DOWNTO 0);
    SIGNAL w_EMPTY : std_logic;

    COMPONENT module_fifo_regs_no_flags IS
        GENERIC (
            g_WIDTH : NATURAL := 8;
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
BEGIN

    MODULE_FIFO_REGS_NO_FLAGS_INST : module_fifo_regs_no_flags
    GENERIC MAP(
        g_WIDTH => c_WIDTH,
        g_DEPTH => c_DEPTH
    )
    PORT MAP(
        i_rst_sync => r_RESET,
        i_clk => r_CLOCK,
        i_wr_en => r_WR_EN,
        i_wr_data => r_WR_DATA,
        o_full => w_FULL,
        i_rd_en => r_RD_EN,
        o_rd_data => w_RD_DATA,
        o_empty => w_EMPTY
    );
    r_CLOCK <= NOT r_CLOCK AFTER 5 ns;

    p_TEST : PROCESS IS
    BEGIN
        WAIT UNTIL r_CLOCK = '1';
        r_WR_EN <= '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        r_WR_EN <= '0';
        r_RD_EN <= '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        r_RD_EN <= '0';
        r_WR_EN <= '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        r_RD_EN <= '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        r_WR_EN <= '0';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';
        WAIT UNTIL r_CLOCK = '1';

    END PROCESS;
END behave;