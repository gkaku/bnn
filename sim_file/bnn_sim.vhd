library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;
library STD;
use STD.TEXTIO.ALL;
use std.env.all; -- VHDL 2008

entity bnn_sim is
end bnn_sim;

architecture Behavioral of bnn_sim is
    component bnn 
        port (
            clk : in STD_LOGIC;
            start : in STD_LOGIC;
            x : in STD_LOGIC_VECTOR(32*32*3*8-1 downto 0);
            done : out STD_LOGIC;
            --y_hat : out STD_LOGIC_VECTOR(1024-1 downto 0)
            y_hat:  out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;
    signal clk: STD_LOGIC := '0';
    signal start: STD_LOGIC;
    signal done: STD_LOGIC;
    signal x : STD_LOGIC_VECTOR(32*32*3*8-1 downto 0);
    signal y_hat: STD_LOGIC_VECTOR(11 downto 0);

    constant clock_period: time := 100 ns;
    file input_x: TEXT is in "./data/layer1_data/conv1_x.txt";

    begin

        bnn_lab: bnn port map(
            clk => clk,
            start => start,
            x => x,
            done => done,
            --y_hat : out STD_LOGIC_VECTOR(1024-1 downto 0)
            y_hat => y_hat
        );

        clk <= not clk after (clock_period/2);
        process
        begin
            start <= '1';
            wait for clock_period;
            start <= '0';
            wait;
            --wait for (clock_period*8*8*512);
            --finish; -- terminate the simulation (VHDL 2008)
        end process;

        process(clk)
        begin
            if(clk'event and clk='1') then
                if done='1' then
                    finish;
                end if ;
            end if;
        end process;

        read_x: process
        variable V_LI: line;
        variable V_X: integer;--STD_LOGIC_VECTOR(7 downto 0);
    begin
        for i in 0 to 32*32*3-1 loop
            readline(input_x, V_LI);
            read(V_LI, V_X);
            x(8*i+7 downto 8*i) <= std_logic_vector(to_signed(V_X, 8));
        end loop;
        --x <= V_X;
        wait;
    end process;

end Behavioral;
