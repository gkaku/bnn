library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;
library STD;
use STD.TEXTIO.ALL;
use std.env.all; -- VHDL 2008


entity batch_norm_binarize_6_sim is
end;

architecture bench of batch_norm_binarize_6_sim is

    component batch_norm_binarize
    generic (
        bitwidth : integer
    );
    port(
        x : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        const : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        z : out STD_LOGIC
    );
    end component;

    signal x: STD_LOGIC_VECTOR (13 downto 0);
    signal const: STD_LOGIC_VECTOR (13 downto 0);
    signal z: STD_LOGIC;
    signal cnt : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal reset : STD_LOGIC;
    signal clk : STD_LOGIC := '0';
    constant clock_period: time := 100 ns;
    
    file input_x: TEXT is in "./data/maxpooling3.txt";
    file input_const: TEXT is in "./data/const_floor.txt";
    file output_z : TEXT open write_mode is "./data/output_batch.txt";
begin

    uut: batch_norm_binarize
    generic map (
        bitwidth => 14
    )
    port map ( x => x,
                              const => const,
                              z => z );
        
    clk <= not clk after (clock_period/2);
    process
    begin
        reset <= '1';
        wait for clock_period;
        reset <= '0';
        wait for (clock_period*4*4*512);
        finish; -- terminate the simulation (VHDL 2008)
    end process;

    process(clk) is
    begin
        if (clk'event and clk = '1') then 
            cnt <= cnt + '1';
        end if;
    end process;
    -- print the results
    process (clk) is
        variable tmp_int : integer;
        variable tmp_line : line;
        variable heartbeat_cnt : integer := 0;
    begin
        if (clk'event and clk = '1') then
            if (reset = '0') then
                if (z='0') then
                    tmp_int := -1;
                else
                    tmp_int := 1;
                end if;
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
    
    process(clk)
        variable V_LI: line;
        variable V_X:INTEGER;
        variable V_const: INTEGER;
        begin
            if (clk'event and clk = '1') then
              --if (start = '0') then
                readline(input_x, V_LI);
                read(V_LI, V_X);
                if (cnt = "0000") then
                    readline(input_const, V_LI);
                    read(V_LI, V_const);
                end if;
              --end if;
            end if;

    
            x <= std_logic_vector(to_signed(V_X, 14));
            const <= std_logic_vector(to_signed(V_const, 14));
    end process;


end;