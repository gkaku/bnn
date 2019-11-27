library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity batch_norm_binarize is
    generic (
        bitwidth : integer := 14
    );
    port(
        x : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        const : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        z : out STD_LOGIC
    );
end batch_norm_binarize;

architecture Behavioral of batch_norm_binarize is
    signal temp : STD_LOGIC_VECTOR(bitwidth downto 0);

    begin
        temp <= (x(bitwidth-1)&x) + (const(bitwidth-1)&const);
        z <= not temp(bitwidth);
        
end Behavioral;