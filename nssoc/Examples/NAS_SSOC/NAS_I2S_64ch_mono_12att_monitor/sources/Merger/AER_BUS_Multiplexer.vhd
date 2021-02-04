----------------------------------------------------------------------------------
-- Company: University of Sevilla
-- Engineer: Antonio Rios-Navarro
-- 
-- Create Date:    10:42:55 12/09/2014 
-- Modification date: 15:58 23/08/2019
-- Modified by: Daniel Gutierrez-Galan
-- Design Name: 
-- Module Name:    AER_BUS_Multiplexer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY AER_BUS_Multiplexer IS
    PORT (
        i_input_sel    : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

        i_aer_data_nas : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        i_aer_req_nas  : IN  STD_LOGIC;
        o_aer_ack_nas  : OUT STD_LOGIC;

        i_aer_data_mso : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        i_aer_req_mso  : IN  STD_LOGIC;
        o_aer_ack_mso  : OUT STD_LOGIC;

        o_aer_data_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        o_aer_req_out  : OUT STD_LOGIC;
        i_aer_ack_out  : IN  STD_LOGIC
    );
END AER_BUS_Multiplexer;

ARCHITECTURE Behavioral OF AER_BUS_Multiplexer IS

    signal sel: std_logic;

    BEGIN


        sel <= i_input_sel(0);

        multiplexer : PROCESS (sel, i_aer_data_mso, i_aer_req_mso, i_aer_data_nas, i_aer_req_nas, i_aer_ack_out)
        BEGIN

    --        --CASE i_input_sel IS
    --        CASE sel IS
    --            --WHEN "11" =>
    --            WHEN '0' =>
    --                o_aer_data_out <= i_aer_data_nas;
    --                o_aer_req_out <= i_aer_req_nas;
    --                o_aer_ack_nas <= i_aer_ack_out;
    --                o_aer_ack_mso <= '1';

    --            --WHEN "01" =>
    --            WHEN '1' =>
    --                o_aer_data_out <= i_aer_data_mso;
    --                o_aer_req_out <= i_aer_req_mso;
    --                o_aer_ack_mso <= i_aer_ack_out;
    --                o_aer_ack_nas <= '1';

    --            -- WHEN OTHERS =>
    --            --     o_aer_data_out <= x"000F";--(OTHERS => '0');
    --            --     o_aer_req_out <= '1';
    --            --     o_aer_ack_nas <= '1';
    --            --     o_aer_ack_mso <= '1';

    --        END CASE;

                if(sel = '0') then
                    o_aer_data_out <= i_aer_data_nas;
                    o_aer_req_out <= i_aer_req_nas;
                    o_aer_ack_nas <= i_aer_ack_out;
                    o_aer_ack_mso <= '1';
                else
                    o_aer_data_out <= i_aer_data_mso;
                    o_aer_req_out <= i_aer_req_mso;
                    o_aer_ack_mso <= i_aer_ack_out;
                    o_aer_ack_nas <= '1';
                end if;

        END PROCESS multiplexer;

END Behavioral;