-------------------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
--
-- Description: Creates a Synchronous FIFO made out of registers.
--              Generic: g_WIDTH sets the width of the FIFO created.
--              Generic: g_DEPTH sets the depth of the FIFO created.
--
--              Total FIFO register usage will be width * depth
--              Note that this fifo should not be used to cross clock domains.
--              (Read and write clocks NEED TO BE the same clock domain)
--
--              FIFO Full Flag will assert as soon as last word is written.
--              FIFO Empty Flag will assert as soon as last word is read.
--
--              FIFO is 100% synthesizable.  It uses assert statements which do
--              not synthesize, but will cause your simulation to crash if you
--              are doing something you shouldn't be doing (reading from an
--              empty FIFO or writing to a full FIFO).
--
--              No Flags = No Almost Full (AF)/Almost Empty (AE) Flags
--              There is a separate module that has programmable AF/AE flags.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY module_fifo_regs_no_flags IS
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
END module_fifo_regs_no_flags;

ARCHITECTURE rtl OF module_fifo_regs_no_flags IS

    TYPE t_FIFO_DATA IS ARRAY (0 TO g_DEPTH - 1) OF std_logic_vector(g_WIDTH - 1 DOWNTO 0);
    SIGNAL r_FIFO_DATA : t_FIFO_DATA := (OTHERS => (OTHERS => '0'));

    SIGNAL r_WR_INDEX : INTEGER RANGE 0 TO g_DEPTH - 1 := 0;
    SIGNAL r_RD_INDEX : INTEGER RANGE 0 TO g_DEPTH - 1 := 0;

    -- # Words in FIFO, has extra range to allow for assert conditions
    SIGNAL r_FIFO_COUNT : INTEGER RANGE -1 TO g_DEPTH + 1 := 0;

    SIGNAL w_FULL : std_logic;
    SIGNAL w_EMPTY : std_logic;

BEGIN

    p_CONTROL : PROCESS (i_clk) IS
    BEGIN
        IF rising_edge(i_clk) THEN
            IF i_rst_sync = '0' THEN
                r_FIFO_COUNT <= 0;
                r_WR_INDEX <= 0;
                r_RD_INDEX <= 0;
            ELSE

                -- Keeps track of the total number of words in the FIFO
                IF (i_wr_en = '1' AND i_rd_en = '0') THEN
                    r_FIFO_COUNT <= r_FIFO_COUNT + 1;
                ELSIF (i_wr_en = '0' AND i_rd_en = '1') THEN
                    r_FIFO_COUNT <= r_FIFO_COUNT - 1;
                END IF;

                -- Keeps track of the write index (and controls roll-over)
                IF (i_wr_en = '1' AND w_FULL = '0') THEN
                    IF r_WR_INDEX = g_DEPTH - 1 THEN
                        r_WR_INDEX <= 0;
                    ELSE
                        r_WR_INDEX <= r_WR_INDEX + 1;
                    END IF;
                END IF;

                -- Keeps track of the read index (and controls roll-over)        
                IF (i_rd_en = '1' AND w_EMPTY = '0') THEN
                    IF r_RD_INDEX = g_DEPTH - 1 THEN
                        r_RD_INDEX <= 0;
                    ELSE
                        r_RD_INDEX <= r_RD_INDEX + 1;
                    END IF;
                END IF;

                -- Registers the input data when there is a write
                IF i_wr_en = '1' THEN
                    r_FIFO_DATA(r_WR_INDEX) <= i_wr_data;
                END IF;

            END IF; -- sync reset
        END IF; -- rising_edge(i_clk)
    END PROCESS p_CONTROL;

    -- p_OUT : PROCESS(i_clk)
    -- BEGIN
        -- IF rising_edge(i_clk) THEN
            -- IF i_rst_sync = '0' THEN
                -- o_rd_data <= (OTHERS => '0');
            -- ELSE
                -- IF i_rd_en = '1' THEN
                    -- o_rd_data <= r_FIFO_DATA(r_RD_INDEX);
                -- ELSE
                
                -- END IF;
            -- END IF;
        -- ELSE
        
        -- END IF;
    -- END PROCESS p_OUT;
    
    
    o_rd_data <= r_FIFO_DATA(r_RD_INDEX);

    w_FULL <= '1' WHEN r_FIFO_COUNT = g_DEPTH ELSE
        '0';
    w_EMPTY <= '1' WHEN r_FIFO_COUNT = 0 ELSE
        '0';

    o_full <= w_FULL;
    o_empty <= w_EMPTY;

    -- ASSERTION LOGIC - Not synthesized
    -- synthesis translate_off

    p_ASSERT : PROCESS (i_clk) IS
    BEGIN
        IF rising_edge(i_clk) THEN
            IF i_wr_en = '1' AND w_FULL = '1' THEN
                REPORT "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS FULL AND BEING WRITTEN " SEVERITY failure;
            END IF;

            IF i_rd_en = '1' AND w_EMPTY = '1' THEN
                REPORT "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS EMPTY AND BEING READ " SEVERITY failure;
            END IF;
        END IF;
    END PROCESS p_ASSERT;

    -- synthesis translate_on
END rtl;