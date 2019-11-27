library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_misc.all;
--use IEEE.STD_LOGIC_TEXTIO.ALL;
--library STD;
--use STD.TEXTIO.ALL;

entity top is
    port(
        sys_clk_p : in STD_LOGIC;
        sys_clk_n : in STD_LOGIC;
        sys_rst : in STD_LOGIC;
        start : in STD_LOGIC;
        ibit : in STD_LOGIC;
        done : out STD_LOGIC;
        obit : out STD_LOGIC
    );
end top;

architecture Behavioral of top is

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

component clk_wiz_0
    port (
        clk_in1_p: in STD_LOGIC;
        clk_in1_n: in STD_LOGIC;
        reset: in STD_LOGIC;
        locked: out STD_LOGIC;
        clk_out1: out STD_LOGIC
    );
end component;
signal clk : STD_LOGIC;
signal x : STD_LOGIC_VECTOR(32*32*3*8-1 downto 0);
signal y_hat: STD_LOGIC_VECTOR(11 downto 0);
signal locked: STD_LOGIC;

begin
    bnn_map: bnn port map(
        clk => clk,
        start => start,
        x => x,
        done => done,
        y_hat => y_hat
    );

    clk_inst: clk_wiz_0 port map(
        clk_in1_p => sys_clk_p,
        clk_in1_n => sys_clk_n,
        reset => sys_rst,
        locked => locked,
        clk_out1 => clk
    );

    process(clk)
    begin
        if(clk'event and clk='1') then
            x <= x(32*32*3*8-2 downto 0) & ibit;
        end if;
    end process;

    --obit <= y_hat(11) xor y_hat(10) xor y_hat(9) xor y_hat(8) xor y_hat(7) xor y_hat(6) xor y_hat(5) xor y_hat(4) xor y_hat(3) xor y_hat(2) xor y_hat(1) xor y_hat(0);
    obit <= xor_reduce(y_hat);


end Behavioral;