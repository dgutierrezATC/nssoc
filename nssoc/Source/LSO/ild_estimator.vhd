----------------------------------------------------------------------------------
-- Company: University of Sevilla
-- Engineer: Daniel Gutierrez-Galan
-- 
-- Create Date:    12:35:08 09/06/2007 
-- Design Name: 
-- Module Name:    ild_estimator_neuron - Behavioral 
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
-- Based on the original AER_DIFF model
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY ild_estimator IS
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        SPIKES_IN_UP : IN STD_LOGIC;
        SPIKES_IN_UN : IN STD_LOGIC;
        SPIKES_IN_YP : IN STD_LOGIC;
        SPIKES_IN_YN : IN STD_LOGIC;
        SPIKES_OUT_P : OUT STD_LOGIC;
        SPIKES_OUT_N : OUT STD_LOGIC
    );
END ild_estimator;

ARCHITECTURE Behavioral OF ild_estimator IS
    COMPONENT ild_estimator_neuron IS
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            SET : IN STD_LOGIC;
            HOLD_PULSE : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL SPIKES_IN : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL SPIKES_IN_TEMP : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL SPIKES_OUT : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL SPIKES_HOLD : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL SPIKES_SET : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL SPIKES_RST : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL SPIKES_EXTRAS : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

    SPIKES_OUT <= SPIKES_EXTRAS; --realmente puede ser solo spikes_extras no?

    SPIKES_OUT_P <= SPIKES_OUT(1);
    SPIKES_OUT_N <= SPIKES_OUT(0);
    WITH SPIKES_IN_TEMP SELECT
        SPIKES_IN <=
        (OTHERS => '0') WHEN b"0011",
        (OTHERS => '0') WHEN b"1100",
        (OTHERS => '0') WHEN b"0101",
        (OTHERS => '0') WHEN b"1010",
        (OTHERS => '0') WHEN b"1111",
        b"0100" WHEN b"0110",
        b"1000" WHEN b"1001",
        b"1000" WHEN b"1011",
        b"0100" WHEN b"0111",
        b"0010" WHEN b"1110",
        b"0001" WHEN b"1101",
        SPIKES_IN_TEMP WHEN OTHERS;
    --tpo u: 0x0fff - tpo y: 0x0002
    u_ild_estimator_neuron_Up : ild_estimator_neuron
    PORT MAP(
        CLK => clk,
        RST => SPIKES_RST(3),
        SET => SPIKES_SET(3),
        HOLD_PULSE => SPIKES_HOLD(3)
    );

    u_ild_estimator_neuron_Un : ild_estimator_neuron
    PORT MAP(
        CLK => clk,
        RST => SPIKES_RST(2),
        SET => SPIKES_SET(2),
        HOLD_PULSE => SPIKES_HOLD(2)
    );

    u_ild_estimator_neuron_Yp : ild_estimator_neuron
    PORT MAP(
        CLK => clk,
        RST => SPIKES_RST(1),
        SET => SPIKES_SET(1),
        HOLD_PULSE => SPIKES_HOLD(1)
    );

    u_ild_estimator_neuron_Yn : ild_estimator_neuron
    PORT MAP(
        CLK => clk,
        RST => SPIKES_RST(0),
        SET => SPIKES_SET(0),
        HOLD_PULSE => SPIKES_HOLD(0)
    );

    PROCESS (rst, spikes_in, spikes_hold, SPIKES_IN_UP, SPIKES_IN_UN, SPIKES_IN_YP, SPIKES_IN_YN)
    BEGIN

        IF (rst = '0') THEN
            SPIKES_SET <= (OTHERS => '0');
            SPIKES_RST <= (OTHERS => '1');
            SPIKES_EXTRAS <= (OTHERS => '0');
            SPIKES_IN_TEMP <= (OTHERS => '0');--OJO CON ESTO
        ELSE
            SPIKES_IN_TEMP <= SPIKES_IN_UP & SPIKES_IN_UN & SPIKES_IN_YP & SPIKES_IN_YN;

            CASE SPIKES_HOLD IS
                WHEN b"0000" =>
                    SPIKES_SET <= SPIKES_IN;
                    SPIKES_RST <= (OTHERS => '0');
                    SPIKES_EXTRAS <= (OTHERS => '0');
                WHEN b"1000" => --Retenido U+
                    CASE SPIKES_IN IS
                        WHEN b"0000" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN b"1000" =>
                            SPIKES_SET <= b"1000";
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= b"10";
                        WHEN b"0100" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= b"1000";
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN b"0010" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= b"1000";
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN b"0001" =>
                            SPIKES_SET <= b"0001";
                            SPIKES_RST <= b"1000";
                            SPIKES_EXTRAS <= b"10";
                        WHEN OTHERS =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= (OTHERS => '0');
                    END CASE;
                WHEN b"0100" => --Retenido U-
                    CASE SPIKES_IN IS
                        WHEN b"0000" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN b"1000" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= b"0100";
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN b"0100" =>
                            SPIKES_SET <= b"0100";
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= b"01";
                        WHEN b"0010" =>
                            SPIKES_SET <= b"0010";
                            SPIKES_RST <= b"0100";
                            SPIKES_EXTRAS <= b"01";
                        WHEN b"0001" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= b"0100";
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN OTHERS =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= (OTHERS => '0');
                    END CASE;
                WHEN b"0010" => --Retenido Y+
                    CASE SPIKES_IN IS
                        WHEN b"0000" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN b"1000" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= b"0010";
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN b"0100" =>
                            SPIKES_SET <= b"0100";
                            SPIKES_RST <= b"0010";
                            SPIKES_EXTRAS <= b"01";
                        WHEN b"0010" =>
                            SPIKES_SET <= b"0010";
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= b"01";
                        WHEN b"0001" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= b"0010";
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN OTHERS =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= (OTHERS => '0');
                    END CASE;
                WHEN b"0001" => --Retenido Y-
                    CASE SPIKES_IN IS
                        WHEN b"0000" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN b"1000" =>
                            SPIKES_SET <= b"1000";
                            SPIKES_RST <= b"0001";
                            SPIKES_EXTRAS <= b"10";
                        WHEN b"0100" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= b"0001";
                            SPIKES_EXTRAS <= (OTHERS => '0');
                        WHEN b"0010" =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= b"0001";
                            SPIKES_EXTRAS <= b"00";
                        WHEN b"0001" =>
                            SPIKES_SET <= b"0001";
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= b"10";
                        WHEN OTHERS =>
                            SPIKES_SET <= (OTHERS => '0');
                            SPIKES_RST <= (OTHERS => '0');
                            SPIKES_EXTRAS <= (OTHERS => '0');
                    END CASE;
                WHEN OTHERS =>
                    SPIKES_SET <= SPIKES_IN;
                    SPIKES_RST <= (OTHERS => '1');
                    SPIKES_EXTRAS <= (OTHERS => '0');
            END CASE;
        END IF;
        --	end if;
    END PROCESS;

END Behavioral;