----------------------------------------------------------------------------------
-- Company: University of Seville
-- Engineer: Daniel Gutierrez-Galan
-- 
-- Create Date:    10:09:34 13/06/2019 
-- Design Name: 
-- Module Name:    events_encoder - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity events_encoder is
	Generic (
		N_EVENTS      : integer := 16; -- Max number of input event IDs (from 0 to 15): NUM_NEURONS_JEFFRESS_MODEL
		NBITS_ADDRESS : integer := 4 -- Log2(N_EVENTS)
	);
	Port ( 
		i_clock           : in  STD_LOGIC;
		i_reset           : in  STD_LOGIC;
		i_in_events       : in  STD_LOGIC_VECTOR ((N_EVENTS-1) downto 0);
		o_out_address     : out STD_LOGIC_VECTOR ((NBITS_ADDRESS-1) downto 0);
		o_new_out_address : out STD_LOGIC
	);
end events_encoder;

architecture Behavioral of events_encoder is

begin
--	main_process: process(i_reset, i_clock)
--	begin
--		if (i_reset = '0') then
--			o_out_address     <= (others => '0');
--			o_new_out_address <= '0';
--		else
--            if (rising_edge(i_clock)) then
--                for i in 0 to (N_EVENTS-1) loop
--                    if(i_in_events(i) = '1') then -- We can do this because we are sure we only will get 1 spike at the same time
--                        o_out_address     <= std_logic_vector(to_unsigned(i, o_out_address'length));
--                        o_new_out_address <= '1';
--                        exit;
--                    else
--                        o_new_out_address <= '0';
--                    end if;
--                end loop;
--            else
                
--            end if;
--        end if;
--	end process main_process;
	
        main_process: process(i_in_events)
        begin
            for i in 0 to (N_EVENTS-1) loop
                if(i_in_events(i) = '1') then -- We can do this because we are sure we only will get 1 spike at the same time
                    o_out_address     <= std_logic_vector(to_unsigned(i, o_out_address'length));
                    o_new_out_address <= '1';
                    exit;
                else
                    o_new_out_address <= '0';
                    o_out_address     <= (others => '0');
                end if;
            end loop;
        end process main_process;

end Behavioral;

