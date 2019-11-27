library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity single_step_conv is
    Port ( w : in STD_LOGIC_VECTOR (3*3*256-1 downto 0);
           x : in STD_LOGIC_VECTOR (3*3*256-1 downto 0);
           c : in STD_LOGIC_VECTOR (3 downto 0);
           z : out STD_LOGIC_VECTOR (12 downto 0));
end single_step_conv;

architecture Behavioral of single_step_conv is
    component matmul3x3 
        Port ( w : in STD_LOGIC_VECTOR (8 downto 0);
               x : in STD_LOGIC_VECTOR (8 downto 0);
               c : in STD_LOGIC_VECTOR (3 downto 0);
               z : out STD_LOGIC_VECTOR (4 downto 0));
    end component;
    
    --type L1_512 is array(511 downto 0) of STD_LOGIC_VECTOR(4 downto 0);
    type L1_256 is array(255 downto 0) of STD_LOGIC_VECTOR(4 downto 0);
    type L2_128 is array(127 downto 0) of STD_LOGIC_VECTOR(5 downto 0);
    type L3_64 is array(63 downto 0) of STD_LOGIC_VECTOR(6 downto 0);
    type L4_32 is array(31 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
    type L5_16 is array(15 downto 0) of STD_LOGIC_VECTOR(8 downto 0);
    type L6_8 is array(7 downto 0) of STD_LOGIC_VECTOR(9 downto 0);
    type L7_4 is array(3 downto 0) of STD_LOGIC_VECTOR(10 downto 0);
    type L8_2 is array(1 downto 0) of STD_LOGIC_VECTOR(11 downto 0);

    --signal L1_temp : L1_512;
    signal L1_temp : L1_256;
    signal L2_temp : L2_128;
    signal L3_temp : L3_64;
    signal L4_temp : L4_32;
    signal L5_temp : L5_16;
    signal L6_temp : L6_8;
    signal L7_temp : L7_4;
    signal L8_temp : L8_2;

begin
    
    L1: for i in 0 to 255 generate
        uut: matmul3x3 port map ( w => w((i*9+8) downto (i*9)),
                                  x => x((i*9+8) downto (i*9)),
                                  c => c,
                                  z => L1_temp(i) );
    end generate;
    
    L2: for i in 0 to 127 generate
        L2_temp(i)<=( (L1_temp(i*2)(4)) &L1_temp(i*2)) + ( (L1_temp(i*2+1)(4)) &L1_temp(i*2+1));  
    end generate;
    L3: for i in 0 to 63 generate
        L3_temp(i)<=( (L2_temp(i*2)(5)) &L2_temp(i*2)) + ( (L2_temp(i*2+1)(5)) &L2_temp(i*2+1));  
        
    end generate;
    L4: for i in 0 to 31 generate
        L4_temp(i)<=( (L3_temp(i*2)(6)) &L3_temp(i*2)) + ( (L3_temp(i*2+1)(6)) &L3_temp(i*2+1));
    end generate;
    L5: for i in 0 to 15 generate
        L5_temp(i)<=( (L4_temp(i*2)(7)) &L4_temp(i*2)) + ( (L4_temp(i*2+1)(7)) &L4_temp(i*2+1));
    end generate;
    L6: for i in 0 to 7 generate
        L6_temp(i)<=( (L5_temp(i*2)(8)) &L5_temp(i*2)) + ( (L5_temp(i*2+1)(8)) &L5_temp(i*2+1));                            
    end generate;
    L7: for i in 0 to 3 generate
        L7_temp(i)<=( (L6_temp(i*2)(9)) &L6_temp(i*2)) + ( (L6_temp(i*2+1)(9)) &L6_temp(i*2+1));                                    
    end generate;
    L8: for i in 0 to 1 generate
        L8_temp(i)<=( (L7_temp(i*2)(10)) &L7_temp(i*2)) + ( (L7_temp(i*2+1)(10)) &L7_temp(i*2+1));
    end generate;
    --L9: for i in 0 to 1 generate
    --    L9_temp(i)<=( (L8_temp(i*2)(11)) &L8_temp(i*2)) + ( (L8_temp(i*2+1)(11)) &L8_temp(i*2+1));                  
    --end generate;
    
    z <= ( (L8_temp(0)(11)) &L8_temp(0)) + ( (L8_temp(1)(11)) &L8_temp(1));
    
end Behavioral;
