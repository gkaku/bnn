library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;
library STD;
use STD.TEXTIO.ALL;
use std.env.all; -- VHDL 2008

entity conv_layer_6_tb is
end;

architecture bench of conv_layer_6_tb is
    component conv_layer_6
        Port ( 
            clk : in STD_LOGIC;  
            start : in STD_LOGIC;
            w : in STD_LOGIC_VECTOR (3*3*512*512-1 downto 0);
            x : in STD_LOGIC_VECTOR (8*8*512-1 downto 0);
            done : out STD_LOGIC;
            z : out STD_LOGIC_VECTOR (13 downto 0));
            -- z : out STD_LOGIC_VECTOR (14*8*8*512-1 downto 0));
    end component;
    
    signal clk: STD_LOGIC := '0';
    signal start: STD_LOGIC;
    signal w: STD_LOGIC_VECTOR (3*3*512*512-1 downto 0);
    signal x: STD_LOGIC_VECTOR (8*8*512-1 downto 0);
    signal done: STD_LOGIC;
    signal z: STD_LOGIC_VECTOR (13 downto 0);
    -- signal z: STD_LOGIC_VECTOR (14*8*8*512-1 downto 0);

    constant clock_period: time := 100 ns;
    
    file input_x: TEXT is in "./data/conv6_x.txt";
    file input_w: TEXT is in "./data/conv6_w.txt";
    file output_z : TEXT open write_mode is "./data/output.txt";
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
                tmp_int := to_integer(signed(z));
                write(tmp_line, tmp_int);
                writeline(output_z, tmp_line);
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
    
    process
        variable V_LI: line;
        variable V_X: STD_LOGIC_VECTOR(8*8*512-1 downto 0);
        variable V_W: STD_LOGIC_VECTOR(3*3*512*512-1 downto 0);
    begin
        
        for i in 0 to 8*8*512-1 loop
            readline(input_x, V_LI);
            read(V_LI, V_X(i));
        end loop;
        
        for i in 0 to 3*3*512*512-1 loop
            readline(input_w, V_LI);
            read(V_LI, V_W(i));
        end loop;
        
        x <= V_X;
        w <= V_W;
        
        wait;
        
    end process;
    
    uut: conv_layer_6 port map ( clk   => clk,
                                 start => start,
                                 w     => w,
                                 x     => x,
                                 done  => done,
                                 z     => z
                                 );
    
end;
