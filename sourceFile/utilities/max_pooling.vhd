library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


entity max_pooling is
    generic (
        bitwidth : integer
    );

    Port (
      x : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
      start : in STD_LOGIC;
      clk : in STD_LOGIC;
      z : out STD_LOGIC_VECTOR(bitwidth-1 downto 0)
    );
end max_pooling;

architecture Behavioral of max_pooling is

    component max
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
    end component;

signal cnt : STD_LOGIC_VECTOR(1 downto 0);
signal x0, x1, x2, x3 : STD_LOGIC_VECTOR(bitwidth-1 downto 0);
begin
    uut : max generic map(
        bitwidth => bitwidth
    )
    port map(x0 => x0,
            x1 => x1,
            x2 => x2,
            x3 => x,
            z => z 
            );

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (start = '1') then
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (cnt = "00") then
                x0 <= x;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (cnt = "01") then
                x1 <= x;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (cnt = "10") then
                x2 <= x;
            end if;
        end if;
    end process;

    --process(clk)
    --begin
    --    if (clk'event and clk = '1') then
    --        if (cnt = "11") then
    --            x3 <= x;
    --        end if;
    --    end if ;
    --end process;

end Behavioral;
