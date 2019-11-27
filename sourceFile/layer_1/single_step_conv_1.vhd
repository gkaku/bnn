library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity single_step_conv_1 is
    Port ( w : in STD_LOGIC_VECTOR (3*3*3-1 downto 0);
           x : in STD_LOGIC_VECTOR (3*3*3*8-1 downto 0);
           c : in STD_LOGIC_VECTOR (3 downto 0);
           z : out STD_LOGIC_VECTOR (14 downto 0));
end single_step_conv_1;

architecture Behavioral of single_step_conv_1 is
    component matmul3x3_8bits 
        Port ( w : in STD_LOGIC_VECTOR (8 downto 0);
               x : in STD_LOGIC_VECTOR (3*3*8-1 downto 0);
               c : in STD_LOGIC_VECTOR (3 downto 0);
               z : out STD_LOGIC_VECTOR (12 downto 0));
    end component;

    type L1_TYPE is array(2 downto 0) of STD_LOGIC_VECTOR(12 downto 0);

    signal L1_temp : L1_TYPE;
    signal L2_temp : STD_LOGIC_VECTOR(13 downto 0);

begin
    
    L1: for i in 0 to 2 generate
        uut: matmul3x3_8bits port map ( w => w((i*9+8) downto (i*9)),
                                  x => x((i*3*3*8+3*3*8-1) downto (i*3*3*8)),
                                  c => c,
                                  z => L1_temp(i) );
    end generate;
    
    
    L2_temp <= (L1_temp(0)(12) &L1_temp(0)) + (L1_temp(1)(12) &L1_temp(1));  
    
    
    z <= (L2_temp(13) &L2_temp) + (L1_temp(2)(12) & L1_temp(2)(12) &L1_temp(2));
    
end Behavioral;
