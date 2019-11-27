library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity conv_layer_6 is
    Port (
        --clk : in STD_LOGIC;
        --start : in STD_LOGIC;
        --w : in STD_LOGIC_VECTOR (3*3*512*512-1 downto 0);
        w : in STD_LOGIC_VECTOR (3*3*256-1 downto 0);
        x : in STD_LOGIC_VECTOR (8*8*256-1 downto 0);
        cnt : in STD_LOGIC_VECTOR(5 downto 0);
        --done : out STD_LOGIC;
        z : out STD_LOGIC_VECTOR (12 downto 0));
        -- z : out STD_LOGIC_VECTOR (14*8*8*512-1 downto 0));
end conv_layer_6;

architecture Behavioral of conv_layer_6 is
    component single_step_conv
        Port ( w : in STD_LOGIC_VECTOR (3*3*256-1 downto 0);
               x : in STD_LOGIC_VECTOR (3*3*256-1 downto 0);
               c : in STD_LOGIC_VECTOR (3 downto 0);
               z : out STD_LOGIC_VECTOR (12 downto 0));
    end component;

    --signal cnt : STD_LOGIC_VECTOR(14 downto 0) := (others => '0');
    signal S : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');--conv state 
    signal x_single : STD_LOGIC_VECTOR(3*3*256-1 downto 0);--input for single step conv
    --signal n : STD_LOGIC_VECTOR(8 downto 0);--count the number of kernels
    signal c : STD_LOGIC_VECTOR (3 downto 0);
    --signal weight : STD_LOGIC_VECTOR(3*3*512-1 downto 0);--weight for single step conv
    signal z_single : STD_LOGIC_VECTOR(12 downto 0);
    signal xx : STD_LOGIC_VECTOR (40*256-1 downto 0);
