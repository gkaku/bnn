library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity matmul3x3 is
    Port ( w : in STD_LOGIC_VECTOR (8 downto 0);
           x : in STD_LOGIC_VECTOR (8 downto 0);
           c : in STD_LOGIC_VECTOR (3 downto 0);
           z : out STD_LOGIC_VECTOR (4 downto 0));
end matmul3x3;

architecture Behavioral of matmul3x3 is
    signal t : std_logic_vector(8 downto 0);
    signal s : std_logic_vector(8 downto 0);
    signal N : std_logic_vector(4 downto 0);

begin

    t <= w xor x;

    process(c, t)
    begin
        case(c) is
            when "0000" => s <= t(8 downto 7) & '0' & t(5 downto 4) & "0000"; --P0
            when "0100" => s <= t(8 downto 3) & "000";--P1
            when "0001" => s <= '0' & t(7 downto 6) & '0' & t(4 downto 3) & "000";--P2
            when "0101" => s <= t(8 downto 7) & '0' & t(5 downto 4) & '0' & t(2 downto 1) & '0';--P3
            when "0110" => s <= '0' & t(7 downto 6) & '0' & t(4 downto 3) & '0' & t(1 downto 0);--P5
            when "0010" => s <= "000" & t(5 downto 4) & '0' & t(2 downto 1) & '0';--P6
            when "0111" => s <= "000" & t(5 downto 0);--P7
            when "0011" => s <= "0000" & t(4 downto 3) & '0' & t(1 downto 0);--P8
            when others => s <= t;--P4
        end case;
    end process;

    process(c)
    begin
        if(c(3) = '1') then
            N <= "01001";
        elsif(c(2) = '1') then
            N <= "00110";
        else
            N <= "00100";
        end if;
    end process;

    process(s,N)
        variable sum : std_logic_vector(3 downto 0);
    begin
        sum := "0000";
        for i in 0 to 8 loop
            sum := sum + s(i);
        end loop;
        z <= N - (sum&'0');
    end process;

end Behavioral;
