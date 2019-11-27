library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;
library STD;
use STD.TEXTIO.ALL;
use std.env.all; -- VHDL 2008

entity max_pooling3_tb is
end;

architecture bench of max_pooling3_tb is
    component max_pooling3
      generic (
        bitwidth : integer
      );
      Port (
          x : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
          start : in STD_LOGIC;
          clk : in STD_LOGIC;
          z : out STD_LOGIC_VECTOR(bitwidth-1 downto 0)
        );
    end component;

    signal clk: STD_LOGIC := '0';
    signal start: STD_LOGIC;
    signal done: STD_LOGIC;
    signal x: STD_LOGIC_VECTOR (13 downto 0);
    signal z: STD_LOGIC_VECTOR (13 downto 0);

    constant clock_period: time := 100 ns;

    file input_x: TEXT is in "./data/output.txt";
    file output_z : text open write_mode is "./data/pooling3_output.txt";
begin
    clk <= not clk after (clock_period/2);

    process
    begin
        start <= '1';
        wait for clock_period;
        start <= '0';
        wait for (clock_period*8*8*512);
        finish; -- terminate the simulation (VHDL 2008)
    end process;

    -- print the results
    process (clk) is
        variable tmp_int : integer;
        variable tmp_line : line;
        variable heartbeat_cnt : integer := 0;
    begin
        if (clk'event and clk = '1') then
            if (start = '0') then
                if (heartbeat_cnt mod 4 = 3) then
                  tmp_int := to_integer(signed(z));
                  write(tmp_line, tmp_int);
                  writeline(output_z, tmp_line);
                end if;
                -- heartbeat --
                heartbeat_cnt := heartbeat_cnt + 1;
                if (heartbeat_cnt mod 1000 = 0) then
                    write(tmp_line, string'("executed "));
                    write(tmp_line, heartbeat_cnt);
                    write(tmp_line, string'(" cycles"));
                    writeline(output, tmp_line);
                end if;
                ---------------
            end if;
        end if;
    end process;

    process (clk)
        variable V_LI: line;
        variable V_X: integer;
    begin
        if (clk'event and clk = '1') then
          --if (start = '0') then
            readline(input_x, V_LI);
            read(V_LI, V_X);
          --end if;
        end if;

        x <= std_logic_vector(to_signed(V_X, 14));
    end process;

    uut : max_pooling3 generic map(
      bitwidth => 14
    )
    port map(x => x,
            start => start,
            clk => clk,
            z => z 
            );

end;
