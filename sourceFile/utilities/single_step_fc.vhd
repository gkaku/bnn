library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity single_step_fc is
    generic (
        x_width: integer;
        z_width: integer
    );
    port (
        x : in STD_LOGIC_VECTOR(x_width-1 downto 0);
        w : in STD_LOGIC_VECTOR(x_width-1 downto 0);
        z : out STD_LOGIC_VECTOR(z_width-1 downto 0)
    );
end single_step_fc;

architecture Behavioral of single_step_fc is
    signal t : std_logic_vector(x_width-1 downto 0);
begin
    t <= w xor x;
    process(t)
        variable sum : std_logic_vector(z_width-2 downto 0);
    begin
        sum := (others => '0');
        for i in 0 to x_width-1 loop
            sum := sum + t(i);
        end loop;
        z <= std_logic_vector(to_signed(x_width, z_width)) - (sum&'0');
    end process;

end Behavioral;
