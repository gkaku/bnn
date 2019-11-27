library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_TEXTIO.ALL;
--library STD;
--use STD.TEXTIO.ALL;

entity bnn is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(32*32*3*8-1 downto 0);
        done : out STD_LOGIC;
        --y_hat : out STD_LOGIC_VECTOR(1024-1 downto 0)
        y_hat:  out STD_LOGIC_VECTOR(11 downto 0)
    );
end bnn;

architecture Behavioral of bnn is

component layer_1 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(32*32*3*8-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(32*32*64-1 downto 0)
        --y_hat : out STD_LOGIC_VECTOR(14 downto 0)
    );
end component;

component layer_2 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(32*32*64-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(16*16*64-1 downto 0)
        --y_hat : out STD_LOGIC_VECTOR(13 downto 0)
    );
end component;

component layer_3 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(16*16*64-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(16*16*128-1 downto 0)
        --y_hat : out STD_LOGIC_VECTOR(13 downto 0)
    );
end component;

component layer_4 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(16*16*128-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(8*8*128-1 downto 0)
        --y_hat : out STD_LOGIC_VECTOR(13 downto 0)
    );
end component;

component layer_5 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(8*8*128-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(8*8*256-1 downto 0)
        --y_hat : out STD_LOGIC_VECTOR(12 downto 0)
    );
end component;

component layer_6 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(8*8*256-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(4*4*256-1 downto 0)
        --y_hat : out STD_LOGIC_VECTOR(13 downto 0)
    );
end component;

component fc_1 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(4096-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(1024-1 downto 0)
        --y_hat:  out STD_LOGIC_VECTOR(14 downto 0)
    );
end component;

component fc_2 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(1024-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(1024-1 downto 0)
        --y_hat:  out STD_LOGIC_VECTOR(14 downto 0)
    );
end component;

component fc_3 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(1024-1 downto 0);
        done : out STD_LOGIC;
        --y_hat : out STD_LOGIC_VECTOR(1024-1 downto 0)
        y_hat:  out STD_LOGIC_VECTOR(11 downto 0)
    );
end component;

signal layer_1_output : STD_LOGIC_VECTOR(32*32*64-1 downto 0);
signal layer_2_output : STD_LOGIC_VECTOR(16*16*64-1 downto 0);
signal layer_3_output : STD_LOGIC_VECTOR(16*16*128-1 downto 0);
signal layer_4_output : STD_LOGIC_VECTOR(8*8*128-1 downto 0);
signal layer_5_output : STD_LOGIC_VECTOR(8*8*256-1 downto 0);
signal layer_6_output : STD_LOGIC_VECTOR(4*4*256-1 downto 0);
signal fc_1_output : STD_LOGIC_VECTOR(1024-1 downto 0);
signal fc_2_output : STD_LOGIC_VECTOR(1024-1 downto 0);
signal layer_2_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal layer_3_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal layer_4_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal layer_5_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal layer_6_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal fc_1_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal fc_2_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal fc_3_state : STD_LOGIC_VECTOR(1 downto 0) := "00";

--signal clk : STD_LOGIC := 0;
signal layer_1_start, layer_2_start, layer_3_start, layer_4_start, layer_5_start, layer_6_start, fc_1_start, fc_2_start, fc_3_start : STD_LOGIC;
signal layer_1_done, layer_2_done, layer_3_done, layer_4_done, layer_5_done, layer_6_done, fc_1_done, fc_2_done : STD_LOGIC;

