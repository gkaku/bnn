library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity max is
    generic (
        bitwidth : integer
    );

    Port (
        x0 : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        x1 : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        x2 : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        x3 : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        z : out STD_LOGIC_VECTOR(bitwidth-1 downto 0)
    );
end max;

architecture Behavioral of max is

    signal t0 : STD_LOGIC_VECTOR(bitwidth-1 downto 0);
    signal t1 : STD_LOGIC_VECTOR(bitwidth-1 downto 0);

begin
    process(x0, x1)
    begin
        if x0 > x1 then
            t0 <= x0;
        else
            t0 <= x1;
        end if;
    end process;

    process(x2, x3)
    begin
        if x2 > x3 then
            t1 <= x2;
        else
            t1 <= x3;
        end if;
    end process;

    process(t0, t1)
    begin
        if t0 > t1 then
            z <= t0;
        else
            z <= t1;
        end if;
    end process;

end Behavioral;
