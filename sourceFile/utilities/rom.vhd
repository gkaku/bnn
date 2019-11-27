library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
library STD;
use STD.TEXTIO.ALL;

entity rom is
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
end rom;

architecture Behavioral of rom is
    subtype word is std_logic_vector(data_length-1 downto 0);
    type storage_array is
        array(integer range 0 to 2**address_length-1) of word;

    impure function read_file return storage_array is
        variable rdline : line;
        variable storage_var : storage_array;
        file load_file : text is in load_file_name;
    begin
        for index in storage_array'range loop
            readline(load_file, rdline);
            read(rdline, storage_var(index));
        end loop;
        return storage_var;
    end function;
    
    signal storage : storage_array := read_file;
    attribute rom_style : string;
    attribute rom_style of storage : signal is "block";

    begin
        process(clk)
        begin
            if (clk'event and clk='1') then
                data <= storage(to_integer(unsigned(address)));
            end if;
        end process;

end Behavioral;