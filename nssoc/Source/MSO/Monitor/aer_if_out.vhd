--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright (c) 2016  Angel Francisco Jimenez-Fernandez                    //
--//                                                                             //
--//    This file is part of OpenNAS.                                            //
--//                                                                             //
--//    OpenNAS is free software: you can redistribute it and/or modify          //
--//    it under the terms of the GNU General Public License as published by     //
--//    the Free Software Foundation, either version 3 of the License, or        //
--//    (at your option) any later version.                                      //
--//                                                                             //
--//    OpenNAS is distributed in the hope that it will be useful,               //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of           //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the              //
--//    GNU General Public License for more details.                             //
--//                                                                             //
--//    You should have received a copy of the GNU General Public License        //
--//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.          //
--//                                                                             //
--/////////////////////////////////////////////////////////////////////////////////

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY aer_if_out IS
    PORT (
        i_nreset     : IN STD_LOGIC;
        i_clock      : IN STD_LOGIC;
        i_ack        : IN STD_LOGIC;
        i_aer_in     : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        i_new_aer_in : IN STD_LOGIC;
        o_req        : OUT STD_LOGIC;
        o_aer_out    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        o_busy       : OUT STD_LOGIC
    );
END aer_if_out;

ARCHITECTURE aer_if_out_arch OF aer_if_out IS

    SIGNAL state      : INTEGER RANGE 0 TO 5;
    SIGNAL next_state : INTEGER RANGE 0 TO 5;

BEGIN

    PROCESS (i_new_aer_in, i_ack, state, i_aer_in, state)
    BEGIN
        CASE state IS
            WHEN 0 =>
                o_req  <= '1';
                o_busy <= '0';
                IF (i_new_aer_in = '1') THEN
                    next_state <= 3;
                ELSE
                    next_state <= 0;
                END IF;
            WHEN 3 => --Estado de setup
                o_busy     <= '1';
                o_req      <= '1';
                next_state <= 1;
                --				when 4 =>	--Estado de setup
                --		
                --					o_busy<='1';
                --					o_req <= '1';
                --					next_state <= 1;
            WHEN 1 =>
                o_busy <= '1';
                o_req  <= '0';
                IF (i_ack = '0') THEN
                    next_state <= 2;
                ELSE
                    next_state <= 1;
                END IF;
            WHEN 2 =>
                o_busy <= '1';
                o_req  <= '1';
                IF (i_ack = '1') THEN
                    next_state <= 5;
                ELSE
                    next_state <= 2;
                END IF;
            WHEN 5 => --state de hold
                o_busy     <= '1';
                o_req      <= '1';
                next_state <= 0;
            WHEN OTHERS =>
                o_busy     <= '1';
                o_req      <= '1';
                next_state <= 0;
        END CASE;
    END PROCESS;

    PROCESS (i_clock, i_nreset)
    BEGIN
        IF (i_nreset = '0') THEN
            state <= 0;
            o_aer_out <= (OTHERS => '0');
        ELSE
            IF (i_clock = '1' AND i_clock'event) THEN
                state <= next_state;

                IF (i_new_aer_in = '1' AND state = 0) THEN
                    o_aer_out <= i_aer_in;
                ELSE

                END IF;
            ELSE

            END IF;
        END IF;
    END PROCESS;

END aer_if_out_arch;