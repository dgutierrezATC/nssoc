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
-- Title      : Medial Superior Olivar (MSO) model
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : MSO.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2019-08-26
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

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY AER_audio_out_merger IS
    PORT (
        --// Clock and external reset button-----------------
        i_clock            : IN  STD_LOGIC;
        i_nreset           : IN  STD_LOGIC;
        --// INPUT interfaces-------------------------------
        --// NAS AER interface
        i_nas_aer_out_data : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_nas_aer_out_req  : IN  STD_LOGIC;
        o_nas_aer_out_ack  : OUT STD_LOGIC;
        --// SOC AER interface
        i_soc_aer_out_data : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_soc_aer_out_req  : IN  STD_LOGIC;
        o_soc_aer_out_ack  : OUT STD_LOGIC;
        --// OUTPUT interface--------------------------------
        --// Auditory AER interface
        o_aer_out_data     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        o_aer_out_req      : OUT STD_LOGIC;
        i_aer_out_ack      : IN  STD_LOGIC
    );
END AER_audio_out_merger;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE AER_audio_out_merger_arch OF AER_audio_out_merger IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------
    --FSM
    TYPE t_state IS (
        s_reset,
        s_NAS_check_req, s_NAS_req_detected, s_NAS_wait_ack_from_ext, s_NAS_wait_req_remove, s_NAS_wait_ack_remove,
        s_SOC_check_req, s_SOC_req_detected, s_SOC_wait_ack_from_ext, s_SOC_wait_req_remove, s_SOC_wait_ack_remove
    );
    SIGNAL fsm_current_state : t_state;
    SIGNAL fsm_next_state    : t_state;

    --// Signals AER bux mux
    SIGNAL aer_bus_mux_sel            : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL aer_bus_mux_sel_registered : STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL nas_aer_out_req : STD_LOGIC;
    SIGNAL nas_aer_out_ack : STD_LOGIC;
    SIGNAL soc_aer_out_req : STD_LOGIC;
    SIGNAL soc_aer_out_ack : STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    --//=========================
    --//-----AER BUS multiplexer------- 
    --//=========================
    COMPONENT AER_BUS_Multiplexer IS
        PORT (
            i_input_sel    : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            --// AER interface from NAS
            i_aer_data_nas : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
            i_aer_req_nas  : IN  STD_LOGIC;
            o_aer_ack_nas  : OUT STD_LOGIC;
            --// AER interface from SOC
            i_aer_data_mso : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
            i_aer_req_mso  : IN  STD_LOGIC;
            o_aer_ack_mso  : OUT STD_LOGIC;
            --// Output AER interface
            o_aer_data_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            o_aer_req_out  : OUT STD_LOGIC;
            i_aer_ack_out  : IN  STD_LOGIC
        );
    END COMPONENT;

