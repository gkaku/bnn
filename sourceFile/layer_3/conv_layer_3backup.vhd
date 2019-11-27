library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity conv_layer_3 is
    Port (
        w : in STD_LOGIC_VECTOR (3*3*64-1 downto 0);
        x : in STD_LOGIC_VECTOR (16*16*64-1 downto 0);
        cnt : in STD_LOGIC_VECTOR(7 downto 0);
        --done : out STD_LOGIC;
        z : out STD_LOGIC_VECTOR (10 downto 0)
        );
end conv_layer_3;

architecture Behavioral of conv_layer_3 is
    component single_step_conv_3
        Port ( w : in STD_LOGIC_VECTOR (3*3*64-1 downto 0);
               x : in STD_LOGIC_VECTOR (3*3*64-1 downto 0);
               c : in STD_LOGIC_VECTOR (3 downto 0);
               z : out STD_LOGIC_VECTOR (10 downto 0));
    end component;

    
    signal S : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');--conv state 
    signal x_single : STD_LOGIC_VECTOR(3*3*64-1 downto 0);--input for single step conv
    signal c : STD_LOGIC_VECTOR (3 downto 0);
    signal z_single : STD_LOGIC_VECTOR(10 downto 0);
begin

    z <= z_single;                      

    uut: single_step_conv_3 port map ( --w => weight,
                                     w => w,
                                     x => x_single,
                                     c => c,
                                     z => z_single
                                    );

    --S <= cnt(7 downto 5) & cnt(1) & cnt(4 downto 2) & cnt(0);--order of output for next pooling layer
    S <= cnt(7 downto 0);
    
    L1: for m in 0 to 63 generate 
        process(S, x)
            variable I : integer;
        begin
            I := to_integer(unsigned(S));
            case(S) is
                when "00000000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+17 downto 16*16*m+16) & '0' & x(16*16*m+1 downto 16*16*m) & "0000";--p0 the left top corner

                when "00000001" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+18 downto 16*16*m+16) & x(16*16*m+2 downto 16*16*m) & "000";--p1 the top edge
                when "00000010" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+19 downto 16*16*m+17) & x(16*16*m+3 downto 16*16*m+1) & "000";
                when "00000011" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+20 downto 16*16*m+18) & x(16*16*m+4 downto 16*16*m+2) & "000";
                when "00000100" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+21 downto 16*16*m+19) & x(16*16*m+5 downto 16*16*m+3) & "000";
                when "00000101" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+22 downto 16*16*m+20) & x(16*16*m+6 downto 16*16*m+4) & "000";
                when "00000110" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+23 downto 16*16*m+21) & x(16*16*m+7 downto 16*16*m+5) & "000";
                when "00000111" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+24 downto 16*16*m+22) & x(16*16*m+8 downto 16*16*m+6) & "000";
                when "00001000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+25 downto 16*16*m+23) & x(16*16*m+9 downto 16*16*m+7) & "000";
                when "00001001" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+26 downto 16*16*m+24) & x(16*16*m+10 downto 16*16*m+8) & "000";
                when "00001010" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+27 downto 16*16*m+25) & x(16*16*m+11 downto 16*16*m+9) & "000";
                when "00001011" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+28 downto 16*16*m+26) & x(16*16*m+12 downto 16*16*m+10) & "000";
                when "00001100" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+29 downto 16*16*m+27) & x(16*16*m+13 downto 16*16*m+11) & "000";
                when "00001101" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+30 downto 16*16*m+28) & x(16*16*m+14 downto 16*16*m+12) & "000";
                when "00001110" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+31 downto 16*16*m+29) & x(16*16*m+15 downto 16*16*m+13) & "000";

                when "00001111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+31 downto 16*16*m+30) & '0' & x(16*16*m+15 downto 16*16*m+14) & "000";--p2 the right top corner

                when "00010000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+33 downto 16*16*m+32) & '0' & x(16*16*m+17 downto 16*16*m+16) & '0' & x(16*16*m+1 downto 16*16*m) & '0';--p3 the left edge
                when "00100000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+49 downto 16*16*m+48) & '0' & x(16*16*m+33 downto 16*16*m+32) & '0' & x(16*16*m+17 downto 16*16*m+16) & '0';
                when "00110000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+65 downto 16*16*m+64) & '0' & x(16*16*m+49 downto 16*16*m+48) & '0' & x(16*16*m+33 downto 16*16*m+32) & '0';
                when "01000000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+81 downto 16*16*m+80) & '0' & x(16*16*m+65 downto 16*16*m+64) & '0' & x(16*16*m+49 downto 16*16*m+48) & '0';
                when "01010000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+97 downto 16*16*m+96) & '0' & x(16*16*m+81 downto 16*16*m+80) & '0' & x(16*16*m+65 downto 16*16*m+64) & '0';
                when "01100000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+113 downto 16*16*m+112) & '0' & x(16*16*m+97 downto 16*16*m+96) & '0' & x(16*16*m+81 downto 16*16*m+80) & '0';
                when "01110000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+129 downto 16*16*m+128) & '0' & x(16*16*m+113 downto 16*16*m+112) & '0' & x(16*16*m+97 downto 16*16*m+96) & '0';
                when "10000000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+145 downto 16*16*m+144) & '0' & x(16*16*m+129 downto 16*16*m+128) & '0' & x(16*16*m+113 downto 16*16*m+112) & '0';
                when "10010000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+161 downto 16*16*m+160) & '0' & x(16*16*m+145 downto 16*16*m+144) & '0' & x(16*16*m+129 downto 16*16*m+128) & '0';
                when "10100000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+177 downto 16*16*m+176) & '0' & x(16*16*m+161 downto 16*16*m+160) & '0' & x(16*16*m+145 downto 16*16*m+144) & '0';
                when "10110000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+193 downto 16*16*m+192) & '0' & x(16*16*m+177 downto 16*16*m+176) & '0' & x(16*16*m+161 downto 16*16*m+160) & '0';
                when "11000000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+209 downto 16*16*m+208) & '0' & x(16*16*m+193 downto 16*16*m+192) & '0' & x(16*16*m+177 downto 16*16*m+176) & '0';
                when "11010000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+225 downto 16*16*m+224) & '0' & x(16*16*m+209 downto 16*16*m+208) & '0' & x(16*16*m+193 downto 16*16*m+192) & '0';
                when "11100000" => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+241 downto 16*16*m+240) & '0' & x(16*16*m+225 downto 16*16*m+224) & '0' & x(16*16*m+209 downto 16*16*m+208) & '0';

                when "00011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+47 downto 16*16*m+46) & '0' & x(16*16*m+31 downto 16*16*m+30) & '0' & x(16*16*m+15 downto 16*16*m+14);--p5 the right edge
                when "00101111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+63 downto 16*16*m+62) & '0' & x(16*16*m+47 downto 16*16*m+46) & '0' & x(16*16*m+31 downto 16*16*m+30);
                when "00111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+79 downto 16*16*m+78) & '0' & x(16*16*m+63 downto 16*16*m+62) & '0' & x(16*16*m+47 downto 16*16*m+46);
                when "01001111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+95 downto 16*16*m+94) & '0' & x(16*16*m+79 downto 16*16*m+78) & '0' & x(16*16*m+63 downto 16*16*m+62);
                when "01011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+111 downto 16*16*m+110) & '0' & x(16*16*m+95 downto 16*16*m+94) & '0' & x(16*16*m+79 downto 16*16*m+78);
                when "01101111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+127 downto 16*16*m+126) & '0' & x(16*16*m+111 downto 16*16*m+110) & '0' & x(16*16*m+95 downto 16*16*m+94);
                when "01111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+143 downto 16*16*m+142) & '0' & x(16*16*m+127 downto 16*16*m+126) & '0' & x(16*16*m+111 downto 16*16*m+110);
                when "10001111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+159 downto 16*16*m+158) & '0' & x(16*16*m+143 downto 16*16*m+142) & '0' & x(16*16*m+127 downto 16*16*m+126);
                when "10011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+175 downto 16*16*m+174) & '0' & x(16*16*m+159 downto 16*16*m+158) & '0' & x(16*16*m+143 downto 16*16*m+142);
                when "10101111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+191 downto 16*16*m+190) & '0' & x(16*16*m+175 downto 16*16*m+174) & '0' & x(16*16*m+159 downto 16*16*m+158);
                when "10111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+207 downto 16*16*m+206) & '0' & x(16*16*m+191 downto 16*16*m+190) & '0' & x(16*16*m+175 downto 16*16*m+174);
                when "11001111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+223 downto 16*16*m+222) & '0' & x(16*16*m+207 downto 16*16*m+206) & '0' & x(16*16*m+191 downto 16*16*m+190);
                when "11011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+239 downto 16*16*m+238) & '0' & x(16*16*m+223 downto 16*16*m+222) & '0' & x(16*16*m+207 downto 16*16*m+206);
                when "11101111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(16*16*m+255 downto 16*16*m+254) & '0' & x(16*16*m+239 downto 16*16*m+238) & '0' & x(16*16*m+223 downto 16*16*m+222);

                when "11110000" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+241 downto 16*16*m+240) & '0' & x(16*16*m+225 downto 16*16*m+224) & '0';--p6 the left bottom corner

                when "11110001" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+242 downto 16*16*m+240) & x(16*16*m+226 downto 16*16*m+224);--p7 the bottom edge
                when "11110010" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+243 downto 16*16*m+241) & x(16*16*m+227 downto 16*16*m+225);
                when "11110011" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+244 downto 16*16*m+242) & x(16*16*m+228 downto 16*16*m+226);
                when "11110100" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+245 downto 16*16*m+243) & x(16*16*m+229 downto 16*16*m+227);
                when "11110101" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+246 downto 16*16*m+244) & x(16*16*m+230 downto 16*16*m+228);
                when "11110110" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+247 downto 16*16*m+245) & x(16*16*m+231 downto 16*16*m+229);
                when "11110111" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+248 downto 16*16*m+246) & x(16*16*m+232 downto 16*16*m+230);
                when "11111000" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+249 downto 16*16*m+247) & x(16*16*m+233 downto 16*16*m+231);
                when "11111001" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+250 downto 16*16*m+248) & x(16*16*m+234 downto 16*16*m+232);
                when "11111010" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+251 downto 16*16*m+249) & x(16*16*m+235 downto 16*16*m+233);
                when "11111011" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+252 downto 16*16*m+250) & x(16*16*m+236 downto 16*16*m+234);
                when "11111100" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+253 downto 16*16*m+251) & x(16*16*m+237 downto 16*16*m+235);
                when "11111101" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+254 downto 16*16*m+252) & x(16*16*m+238 downto 16*16*m+236);
                when "11111110" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(16*16*m+255 downto 16*16*m+253) & x(16*16*m+239 downto 16*16*m+237);

                when "11111111" => x_single(3*3*m+8 downto 3*3*m) <= "0000" & x(16*16*m+255 downto 16*16*m+254) & '0' & x(16*16*m+239 downto 16*16*m+238);--p8 the right bottom corner

                when others => x_single(3*3*m+8 downto 3*3*m) <= x(16*16*m+I+17 downto 16*16*m+I+15) & x(16*16*m+I+1 downto 16*16*m+I-1) & x(16*16*m+I-15 downto 16*16*m+I-17);--p4 the center part
            end case;
        end process;
    end generate;

    process(S, x)
    begin
        case to_integer(unsigned(S)) is
            when 0 => c <= "0000";--p0
            when 1 to 14 => c <= "0100";--p1
            when 15 => c <= "0001";--p2
            when 16 | 32 | 48 | 64 | 80 | 96 | 112 | 128 | 144 | 160 | 176 | 192 | 208 | 224 => c <= "0101"; --p3
            when 31 | 47 | 63 | 79 | 95 | 111| 127 | 143 | 159 | 175 | 191 | 207 | 223 | 239 => c <= "0110"; --p5
            when 240 => c <= "0010"; --p6
            when 241 to 254 => c <= "0111"; --p7
            when 255 => c <= "0011"; --p8
            when others => c <= "1000"; --p4
        end case;
    end process;
end Behavioral;
