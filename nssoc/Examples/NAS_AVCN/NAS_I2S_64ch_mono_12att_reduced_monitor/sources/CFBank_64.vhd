--///////////////////////////////////////////////////////////////////////////////
--//                                                                           //
--//    Copyright © 2016  Angel Francisco Jimenez-Fernandez                    //
--//                                                                           //
--//    This file is part of OpenNAS.                                          //
--//                                                                           //
--//    OpenNAS is free software: you can redistribute it and/or modify        //
--//    it under the terms of the GNU General Public License as published by   //
--//    the Free Software Foundation, either version 3 of the License, or      //
--//    (at your option) any later version.                                    //
--//                                                                           //
--//    OpenNAS is distributed in the hope that it will be useful,             //
--//    but WITHOUT ANY WARRANTY; without even the implied warranty of         //
--//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the            //
--//    GNU General Public License for more details.                           //
--//                                                                           //
--//    You should have received a copy of the GNU General Public License      //
--//    along with OpenNAS. If not, see <http://www.gnu.org/licenses/>.        //
--//                                                                           //
--///////////////////////////////////////////////////////////////////////////////


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CFBank_2or_64CH is
    Port (
        clock      : in  std_logic;
        rst        : in  std_logic;
        spikes_in  : in  std_logic_vector(1 downto 0);
        spikes_out : out std_logic_vector(127 downto 0)
    );
end CFBank_2or_64CH;

