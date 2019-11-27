library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity single_step_conv_tb is
end;

architecture bench of single_step_conv_tb is

    component single_step_conv
        Port ( w : in STD_LOGIC_VECTOR (3*3*512-1 downto 0);
               x : in STD_LOGIC_VECTOR (3*3*512-1 downto 0);
               z : out STD_LOGIC_VECTOR (13 downto 0));
    end component;

    signal w: STD_LOGIC_VECTOR (3*3*512-1 downto 0);
    signal x: STD_LOGIC_VECTOR (3*3*512-1 downto 0);
    signal z: STD_LOGIC_VECTOR (13 downto 0);

begin

    uut: single_step_conv port map ( w => w,
                                     x => x,
                                     z => z );

    stimulus: process
    begin        
        w(17 downto 0) <= "010111000011011100";
        x(17 downto 0) <= "001010111110010010";
        w(4607 downto 18) <= (others=>'0');
        x(4607 downto 18) <= (others=>'0');
    end process;
    
end;
