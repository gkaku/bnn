library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity conv_layer_1 is
    Port (
        w : in STD_LOGIC_VECTOR (3*3*3-1 downto 0);
        x : in STD_LOGIC_VECTOR (32*32*3*8-1 downto 0);
        cnt : in STD_LOGIC_VECTOR(9 downto 0);
        --done : out STD_LOGIC;
        z : out STD_LOGIC_VECTOR (14 downto 0)
        );
end conv_layer_1;

architecture Behavioral of conv_layer_1 is
    component single_step_conv_1
            Port ( 
                    w : in STD_LOGIC_VECTOR (3*3*3-1 downto 0);
                    x : in STD_LOGIC_VECTOR (3*3*3*8-1 downto 0);
                    c : in STD_LOGIC_VECTOR (3 downto 0);
                    z : out STD_LOGIC_VECTOR (14 downto 0)
                 );
    end component;

    
    signal S : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');--conv state 
    signal x_single : STD_LOGIC_VECTOR(3*3*3*8-1 downto 0);--input for single step conv
    signal c : STD_LOGIC_VECTOR (3 downto 0);
    signal z_single : STD_LOGIC_VECTOR(14 downto 0);
    signal xx : STD_LOGIC_VECTOR (102*8*3-1 downto 0);
begin

    z <= z_single;                      

    uut: single_step_conv_1 port map ( --w => weight,
                                     w => w,
                                     x => x_single,
                                     c => c,
                                     z => z_single
                                    );

    --S <= cnt(9 downto 6) & cnt(1) & cnt(5 downto 2) & cnt(0);--order of output for next pooling layer
    S <= cnt(9 downto 0);
    
    L1: for m in 0 to 2 generate 
        process(S, xx)
            variable s_low : integer;
        begin
            s_low := to_integer(unsigned(S(4 downto 0)));
            --case(S(5)) is
                --when '0' => 
                x_single(3*3*m*8+3*3*8-1 downto 3*3*m*8) <= xx(102*8*m+(s_low + 70)*8+7 downto 102*8*m+(s_low + 68)*8) & 
                                                            xx(102*8*m+(s_low + 36)*8+7 downto 102*8*m+(s_low + 34)*8) &
                                                            xx(102*8*m+(s_low + 2)*8+7 downto 102*8*m+s_low*8);
                --when others => x_single(3*3*m+8 downto 3*3*m) <= xx(136*m+(s_low + 104) downto 136*m+(s_low + 102)) & 
                --                                                 xx(136*m+(s_low + 70) downto 136*m+(s_low + 68)) &
                --                                                 xx(136*m+(s_low + 36) downto 136*m+(s_low + 34));
            --end case;
        end process;
    end generate;

    L2: for m in 0 to 2 generate 
        process(S, x)
            variable I : integer;
        begin
            I := to_integer(unsigned(S(9 downto 5)));
            case(S(9 downto 5)) is
                when "00000" => xx(102*m*8+101*8+7 downto 102*m*8) <= 
                                    "00000000" & x(32*32*m*8+63*8+7 downto 32*32*m*8+32*8) & "00000000" &
                                    "00000000" & x(32*32*m*8+31*8+7 downto 32*32*m*8) & "00000000" &
                                    "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
                
                when "11111" => xx(102*m*8+101*8+7 downto 102*m*8) <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" &
                                    "00000000" & x(32*32*m*8+1023*8+7 downto 32*32*m*8+992*8) & "00000000" &
                                    "00000000" & x(32*32*m*8+991*8+7 downto 32*32*m*8+960*8) & "00000000";
                                    
                when others => xx(102*m*8+101*8+7 downto 102*m*8) <= 
                                    "00000000" & x(32*32*m*8+(I+2)*32*8-1 downto 32*32*m*8+(I+1)*32*8) & "00000000" &
                                    "00000000" & x(32*32*m*8+(I+1)*32*8-1 downto 32*32*m*8+I*32*8) & "00000000" &
                                    "00000000" & x(32*32*m*8+I*32*8-1 downto 32*32*m*8+(I-1)*32*8) & "00000000";
                                    
            end case;
        end process;
    end generate;

    L3: process(S, x)
    begin
        case to_integer(unsigned(S)) is
            when 0 => c <= "0000";--p0
            when 1 to 30 => c <= "0100";--p1
            when 31 => c <= "0001";--p2
            when 32 | 64 | 96 | 128 | 160 | 192 | 224 | 256 | 288 | 320 | 352 | 384 | 416 | 448 | 480 | 512 | 544 | 576 | 608 | 640 | 672 | 704 | 736 | 768 | 800 | 832 | 864 | 896 | 928 | 960 => c <= "0101"; --p3
            when 63 | 95 | 127 | 159 | 191 | 223 | 255 | 287 | 319 | 351 | 383 | 415 | 447 | 479 | 511 | 543 | 575 | 607 | 639 | 671 | 703 | 735 | 767 | 799 | 831 | 863 | 895 | 927 | 959 | 991 => c <= "0110"; --p5
            when 992 => c <= "0010"; --p6
            when 993 to 1022 => c <= "0111"; --p7
            when 1023 => c <= "0011"; --p8
            when others => c <= "1000"; --p4
        end case;
    end process;
end Behavioral;
