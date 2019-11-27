library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity matmul3x3_8bits is
    Port ( w : in STD_LOGIC_VECTOR (8 downto 0);
           x : in STD_LOGIC_VECTOR (3*3*8-1 downto 0);
           c : in STD_LOGIC_VECTOR (3 downto 0);
           z : out STD_LOGIC_VECTOR (12 downto 0));
end matmul3x3_8bits;

architecture Behavioral of matmul3x3_8bits is
    --signal t : std_logic_vector(8 downto 0);
    --signal s : std_logic_vector(8 downto 0);
    --signal N : std_logic_vector(4 downto 0);
    signal mask : STD_LOGIC_VECTOR(8 downto 0);

    type TEMP is array(8 downto 0) of STD_LOGIC_VECTOR(8 downto 0);
    signal t : TEMP;
    signal t0_1, t2_3, t4_5, t6_7 : STD_LOGIC_VECTOR(9 downto 0);
    signal t0_3, t4_7 : STD_LOGIC_VECTOR(10 downto 0);
    signal t0_7 : STD_LOGIC_VECTOR(11 downto 0);
begin

    t0_1 <= (t(0)(8) & t(0)) + (t(1)(8) & t(1));
    t2_3 <= (t(2)(8) & t(2)) + (t(3)(8) & t(3));
    t4_5 <= (t(4)(8) & t(4)) + (t(5)(8) & t(5));
    t6_7 <= (t(6)(8) & t(6)) + (t(7)(8) & t(7));

    t0_3 <= (t0_1(9) & t0_1) + (t2_3(9) & t2_3);
    t4_7 <= (t4_5(9) & t4_5) + (t6_7(9) & t6_7);

    t0_7 <= (t0_3(10) & t0_3) + (t4_7(10) & t4_7);

    z <= (t0_7(11) & t0_7) + (t(8)(8)&t(8)(8)&t(8)(8)&t(8)(8)&t(8));
    --t <= w xor x;
    L: for i in 0 to 8 generate
    process(x,w,mask)
    begin
        if (w(i)='1' and mask(i)='1') then
            t(i)<= '0' & x(8*i+7 downto 8*i);
        elsif(mask(i)='1') then
            t(i)<= 0 - ('0' & x(8*i+7 downto 8*i));
        else 
            t(i)<=(others => '0');
        end if;
    end process;
    end generate;



    process(c)
    begin
        case(c) is
            when "0000" => mask <= "11" & '0' & "11" & "0000"; --P0
            when "0100" => mask <= "111111" & "000";--P1
            when "0001" => mask <= '0' & "11" & '0' & "11" & "000";--P2
            when "0101" => mask <= "11" & '0' & "11" & '0' & "11" & '0';--P3
            when "0110" => mask <= '0' & "11" & '0' & "11" & '0' & "11";--P5
            when "0010" => mask <= "000" & "11" & '0' & "11" & '0';--P6
            when "0111" => mask <= "000" & "111111";--P7
            when "0011" => mask <= "0000" & "11" & '0' & "11";--P8
            when others => mask <= (others=>'1');--P4
        end case;
    end process;



    --process(c)
    --begin
    --    if(c(3) = '1') then
    --        N <= "01001";
    --    elsif(c(2) = '1') then
    --        N <= "00110";
    --    else
    --        N <= "00100";
    --    end if;
    --end process;

    --process(s,N)
    --    variable sum : std_logic_vector(3 downto 0);
    --begin
    --    sum := "0000";
    --    for i in 0 to 8 loop
    --        sum := sum + s(i);
    --    end loop;
    --    z <= N - (sum&'0');
    --end process;

end Behavioral;
