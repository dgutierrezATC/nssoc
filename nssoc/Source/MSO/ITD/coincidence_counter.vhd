----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.12.2018 13:09:46
-- Design Name: 
-- Module Name: coincidence_counter - Behavioral
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
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY coincidence_counter IS
    GENERIC (
        INTEGRATION_PERIOD : INTEGER := 5000000 --ns
    );
    PORT (
        i_clock : IN STD_LOGIC;
        i_reset : IN STD_LOGIC;
        i_spike_in : IN STD_LOGIC;
        o_spikes_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END coincidence_counter;

ARCHITECTURE Behavioral OF coincidence_counter IS

    --=================================
    -- FSM states and signals
    --=================================

    TYPE state IS (state_reset, state_integrate, state_fire, state_refr_period);
    SIGNAL current_state, next_state : state;
    -----------------------------------

    --=================================
    -- Internal timer
    --=================================

    SIGNAL delay_timeout : std_logic;
    SIGNAL delay_time : std_logic_vector(23 DOWNTO 0);

    CONSTANT timer_val : INTEGER := (INTEGRATION_PERIOD / 20);
    CONSTANT integr_period : std_logic_vector(23 DOWNTO 0) := std_logic_vector(to_unsigned(timer_val, 24));
    -----------------------------------

    --=================================
    -- Integrator signal
    --=================================
    SIGNAL integrator_value : std_logic_vector(7 DOWNTO 0);
    -----------------------------------

BEGIN

    ----------------FSM update state----------------
    FSM_clocked : PROCESS (i_reset, i_clock)
    BEGIN
        IF i_reset = '0' THEN
            current_state <= state_reset;
        ELSIF rising_edge(i_clock) THEN
            current_state <= next_state;
        END IF;
    END PROCESS FSM_clocked;

    ----------------FSM states transition----------------
    FSM_transition : PROCESS (i_reset, current_state, i_spike_in, delay_timeout)

    BEGIN
        next_state <= current_state;

        CASE current_state IS
            WHEN state_reset =>
                IF i_reset = '1' THEN
                    next_state <= state_integrate;
                ELSE
                    next_state <= state_reset;
                END IF;

            WHEN state_integrate =>
                IF delay_timeout = '1' THEN
                    next_state <= state_fire;
                ELSE
                    next_state <= state_integrate;
                END IF;

            WHEN state_fire =>
                next_state <= state_refr_period;

            WHEN state_refr_period =>
                next_state <= state_integrate;

            WHEN OTHERS =>
                next_state <= state_integrate;

        END CASE;
    END PROCESS FSM_transition;

    ----------------FSM states outputs ----------------

    Output_secuential : PROCESS (i_clock)
    BEGIN
        IF rising_edge(i_clock) THEN
            CASE current_state IS

                WHEN state_reset =>
                    delay_timeout <= '0';
                    delay_time <= integr_period;
                    integrator_value <= (OTHERS => '0');

                WHEN state_integrate =>
                    IF (delay_time = x"000000") THEN
                        delay_timeout <= '1';
                    ELSE
                        delay_time <= delay_time - 1;
                    END IF;
                    IF (i_spike_in = '1') THEN
                        integrator_value <= integrator_value + 1;
                    ELSE

                    END IF;
                WHEN state_fire =>
                    delay_timeout <= '0';
                    o_spikes_count <= integrator_value;

                WHEN state_refr_period =>
                    delay_time <= integr_period;
                    delay_timeout <= '0';
                    integrator_value <= (OTHERS => '0');

                WHEN OTHERS =>
            END CASE;
        END IF;
    END PROCESS Output_secuential;
    ---------------- Output assignment ----------------
END Behavioral;