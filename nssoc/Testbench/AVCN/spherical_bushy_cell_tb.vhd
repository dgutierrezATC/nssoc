----------------------------------------------------------------------------------
-- Company: University of Sevilla
-- Engineer: Daniel Gutierrez-Galan
-- 
-- Create Date: 12.12.2018 14:14:23
-- Design Name: 
-- Module Name: spherical_bushy_cell_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY spherical_bushy_cell_tb IS
    --  Port ( );
END spherical_bushy_cell_tb;

ARCHITECTURE Behavioral OF spherical_bushy_cell_tb IS

    --Component declaration for the Unit Under Test (UUT)
    COMPONENT spherical_bushy_cell IS
        PORT (
            i_clock : IN std_logic;
            i_nreset : IN std_logic;
            i_pos_spike : IN std_logic;
            i_neg_spike : IN std_logic;
            o_phase_locked_spike : OUT std_logic
        );
    END COMPONENT;

    --Constants
    CONSTANT clock_period : TIME := 20 ns;

    --Inputs
    SIGNAL i_clock : std_logic := '0';
    SIGNAL i_nreset : std_logic := '0';
    SIGNAL i_pos_spike : std_logic := '0';
    SIGNAL i_neg_spike : std_logic := '0';

    --Outputs
    SIGNAL o_phase_locked_spike : std_logic;

BEGIN

    --Instantiate the Unit Under Test (UUT)
    uut : spherical_bushy_cell
    PORT MAP(
        i_clock => i_clock,
        i_nreset => i_nreset,
        i_pos_spike => i_pos_spike,
        i_neg_spike => i_neg_spike,
        o_phase_locked_spike => o_phase_locked_spike
    );

    --Clock generation
    i_clock <= NOT i_clock AFTER clock_period/2;

    --Reset process
    reset_proc : PROCESS
    BEGIN
        i_nreset <= '0';
        WAIT FOR clock_period * 2;
        i_nreset <= '1';
        WAIT;
    END PROCESS reset_proc;

    --Stimulus process
    stim_proc : PROCESS
        VARIABLE num_iter : INTEGER := 0;
    BEGIN
        WHILE(num_iter < 10) LOOP
            FOR tiempo IN 0 TO 10 LOOP
                i_pos_spike <= '1';
                WAIT FOR clock_period;
                i_pos_spike <= '0';
                WAIT FOR 400 us;
            END LOOP;

            FOR tiempo IN 0 TO 10 LOOP
                i_neg_spike <= '1';
                WAIT FOR clock_period;
                i_neg_spike <= '0';
                WAIT FOR 400 us;
            END LOOP;

            num_iter := num_iter + 1;

        END LOOP;

    END PROCESS stim_proc;

END Behavioral;