begin
    layer_1_start <= start;
    process(clk)
    begin
        if (clk'event and clk='1') then
            if layer_2_state="00" then
                if layer_1_done='1' then
                    layer_2_state <= "01";
                end if ;
            elsif layer_2_state="01" then
                layer_2_state <= "11";
            end if;
        end if ;
    end process;

    process(layer_2_state)
    begin
        if layer_2_state="01" then
            layer_2_start <= '1';
        else
            layer_2_start <= '0';
        end if ;
    end process;

    process(clk)
    begin
        if (clk'event and clk='1') then
            if layer_3_state="00" then
                if layer_2_done='1' then
                    layer_3_state <= "01";
                end if ;
            elsif layer_3_state="01" then
                layer_3_state <= "11";
            end if;
        end if ;
    end process;

    process(layer_3_state)
    begin
        if layer_3_state="01" then
            layer_3_start <= '1';
        else
            layer_3_start <= '0';
        end if ;
    end process;

    process(clk)
    begin
        if (clk'event and clk='1') then
            if layer_4_state="00" then
                if layer_3_done='1' then
                    layer_4_state <= "01";
                end if ;
            elsif layer_4_state="01" then
                layer_4_state <= "11";
            end if;
        end if ;
    end process;

    process(layer_4_state)
    begin
        if layer_4_state="01" then
            layer_4_start <= '1';
        else
            layer_4_start <= '0';
        end if ;
    end process;

    process(clk)
    begin
        if (clk'event and clk='1') then
            if layer_5_state="00" then
                if layer_4_done='1' then
                    layer_5_state <= "01";
                end if ;
            elsif layer_5_state="01" then
                layer_5_state <= "11";
            end if;
        end if ;
    end process;

    process(layer_5_state)
    begin
        if layer_5_state="01" then
            layer_5_start <= '1';
        else
            layer_5_start <= '0';
        end if ;
    end process;

    process(clk)
    begin
        if (clk'event and clk='1') then
            if layer_6_state="00" then
                if layer_5_done='1' then
                    layer_6_state <= "01";
                end if ;
            elsif layer_6_state="01" then
                layer_6_state <= "11";
            end if;
        end if ;
    end process;

    process(layer_6_state)
    begin
        if layer_6_state="01" then
            layer_6_start <= '1';
        else
            layer_6_start <= '0';
        end if ;
    end process;

    process(clk)
    begin
        if (clk'event and clk='1') then
            if fc_1_state="00" then
                if layer_6_done='1' then
                    fc_1_state <= "01";
                end if ;
            elsif fc_1_state="01" then
                fc_1_state <= "11";
            end if;
        end if ;
    end process;

    process(fc_1_state)
    begin
        if fc_1_state="01" then
            fc_1_start <= '1';
        else
            fc_1_start <= '0';
        end if ;
    end process;

    process(clk)
    begin
        if (clk'event and clk='1') then
            if fc_2_state="00" then
                if fc_1_done='1' then
                    fc_2_state <= "01";
                end if ;
            elsif fc_2_state="01" then
                fc_2_state <= "11";
            end if;
        end if ;
    end process;

    process(fc_2_state)
    begin
        if fc_2_state="01" then
            fc_2_start <= '1';
        else
            fc_2_start <= '0';
        end if ;
    end process;

    process(clk)
    begin
        if (clk'event and clk='1') then
            if fc_3_state="00" then
                if fc_2_done='1' then
                    fc_3_state <= "01";
                end if ;
            elsif fc_3_state="01" then
                fc_3_state <= "11";
            end if;
        end if ;
    end process;

    process(fc_3_state)
    begin
        if fc_3_state="01" then
            fc_3_start <= '1';
        else
            fc_3_start <= '0';
        end if ;
    end process;

    layer_1_map: layer_1 port map (
        clk => clk,
        start => layer_1_start,
        x => x,
        done => layer_1_done,
        y_hat => layer_1_output
    );

    layer_2_map: layer_2 port map (
        clk => clk,
        start => layer_2_start,
        x => layer_1_output,
        done => layer_2_done,
        y_hat => layer_2_output
    );

    layer_3_map: layer_3 port map (
        clk => clk,
        start => layer_3_start,
        x => layer_2_output,
        done => layer_3_done,
        y_hat => layer_3_output
    );

    layer_4_map: layer_4 port map (
        clk => clk,
        start => layer_4_start,
        x => layer_3_output,
        done => layer_4_done,
        y_hat => layer_4_output
    );

    layer_5_map: layer_5 port map (
        clk => clk,
        start => layer_5_start,
        x => layer_4_output,
        done => layer_5_done,
        y_hat => layer_5_output
    );

    layer_6_map: layer_6 port map (
        clk => clk,
        start => layer_6_start,
        x => layer_5_output,
        done => layer_6_done,
        y_hat => layer_6_output
    );

    fc_1_map: fc_1 port map (
        clk => clk,
        start => fc_1_start,
        x => layer_6_output,
        done => fc_1_done,
        y_hat => fc_1_output
    );

    fc_2_map: fc_2 port map (
        clk => clk,
        start => fc_2_start,
        x => fc_1_output,
        done => fc_2_done,
        y_hat => fc_2_output
    );

    fc_3_map: fc_3 port map (
        clk => clk,
        start => fc_3_start,
        x => fc_2_output,
        done => done,
        y_hat => y_hat
    );
--remove here!!--
    --process(clk)
    --    variable tmp_int : integer; --STD_LOGIC_VECTOR(4*4*512-1 downto 0);
    --    variable tmp_line : line;
    --    variable n : integer := 0;
    --begin
    --    tmp_int := to_integer(signed(y_hat));
    --    if (clk'event and clk = '1') then
    --        if(fc_2_done='1') then
    --            write(tmp_line, tmp_int);
    --            writeline(output, tmp_line);
    --        end if;
    --    end if;
    --end process;
--end--
end Behavioral;