----------------------------------------------------------------------------------
-- Company: University of Seville
-- Engineer: Daniel Gutierrez-Galan
-- 
-- Create Date: 10.09.2018 21:23:12
-- Design Name: location_neuron_array
-- Module Name: simple_location_neuron - Behavioral
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

ENTITY delay_line IS
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

END delay_line;

ARCHITECTURE Behavioral OF delay_line IS

    --=================================
    -- FSM states and signals
    --=================================
    TYPE state IS (state_idle, state_hold, state_fire);
    SIGNAL current_state, next_state : state;
    -----------------------------------

    --=================================
    -- Internal timer
    --=================================
    CONSTANT delay_val : INTEGER := TRANSMISSION_TIME * (CLOCK_FREQ / 1000000);

    SIGNAL delay_timer_timeout : std_logic;
    SIGNAL delay_timer_enable : std_logic;
    SIGNAL delay_timer_val : INTEGER RANGE 0 TO delay_val;
    -----------------------------------

    --=================================
    -- Spike out
    --=================================

    -----------------------------------

BEGIN

    ----------------FSM update state----------------
    FSM_clocked : PROCESS (i_nreset, i_clock)
    BEGIN
        IF i_nreset = '0' THEN
            current_state <= state_idle;
        ELSIF rising_edge(i_clock) THEN
            current_state <= next_state;
        END IF;
    END PROCESS FSM_clocked;

    ----------------FSM states transition----------------
    FSM_transition : PROCESS (current_state, i_spike_in, delay_timer_timeout)

    BEGIN
        next_state <= current_state;

        CASE current_state IS

            WHEN state_idle =>
                delay_timer_enable <= '0';

                IF i_spike_in = '1' THEN
                    next_state <= state_hold;
                ELSE
                    next_state <= state_idle;
                END IF;

            WHEN state_hold =>
                delay_timer_enable <= '1';

                IF delay_timer_timeout = '1' THEN
                    next_state <= state_fire;
                ELSE
                    next_state <= state_hold;
                END IF;

            WHEN state_fire =>
                delay_timer_enable <= '0';
                next_state <= state_idle;

            WHEN OTHERS =>
                delay_timer_enable <= '0';
                next_state <= state_idle;

        END CASE;
    END PROCESS FSM_transition;

    ----------------Timeout activation ----------------

    timeout_activation : PROCESS (delay_timer_val, delay_timer_enable)--i_clock, i_nreset, delay_timer_val, delay_timer_enable)
    BEGIN
        --if(i_nreset = '0') then
        --delay_timer_timeout <= '0';
        --else
        --if(rising_edge(i_clock)) then
        IF ((delay_timer_enable = '1') AND (delay_timer_val = 0)) THEN
            delay_timer_timeout <= '1';
        ELSE
            delay_timer_timeout <= '0';
        END IF;
        --else

        --end if;

        --end if;
    END PROCESS timeout_activation;

    ----------------Timer count ----------------

    delay_timer : PROCESS (i_clock, i_nreset, delay_timer_enable, delay_timer_timeout)
    BEGIN
        IF (i_nreset = '0') THEN
            delay_timer_val <= delay_val;
        ELSE
            IF (rising_edge(i_clock)) THEN
                IF ((delay_timer_enable = '1') AND (delay_timer_timeout = '0')) THEN
                    delay_timer_val <= delay_timer_val - 1;
                ELSIF (delay_timer_timeout = '1') THEN
                    delay_timer_val <= delay_val;
                ELSE

                END IF;
            ELSE

            END IF;
        END IF;
    END PROCESS delay_timer;

    ---------------- Output assignment ----------------
--    PROCESS (i_clock)
--    BEGIN
--        IF (rising_edge(i_clock)) THEN
--            o_spike_delayed <= delay_timer_timeout;
--        ELSE

--        END IF;
--    END PROCESS;

    o_spike_delayed <= delay_timer_timeout;

END Behavioral;