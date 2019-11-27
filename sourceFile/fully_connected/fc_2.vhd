library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fc_2 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(1024-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(1024-1 downto 0)
        --y_hat:  out STD_LOGIC_VECTOR(14 downto 0)
    );
end fc_2;

architecture Behavioral of fc_2 is

component single_step_fc
    generic (
        x_width: integer;
        z_width: integer
    );
    port (
        x : in STD_LOGIC_VECTOR(x_width-1 downto 0);
        w : in STD_LOGIC_VECTOR(x_width-1 downto 0);
        z : out STD_LOGIC_VECTOR(z_width-1 downto 0)
    );
end component;

component batch_norm_binarize is
    generic (
        bitwidth : integer := 14
    );
    port(
        x : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        const : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
        z : out STD_LOGIC
    );
end component;

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

signal cnt : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
signal w : STD_LOGIC_VECTOR(1024-1 downto 0);
signal address : STD_LOGIC_VECTOR(9 downto 0);
signal cnt_plus_1 : STD_LOGIC_VECTOR(9 downto 0);
signal z_single : STD_LOGIC_VECTOR(11 downto 0);
signal const : STD_LOGIC_VECTOR(11 downto 0);
signal y_hat_reg : STD_LOGIC_VECTOR(1024-1 downto 0);
signal y_hat_wire : STD_LOGIC;
signal done_reg : STD_LOGIC := '0';
signal flag : STD_LOGIC := '0';


begin
    process(clk)
    begin
        if(clk'event and clk='1') then
            if start='1' then
                flag <= '1';
            end if ;
        end if;
    end process;

    cnt_plus_1 <= cnt + 1;

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (start = '1') then
                cnt <= (others => '0');
            elsif flag='1' then
                cnt <= cnt_plus_1;
            end if;
        end if;
    end process;

    process(cnt_plus_1, start)
    begin
        if (start = '1') then
            address <= (others => '0');
        else 
            address <= cnt_plus_1;
        end if;
    end process;

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if cnt= "1111111111" then
                done_reg <= '1';
            end if ;
        end if;
    end process;

    done <= done_reg;

    fc1: single_step_fc generic map(
        x_width => 1024,
        z_width => 12
    )
    port map (
        x => x,
        w => w,
        z => z_single
    );
    
    bn_and_bin: batch_norm_binarize generic map(
            bitwidth => 12
    )
    port map(
            x => z_single,
            const => const,
            z => y_hat_wire 
    );

    process(clk)
    begin
        if(clk'event and clk = '1') then
            if done_reg='0' then
                --y_hat_reg(to_integer(unsigned(cnt))) <= y_hat_wire;
                y_hat_reg <= y_hat_wire & y_hat_reg(1023 downto 1);
            end if;
        end if;
    end process;
    
    y_hat <= y_hat_reg;  

    ---
    --y_hat <= z_single;
    ---

    weight_file: rom generic map(
        load_file_name => "/mnt/fs800/home/jiajun-guo/Desktop/bnn/data/fc2_data/fc2_w_rom.txt",
        data_length => 1024,
        address_length => 10
    )
    port map(
        clk => clk,
        address => address,
        data => w
    );
    
    read_const: rom generic map(
        load_file_name => "/mnt/fs800/home/jiajun-guo/Desktop/bnn/data/fc2_data/fc2_const_bin.txt",
        data_length => 12,
        address_length => 10
    )
    port map(
        clk => clk,
        address => address,
        data => const
    );

end Behavioral;
