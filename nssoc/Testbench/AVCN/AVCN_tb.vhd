----------------------------------------------------------------------------------
-- Company: University of Sevilla
-- Engineer: Daniel Gutierrez-Galan
-- 
-- Create Date: 12.12.2018 14:14:23
-- Design Name: 
-- Module Name: AVCN_tb - Behavioral
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

ENTITY AVCN_tb IS
    --  Port ( );
END AVCN_tb;

ARCHITECTURE Behavioral OF AVCN_tb IS

    COMPONENT AVCN IS
        GENERIC (
            NUM_FREQ_CH : INTEGER := 36
        );
        PORT (
            i_clock : IN std_logic;
            i_nreset : IN std_logic;
            i_auditory_nerve_spikes : IN std_logic_vector(((NUM_FREQ_CH * 2) - 1) DOWNTO 0);
            o_phase_locked_spikes : OUT std_logic_vector((NUM_FREQ_CH - 1) DOWNTO 0)
        );
    END COMPONENT;

    --Constants
    CONSTANT clock_period : TIME := 20 ns;
    CONSTANT c_num_freq_ch : INTEGER := 4;

    --Inputs
    SIGNAL i_clock : std_logic := '0';
    SIGNAL i_nreset : std_logic := '0';
    SIGNAL i_auditory_nerve_spikes : std_logic_vector(((c_num_freq_ch * 2) - 1) DOWNTO 0) := (OTHERS => '0');
    --Outputs
    SIGNAL o_phase_locked_spikes : std_logic_vector((c_num_freq_ch - 1) DOWNTO 0);

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : AVCN
    GENERIC MAP(
        NUM_FREQ_CH => c_num_freq_ch
    )
    PORT MAP(
        i_clock => i_clock,
        i_nreset => i_nreset,
        i_auditory_nerve_spikes => i_auditory_nerve_spikes,
        o_phase_locked_spikes => o_phase_locked_spikes
    );

    --Clock generation
    i_clock <= NOT i_clock AFTER clock_period/2;
    --Stimulus process
    stim_proc : PROCESS
    BEGIN
        --Start reset
        i_nreset <= '0';
        WAIT FOR 1 ms;
        i_nreset <= '1';
        WAIT FOR 1 ms;
        --Finish reset

        --------------------------------------------
        --First case: single spike
        --------------------------------------------
        i_auditory_nerve_spikes(0) <= '1';
        WAIT FOR clock_period;
        i_auditory_nerve_spikes(0) <= '0';

        WAIT FOR clock_period * 2;

        i_auditory_nerve_spikes(1) <= '1';
        WAIT FOR clock_period;
        i_auditory_nerve_spikes(1) <= '0';

        WAIT FOR clock_period * 2;

        i_auditory_nerve_spikes(0) <= '1';
        WAIT FOR clock_period;
        i_auditory_nerve_spikes(0) <= '0';
        WAIT;

        --------------------------------------------
        --Second case: spike bursts
        --------------------------------------------

        WHILE(num_iter < 10) LOOP
            FOR tiempo IN 0 TO 10 LOOP
                i_auditory_nerve_spikes(0) <= '1';
                WAIT FOR clock_period;
                i_auditory_nerve_spikes(0) <= '0';
                WAIT FOR 400 us;
            END LOOP;

            FOR tiempo IN 0 TO 10 LOOP
                i_auditory_nerve_spikes(1) <= '1';
                WAIT FOR clock_period;
                i_auditory_nerve_spikes(1) <= '0';
                WAIT FOR 400 us;
            END LOOP;

            num_iter := num_iter + 1;

        END LOOP;

    END PROCESS;

END Behavioral;