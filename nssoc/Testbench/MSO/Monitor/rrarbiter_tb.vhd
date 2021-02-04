-- -----------------------------------------------------------------------------
-- Copyright (c) 2009 Benjamin Krill <benjamin@krll.de>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_Logic_unsigned.all;
use IEEE.numeric_std.all;

entity rrarbiter_tb is
end rrarbiter_tb;

architecture rtl of rrarbiter_tb is

	component rrarbiter is
		generic ( CNT : integer := 7 );
		port (
			clk   : in    std_logic;
			rst_n : in    std_logic;

			req   : in    std_logic_vector(CNT-1 downto 0);
			ack   : in    std_logic;
			grant : out   std_logic_vector(CNT-1 downto 0)
		);
	end component;

	constant CLK_PERIOD : time := 36 ns;

	signal clk       : std_logic;
	signal rst       : std_logic;
	signal rst_n     : std_logic;

	signal req       : std_logic_vector(6 downto 0);
	signal grant     : std_logic_vector(6 downto 0);
	signal ack       : std_logic;
begin

    DUT: rrarbiter
    generic map (
        CNT   => 7
    )
	port map (
		clk   => clk,
		rst_n => rst_n,

		ack   => ack,
		req   => req,
		grant => grant
	);
    
	rst   <= transport '1', '0' after ( 4 * CLK_PERIOD);
	rst_n <= not rst;

	clock:	process
	begin
		clk <= '1', '0' after CLK_PERIOD/2;
		wait for Clk_PERIOD;
	end process;

	beh: process
	begin
		req <= "0000000";
		wait for 10*CLK_PERIOD;
		req <= "0000011";
		wait for 5*CLK_PERIOD;
		req <= "0000000";
		wait for 5*CLK_PERIOD;
		req <= "0001111";
		wait for 5*CLK_PERIOD;
		req <= "0001110";
		wait for 20*CLK_PERIOD;
		req <= "0000000";
		wait for 20*CLK_PERIOD;
		wait;
	end process beh;

	beh0: process
	begin
		ack <= '0';
		wait for 10*CLK_PERIOD;
		wait for 6*CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for 8*CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for 5*CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for 2*CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		ack <= '1';
		wait for CLK_PERIOD;
		ack <= '0';
		wait for CLK_PERIOD;
		wait for 20*CLK_PERIOD;
		wait;
	end process beh0;

end rtl;

configuration rrarbiter_tb_rtl_cfg of rrarbiter_tb is
  for rtl
  end for;
end rrarbiter_tb_rtl_cfg;