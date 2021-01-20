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
-- File       : AVCN.vhd
-- Author     : Daniel Gutierrez-Galan (dgutierrez@atc.us.es)
-- Company    : University of Seville
-- Created    : 2018-12-12
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

-------------------------------------------------------------------------------
-- Entity declaration
-------------------------------------------------------------------------------
ENTITY AVCN IS
    GENERIC (
        NUM_FREQ_CH : INTEGER := 64
    );
    PORT (
        i_clock                 : IN  std_logic;
        i_nreset                : IN  std_logic;
        i_auditory_nerve_spikes : IN  std_logic_vector(((NUM_FREQ_CH * 2) - 1) DOWNTO 0);
        o_phase_locked_spikes   : OUT std_logic_vector((NUM_FREQ_CH - 1) DOWNTO 0)
    );
END AVCN;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF AVCN IS

    ---------------------------------------------------------------------------
    -- Constants declaration
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Signals declaration
    ---------------------------------------------------------------------------


    ---------------------------------------------------------------------------
    -- Components declaration
    ---------------------------------------------------------------------------
    
    --
    --Spherical bushy cell neuron component
    --
    COMPONENT spherical_bushy_cell IS
        PORT (
            i_clock              : IN  STD_LOGIC;
            i_nreset             : IN  STD_LOGIC;
            i_pos_spike          : IN  STD_LOGIC;
            i_neg_spike          : IN  STD_LOGIC;
            o_phase_locked_spike : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN  -- architecture Behavioral

    ---------------------------------------------------------------------------
    -- Components instantiation
    ---------------------------------------------------------------------------

    --
    -- Spherical bushy cell
    --
    GEN_SBC : FOR I IN 0 TO (NUM_FREQ_CH - 1) GENERATE
        SBCX : spherical_bushy_cell
            PORT MAP(
                i_clock              => i_clock,
                i_nreset             => i_nreset,
                i_pos_spike          => i_auditory_nerve_spikes(I * 2),
                i_neg_spike          => i_auditory_nerve_spikes((I * 2) + 1),
                o_phase_locked_spike => o_phase_locked_spikes(I)
            );
    END GENERATE GEN_SBC;

END Behavioral;