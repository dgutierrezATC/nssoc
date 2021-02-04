--/////////////////////////////////////////////////////////////////////////////////
--//                                                                             //
--//    Copyright (c) 2020  Daniel Gutierrez Galan                               //
--//                                                                             //
--//    This file is part of NSSOC.                                              //
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
-- Title      : Antero ventricular coclear nucleus
-- Project    : NSSOC
-------------------------------------------------------------------------------
-- File       : events_mask.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2019-06-13
-- Last update: 2021-01-13
-- Platform   : any
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Main module
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
ENTITY events_mask IS
    GENERIC (
        NBITS_ADDRESS       : INTEGER := 4;
        CHANNEL_VAL         : INTEGER := 1
    );
    PORT (
        i_input_address     : IN  STD_LOGIC_VECTOR ((NBITS_ADDRESS - 1) DOWNTO 0);
        o_output_masked_aer : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END events_mask;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF events_mask IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------
    CONSTANT channel_mask : STD_LOGIC_VECTOR(5 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(CHANNEL_VAL, 6));

    CONSTANT SSSL         : STD_LOGIC := '1';                     -- '0' means NAS data; '1' means Sound Source Localization data
    CONSTANT xSO_type     : STD_LOGIC := '0';                     -- '0' means MSO; '1' means LSO
    CONSTANT LR           : STD_LOGIC := '0';                     -- This field does not care
    CONSTANT POL          : STD_LOGIC := '0';                     -- '0' means POSITIVE; '1' means NEGATIVE.
    CONSTANT filler       : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; --

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------
    SIGNAL masked_aer : STD_LOGIC_VECTOR(15 DOWNTO 0);

    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------

    BEGIN  -- architecture Behavioral

        -----------------------------------------------------------------------------
        -- Processes
        -----------------------------------------------------------------------------

        -- purpose: Apply a mask to the input data
        -- type   : combinational
        -- inputs : i_input_address
        -- outputs: masked_aer
        mask_process : PROCESS (i_input_address)
        BEGIN
            masked_aer <= SSSL & xSO_type & filler & i_input_address & LR & channel_mask & POL;
        END PROCESS mask_process;

        -----------------------------------------------------------------------------
        -- Output assign
        -----------------------------------------------------------------------------
        o_output_masked_aer <= masked_aer;

END Behavioral;