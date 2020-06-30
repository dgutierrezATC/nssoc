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
ENTITY coincidence_detector_neuron IS
    GENERIC (
        TEMPORAL_COINCIDENCE_WINDOW : INTEGER := 100; --us
        CLOCK_FREQ : INTEGER := 50000000 --Hz
    );
    PORT (
        i_clock : IN std_logic;
        i_nreset : IN std_logic;
        i_left_spike : IN std_logic;
        i_right_spike : IN std_logic;
        o_coincidence_spike : OUT std_logic
    );

END coincidence_detector_neuron;

ARCHITECTURE Behavioral OF coincidence_detector_neuron IS

    --=================================
    -- FSM states and signals
    --=================================
    TYPE state IS (state_idle, state_wait_left, state_wait_right, state_coincidence, state_refr_period);
    SIGNAL current_state, next_state : state;
    -----------------------------------

    --=================================
    -- Internal timer
    --=================================
    CONSTANT COINCIDENCE_TIME : INTEGER := (TEMPORAL_COINCIDENCE_WINDOW * (CLOCK_FREQ / 1000000));

    SIGNAL coincidence_timer_timeout : std_logic;
    SIGNAL coincidence_timer_enable : std_logic;
    SIGNAL coincidence_timer_val : INTEGER RANGE 0 TO COINCIDENCE_TIME;

    -----------------------------------

    --=================================
    -- Spike out
    --=================================
    SIGNAL coincidence_detected : std_logic;
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
    FSM_transition : PROCESS (current_state, i_left_spike, i_right_spike, coincidence_timer_timeout)

    BEGIN
        next_state <= current_state;

        CASE current_state IS

            WHEN state_idle =>
                coincidence_detected <= '0';
                coincidence_timer_enable <= '0';

                IF i_right_spike = '1' AND i_left_spike = '0' THEN
                    next_state <= state_wait_left;
                ELSIF i_right_spike = '0' AND i_left_spike = '1' THEN
                    next_state <= state_wait_right;
                ELSIF i_right_spike = '1' AND i_left_spike = '1' THEN
                    next_state <= state_coincidence;
                ELSE
                    next_state <= state_idle;
                END IF;

            WHEN state_wait_left =>
                coincidence_detected <= '0';
                coincidence_timer_enable <= '1';

                IF coincidence_timer_timeout = '1' AND i_left_spike = '0' THEN
                    next_state <= state_idle;
                ELSIF coincidence_timer_timeout = '0' AND i_left_spike = '1' THEN
                    next_state <= state_coincidence;
                ELSIF coincidence_timer_timeout = '1' AND i_left_spike = '1' THEN
                    next_state <= state_coincidence;
                ELSE
                    next_state <= state_wait_left;
                END IF;

            WHEN state_wait_right =>
                coincidence_detected <= '0';
                coincidence_timer_enable <= '1';

                IF coincidence_timer_timeout = '1' AND i_right_spike = '0' THEN
                    next_state <= state_idle;
                ELSIF coincidence_timer_timeout = '0' AND i_right_spike = '1' THEN
                    next_state <= state_coincidence;
                ELSIF coincidence_timer_timeout = '1' AND i_right_spike = '1' THEN
                    next_state <= state_coincidence;
                ELSE
                    next_state <= state_wait_right;
                END IF;

            WHEN state_coincidence =>
                coincidence_timer_enable <= '0';
                coincidence_detected <= '1';
                next_state <= state_refr_period;

            WHEN state_refr_period =>
                coincidence_timer_enable <= '0';
                coincidence_detected <= '0';
                next_state <= state_idle;

            WHEN OTHERS =>
                coincidence_timer_enable <= '0';
                coincidence_detected <= '0';
                next_state <= state_idle;

        END CASE;
    END PROCESS FSM_transition;

    ---------------- Timer count ----------------	
    coincidence_timer : PROCESS (i_clock, i_nreset, coincidence_timer_enable, coincidence_timer_timeout)
    BEGIN
        IF (i_nreset = '0') THEN
            coincidence_timer_val <= COINCIDENCE_TIME;
        ELSE
            IF (rising_edge(i_clock)) THEN
                IF ((coincidence_timer_enable = '1') AND (coincidence_timer_timeout = '0')) THEN
                    coincidence_timer_val <= coincidence_timer_val - 1;
                ELSIF (coincidence_timer_timeout = '1' OR coincidence_timer_enable = '0') THEN
                    coincidence_timer_val <= COINCIDENCE_TIME;
                ELSE

                END IF;
            ELSE

            END IF;
        END IF;
    END PROCESS coincidence_timer;
    ----------------Timer timeout detection ----------------	

    timeout_activation : PROCESS (coincidence_timer_val, coincidence_timer_enable)
    BEGIN

        IF ((coincidence_timer_enable = '1') AND (coincidence_timer_val = 1)) THEN
            coincidence_timer_timeout <= '1';
        ELSE
            coincidence_timer_timeout <= '0';
        END IF;

    END PROCESS timeout_activation;

    ----------------FSM states outputs ----------------

    --    Output_secuential : PROCESS (i_clock)
    --    BEGIN
    --        IF rising_edge(i_clock) THEN
    --            o_coincidence_spike <= coincidence_detected;
    --        END IF;
    --    END PROCESS Output_secuential;
    ---------------- Output assignment ----------------
    o_coincidence_spike <= coincidence_detected;

END Behavioral;