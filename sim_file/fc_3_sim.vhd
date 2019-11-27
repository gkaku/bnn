library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;
library STD;
use STD.TEXTIO.ALL;
use std.env.all; -- VHDL 2008

entity fc_3_sim is
end;

    architecture bench of fc_3_sim is

    component fc_3
    port (
            clk : in STD_LOGIC;
            start : in STD_LOGIC;
            x : in STD_LOGIC_VECTOR(1024-1 downto 0);
            done : out STD_LOGIC;
            --y_hat : out STD_LOGIC_VECTOR(1024-1 downto 0)
            --
            y_hat: out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

    signal clk: STD_LOGIC := '0';
    signal start: STD_LOGIC;
    signal x: STD_LOGIC_VECTOR(1024-1 downto 0);
    signal done: STD_LOGIC;
    --signal y_hat: STD_LOGIC_VECTOR(1024-1 downto 0) ;
    ---
    signal y_hat: STD_LOGIC_VECTOR(11 downto 0);
    ---

    constant clock_period: time := 100 ns;

    file input_x: TEXT is in "./data/fc3_data/fc3_x.txt";

begin
    clk <= not clk after (clock_period/2);

    uut: fc_3 port map ( clk   => clk,
                            start => start,
                            x     => x,
                            done  => done,
                            y_hat => y_hat );

    process
    begin
        start <= '1';
        wait for clock_period;
        start <= '0';
        wait for (clock_period*11);
        finish; -- terminate the simulation (VHDL 2008)
    end process;


    read_x: process
        variable V_LI: line;
        variable V_X: STD_LOGIC_VECTOR(1024-1 downto 0);
    begin
        for i in 0 to 1024-1 loop
            readline(input_x, V_LI);
            read(V_LI, V_X(i));
        end loop;
        x <= V_X;
        wait;
    end process;

    process(clk)
        variable tmp_int : integer; --STD_LOGIC_VECTOR(4*4*512-1 downto 0);
        variable tmp_line : line;
        variable n : integer := 0;
    begin
        tmp_int := to_integer(signed(y_hat));
        if (clk'event and clk = '1') then
            if(start='0') then
                if (n < 11 and n > 0) then
                --wait for clock_period;
                --wait for (clock_period*8*8*512);
                --tmp_int := y_hat;
                    write(tmp_line, tmp_int);
                    writeline(output, tmp_line);
                end if;
                n := n + 1;
            end if;
        end if;
    end process;

end;