BEGIN  -- architecture Behavioral

    -----------------------------------------------------------------------------
    -- Processes
    -----------------------------------------------------------------------------

    --//=========================
    --//-----AER bus arbiter----- 
    --//=========================

    -- purpose: FSM update state
    -- type   : sequential
    -- inputs : i_clock, i_nreset
    -- outputs: fsm_current_state, aer_bus_mux_sel_registered
    FSM_update : PROCESS (i_clock, i_nreset)
    BEGIN
        IF (i_nreset = '0') THEN
            fsm_current_state          <= s_reset;
            aer_bus_mux_sel_registered <= (OTHERS => '0');
        ELSE
            IF (rising_edge(i_clock)) THEN
                fsm_current_state          <= fsm_next_state;
                aer_bus_mux_sel_registered <= aer_bus_mux_sel;
            ELSE

            END IF;
        END IF;
    END PROCESS FSM_update;

    -- purpose: FSM states transition
    -- type   : combinational
    -- inputs : fsm_current_state, nas_aer_out_req, nas_aer_out_ack, soc_aer_out_req, soc_aer_out_ack
    -- outputs: fsm_next_state, aer_bus_mux_sel
    FSM_transitions : PROCESS (fsm_current_state, nas_aer_out_req, nas_aer_out_ack, soc_aer_out_req, soc_aer_out_ack)
    BEGIN

        CASE fsm_current_state IS
            --// Reset
            WHEN s_reset =>
                fsm_next_state  <= s_SOC_check_req;
                aer_bus_mux_sel <= (OTHERS => '0');

            --// SOC
            WHEN s_SOC_check_req =>
                IF (soc_aer_out_req = '0') THEN
                    fsm_next_state  <= s_SOC_req_detected;
                    aer_bus_mux_sel <= "01";
                ELSE
                    fsm_next_state  <= s_NAS_check_req;
                    aer_bus_mux_sel <= (OTHERS => '0');
                END IF;

            WHEN s_SOC_req_detected =>
                fsm_next_state  <= s_SOC_wait_ack_from_ext;
                aer_bus_mux_sel <= "01";

            WHEN s_SOC_wait_ack_from_ext =>
                IF (soc_aer_out_ack = '0') THEN
                    fsm_next_state <= s_SOC_wait_req_remove;
                END IF;
                aer_bus_mux_sel    <= "01";

            WHEN s_SOC_wait_req_remove =>
                IF (soc_aer_out_req = '1') THEN
                    fsm_next_state <= s_SOC_wait_ack_remove;
                END IF;
                aer_bus_mux_sel    <= "01";

            WHEN s_SOC_wait_ack_remove =>
                IF (soc_aer_out_ack = '1') THEN
                    fsm_next_state <= s_NAS_check_req;
                END IF;
                aer_bus_mux_sel    <= "01";

            --// NAS
            WHEN s_NAS_check_req =>
                IF (nas_aer_out_req = '0') THEN
                    fsm_next_state  <= s_NAS_req_detected;
                    aer_bus_mux_sel <= (OTHERS => '0');
                ELSE
                    fsm_next_state  <= s_SOC_check_req;
                    aer_bus_mux_sel <= "01";
                END IF;
            WHEN s_NAS_req_detected =>
                fsm_next_state  <= s_NAS_wait_ack_from_ext;
                aer_bus_mux_sel <= (OTHERS => '0');

            WHEN s_NAS_wait_ack_from_ext =>
                IF (nas_aer_out_ack = '0') THEN
                    fsm_next_state <= s_NAS_wait_req_remove;
                END IF;
                aer_bus_mux_sel    <= (OTHERS => '0');

            WHEN s_NAS_wait_req_remove =>
                IF (nas_aer_out_req = '1') THEN
                    fsm_next_state <= s_NAS_wait_ack_remove;
                END IF;
                aer_bus_mux_sel <= (OTHERS => '0');

            WHEN s_NAS_wait_ack_remove =>
                IF (nas_aer_out_ack = '1') THEN
                    fsm_next_state <= s_SOC_check_req;
                END IF;
                aer_bus_mux_sel    <= (OTHERS => '0');

            WHEN OTHERS =>
                fsm_next_state  <= s_NAS_check_req;
                aer_bus_mux_sel <= (OTHERS => '0');

        END CASE;
    END PROCESS FSM_transitions;

    ---------------------------------------------------------------------------
    -- Components instantiation
    ---------------------------------------------------------------------------
    --//=========================
    --//---AER bus multiplexer---
    --//=========================

    nas_aer_out_req   <= i_nas_aer_out_req;
    o_nas_aer_out_ack <= nas_aer_out_ack;
    soc_aer_out_req   <= i_soc_aer_out_req;
    o_soc_aer_out_ack <= soc_aer_out_ack;

    U_AER_bus_mux : AER_BUS_Multiplexer
        PORT MAP(
            i_input_sel    => aer_bus_mux_sel,
            --// AER interface from NAS
            i_aer_data_nas => i_nas_aer_out_data,
            i_aer_req_nas  => nas_aer_out_req,
            o_aer_ack_nas  => nas_aer_out_ack,
            --// AER interface from SOC
            i_aer_data_mso => i_soc_aer_out_data,
            i_aer_req_mso  => soc_aer_out_req,
            o_aer_ack_mso  => soc_aer_out_ack,
            --// Output AER interface
            o_aer_data_out => o_aer_out_data,
            o_aer_req_out  => o_aer_out_req,
            i_aer_ack_out  => i_aer_out_ack
        );

END AER_audio_out_merger_arch;