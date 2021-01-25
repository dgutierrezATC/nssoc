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
-- File       : delay_line.vhd
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
ENTITY delay_line IS
    GENERIC (
        TRANSMISSION_TIME : INTEGER := 500;     -- In microseconds
        CLOCK_FREQ        : INTEGER := 50000000 -- In Hz
    );
    PORT (
        i_clock           : IN  STD_LOGIC;
        i_nreset          : IN  STD_LOGIC;
        i_spike_in        : IN  STD_LOGIC;
        o_spike_delayed   : OUT STD_LOGIC
    );
END delay_line;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF delay_line IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------
    CONSTANT delay_val : INTEGER := TRANSMISSION_TIME * (CLOCK_FREQ / 1000000);

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------
    
    --
    -- FSM states and signals
    --
    TYPE state IS (state_idle, state_hold, state_fire);
    SIGNAL current_state, next_state : state;

    --
    -- Internal timer
    --
    SIGNAL delay_timer_timeout : STD_LOGIC;
    SIGNAL delay_timer_enable  : STD_LOGIC;
    SIGNAL delay_timer_val     : INTEGER RANGE 0 TO delay_val;

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
    -- inputs : current_state, i_spike_in, delay_timer_timeout
    -- outputs: next_state, delay_timer_enable
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

    -- purpose: Timeout activation
    -- type   : combinational
    -- inputs : delay_timer_val, delay_timer_enable
    -- outputs: delay_timer_timeout
    timeout_activation : PROCESS (delay_timer_val, delay_timer_enable)
    BEGIN
        IF ((delay_timer_enable = '1') AND (delay_timer_val = 0)) THEN
            delay_timer_timeout <= '1';
        ELSE
            delay_timer_timeout <= '0';
        END IF;
    END PROCESS timeout_activation;

    -- purpose: Timer count
    -- type   : sequential
    -- inputs : i_clock, i_nreset, delay_timer_enable, delay_timer_timeout
    -- outputs: delay_timer_val
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

    -----------------------------------------------------------------------------
    -- Output assign
    -----------------------------------------------------------------------------
    o_spike_delayed <= delay_timer_timeout;

END Behavioral;