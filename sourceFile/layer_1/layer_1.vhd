library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity layer_1 is
    port (
        clk : in STD_LOGIC;
        start : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(32*32*3*8-1 downto 0);
        done : out STD_LOGIC;
        y_hat : out STD_LOGIC_VECTOR(32*32*64-1 downto 0)
        --y_hat : out STD_LOGIC_VECTOR(14 downto 0)
    );
end layer_1;

architecture Behavioral of layer_1 is

component conv_layer_1
    Port (
        w : in STD_LOGIC_VECTOR (3*3*3-1 downto 0);
        x : in STD_LOGIC_VECTOR (32*32*3*8-1 downto 0);
        cnt : in STD_LOGIC_VECTOR(9 downto 0);
        --done : out STD_LOGIC;
        z : out STD_LOGIC_VECTOR (14 downto 0)
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

signal cnt : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal w : STD_LOGIC_VECTOR(3*3*3-1 downto 0);
signal address : STD_LOGIC_VECTOR(5 downto 0);
signal cnt_plus_1 : STD_LOGIC_VECTOR(15 downto 0);
signal z_single : STD_LOGIC_VECTOR(14 downto 0);
signal const : STD_LOGIC_VECTOR(14 downto 0);
signal y_hat_reg : STD_LOGIC_VECTOR(32*32*64-1 downto 0);
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
            address <= cnt_plus_1(15 downto 10);
        end if;
    end process;

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if cnt= "1111111111111111" then
                done_reg <= '1';
            end if ;
        end if;
    end process;

    done <= done_reg;

    conv1: conv_layer_1 port map (
        w => w,
        x => x,
        cnt => cnt(9 downto 0),
        z => z_single
    );

    
    bn_and_bin: batch_norm_binarize generic map(
            bitwidth => 15
    )
    port map(
            x => z_single,
            const => const,
            z => y_hat_wire 
            --z => y_hat
    );

    process(clk)
    begin
        if(clk'event and clk = '1') then
            if done_reg='0' then
                y_hat_reg <= y_hat_wire & y_hat_reg(32*32*64-1 downto 1);
            end if ;
        end if;
    end process;
    
    y_hat <= y_hat_reg;    
    --
    --process(clk)
    --begin
    --    if(clk'event and clk = '1') then
    --        y_hat <= z_single;
    --    end if;
    --end process;
    --
    
    kernel_file: rom generic map(
        load_file_name => "/mnt/fs800/home/jiajun-guo/Desktop/bnn/data/layer1_data/rom_weight_1.txt",
        data_length => 3*3*3,
        address_length => 6
    )
    port map(
        clk => clk,
        address => address,
        data => w
    );
    
    
    read_const: rom generic map(
        load_file_name => "/mnt/fs800/home/jiajun-guo/Desktop/bnn/data/layer1_data/const_bin_1.txt",
        data_length => 15,
        address_length => 6
    )
    port map(
        clk => clk,
        address => address,
        data => const
    );

end Behavioral;