library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity matmul3x3_tb is
end;

architecture bench of matmul3x3_tb is

    component matmul3x3
        Port ( w : in STD_LOGIC_VECTOR (8 downto 0);
               x : in STD_LOGIC_VECTOR (8 downto 0);
               z : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    signal w: STD_LOGIC_VECTOR (8 downto 0);
    signal x: STD_LOGIC_VECTOR (8 downto 0);
    signal z: STD_LOGIC_VECTOR (4 downto 0);

begin

    uut: matmul3x3 port map ( w => w,
                              x => x,
                              z => z );

    stimulus: process
    begin
        
        -- Put initialisation code here
        w <= "011011011";
        x <= "101101100";

        -- Put test bench stimulus code here

        wait for 100 ns;
    end process;


end;
