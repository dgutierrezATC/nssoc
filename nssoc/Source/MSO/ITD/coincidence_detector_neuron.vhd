--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright (c) 2020  Daniel Gutierrez Galan                               //
--//                                                                             //
--//    This file is part of NSSOC project.                                      //
--//                                                                             //
--//    NSSOC is free software: you can redistribute it and/or modify            //
--//    it under the terms of the GNU General Public License as published by     //
--//    the Free Software Foundation, either version 3 of the License, or        //
--//    (at your option) any later version.                                      //
--//                                                                             //
--//    NSSOC is distributed in the hope that it will be useful,                 //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
--//    GNU General Public License for more details.                             //
--//                                                                             //
--//    You should have received a copy of the GNU General Public License        //
--//    along with NSSOC. If not, see <http://www.gnu.org/licenses/>.            //
--//                                                                             //
--/////////////////////////////////////////////////////////////////////////////////

-------------------------------------------------------------------------------
-- Title      : Delay line of the Jeffress model
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : coincidence_detector_neuron.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2018-09-10
-- Last update: 2021-01-21
-- Platform   : any
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-20  1.0      dgutierrez	Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Libraries
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY coincidence_detector_neuron IS
    GENERIC (
        TEMPORAL_COINCIDENCE_WINDOW : INTEGER := 100;     -- In microseconds
        CLOCK_FREQ                  : INTEGER := 50000000 -- In Hz
    );
    PORT (
        i_clock             : IN  STD_LOGIC;
        i_nreset            : IN  STD_LOGIC;
        i_left_spike        : IN  STD_LOGIC;
        i_right_spike       : IN  STD_LOGIC;
        o_coincidence_spike : OUT STD_LOGIC
    );
END coincidence_detector_neuron;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF coincidence_detector_neuron IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------
    CONSTANT COINCIDENCE_TIME : INTEGER := (TEMPORAL_COINCIDENCE_WINDOW * (CLOCK_FREQ / 1000000));

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------

    --
    -- FSM states and signals
    --
    TYPE state IS (state_idle, state_wait_left, state_wait_right, state_coincidence, state_refr_period);
    SIGNAL current_state, next_state : state;

    --
    -- Internal timer
    --
    SIGNAL coincidence_timer_timeout : STD_LOGIC;
    SIGNAL coincidence_timer_enable  : STD_LOGIC;
    SIGNAL coincidence_timer_val     : INTEGER RANGE 0 TO COINCIDENCE_TIME;

    --
    -- Spike out
    --
    SIGNAL coincidence_detected      : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

BEGIN  -- architecture Behavioral

    -----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    -- purpose: FSM update state
    -- type   : sequential
    -- inputs : i_clock, i_nreset
    -- outputs: current_state
    FSM_clocked : PROCESS (i_nreset, i_clock)
    BEGIN
        IF i_nreset = '0' THEN
            current_state <= state_idle;
        ELSIF rising_edge(i_clock) THEN
            current_state <= next_state;
        END IF;
    END PROCESS FSM_clocked;

    -- purpose: FSM states transition
    -- type   : combinational
    -- inputs : current_state, i_left_spike, i_right_spike, coincidence_timer_timeout
    -- outputs: next_state, coincidence_detected, coincidence_timer_enable
    FSM_transition : PROCESS (current_state, i_left_spike, i_right_spike, coincidence_timer_timeout)

    BEGIN
        next_state <= current_state;

        CASE current_state IS

            WHEN state_idle =>
                coincidence_detected     <= '0';
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
                coincidence_detected     <= '0';
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
                coincidence_detected     <= '0';
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
                coincidence_detected     <= '1';
                next_state               <= state_refr_period;

            WHEN state_refr_period =>
                coincidence_timer_enable <= '0';
                coincidence_detected     <= '0';
                next_state               <= state_idle;

            WHEN OTHERS =>
                coincidence_timer_enable <= '0';
                coincidence_detected     <= '0';
                next_state               <= state_idle;

        END CASE;
    END PROCESS FSM_transition;

    -- purpose: Timer count
    -- type   : sequential
    -- inputs : i_clock, i_nreset, coincidence_timer_enable, coincidence_timer_timeout
    -- outputs: coincidence_timer_val
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

    -- purpose: Timeout activation
    -- type   : combinational
    -- inputs : coincidence_timer_val, coincidence_timer_enable
    -- outputs: coincidence_timer_timeout
    timeout_activation : PROCESS (coincidence_timer_val, coincidence_timer_enable)
    BEGIN
        IF ((coincidence_timer_enable = '1') AND (coincidence_timer_val = 1)) THEN
            coincidence_timer_timeout <= '1';
        ELSE
            coincidence_timer_timeout <= '0';
        END IF;
    END PROCESS timeout_activation;

    -----------------------------------------------------------------------------
    -- Output assign
    -----------------------------------------------------------------------------
    o_coincidence_spike <= coincidence_detected;

END Behavioral;