begin

    z <= z_single;                      -- added by thiem (for the testbench)

    uut: single_step_conv port map ( --w => weight,
                                     w => w,
                                     x => x_single,
                                     c => c,
                                     z => z_single );

    --process(n, w)
    --    variable n_int : integer;
    --begin
    --    n_int := to_integer(unsigned(n));
    --    weight <= w(3*3*512*(n_int+1)-1 downto 3*3*512*n_int);
    --end process;

    --process(clk)
    --begin
    --    if (clk'event and clk = '1') then
    --        if (start = '1') then
    --            cnt <= (others => '0');
    --        else
    --            cnt <= cnt + 1;
    --        end if;
    --    end if;
    --end process;

    S <= cnt(5 downto 4) & cnt(1) & cnt(3 downto 2) & cnt(0);--order of output for next pooling layer
    --S <= cnt(5 downto 0);
    --n <= cnt(14 downto 6);
    L1: for m in 0 to 255 generate 
        process(S, xx)
            variable s_low : integer;
        begin
            s_low := to_integer(unsigned(S(2 downto 0)));
            case(S(3)) is
                when '0' => x_single(3*3*m+8 downto 3*3*m) <= xx(40*m+(s_low + 22) downto 40*m+(s_low + 20)) & 
                                                              xx(40*m+(s_low + 12) downto 40*m+(s_low + 10)) &
                                                              xx(40*m+(s_low + 2) downto 40*m+(s_low));
                when others => x_single(3*3*m+8 downto 3*3*m) <= xx(40*m+(s_low + 32) downto 40*m+(s_low + 30)) & 
                                                                 xx(40*m+(s_low + 22) downto 40*m+(s_low + 20)) &
                                                                 xx(40*m+(s_low + 12) downto 40*m+(s_low + 10));
            end case;
        end process;
    end generate;

    L2: for m in 0 to 255 generate 
        process(S, x)
            variable I : integer;
        begin
            I := to_integer(unsigned(S(5 downto 4)));
            case(S(5 downto 4)) is
                when "00" => xx(40*m+39 downto 40*m) <= '0' & x(8*8*m+23 downto 8*8*m+16) & '0' &
                                                        '0' & x(8*8*m+15 downto 8*8*m+8) & '0' &
                                                        '0' & x(8*8*m+7 downto 8*8*m) & '0' &
                                                        "0000000000";
                
                when "11" => xx(40*m+39 downto 40*m) <=  "0000000000" &
                                                         '0' & x(8*8*m+63 downto 8*8*m+56) & '0' &
                                                         '0' & x(8*8*m+55 downto 8*8*m+48) & '0' &
                                                         '0' & x(8*8*m+47 downto 8*8*m+40) & '0';
                when others => xx(40*m+39 downto 40*m) <= '0' & x(8*8*m+8+(I+1)*16-1 downto 8*8*m+(I+1)*16) & '0' &
                                                          '0' & x(8*8*m+ (I+1)*16-1 downto 8*8*m+8+I*16) & '0' &
                                                          '0' & x(8*8*m+8+I*16-1 downto 8*8*m+I*16) & '0' &
                                                          '0' & x(8*8*m+I*16-1 downto 8*8*m+8+ (I-1)*16) & '0';
            end case;
        end process;
    end generate;

    -- L1: for m in 0 to 255 generate 
    --     process(S, x)
    --         variable I : integer;
    --     begin
    --         I := to_integer(unsigned(S));
    --         case(S) is
    --             when "000000" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+9 downto 8*8*m+8) & '0' & x(8*8*m+1 downto 8*8*m) & "0000";--p0 the left top corner
    --             when "000001" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+10 downto 8*8*m+8) & x(8*8*m+2 downto 8*8*m) & "000";--p1 the top edge
    --             when "000010" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+11 downto 8*8*m+9) & x(8*8*m+3 downto 8*8*m+1) & "000";
    --             when "000011" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+12 downto 8*8*m+10) & x(8*8*m+4 downto 8*8*m+2) & "000";
    --             when "000100" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+13 downto 8*8*m+11) & x(8*8*m+5 downto 8*8*m+3) & "000";
    --             when "000101" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+14 downto 8*8*m+12) & x(8*8*m+6 downto 8*8*m+4) & "000";
    --             when "000110" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+15 downto 8*8*m+13) & x(8*8*m+7 downto 8*8*m+5) & "000";
    --             when "000111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(8*8*m+15 downto 8*8*m+14) & '0' & x(8*8*m+7 downto 8*8*m+6) & "000";--p2 the right top corner
    --             when "001000" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+17 downto 8*8*m+16) & '0' & x(8*8*m+9 downto 8*8*m+8) & '0' & x(8*8*m+1 downto 8*8*m) & '0';--p3 the left edge
    --             when "010000" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+25 downto 8*8*m+24) & '0' & x(8*8*m+17 downto 8*8*m+16) & '0' & x(8*8*m+9 downto 8*8*m+8) & '0';
    --             when "011000" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+33 downto 8*8*m+32) & '0' & x(8*8*m+25 downto 8*8*m+24) & '0' & x(8*8*m+17 downto 8*8*m+16) & '0';
    --             when "100000" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+41 downto 8*8*m+40) & '0' & x(8*8*m+33 downto 8*8*m+32) & '0' & x(8*8*m+25 downto 8*8*m+24) & '0';
    --             when "101000" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+49 downto 8*8*m+48) & '0' & x(8*8*m+41 downto 8*8*m+40) & '0' & x(8*8*m+33 downto 8*8*m+32) & '0';
    --             when "110000" => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+57 downto 8*8*m+56) & '0' & x(8*8*m+49 downto 8*8*m+48) & '0' & x(8*8*m+41 downto 8*8*m+40) & '0';
    --             when "001111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(8*8*m+23 downto 8*8*m+22) & '0' & x(8*8*m+15 downto 8*8*m+14) & '0' & x(8*8*m+7 downto 8*8*m+6);--p5 the right edge
    --             when "010111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(8*8*m+31 downto 8*8*m+30) & '0' & x(8*8*m+23 downto 8*8*m+22) & '0' & x(8*8*m+15 downto 8*8*m+14);
    --             when "011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(8*8*m+39 downto 8*8*m+38) & '0' & x(8*8*m+31 downto 8*8*m+30) & '0' & x(8*8*m+23 downto 8*8*m+22);
    --             when "100111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(8*8*m+47 downto 8*8*m+46) & '0' & x(8*8*m+39 downto 8*8*m+38) & '0' & x(8*8*m+31 downto 8*8*m+30);
    --             when "101111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(8*8*m+55 downto 8*8*m+54) & '0' & x(8*8*m+47 downto 8*8*m+46) & '0' & x(8*8*m+39 downto 8*8*m+38);
    --             when "110111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(8*8*m+63 downto 8*8*m+62) & '0' & x(8*8*m+55 downto 8*8*m+54) & '0' & x(8*8*m+47 downto 8*8*m+46);
    --             when "111000" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(8*8*m+57 downto 8*8*m+56) & '0' & x(8*8*m+49 downto 8*8*m+48) & '0';--p6 the left bottom corner
    --             when "111001" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(8*8*m+58 downto 8*8*m+56) & x(8*8*m+50 downto 8*8*m+48);--p7 the bottom edge
    --             when "111010" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(8*8*m+59 downto 8*8*m+57) & x(8*8*m+51 downto 8*8*m+49);
    --             when "111011" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(8*8*m+60 downto 8*8*m+58) & x(8*8*m+52 downto 8*8*m+50);
    --             when "111100" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(8*8*m+61 downto 8*8*m+59) & x(8*8*m+53 downto 8*8*m+51);
    --             when "111101" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(8*8*m+62 downto 8*8*m+60) & x(8*8*m+54 downto 8*8*m+52);
    --             when "111110" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(8*8*m+63 downto 8*8*m+61) & x(8*8*m+55 downto 8*8*m+53);
    --             when "111111" => x_single(3*3*m+8 downto 3*3*m) <= "0000" & x(8*8*m+63 downto 8*8*m+62) & '0' & x(8*8*m+55 downto 8*8*m+54);--p8 the right bottom corner
    --             when others => x_single(3*3*m+8 downto 3*3*m) <= x(8*8*m+I+9 downto 8*8*m+I+7) & x(8*8*m+I+1 downto 8*8*m+I-1) & x(8*8*m+I-7 downto 8*8*m+I-9);--p4 the center part
    --         end case;
    --     end process;
    -- end generate;

    process(S, x)
    begin
        case to_integer(unsigned(S)) is
            when 0 => c <= "0000";--p0
            when 1 to 6 => c <= "0100";--p1
            when 7 => c <= "0001";--p2
            when 8 | 16 | 24 | 32 | 40 | 48 => c <= "0101"; --p3
            when 15 | 23 | 31 | 39 | 47 | 55 => c <= "0110"; --p5
            when 56 => c <= "0010"; --p6
            when 57 to 62 => c <= "0111"; --p7
            when 63 => c <= "0011"; --p8
            when others => c <= "1000"; --p4
        end case;
    end process;
end Behavioral;
