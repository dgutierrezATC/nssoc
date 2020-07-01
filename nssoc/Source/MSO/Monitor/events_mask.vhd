----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:21:31 06/13/2019 
-- Design Name: 
-- Module Name:    events_mask - Behavioral 
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

entity events_mask is
	Generic (
		NBITS_ADDRESS : INTEGER := 4;
		CHANNEL_VAL   : INTEGER := 1
	);
	Port ( 
		i_input_address     : in  STD_LOGIC_VECTOR ((NBITS_ADDRESS-1) downto 0);
		o_output_masked_aer : out STD_LOGIC_VECTOR (15 downto 0)
	);
end events_mask;

architecture Behavioral of events_mask is

    constant channel_mask : std_logic_vector(5 downto 0) := std_logic_vector(to_unsigned(CHANNEL_VAL, 6));
    
    constant SSSL         : std_logic := '1'; -- '0' means NAS data; '1' means Sound Source Localization data
    constant xSO_type     : std_logic := '0'; -- '0' means MSO; '1' means LSO
    constant LR           : std_logic := '0'; -- This field does not care
    constant POL          : std_logic := '0'; -- '0' means POSITIVE; '1' means NEGATIVE.
    --constant filler       : std_logic_vector(5 downto 0) := (others => '0');
    constant filler       : std_logic_vector(1 downto 0) := "00";
	
    signal masked_aer     : std_logic_vector(15 downto 0);
    
    begin
        
        -- mask_process: process(i_input_address)
            -- variable v_filler_index : INTEGER := 0;
        -- begin
            -- v_filler_index := 6 - NBITS_ADDRESS;
            -- if(v_filler_index > 1) then
                -- masked_aer <= SSSL & xSO_type & filler((v_filler_index - 1) downto 0) & i_input_address & LR & channel_mask & POL;
            -- elsif(v_filler_index = 1) then
                -- masked_aer <= SSSL & xSO_type & filler(0) & i_input_address & LR & channel_mask & POL;
            -- else
                -- masked_aer <= SSSL & xSO_type & i_input_address & LR & channel_mask & POL;
            -- end if;
        -- end process mask_process;
		
		mask_process: process(i_input_address)
        begin
            masked_aer <= SSSL & xSO_type & filler & i_input_address & LR & channel_mask & POL;
        end process mask_process;
        
        o_output_masked_aer <= masked_aer;
	
end Behavioral;

