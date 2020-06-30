----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:35:08 09/06/2007 
-- Design Name: 
-- Module Name:    AER_HOLDER_AND_FIRE - Behavioral 
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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY ild_estimator_neuron IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        SET : IN STD_LOGIC;
        HOLD_PULSE : OUT STD_LOGIC
    );
END ild_estimator_neuron;

ARCHITECTURE Behavioral OF ild_estimator_neuron IS

    TYPE STATE_TYPE IS (IDLE, HOLD);

    SIGNAL CS : STATE_TYPE;
    SIGNAL NS : STATE_TYPE;

BEGIN

    PROCESS (RST, SET, CS, NS)
    BEGIN
        CASE CS IS
            WHEN IDLE =>
                HOLD_PULSE <= '0';
                IF (SET = '1') THEN
                    NS <= HOLD;
                ELSE
                    NS <= IDLE;
                END IF;
            WHEN HOLD =>
                HOLD_PULSE <= '1';
                NS <= HOLD;
                --when others=> --Warning: nunca se va a dar este caso porque se contemplan todos los casos posibles anteriormente
                --HOLD_PULSE<='0';	
                --NS<=IDLE;
        END CASE;

    END PROCESS;

    PROCESS (CLK, RST, CS, NS)
    BEGIN

        IF (CLK = '1' AND CLK'event) THEN
            IF (RST = '1') THEN
                CS <= IDLE;
            ELSE
                CS <= NS;
            END IF;
        ELSE

        END IF;

    END PROCESS;
END Behavioral;