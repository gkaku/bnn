library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
library STD;
use STD.TEXTIO.ALL;
use std.env.all; -- VHDL 2008

entity rom_sim is
end entity rom_sim;

architecture Behavioral of rom_sim is
component rom is
    generic(
        load_file_name : string;
        data_length : integer;
        address_length : integer
    );
    port (
        clk : in STD_LOGIC;
        address : in STD_LOGIC_VECTOR(address_length-1 downto 0);
        data : out STD_LOGIC_VECTOR(data_length-1 downto 0)
    );
end component;

signal clk : STD_LOGIC := '0';
signal address : STD_LOGIC_VECTOR(8 downto 0) := "000000000";
constant clock_period: time := 100 ns;
signal w : STD_LOGIC_VECTOR(3*3*512-1 downto 0);

--file output_w : TEXT open write_mode is "./data/output_rom.txt";

begin

    clk <= not clk after (clock_period/2);

    process(clk)
    begin
        if(clk'event and clk='1') then
            address <= address + 1;
        end if;
    end process;

    kernel_file: rom generic map(
        load_file_name => "./data/conv6_w_rom.txt",
        data_length => 3*3*512,
        address_length => 9
    )
    port map(
        clk => clk,
        address => address,
        data => w
    );

    process (clk) is
        --variable tmp_int : integer;
        variable tmp_line : line;
        
    begin
        if (clk'event and clk = '1') then
            if(address = "000000001") then
            --for i in 0 to 3*3*512-1 loop
                write(tmp_line, w);
                writeline(output, tmp_line);
            --end loop;
            finish;
            end if;
        end if;
    end process;

end Behavioral;