architecture CFBank_arq of CFBank_2or_64CH is

    component spikes_2BPF_fullGain is
        Generic (
            GL              : integer := 11;
            SAT             : integer := 1023
        );
        Port (
            CLK             : in  STD_LOGIC;
            RST             : in  STD_LOGIC;
            FREQ_DIV        : in  STD_LOGIC_VECTOR(7 downto 0);
            SPIKES_DIV_FB   : in  STD_LOGIC_VECTOR(15 downto 0);
            SPIKES_DIV_OUT  : in  STD_LOGIC_VECTOR(15 downto 0);
            SPIKES_DIV_BPF  : in  STD_LOGIC_VECTOR(15 downto 0);
            spike_in_slpf_p : in  STD_LOGIC;
            spike_in_slpf_n : in  STD_LOGIC;
            spike_in_shf_p  : in  STD_LOGIC;
            spike_in_shf_n  : in  STD_LOGIC;
            spike_out_p     : out STD_LOGIC;
            spike_out_n     : out STD_LOGIC;
            spike_out_lpf_p : out STD_LOGIC;
            spike_out_lpf_n : out STD_LOGIC
        );
    end component;

    signal not_rst: std_logic;
    signal lpf_spikes_0   : std_logic_vector(1 downto 0);
    signal lpf_spikes_1   : std_logic_vector(1 downto 0);
    signal lpf_spikes_2   : std_logic_vector(1 downto 0);
    signal lpf_spikes_3   : std_logic_vector(1 downto 0);
    signal lpf_spikes_4   : std_logic_vector(1 downto 0);
    signal lpf_spikes_5   : std_logic_vector(1 downto 0);
    signal lpf_spikes_6   : std_logic_vector(1 downto 0);
    signal lpf_spikes_7   : std_logic_vector(1 downto 0);
    signal lpf_spikes_8   : std_logic_vector(1 downto 0);
    signal lpf_spikes_9   : std_logic_vector(1 downto 0);
    signal lpf_spikes_10   : std_logic_vector(1 downto 0);
    signal lpf_spikes_11   : std_logic_vector(1 downto 0);
    signal lpf_spikes_12   : std_logic_vector(1 downto 0);
    signal lpf_spikes_13   : std_logic_vector(1 downto 0);
    signal lpf_spikes_14   : std_logic_vector(1 downto 0);
    signal lpf_spikes_15   : std_logic_vector(1 downto 0);
    signal lpf_spikes_16   : std_logic_vector(1 downto 0);
    signal lpf_spikes_17   : std_logic_vector(1 downto 0);
    signal lpf_spikes_18   : std_logic_vector(1 downto 0);
    signal lpf_spikes_19   : std_logic_vector(1 downto 0);
    signal lpf_spikes_20   : std_logic_vector(1 downto 0);
    signal lpf_spikes_21   : std_logic_vector(1 downto 0);
    signal lpf_spikes_22   : std_logic_vector(1 downto 0);
    signal lpf_spikes_23   : std_logic_vector(1 downto 0);
    signal lpf_spikes_24   : std_logic_vector(1 downto 0);
    signal lpf_spikes_25   : std_logic_vector(1 downto 0);
    signal lpf_spikes_26   : std_logic_vector(1 downto 0);
    signal lpf_spikes_27   : std_logic_vector(1 downto 0);
    signal lpf_spikes_28   : std_logic_vector(1 downto 0);
    signal lpf_spikes_29   : std_logic_vector(1 downto 0);
    signal lpf_spikes_30   : std_logic_vector(1 downto 0);
    signal lpf_spikes_31   : std_logic_vector(1 downto 0);
    signal lpf_spikes_32   : std_logic_vector(1 downto 0);
    signal lpf_spikes_33   : std_logic_vector(1 downto 0);
    signal lpf_spikes_34   : std_logic_vector(1 downto 0);
    signal lpf_spikes_35   : std_logic_vector(1 downto 0);
    signal lpf_spikes_36   : std_logic_vector(1 downto 0);
    signal lpf_spikes_37   : std_logic_vector(1 downto 0);
    signal lpf_spikes_38   : std_logic_vector(1 downto 0);
    signal lpf_spikes_39   : std_logic_vector(1 downto 0);
    signal lpf_spikes_40   : std_logic_vector(1 downto 0);
    signal lpf_spikes_41   : std_logic_vector(1 downto 0);
    signal lpf_spikes_42   : std_logic_vector(1 downto 0);
    signal lpf_spikes_43   : std_logic_vector(1 downto 0);
    signal lpf_spikes_44   : std_logic_vector(1 downto 0);
    signal lpf_spikes_45   : std_logic_vector(1 downto 0);
    signal lpf_spikes_46   : std_logic_vector(1 downto 0);
    signal lpf_spikes_47   : std_logic_vector(1 downto 0);
    signal lpf_spikes_48   : std_logic_vector(1 downto 0);
    signal lpf_spikes_49   : std_logic_vector(1 downto 0);
    signal lpf_spikes_50   : std_logic_vector(1 downto 0);
    signal lpf_spikes_51   : std_logic_vector(1 downto 0);
    signal lpf_spikes_52   : std_logic_vector(1 downto 0);
    signal lpf_spikes_53   : std_logic_vector(1 downto 0);
    signal lpf_spikes_54   : std_logic_vector(1 downto 0);
    signal lpf_spikes_55   : std_logic_vector(1 downto 0);
    signal lpf_spikes_56   : std_logic_vector(1 downto 0);
    signal lpf_spikes_57   : std_logic_vector(1 downto 0);
    signal lpf_spikes_58   : std_logic_vector(1 downto 0);
    signal lpf_spikes_59   : std_logic_vector(1 downto 0);
    signal lpf_spikes_60   : std_logic_vector(1 downto 0);
    signal lpf_spikes_61   : std_logic_vector(1 downto 0);
    signal lpf_spikes_62   : std_logic_vector(1 downto 0);
    signal lpf_spikes_63   : std_logic_vector(1 downto 0);
    signal lpf_spikes_64   : std_logic_vector(1 downto 0);

    begin

        not_rst <= not rst;

        --Ideal cutoff: 15522,8942Hz - Real cutoff: 15522,0792Hz - Error: 0,0053%
        U_BPF_0: spikes_2BPF_fullGain
        Generic Map (
            GL              => 8,
            SAT             => 127
        )
        Port Map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"7FD5",
            SPIKES_DIV_OUT  => x"7FD5",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => spikes_in(1),
            spike_in_slpf_n => spikes_in(0),
            spike_in_shf_p  => '0',
            spike_in_shf_n  => '0',
            spike_out_p     => open,
            spike_out_n     => open, 
            spike_out_lpf_p => lpf_spikes_0(1),
            spike_out_lpf_n => lpf_spikes_0(0)
        );

        --Ideal cutoff: 14494,7197Hz - Real cutoff: 14494,2306Hz - Error: 0,0034%
        U_BPF_1: spikes_2BPF_fullGain
        Generic Map (
            GL              => 8,
            SAT             => 127
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"775E",
            SPIKES_DIV_OUT  => x"775E",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_0(1),
            spike_in_slpf_n => lpf_spikes_0(0),
            spike_in_shf_p  => lpf_spikes_0(1),
            spike_in_shf_n  => lpf_spikes_0(0),
            spike_out_p     => spikes_out(1),
            spike_out_n     => spikes_out(0), 
            spike_out_lpf_p => lpf_spikes_1(1),
            spike_out_lpf_n => lpf_spikes_1(0)
        );

        --Ideal cutoff: 13534,6473Hz - Real cutoff: 13533,7352Hz - Error: 0,0067%
        U_BPF_2: spikes_2BPF_fullGain
        Generic Map (
            GL              => 8,
            SAT             => 127
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"6F75",
            SPIKES_DIV_OUT  => x"6F75",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_1(1),
            spike_in_slpf_n => lpf_spikes_1(0),
            spike_in_shf_p  => lpf_spikes_1(1),
            spike_in_shf_n  => lpf_spikes_1(0),
            spike_out_p     => spikes_out(3),
            spike_out_n     => spikes_out(2), 
            spike_out_lpf_p => lpf_spikes_2(1),
            spike_out_lpf_n => lpf_spikes_2(0)
        );

        --Ideal cutoff: 12638,1663Hz - Real cutoff: 12637,2729Hz - Error: 0,0071%
        U_BPF_3: spikes_2BPF_fullGain
        Generic Map (
            GL              => 8,
            SAT             => 127
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"6813",
            SPIKES_DIV_OUT  => x"6813",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_2(1),
            spike_in_slpf_n => lpf_spikes_2(0),
            spike_in_shf_p  => lpf_spikes_2(1),
            spike_in_shf_n  => lpf_spikes_2(0),
            spike_out_p     => spikes_out(5),
            spike_out_n     => spikes_out(4), 
            spike_out_lpf_p => lpf_spikes_3(1),
            spike_out_lpf_n => lpf_spikes_3(0)
        );

        --Ideal cutoff: 11801,0646Hz - Real cutoff: 11800,6696Hz - Error: 0,0033%
        U_BPF_4: spikes_2BPF_fullGain
        Generic Map (
            GL              => 8,
            SAT             => 127
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"797B",
            SPIKES_DIV_OUT  => x"797B",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_3(1),
            spike_in_slpf_n => lpf_spikes_3(0),
            spike_in_shf_p  => lpf_spikes_3(1),
            spike_in_shf_n  => lpf_spikes_3(0),
            spike_out_p     => spikes_out(7),
            spike_out_n     => spikes_out(6), 
            spike_out_lpf_p => lpf_spikes_4(1),
            spike_out_lpf_n => lpf_spikes_4(0)
        );

        --Ideal cutoff: 11019,4092Hz - Real cutoff: 11018,9924Hz - Error: 0,0038%
        U_BPF_5: spikes_2BPF_fullGain
        Generic Map (
            GL              => 8,
            SAT             => 127
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"716F",
            SPIKES_DIV_OUT  => x"716F",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_4(1),
            spike_in_slpf_n => lpf_spikes_4(0),
            spike_in_shf_p  => lpf_spikes_4(1),
            spike_in_shf_n  => lpf_spikes_4(0),
            spike_out_p     => spikes_out(9),
            spike_out_n     => spikes_out(8), 
            spike_out_lpf_p => lpf_spikes_5(1),
            spike_out_lpf_n => lpf_spikes_5(0)
        );

        --Ideal cutoff: 10289,5276Hz - Real cutoff: 10288,9211Hz - Error: 0,0059%
        U_BPF_6: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"7F1A",
            SPIKES_DIV_OUT  => x"7F1A",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_5(1),
            spike_in_slpf_n => lpf_spikes_5(0),
            spike_in_shf_p  => lpf_spikes_5(1),
            spike_in_shf_n  => lpf_spikes_5(0),
            spike_out_p     => spikes_out(11),
            spike_out_n     => spikes_out(10), 
            spike_out_lpf_p => lpf_spikes_6(1),
            spike_out_lpf_n => lpf_spikes_6(0)
        );

        --Ideal cutoff: 9607,9903Hz - Real cutoff: 9607,4832Hz - Error: 0,0053%
        U_BPF_7: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"76AF",
            SPIKES_DIV_OUT  => x"76AF",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_6(1),
            spike_in_slpf_n => lpf_spikes_6(0),
            spike_in_shf_p  => lpf_spikes_6(1),
            spike_in_shf_n  => lpf_spikes_6(0),
            spike_out_p     => spikes_out(13),
            spike_out_n     => spikes_out(12), 
            spike_out_lpf_p => lpf_spikes_7(1),
            spike_out_lpf_n => lpf_spikes_7(0)
        );

        --Ideal cutoff: 8971,5954Hz - Real cutoff: 8971,2637Hz - Error: 0,0037%
        U_BPF_8: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"6ED3",
            SPIKES_DIV_OUT  => x"6ED3",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_7(1),
            spike_in_slpf_n => lpf_spikes_7(0),
            spike_in_shf_p  => lpf_spikes_7(1),
            spike_in_shf_n  => lpf_spikes_7(0),
            spike_out_p     => spikes_out(15),
            spike_out_n     => spikes_out(14), 
            spike_out_lpf_p => lpf_spikes_8(1),
            spike_out_lpf_n => lpf_spikes_8(0)
        );

        --Ideal cutoff: 8377,3527Hz - Real cutoff: 8376,7843Hz - Error: 0,0068%
        U_BPF_9: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"677B",
            SPIKES_DIV_OUT  => x"677B",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_8(1),
            spike_in_slpf_n => lpf_spikes_8(0),
            spike_in_shf_p  => lpf_spikes_8(1),
            spike_in_shf_n  => lpf_spikes_8(0),
            spike_out_p     => spikes_out(17),
            spike_out_n     => spikes_out(16), 
            spike_out_lpf_p => lpf_spikes_9(1),
            spike_out_lpf_n => lpf_spikes_9(0)
        );

        --Ideal cutoff: 7822,4703Hz - Real cutoff: 7822,1477Hz - Error: 0,0041%
        U_BPF_10: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"60A1",
            SPIKES_DIV_OUT  => x"60A1",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_9(1),
            spike_in_slpf_n => lpf_spikes_9(0),
            spike_in_shf_p  => lpf_spikes_9(1),
            spike_in_shf_n  => lpf_spikes_9(0),
            spike_out_p     => spikes_out(19),
            spike_out_n     => spikes_out(18), 
            spike_out_lpf_p => lpf_spikes_10(1),
            spike_out_lpf_n => lpf_spikes_10(0)
        );

        --Ideal cutoff: 7304,3411Hz - Real cutoff: 7304,0335Hz - Error: 0,0042%
        U_BPF_11: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"784E",
            SPIKES_DIV_OUT  => x"784E",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_10(1),
            spike_in_slpf_n => lpf_spikes_10(0),
            spike_in_shf_p  => lpf_spikes_10(1),
            spike_in_shf_n  => lpf_spikes_10(0),
            spike_out_p     => spikes_out(21),
            spike_out_n     => spikes_out(20), 
            spike_out_lpf_p => lpf_spikes_11(1),
            spike_out_lpf_n => lpf_spikes_11(0)
        );

        --Ideal cutoff: 6820,5308Hz - Real cutoff: 6820,2285Hz - Error: 0,0044%
        U_BPF_12: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"7056",
            SPIKES_DIV_OUT  => x"7056",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_11(1),
            spike_in_slpf_n => lpf_spikes_11(0),
            spike_in_shf_p  => lpf_spikes_11(1),
            spike_in_shf_n  => lpf_spikes_11(0),
            spike_out_p     => spikes_out(23),
            spike_out_n     => spikes_out(22), 
            spike_out_lpf_p => lpf_spikes_12(1),
            spike_out_lpf_n => lpf_spikes_12(0)
        );

        --Ideal cutoff: 6368,7660Hz - Real cutoff: 6368,4399Hz - Error: 0,0051%
        U_BPF_13: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"68E5",
            SPIKES_DIV_OUT  => x"68E5",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_12(1),
            spike_in_slpf_n => lpf_spikes_12(0),
            spike_in_shf_p  => lpf_spikes_12(1),
            spike_in_shf_n  => lpf_spikes_12(0),
            spike_out_p     => spikes_out(25),
            spike_out_n     => spikes_out(24), 
            spike_out_lpf_p => lpf_spikes_13(1),
            spike_out_lpf_n => lpf_spikes_13(0)
        );

        --Ideal cutoff: 5946,9244Hz - Real cutoff: 5946,6283Hz - Error: 0,0050%
        U_BPF_14: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7A6F",
            SPIKES_DIV_OUT  => x"7A6F",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_13(1),
            spike_in_slpf_n => lpf_spikes_13(0),
            spike_in_shf_p  => lpf_spikes_13(1),
            spike_in_shf_n  => lpf_spikes_13(0),
            spike_out_p     => spikes_out(27),
            spike_out_n     => spikes_out(26), 
            spike_out_lpf_p => lpf_spikes_14(1),
            spike_out_lpf_n => lpf_spikes_14(0)
        );

        --Ideal cutoff: 5553,0239Hz - Real cutoff: 5552,7541Hz - Error: 0,0049%
        U_BPF_15: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7253",
            SPIKES_DIV_OUT  => x"7253",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_14(1),
            spike_in_slpf_n => lpf_spikes_14(0),
            spike_in_shf_p  => lpf_spikes_14(1),
            spike_in_shf_n  => lpf_spikes_14(0),
            spike_out_p     => spikes_out(29),
            spike_out_n     => spikes_out(28), 
            spike_out_lpf_p => lpf_spikes_15(1),
            spike_out_lpf_n => lpf_spikes_15(0)
        );

        --Ideal cutoff: 5185,2137Hz - Real cutoff: 5184,8725Hz - Error: 0,0066%
        U_BPF_16: spikes_2BPF_fullGain
        Generic Map (
            GL              => 9,
            SAT             => 255
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"6AC0",
            SPIKES_DIV_OUT  => x"6AC0",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_15(1),
            spike_in_slpf_n => lpf_spikes_15(0),
            spike_in_shf_p  => lpf_spikes_15(1),
            spike_in_shf_n  => lpf_spikes_15(0),
            spike_out_p     => spikes_out(31),
            spike_out_n     => spikes_out(30), 
            spike_out_lpf_p => lpf_spikes_16(1),
            spike_out_lpf_n => lpf_spikes_16(0)
        );

        --Ideal cutoff: 4841,7659Hz - Real cutoff: 4841,5290Hz - Error: 0,0049%
        U_BPF_17: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"779E",
            SPIKES_DIV_OUT  => x"779E",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_16(1),
            spike_in_slpf_n => lpf_spikes_16(0),
            spike_in_shf_p  => lpf_spikes_16(1),
            spike_in_shf_n  => lpf_spikes_16(0),
            spike_out_p     => spikes_out(33),
            spike_out_n     => spikes_out(32), 
            spike_out_lpf_p => lpf_spikes_17(1),
            spike_out_lpf_n => lpf_spikes_17(0)
        );

        --Ideal cutoff: 4521,0666Hz - Real cutoff: 4520,8896Hz - Error: 0,0039%
        U_BPF_18: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"6FB2",
            SPIKES_DIV_OUT  => x"6FB2",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_17(1),
            spike_in_slpf_n => lpf_spikes_17(0),
            spike_in_shf_p  => lpf_spikes_17(1),
            spike_in_shf_n  => lpf_spikes_17(0),
            spike_out_p     => spikes_out(35),
            spike_out_n     => spikes_out(34), 
            spike_out_lpf_p => lpf_spikes_18(1),
            spike_out_lpf_n => lpf_spikes_18(0)
        );

        --Ideal cutoff: 4221,6092Hz - Real cutoff: 4221,4364Hz - Error: 0,0041%
        U_BPF_19: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"684C",
            SPIKES_DIV_OUT  => x"684C",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_18(1),
            spike_in_slpf_n => lpf_spikes_18(0),
            spike_in_shf_p  => lpf_spikes_18(1),
            spike_in_shf_n  => lpf_spikes_18(0),
            spike_out_p     => spikes_out(37),
            spike_out_n     => spikes_out(36), 
            spike_out_lpf_p => lpf_spikes_19(1),
            spike_out_lpf_n => lpf_spikes_19(0)
        );

        --Ideal cutoff: 3941,9867Hz - Real cutoff: 3941,7464Hz - Error: 0,0061%
        U_BPF_20: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"6163",
            SPIKES_DIV_OUT  => x"6163",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_19(1),
            spike_in_slpf_n => lpf_spikes_19(0),
            spike_in_shf_p  => lpf_spikes_19(1),
            spike_in_shf_n  => lpf_spikes_19(0),
            spike_out_p     => spikes_out(39),
            spike_out_n     => spikes_out(38), 
            spike_out_lpf_p => lpf_spikes_20(1),
            spike_out_lpf_n => lpf_spikes_20(0)
        );

        --Ideal cutoff: 3680,8852Hz - Real cutoff: 3680,7131Hz - Error: 0,0047%
        U_BPF_21: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"7940",
            SPIKES_DIV_OUT  => x"7940",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_20(1),
            spike_in_slpf_n => lpf_spikes_20(0),
            spike_in_shf_p  => lpf_spikes_20(1),
            spike_in_shf_n  => lpf_spikes_20(0),
            spike_out_p     => spikes_out(41),
            spike_out_n     => spikes_out(40), 
            spike_out_lpf_p => lpf_spikes_21(1),
            spike_out_lpf_n => lpf_spikes_21(0)
        );

        --Ideal cutoff: 3437,0781Hz - Real cutoff: 3436,9132Hz - Error: 0,0048%
        U_BPF_22: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"7138",
            SPIKES_DIV_OUT  => x"7138",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_21(1),
            spike_in_slpf_n => lpf_spikes_21(0),
            spike_in_shf_p  => lpf_spikes_21(1),
            spike_in_shf_n  => lpf_spikes_21(0),
            spike_out_p     => spikes_out(43),
            spike_out_n     => spikes_out(42), 
            spike_out_lpf_p => lpf_spikes_22(1),
            spike_out_lpf_n => lpf_spikes_22(0)
        );

        --Ideal cutoff: 3209,4198Hz - Real cutoff: 3209,2403Hz - Error: 0,0056%
        U_BPF_23: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"69B8",
            SPIKES_DIV_OUT  => x"69B8",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_22(1),
            spike_in_slpf_n => lpf_spikes_22(0),
            spike_in_shf_p  => lpf_spikes_22(1),
            spike_in_shf_n  => lpf_spikes_22(0),
            spike_out_p     => spikes_out(45),
            spike_out_n     => spikes_out(44), 
            spike_out_lpf_p => lpf_spikes_23(1),
            spike_out_lpf_n => lpf_spikes_23(0)
        );

        --Ideal cutoff: 2996,8406Hz - Real cutoff: 2996,7455Hz - Error: 0,0032%
        U_BPF_24: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7B66",
            SPIKES_DIV_OUT  => x"7B66",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_23(1),
            spike_in_slpf_n => lpf_spikes_23(0),
            spike_in_shf_p  => lpf_spikes_23(1),
            spike_in_shf_n  => lpf_spikes_23(0),
            spike_out_p     => spikes_out(47),
            spike_out_n     => spikes_out(46), 
            spike_out_lpf_p => lpf_spikes_24(1),
            spike_out_lpf_n => lpf_spikes_24(0)
        );

        --Ideal cutoff: 2798,3419Hz - Real cutoff: 2798,1957Hz - Error: 0,0052%
        U_BPF_25: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7339",
            SPIKES_DIV_OUT  => x"7339",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_24(1),
            spike_in_slpf_n => lpf_spikes_24(0),
            spike_in_shf_p  => lpf_spikes_24(1),
            spike_in_shf_n  => lpf_spikes_24(0),
            spike_out_p     => spikes_out(49),
            spike_out_n     => spikes_out(48), 
            spike_out_lpf_p => lpf_spikes_25(1),
            spike_out_lpf_n => lpf_spikes_25(0)
        );

        --Ideal cutoff: 2612,9909Hz - Real cutoff: 2612,8319Hz - Error: 0,0061%
        U_BPF_26: spikes_2BPF_fullGain
        Generic Map (
            GL              => 10,
            SAT             => 511
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"6B97",
            SPIKES_DIV_OUT  => x"6B97",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_25(1),
            spike_in_slpf_n => lpf_spikes_25(0),
            spike_in_shf_p  => lpf_spikes_25(1),
            spike_in_shf_n  => lpf_spikes_25(0),
            spike_out_p     => spikes_out(51),
            spike_out_n     => spikes_out(50), 
            spike_out_lpf_p => lpf_spikes_26(1),
            spike_out_lpf_n => lpf_spikes_26(0)
        );

        --Ideal cutoff: 2439,9168Hz - Real cutoff: 2439,8163Hz - Error: 0,0041%
        U_BPF_27: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"788F",
            SPIKES_DIV_OUT  => x"788F",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_26(1),
            spike_in_slpf_n => lpf_spikes_26(0),
            spike_in_shf_p  => lpf_spikes_26(1),
            spike_in_shf_n  => lpf_spikes_26(0),
            spike_out_p     => spikes_out(53),
            spike_out_n     => spikes_out(52), 
            spike_out_lpf_p => lpf_spikes_27(1),
            spike_out_lpf_n => lpf_spikes_27(0)
        );

        --Ideal cutoff: 2278,3064Hz - Real cutoff: 2278,1527Hz - Error: 0,0067%
        U_BPF_28: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"7092",
            SPIKES_DIV_OUT  => x"7092",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_27(1),
            spike_in_slpf_n => lpf_spikes_27(0),
            spike_in_shf_p  => lpf_spikes_27(1),
            spike_in_shf_n  => lpf_spikes_27(0),
            spike_out_p     => spikes_out(55),
            spike_out_n     => spikes_out(54), 
            spike_out_lpf_p => lpf_spikes_28(1),
            spike_out_lpf_n => lpf_spikes_28(0)
        );

        --Ideal cutoff: 2127,4005Hz - Real cutoff: 2127,3193Hz - Error: 0,0038%
        U_BPF_29: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"691E",
            SPIKES_DIV_OUT  => x"691E",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_28(1),
            spike_in_slpf_n => lpf_spikes_28(0),
            spike_in_shf_p  => lpf_spikes_28(1),
            spike_in_shf_n  => lpf_spikes_28(0),
            spike_out_p     => spikes_out(57),
            spike_out_n     => spikes_out(56), 
            spike_out_lpf_p => lpf_spikes_29(1),
            spike_out_lpf_n => lpf_spikes_29(0)
        );

        --Ideal cutoff: 1986,4900Hz - Real cutoff: 1986,3676Hz - Error: 0,0062%
        U_BPF_30: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"6227",
            SPIKES_DIV_OUT  => x"6227",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_29(1),
            spike_in_slpf_n => lpf_spikes_29(0),
            spike_in_shf_p  => lpf_spikes_29(1),
            spike_in_shf_n  => lpf_spikes_29(0),
            spike_out_p     => spikes_out(59),
            spike_out_n     => spikes_out(58), 
            spike_out_lpf_p => lpf_spikes_30(1),
            spike_out_lpf_n => lpf_spikes_30(0)
        );

        --Ideal cutoff: 1854,9128Hz - Real cutoff: 1854,8232Hz - Error: 0,0048%
        U_BPF_31: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"7A34",
            SPIKES_DIV_OUT  => x"7A34",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_30(1),
            spike_in_slpf_n => lpf_spikes_30(0),
            spike_in_shf_p  => lpf_spikes_30(1),
            spike_in_shf_n  => lpf_spikes_30(0),
            spike_out_p     => spikes_out(61),
            spike_out_n     => spikes_out(60), 
            spike_out_lpf_p => lpf_spikes_31(1),
            spike_out_lpf_n => lpf_spikes_31(0)
        );

        --Ideal cutoff: 1732,0508Hz - Real cutoff: 1731,9747Hz - Error: 0,0044%
        U_BPF_32: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"721C",
            SPIKES_DIV_OUT  => x"721C",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_31(1),
            spike_in_slpf_n => lpf_spikes_31(0),
            spike_in_shf_p  => lpf_spikes_31(1),
            spike_in_shf_n  => lpf_spikes_31(0),
            spike_out_p     => spikes_out(63),
            spike_out_n     => spikes_out(62), 
            spike_out_lpf_p => lpf_spikes_32(1),
            spike_out_lpf_n => lpf_spikes_32(0)
        );

        --Ideal cutoff: 1617,3267Hz - Real cutoff: 1617,2489Hz - Error: 0,0048%
        U_BPF_33: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"6A8D",
            SPIKES_DIV_OUT  => x"6A8D",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_32(1),
            spike_in_slpf_n => lpf_spikes_32(0),
            spike_in_shf_p  => lpf_spikes_32(1),
            spike_in_shf_n  => lpf_spikes_32(0),
            spike_out_p     => spikes_out(65),
            spike_out_n     => spikes_out(64), 
            spike_out_lpf_p => lpf_spikes_33(1),
            spike_out_lpf_n => lpf_spikes_33(0)
        );

        --Ideal cutoff: 1510,2014Hz - Real cutoff: 1510,1359Hz - Error: 0,0043%
        U_BPF_34: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7C5E",
            SPIKES_DIV_OUT  => x"7C5E",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_33(1),
            spike_in_slpf_n => lpf_spikes_33(0),
            spike_in_shf_p  => lpf_spikes_33(1),
            spike_in_shf_n  => lpf_spikes_33(0),
            spike_out_p     => spikes_out(67),
            spike_out_n     => spikes_out(66), 
            spike_out_lpf_p => lpf_spikes_34(1),
            spike_out_lpf_n => lpf_spikes_34(0)
        );

        --Ideal cutoff: 1410,1717Hz - Real cutoff: 1410,1020Hz - Error: 0,0049%
        U_BPF_35: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7421",
            SPIKES_DIV_OUT  => x"7421",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_34(1),
            spike_in_slpf_n => lpf_spikes_34(0),
            spike_in_shf_p  => lpf_spikes_34(1),
            spike_in_shf_n  => lpf_spikes_34(0),
            spike_out_p     => spikes_out(69),
            spike_out_n     => spikes_out(68), 
            spike_out_lpf_p => lpf_spikes_35(1),
            spike_out_lpf_n => lpf_spikes_35(0)
        );

        --Ideal cutoff: 1316,7676Hz - Real cutoff: 1316,7087Hz - Error: 0,0045%
        U_BPF_36: spikes_2BPF_fullGain
        Generic Map (
            GL              => 11,
            SAT             => 1023
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"6C70",
            SPIKES_DIV_OUT  => x"6C70",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_35(1),
            spike_in_slpf_n => lpf_spikes_35(0),
            spike_in_shf_p  => lpf_spikes_35(1),
            spike_in_shf_n  => lpf_spikes_35(0),
            spike_out_p     => spikes_out(71),
            spike_out_n     => spikes_out(70), 
            spike_out_lpf_p => lpf_spikes_36(1),
            spike_out_lpf_n => lpf_spikes_36(0)
        );

        --Ideal cutoff: 1229,5501Hz - Real cutoff: 1229,4736Hz - Error: 0,0062%
        U_BPF_37: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"7981",
            SPIKES_DIV_OUT  => x"7981",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_36(1),
            spike_in_slpf_n => lpf_spikes_36(0),
            spike_in_shf_p  => lpf_spikes_36(1),
            spike_in_shf_n  => lpf_spikes_36(0),
            spike_out_p     => spikes_out(73),
            spike_out_n     => spikes_out(72), 
            spike_out_lpf_p => lpf_spikes_37(1),
            spike_out_lpf_n => lpf_spikes_37(0)
        );

        --Ideal cutoff: 1148,1096Hz - Real cutoff: 1148,0489Hz - Error: 0,0053%
        U_BPF_38: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"7175",
            SPIKES_DIV_OUT  => x"7175",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_37(1),
            spike_in_slpf_n => lpf_spikes_37(0),
            spike_in_shf_p  => lpf_spikes_37(1),
            spike_in_shf_n  => lpf_spikes_37(0),
            spike_out_p     => spikes_out(75),
            spike_out_n     => spikes_out(74), 
            spike_out_lpf_p => lpf_spikes_38(1),
            spike_out_lpf_n => lpf_spikes_38(0)
        );

        --Ideal cutoff: 1072,0634Hz - Real cutoff: 1071,9998Hz - Error: 0,0059%
        U_BPF_39: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"69F1",
            SPIKES_DIV_OUT  => x"69F1",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_38(1),
            spike_in_slpf_n => lpf_spikes_38(0),
            spike_in_shf_p  => lpf_spikes_38(1),
            spike_in_shf_n  => lpf_spikes_38(0),
            spike_out_p     => spikes_out(77),
            spike_out_n     => spikes_out(76), 
            spike_out_lpf_p => lpf_spikes_39(1),
            spike_out_lpf_n => lpf_spikes_39(0)
        );

        --Ideal cutoff: 1001,0542Hz - Real cutoff: 1001,0101Hz - Error: 0,0044%
        U_BPF_40: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"62ED",
            SPIKES_DIV_OUT  => x"62ED",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_39(1),
            spike_in_slpf_n => lpf_spikes_39(0),
            spike_in_shf_p  => lpf_spikes_39(1),
            spike_in_shf_n  => lpf_spikes_39(0),
            spike_out_p     => spikes_out(79),
            spike_out_n     => spikes_out(78), 
            spike_out_lpf_p => lpf_spikes_40(1),
            spike_out_lpf_n => lpf_spikes_40(0)
        );

        --Ideal cutoff: 934,7484Hz - Real cutoff: 934,7043Hz - Error: 0,0047%
        U_BPF_41: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"7B2A",
            SPIKES_DIV_OUT  => x"7B2A",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_40(1),
            spike_in_slpf_n => lpf_spikes_40(0),
            spike_in_shf_p  => lpf_spikes_40(1),
            spike_in_shf_n  => lpf_spikes_40(0),
            spike_out_p     => spikes_out(81),
            spike_out_n     => spikes_out(80), 
            spike_out_lpf_p => lpf_spikes_41(1),
            spike_out_lpf_n => lpf_spikes_41(0)
        );

        --Ideal cutoff: 872,8344Hz - Real cutoff: 872,7760Hz - Error: 0,0067%
        U_BPF_42: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"7301",
            SPIKES_DIV_OUT  => x"7301",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_41(1),
            spike_in_slpf_n => lpf_spikes_41(0),
            spike_in_shf_p  => lpf_spikes_41(1),
            spike_in_shf_n  => lpf_spikes_41(0),
            spike_out_p     => spikes_out(83),
            spike_out_n     => spikes_out(82), 
            spike_out_lpf_p => lpf_spikes_42(1),
            spike_out_lpf_n => lpf_spikes_42(0)
        );

        --Ideal cutoff: 815,0213Hz - Real cutoff: 814,9684Hz - Error: 0,0065%
        U_BPF_43: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"6B63",
            SPIKES_DIV_OUT  => x"6B63",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_42(1),
            spike_in_slpf_n => lpf_spikes_42(0),
            spike_in_shf_p  => lpf_spikes_42(1),
            spike_in_shf_n  => lpf_spikes_42(0),
            spike_out_p     => spikes_out(85),
            spike_out_n     => spikes_out(84), 
            spike_out_lpf_p => lpf_spikes_43(1),
            spike_out_lpf_n => lpf_spikes_43(0)
        );

        --Ideal cutoff: 761,0376Hz - Real cutoff: 760,9969Hz - Error: 0,0053%
        U_BPF_44: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7D58",
            SPIKES_DIV_OUT  => x"7D58",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_43(1),
            spike_in_slpf_n => lpf_spikes_43(0),
            spike_in_shf_p  => lpf_spikes_43(1),
            spike_in_shf_n  => lpf_spikes_43(0),
            spike_out_p     => spikes_out(87),
            spike_out_n     => spikes_out(86), 
            spike_out_lpf_p => lpf_spikes_44(1),
            spike_out_lpf_n => lpf_spikes_44(0)
        );

        --Ideal cutoff: 710,6295Hz - Real cutoff: 710,6005Hz - Error: 0,0041%
        U_BPF_45: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"750B",
            SPIKES_DIV_OUT  => x"750B",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_44(1),
            spike_in_slpf_n => lpf_spikes_44(0),
            spike_in_shf_p  => lpf_spikes_44(1),
            spike_in_shf_n  => lpf_spikes_44(0),
            spike_out_p     => spikes_out(89),
            spike_out_n     => spikes_out(88), 
            spike_out_lpf_p => lpf_spikes_45(1),
            spike_out_lpf_n => lpf_spikes_45(0)
        );

        --Ideal cutoff: 663,5602Hz - Real cutoff: 663,5244Hz - Error: 0,0054%
        U_BPF_46: spikes_2BPF_fullGain
        Generic Map (
            GL              => 12,
            SAT             => 2047
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"6D4A",
            SPIKES_DIV_OUT  => x"6D4A",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_45(1),
            spike_in_slpf_n => lpf_spikes_45(0),
            spike_in_shf_p  => lpf_spikes_45(1),
            spike_in_shf_n  => lpf_spikes_45(0),
            spike_out_p     => spikes_out(91),
            spike_out_n     => spikes_out(90), 
            spike_out_lpf_p => lpf_spikes_46(1),
            spike_out_lpf_n => lpf_spikes_46(0)
        );

        --Ideal cutoff: 619,6086Hz - Real cutoff: 619,5788Hz - Error: 0,0048%
        U_BPF_47: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"7A76",
            SPIKES_DIV_OUT  => x"7A76",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_46(1),
            spike_in_slpf_n => lpf_spikes_46(0),
            spike_in_shf_p  => lpf_spikes_46(1),
            spike_in_shf_n  => lpf_spikes_46(0),
            spike_out_p     => spikes_out(93),
            spike_out_n     => spikes_out(92), 
            spike_out_lpf_p => lpf_spikes_47(1),
            spike_out_lpf_n => lpf_spikes_47(0)
        );

        --Ideal cutoff: 578,5682Hz - Real cutoff: 578,5305Hz - Error: 0,0065%
        U_BPF_48: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"7259",
            SPIKES_DIV_OUT  => x"7259",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_47(1),
            spike_in_slpf_n => lpf_spikes_47(0),
            spike_in_shf_p  => lpf_spikes_47(1),
            spike_in_shf_n  => lpf_spikes_47(0),
            spike_out_p     => spikes_out(95),
            spike_out_n     => spikes_out(94), 
            spike_out_lpf_p => lpf_spikes_48(1),
            spike_out_lpf_n => lpf_spikes_48(0)
        );

        --Ideal cutoff: 540,2462Hz - Real cutoff: 540,2095Hz - Error: 0,0068%
        U_BPF_49: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"6AC6",
            SPIKES_DIV_OUT  => x"6AC6",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_48(1),
            spike_in_slpf_n => lpf_spikes_48(0),
            spike_in_shf_p  => lpf_spikes_48(1),
            spike_in_shf_n  => lpf_spikes_48(0),
            spike_out_p     => spikes_out(97),
            spike_out_n     => spikes_out(96), 
            spike_out_lpf_p => lpf_spikes_49(1),
            spike_out_lpf_n => lpf_spikes_49(0)
        );

        --Ideal cutoff: 504,4624Hz - Real cutoff: 504,4379Hz - Error: 0,0049%
        U_BPF_50: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"63B4",
            SPIKES_DIV_OUT  => x"63B4",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_49(1),
            spike_in_slpf_n => lpf_spikes_49(0),
            spike_in_shf_p  => lpf_spikes_49(1),
            spike_in_shf_n  => lpf_spikes_49(0),
            spike_out_p     => spikes_out(99),
            spike_out_n     => spikes_out(98), 
            spike_out_lpf_p => lpf_spikes_50(1),
            spike_out_lpf_n => lpf_spikes_50(0)
        );

        --Ideal cutoff: 471,0489Hz - Real cutoff: 471,0281Hz - Error: 0,0044%
        U_BPF_51: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"7C22",
            SPIKES_DIV_OUT  => x"7C22",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_50(1),
            spike_in_slpf_n => lpf_spikes_50(0),
            spike_in_shf_p  => lpf_spikes_50(1),
            spike_in_shf_n  => lpf_spikes_50(0),
            spike_out_p     => spikes_out(101),
            spike_out_n     => spikes_out(100), 
            spike_out_lpf_p => lpf_spikes_51(1),
            spike_out_lpf_n => lpf_spikes_51(0)
        );

        --Ideal cutoff: 439,8485Hz - Real cutoff: 439,8268Hz - Error: 0,0049%
        U_BPF_52: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"73E9",
            SPIKES_DIV_OUT  => x"73E9",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_51(1),
            spike_in_slpf_n => lpf_spikes_51(0),
            spike_in_shf_p  => lpf_spikes_51(1),
            spike_in_shf_n  => lpf_spikes_51(0),
            spike_out_p     => spikes_out(103),
            spike_out_n     => spikes_out(102), 
            spike_out_lpf_p => lpf_spikes_52(1),
            spike_out_lpf_n => lpf_spikes_52(0)
        );

        --Ideal cutoff: 410,7147Hz - Real cutoff: 410,6859Hz - Error: 0,0070%
        U_BPF_53: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"6C3B",
            SPIKES_DIV_OUT  => x"6C3B",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_52(1),
            spike_in_slpf_n => lpf_spikes_52(0),
            spike_in_shf_p  => lpf_spikes_52(1),
            spike_in_shf_n  => lpf_spikes_52(0),
            spike_out_p     => spikes_out(105),
            spike_out_n     => spikes_out(104), 
            spike_out_lpf_p => lpf_spikes_53(1),
            spike_out_lpf_n => lpf_spikes_53(0)
        );

        --Ideal cutoff: 383,5106Hz - Real cutoff: 383,4985Hz - Error: 0,0031%
        U_BPF_54: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7E55",
            SPIKES_DIV_OUT  => x"7E55",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_53(1),
            spike_in_slpf_n => lpf_spikes_53(0),
            spike_in_shf_p  => lpf_spikes_53(1),
            spike_in_shf_n  => lpf_spikes_53(0),
            spike_out_p     => spikes_out(107),
            spike_out_n     => spikes_out(106), 
            spike_out_lpf_p => lpf_spikes_54(1),
            spike_out_lpf_n => lpf_spikes_54(0)
        );

        --Ideal cutoff: 358,1084Hz - Real cutoff: 358,0869Hz - Error: 0,0060%
        U_BPF_55: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"75F6",
            SPIKES_DIV_OUT  => x"75F6",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_54(1),
            spike_in_slpf_n => lpf_spikes_54(0),
            spike_in_shf_p  => lpf_spikes_54(1),
            spike_in_shf_n  => lpf_spikes_54(0),
            spike_out_p     => spikes_out(109),
            spike_out_n     => spikes_out(108), 
            spike_out_lpf_p => lpf_spikes_55(1),
            spike_out_lpf_n => lpf_spikes_55(0)
        );

        --Ideal cutoff: 334,3887Hz - Real cutoff: 334,3710Hz - Error: 0,0053%
        U_BPF_56: spikes_2BPF_fullGain
        Generic Map (
            GL              => 13,
            SAT             => 4095
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"6E26",
            SPIKES_DIV_OUT  => x"6E26",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_55(1),
            spike_in_slpf_n => lpf_spikes_55(0),
            spike_in_shf_p  => lpf_spikes_55(1),
            spike_in_shf_n  => lpf_spikes_55(0),
            spike_out_p     => spikes_out(111),
            spike_out_n     => spikes_out(110), 
            spike_out_lpf_p => lpf_spikes_56(1),
            spike_out_lpf_n => lpf_spikes_56(0)
        );

        --Ideal cutoff: 312,2401Hz - Real cutoff: 312,2302Hz - Error: 0,0032%
        U_BPF_57: spikes_2BPF_fullGain
        Generic Map (
            GL              => 14,
            SAT             => 8191
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"7B6D",
            SPIKES_DIV_OUT  => x"7B6D",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_56(1),
            spike_in_slpf_n => lpf_spikes_56(0),
            spike_in_shf_p  => lpf_spikes_56(1),
            spike_in_shf_n  => lpf_spikes_56(0),
            spike_out_p     => spikes_out(113),
            spike_out_n     => spikes_out(112), 
            spike_out_lpf_p => lpf_spikes_57(1),
            spike_out_lpf_n => lpf_spikes_57(0)
        );

        --Ideal cutoff: 291,5586Hz - Real cutoff: 291,5479Hz - Error: 0,0037%
        U_BPF_58: spikes_2BPF_fullGain
        Generic Map (
            GL              => 14,
            SAT             => 8191
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"7340",
            SPIKES_DIV_OUT  => x"7340",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_57(1),
            spike_in_slpf_n => lpf_spikes_57(0),
            spike_in_shf_p  => lpf_spikes_57(1),
            spike_in_shf_n  => lpf_spikes_57(0),
            spike_out_p     => spikes_out(115),
            spike_out_n     => spikes_out(114), 
            spike_out_lpf_p => lpf_spikes_58(1),
            spike_out_lpf_n => lpf_spikes_58(0)
        );

        --Ideal cutoff: 272,2469Hz - Real cutoff: 272,2293Hz - Error: 0,0065%
        U_BPF_59: spikes_2BPF_fullGain
        Generic Map (
            GL              => 14,
            SAT             => 8191
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"6B9D",
            SPIKES_DIV_OUT  => x"6B9D",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_58(1),
            spike_in_slpf_n => lpf_spikes_58(0),
            spike_in_shf_p  => lpf_spikes_58(1),
            spike_in_shf_n  => lpf_spikes_58(0),
            spike_out_p     => spikes_out(117),
            spike_out_n     => spikes_out(116), 
            spike_out_lpf_p => lpf_spikes_59(1),
            spike_out_lpf_n => lpf_spikes_59(0)
        );

        --Ideal cutoff: 254,2144Hz - Real cutoff: 254,1953Hz - Error: 0,0075%
        U_BPF_60: spikes_2BPF_fullGain
        Generic Map (
            GL              => 14,
            SAT             => 8191
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"02",
            SPIKES_DIV_FB   => x"647C",
            SPIKES_DIV_OUT  => x"647C",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_59(1),
            spike_in_slpf_n => lpf_spikes_59(0),
            spike_in_shf_p  => lpf_spikes_59(1),
            spike_in_shf_n  => lpf_spikes_59(0),
            spike_out_p     => spikes_out(119),
            spike_out_n     => spikes_out(118), 
            spike_out_lpf_p => lpf_spikes_60(1),
            spike_out_lpf_n => lpf_spikes_60(0)
        );

        --Ideal cutoff: 237,3762Hz - Real cutoff: 237,3669Hz - Error: 0,0039%
        U_BPF_61: spikes_2BPF_fullGain
        Generic Map (
            GL              => 14,
            SAT             => 8191
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"7D1C",
            SPIKES_DIV_OUT  => x"7D1C",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_60(1),
            spike_in_slpf_n => lpf_spikes_60(0),
            spike_in_shf_p  => lpf_spikes_60(1),
            spike_in_shf_n  => lpf_spikes_60(0),
            spike_out_p     => spikes_out(121),
            spike_out_n     => spikes_out(120), 
            spike_out_lpf_p => lpf_spikes_61(1),
            spike_out_lpf_n => lpf_spikes_61(0)
        );

        --Ideal cutoff: 221,6534Hz - Real cutoff: 221,6402Hz - Error: 0,0059%
        U_BPF_62: spikes_2BPF_fullGain
        Generic Map (
            GL              => 14,
            SAT             => 8191
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"74D2",
            SPIKES_DIV_OUT  => x"74D2",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_61(1),
            spike_in_slpf_n => lpf_spikes_61(0),
            spike_in_shf_p  => lpf_spikes_61(1),
            spike_in_shf_n  => lpf_spikes_61(0),
            spike_out_p     => spikes_out(123),
            spike_out_n     => spikes_out(122), 
            spike_out_lpf_p => lpf_spikes_62(1),
            spike_out_lpf_n => lpf_spikes_62(0)
        );

        --Ideal cutoff: 206,9719Hz - Real cutoff: 206,9586Hz - Error: 0,0064%
        U_BPF_63: spikes_2BPF_fullGain
        Generic Map (
            GL              => 14,
            SAT             => 8191
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"03",
            SPIKES_DIV_FB   => x"6D15",
            SPIKES_DIV_OUT  => x"6D15",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_62(1),
            spike_in_slpf_n => lpf_spikes_62(0),
            spike_in_shf_p  => lpf_spikes_62(1),
            spike_in_shf_n  => lpf_spikes_62(0),
            spike_out_p     => spikes_out(125),
            spike_out_n     => spikes_out(124), 
            spike_out_lpf_p => lpf_spikes_63(1),
            spike_out_lpf_n => lpf_spikes_63(0)
        );

        --Ideal cutoff: 193,2629Hz - Real cutoff: 193,2552Hz - Error: 0,0040%
        U_BPF_64: spikes_2BPF_fullGain
        Generic Map (
            GL              => 14,
            SAT             => 8191
        )
        Port map (
            CLK             => clock,
            RST             => not_rst,
            FREQ_DIV        => x"04",
            SPIKES_DIV_FB   => x"7F53",
            SPIKES_DIV_OUT  => x"7F53",
            SPIKES_DIV_BPF  => x"2025",
            spike_in_slpf_p => lpf_spikes_63(1),
            spike_in_slpf_n => lpf_spikes_63(0),
            spike_in_shf_p  => lpf_spikes_63(1),
            spike_in_shf_n  => lpf_spikes_63(0),
            spike_out_p     => spikes_out(127),
            spike_out_n     => spikes_out(126), 
            spike_out_lpf_p => lpf_spikes_64(1),
            spike_out_lpf_n => lpf_spikes_64(0)
        );

end CFBank_arq;
