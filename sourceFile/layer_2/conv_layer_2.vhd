library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity conv_layer_2 is
    Port (
        w : in STD_LOGIC_VECTOR (3*3*64-1 downto 0);
        x : in STD_LOGIC_VECTOR (32*32*64-1 downto 0);
        cnt : in STD_LOGIC_VECTOR(9 downto 0);
        --done : out STD_LOGIC;
        z : out STD_LOGIC_VECTOR (10 downto 0)
        );
end conv_layer_2;

architecture Behavioral of conv_layer_2 is
    component single_step_conv_2
        Port ( w : in STD_LOGIC_VECTOR (3*3*64-1 downto 0);
               x : in STD_LOGIC_VECTOR (3*3*64-1 downto 0);
               c : in STD_LOGIC_VECTOR (3 downto 0);
               z : out STD_LOGIC_VECTOR (10 downto 0));
    end component;

    
    signal S : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');--conv state 
    signal x_single : STD_LOGIC_VECTOR(3*3*64-1 downto 0);--input for single step conv
    signal c : STD_LOGIC_VECTOR (3 downto 0);
    signal z_single : STD_LOGIC_VECTOR(10 downto 0);
    signal xx : STD_LOGIC_VECTOR (136*64-1 downto 0);
begin

    z <= z_single;                      

    uut: single_step_conv_2 port map ( --w => weight,
                                     w => w,
                                     x => x_single,
                                     c => c,
                                     z => z_single
                                    );

    S <= cnt(9 downto 6) & cnt(1) & cnt(5 downto 2) & cnt(0);--order of output for next pooling layer
    --S <= cnt(9 downto 0);
    L1: for m in 0 to 63 generate 
        process(S, xx)
            variable s_low : integer;
        begin
            s_low := to_integer(unsigned(S(4 downto 0)));
            case(S(5)) is
                when '0' => x_single(3*3*m+8 downto 3*3*m) <= xx(136*m+(s_low + 70) downto 136*m+(s_low + 68)) & 
                                                              xx(136*m+(s_low + 36) downto 136*m+(s_low + 34)) &
                                                              xx(136*m+(s_low + 2) downto 136*m+(s_low));
                when others => x_single(3*3*m+8 downto 3*3*m) <= xx(136*m+(s_low + 104) downto 136*m+(s_low + 102)) & 
                                                                 xx(136*m+(s_low + 70) downto 136*m+(s_low + 68)) &
                                                                 xx(136*m+(s_low + 36) downto 136*m+(s_low + 34));
            end case;
        end process;
    end generate;

    L2: for m in 0 to 63 generate 
        process(S, x)
            variable I : integer;
        begin
            I := to_integer(unsigned(S(9 downto 6)));
            case(S(9 downto 6)) is
                when "0000" => xx(136*m+135 downto 136*m) <= '0' & x(32*32*m+95 downto 32*32*m+64) & '0' &
                                    '0' & x(32*32*m+63 downto 32*32*m+32) & '0' &
                                    '0' & x(32*32*m+31 downto 32*32*m) & '0' &
                                    "0000000000000000000000000000000000";
                
                when "1111" => xx(136*m+135 downto 136*m) <= "0000000000000000000000000000000000" &
                                    '0' & x(32*32*m+1023 downto 32*32*m+992) & '0' &
                                    '0' & x(32*32*m+991 downto 32*32*m+960) & '0' &
                                    '0' & x(32*32*m+959 downto 32*32*m+928) & '0';
                when others => xx(136*m+135 downto 136*m) <= '0' & x(32*32*m+32+(I+1)*64-1 downto 32*32*m+(I+1)*64) & '0' &
                                    '0' & x(32*32*m+ (I+1)*64-1 downto 32*32*m+32+I*64) & '0' &
                                    '0' & x(32*32*m+32+I*64-1 downto 32*32*m+I*64) & '0' &
                                    '0' & x(32*32*m+I*64-1 downto 32*32*m+32+ (I-1)*64) & '0';
            end case;
        end process;
    end generate;

    -- L1: for m in 0 to 63 generate 
    --     process(S, x)
    --         variable I : integer;
    --     begin
    --         I := to_integer(unsigned(S));
    --         case(S) is
    --             when "0000000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+33 downto 32*32*m+32) & '0' & x(32*32*m+1 downto 32*32*m) & "0000";--p0 the left top corner

    --             when "0000000001" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+34 downto 32*32*m+32) & x(32*32*m+2 downto 32*32*m) & "000";--p1 the top edge
    --             when "0000000010" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+35 downto 32*32*m+33) & x(32*32*m+3 downto 32*32*m+1) & "000";
    --             when "0000000011" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+36 downto 32*32*m+34) & x(32*32*m+4 downto 32*32*m+2) & "000";
    --             when "0000000100" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+37 downto 32*32*m+35) & x(32*32*m+5 downto 32*32*m+3) & "000";
    --             when "0000000101" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+38 downto 32*32*m+36) & x(32*32*m+6 downto 32*32*m+4) & "000";
    --             when "0000000110" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+39 downto 32*32*m+37) & x(32*32*m+7 downto 32*32*m+5) & "000";
    --             when "0000000111" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+40 downto 32*32*m+38) & x(32*32*m+8 downto 32*32*m+6) & "000";
    --             when "0000001000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+41 downto 32*32*m+39) & x(32*32*m+9 downto 32*32*m+7) & "000";
    --             when "0000001001" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+42 downto 32*32*m+40) & x(32*32*m+10 downto 32*32*m+8) & "000";
    --             when "0000001010" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+43 downto 32*32*m+41) & x(32*32*m+11 downto 32*32*m+9) & "000";
    --             when "0000001011" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+44 downto 32*32*m+42) & x(32*32*m+12 downto 32*32*m+10) & "000";
    --             when "0000001100" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+45 downto 32*32*m+43) & x(32*32*m+13 downto 32*32*m+11) & "000";
    --             when "0000001101" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+46 downto 32*32*m+44) & x(32*32*m+14 downto 32*32*m+12) & "000";
    --             when "0000001110" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+47 downto 32*32*m+45) & x(32*32*m+15 downto 32*32*m+13) & "000";
    --             when "0000001111" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+48 downto 32*32*m+46) & x(32*32*m+16 downto 32*32*m+14) & "000";
    --             when "0000010000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+49 downto 32*32*m+47) & x(32*32*m+17 downto 32*32*m+15) & "000";
    --             when "0000010001" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+50 downto 32*32*m+48) & x(32*32*m+18 downto 32*32*m+16) & "000";
    --             when "0000010010" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+51 downto 32*32*m+49) & x(32*32*m+19 downto 32*32*m+17) & "000";
    --             when "0000010011" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+52 downto 32*32*m+50) & x(32*32*m+20 downto 32*32*m+18) & "000";
    --             when "0000010100" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+53 downto 32*32*m+51) & x(32*32*m+21 downto 32*32*m+19) & "000";
    --             when "0000010101" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+54 downto 32*32*m+52) & x(32*32*m+22 downto 32*32*m+20) & "000";
    --             when "0000010110" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+55 downto 32*32*m+53) & x(32*32*m+23 downto 32*32*m+21) & "000";
    --             when "0000010111" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+56 downto 32*32*m+54) & x(32*32*m+24 downto 32*32*m+22) & "000";
    --             when "0000011000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+57 downto 32*32*m+55) & x(32*32*m+25 downto 32*32*m+23) & "000";
    --             when "0000011001" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+58 downto 32*32*m+56) & x(32*32*m+26 downto 32*32*m+24) & "000";
    --             when "0000011010" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+59 downto 32*32*m+57) & x(32*32*m+27 downto 32*32*m+25) & "000";
    --             when "0000011011" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+60 downto 32*32*m+58) & x(32*32*m+28 downto 32*32*m+26) & "000";
    --             when "0000011100" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+61 downto 32*32*m+59) & x(32*32*m+29 downto 32*32*m+27) & "000";
    --             when "0000011101" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+62 downto 32*32*m+60) & x(32*32*m+30 downto 32*32*m+28) & "000";
    --             when "0000011110" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+63 downto 32*32*m+61) & x(32*32*m+31 downto 32*32*m+29) & "000";

    --             when "0000011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+63 downto 32*32*m+62) & '0' & x(32*32*m+31 downto 32*32*m+30) & "000";--p2 the right top corner

    --             when "0000100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+65 downto 32*32*m+64) & '0' & x(32*32*m+33 downto 32*32*m+32) & '0' & x(32*32*m+1 downto 32*32*m) & '0';--p3 the left edge
    --             when "0001000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+97 downto 32*32*m+96) & '0' & x(32*32*m+65 downto 32*32*m+64) & '0' & x(32*32*m+33 downto 32*32*m+32) & '0';
    --             when "0001100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+129 downto 32*32*m+128) & '0' & x(32*32*m+97 downto 32*32*m+96) & '0' & x(32*32*m+65 downto 32*32*m+64) & '0';
    --             when "0010000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+161 downto 32*32*m+160) & '0' & x(32*32*m+129 downto 32*32*m+128) & '0' & x(32*32*m+97 downto 32*32*m+96) & '0';
    --             when "0010100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+193 downto 32*32*m+192) & '0' & x(32*32*m+161 downto 32*32*m+160) & '0' & x(32*32*m+129 downto 32*32*m+128) & '0';
    --             when "0011000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+225 downto 32*32*m+224) & '0' & x(32*32*m+193 downto 32*32*m+192) & '0' & x(32*32*m+161 downto 32*32*m+160) & '0';
    --             when "0011100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+257 downto 32*32*m+256) & '0' & x(32*32*m+225 downto 32*32*m+224) & '0' & x(32*32*m+193 downto 32*32*m+192) & '0';
    --             when "0100000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+289 downto 32*32*m+288) & '0' & x(32*32*m+257 downto 32*32*m+256) & '0' & x(32*32*m+225 downto 32*32*m+224) & '0';
    --             when "0100100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+321 downto 32*32*m+320) & '0' & x(32*32*m+289 downto 32*32*m+288) & '0' & x(32*32*m+257 downto 32*32*m+256) & '0';
    --             when "0101000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+353 downto 32*32*m+352) & '0' & x(32*32*m+321 downto 32*32*m+320) & '0' & x(32*32*m+289 downto 32*32*m+288) & '0';
    --             when "0101100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+385 downto 32*32*m+384) & '0' & x(32*32*m+353 downto 32*32*m+352) & '0' & x(32*32*m+321 downto 32*32*m+320) & '0';
    --             when "0110000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+417 downto 32*32*m+416) & '0' & x(32*32*m+385 downto 32*32*m+384) & '0' & x(32*32*m+353 downto 32*32*m+352) & '0';
    --             when "0110100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+449 downto 32*32*m+448) & '0' & x(32*32*m+417 downto 32*32*m+416) & '0' & x(32*32*m+385 downto 32*32*m+384) & '0';
    --             when "0111000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+481 downto 32*32*m+480) & '0' & x(32*32*m+449 downto 32*32*m+448) & '0' & x(32*32*m+417 downto 32*32*m+416) & '0';
    --             when "0111100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+513 downto 32*32*m+512) & '0' & x(32*32*m+481 downto 32*32*m+480) & '0' & x(32*32*m+449 downto 32*32*m+448) & '0';
    --             when "1000000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+545 downto 32*32*m+544) & '0' & x(32*32*m+513 downto 32*32*m+512) & '0' & x(32*32*m+481 downto 32*32*m+480) & '0';
    --             when "1000100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+577 downto 32*32*m+576) & '0' & x(32*32*m+545 downto 32*32*m+544) & '0' & x(32*32*m+513 downto 32*32*m+512) & '0';
    --             when "1001000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+609 downto 32*32*m+608) & '0' & x(32*32*m+577 downto 32*32*m+576) & '0' & x(32*32*m+545 downto 32*32*m+544) & '0';
    --             when "1001100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+641 downto 32*32*m+640) & '0' & x(32*32*m+609 downto 32*32*m+608) & '0' & x(32*32*m+577 downto 32*32*m+576) & '0';
    --             when "1010000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+673 downto 32*32*m+672) & '0' & x(32*32*m+641 downto 32*32*m+640) & '0' & x(32*32*m+609 downto 32*32*m+608) & '0';
    --             when "1010100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+705 downto 32*32*m+704) & '0' & x(32*32*m+673 downto 32*32*m+672) & '0' & x(32*32*m+641 downto 32*32*m+640) & '0';
    --             when "1011000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+737 downto 32*32*m+736) & '0' & x(32*32*m+705 downto 32*32*m+704) & '0' & x(32*32*m+673 downto 32*32*m+672) & '0';
    --             when "1011100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+769 downto 32*32*m+768) & '0' & x(32*32*m+737 downto 32*32*m+736) & '0' & x(32*32*m+705 downto 32*32*m+704) & '0';
    --             when "1100000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+801 downto 32*32*m+800) & '0' & x(32*32*m+769 downto 32*32*m+768) & '0' & x(32*32*m+737 downto 32*32*m+736) & '0';
    --             when "1100100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+833 downto 32*32*m+832) & '0' & x(32*32*m+801 downto 32*32*m+800) & '0' & x(32*32*m+769 downto 32*32*m+768) & '0';
    --             when "1101000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+865 downto 32*32*m+864) & '0' & x(32*32*m+833 downto 32*32*m+832) & '0' & x(32*32*m+801 downto 32*32*m+800) & '0';
    --             when "1101100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+897 downto 32*32*m+896) & '0' & x(32*32*m+865 downto 32*32*m+864) & '0' & x(32*32*m+833 downto 32*32*m+832) & '0';
    --             when "1110000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+929 downto 32*32*m+928) & '0' & x(32*32*m+897 downto 32*32*m+896) & '0' & x(32*32*m+865 downto 32*32*m+864) & '0';
    --             when "1110100000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+961 downto 32*32*m+960) & '0' & x(32*32*m+929 downto 32*32*m+928) & '0' & x(32*32*m+897 downto 32*32*m+896) & '0';
    --             when "1111000000" => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+993 downto 32*32*m+992) & '0' & x(32*32*m+961 downto 32*32*m+960) & '0' & x(32*32*m+929 downto 32*32*m+928) & '0';

    --             when "0000111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+95 downto 32*32*m+94) & '0' & x(32*32*m+63 downto 32*32*m+62) & '0' & x(32*32*m+31 downto 32*32*m+30);--p5 the right edge
    --             when "0001011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+127 downto 32*32*m+126) & '0' & x(32*32*m+95 downto 32*32*m+94) & '0' & x(32*32*m+63 downto 32*32*m+62);
    --             when "0001111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+159 downto 32*32*m+158) & '0' & x(32*32*m+127 downto 32*32*m+126) & '0' & x(32*32*m+95 downto 32*32*m+94);
    --             when "0010011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+191 downto 32*32*m+190) & '0' & x(32*32*m+159 downto 32*32*m+158) & '0' & x(32*32*m+127 downto 32*32*m+126);
    --             when "0010111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+223 downto 32*32*m+222) & '0' & x(32*32*m+191 downto 32*32*m+190) & '0' & x(32*32*m+159 downto 32*32*m+158);
    --             when "0011011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+255 downto 32*32*m+254) & '0' & x(32*32*m+223 downto 32*32*m+222) & '0' & x(32*32*m+191 downto 32*32*m+190);
    --             when "0011111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+287 downto 32*32*m+286) & '0' & x(32*32*m+255 downto 32*32*m+254) & '0' & x(32*32*m+223 downto 32*32*m+222);
    --             when "0100011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+319 downto 32*32*m+318) & '0' & x(32*32*m+287 downto 32*32*m+286) & '0' & x(32*32*m+255 downto 32*32*m+254);
    --             when "0100111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+351 downto 32*32*m+350) & '0' & x(32*32*m+319 downto 32*32*m+318) & '0' & x(32*32*m+287 downto 32*32*m+286);
    --             when "0101011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+383 downto 32*32*m+382) & '0' & x(32*32*m+351 downto 32*32*m+350) & '0' & x(32*32*m+319 downto 32*32*m+318);
    --             when "0101111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+415 downto 32*32*m+414) & '0' & x(32*32*m+383 downto 32*32*m+382) & '0' & x(32*32*m+351 downto 32*32*m+350);
    --             when "0110011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+447 downto 32*32*m+446) & '0' & x(32*32*m+415 downto 32*32*m+414) & '0' & x(32*32*m+383 downto 32*32*m+382);
    --             when "0110111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+479 downto 32*32*m+478) & '0' & x(32*32*m+447 downto 32*32*m+446) & '0' & x(32*32*m+415 downto 32*32*m+414);
    --             when "0111011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+511 downto 32*32*m+510) & '0' & x(32*32*m+479 downto 32*32*m+478) & '0' & x(32*32*m+447 downto 32*32*m+446);
    --             when "0111111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+543 downto 32*32*m+542) & '0' & x(32*32*m+511 downto 32*32*m+510) & '0' & x(32*32*m+479 downto 32*32*m+478);
    --             when "1000011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+575 downto 32*32*m+574) & '0' & x(32*32*m+543 downto 32*32*m+542) & '0' & x(32*32*m+511 downto 32*32*m+510);
    --             when "1000111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+607 downto 32*32*m+606) & '0' & x(32*32*m+575 downto 32*32*m+574) & '0' & x(32*32*m+543 downto 32*32*m+542);
    --             when "1001011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+639 downto 32*32*m+638) & '0' & x(32*32*m+607 downto 32*32*m+606) & '0' & x(32*32*m+575 downto 32*32*m+574);
    --             when "1001111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+671 downto 32*32*m+670) & '0' & x(32*32*m+639 downto 32*32*m+638) & '0' & x(32*32*m+607 downto 32*32*m+606);
    --             when "1010011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+703 downto 32*32*m+702) & '0' & x(32*32*m+671 downto 32*32*m+670) & '0' & x(32*32*m+639 downto 32*32*m+638);
    --             when "1010111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+735 downto 32*32*m+734) & '0' & x(32*32*m+703 downto 32*32*m+702) & '0' & x(32*32*m+671 downto 32*32*m+670);
    --             when "1011011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+767 downto 32*32*m+766) & '0' & x(32*32*m+735 downto 32*32*m+734) & '0' & x(32*32*m+703 downto 32*32*m+702);
    --             when "1011111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+799 downto 32*32*m+798) & '0' & x(32*32*m+767 downto 32*32*m+766) & '0' & x(32*32*m+735 downto 32*32*m+734);
    --             when "1100011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+831 downto 32*32*m+830) & '0' & x(32*32*m+799 downto 32*32*m+798) & '0' & x(32*32*m+767 downto 32*32*m+766);
    --             when "1100111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+863 downto 32*32*m+862) & '0' & x(32*32*m+831 downto 32*32*m+830) & '0' & x(32*32*m+799 downto 32*32*m+798);
    --             when "1101011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+895 downto 32*32*m+894) & '0' & x(32*32*m+863 downto 32*32*m+862) & '0' & x(32*32*m+831 downto 32*32*m+830);
    --             when "1101111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+927 downto 32*32*m+926) & '0' & x(32*32*m+895 downto 32*32*m+894) & '0' & x(32*32*m+863 downto 32*32*m+862);
    --             when "1110011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+959 downto 32*32*m+958) & '0' & x(32*32*m+927 downto 32*32*m+926) & '0' & x(32*32*m+895 downto 32*32*m+894);
    --             when "1110111111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+991 downto 32*32*m+990) & '0' & x(32*32*m+959 downto 32*32*m+958) & '0' & x(32*32*m+927 downto 32*32*m+926);
    --             when "1111011111" => x_single(3*3*m+8 downto 3*3*m) <= '0' & x(32*32*m+1023 downto 32*32*m+1022) & '0' & x(32*32*m+991 downto 32*32*m+990) & '0' & x(32*32*m+959 downto 32*32*m+958);

    --             when "1111100000" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+993 downto 32*32*m+992) & '0' & x(32*32*m+961 downto 32*32*m+960) & '0';--p6 the left bottom corner

    --             when "1111100001" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+994 downto 32*32*m+992) & x(32*32*m+962 downto 32*32*m+960);--p7 the bottom edge
    --             when "1111100010" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+995 downto 32*32*m+993) & x(32*32*m+963 downto 32*32*m+961);
    --             when "1111100011" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+996 downto 32*32*m+994) & x(32*32*m+964 downto 32*32*m+962);
    --             when "1111100100" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+997 downto 32*32*m+995) & x(32*32*m+965 downto 32*32*m+963);
    --             when "1111100101" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+998 downto 32*32*m+996) & x(32*32*m+966 downto 32*32*m+964);
    --             when "1111100110" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+999 downto 32*32*m+997) & x(32*32*m+967 downto 32*32*m+965);
    --             when "1111100111" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1000 downto 32*32*m+998) & x(32*32*m+968 downto 32*32*m+966);
    --             when "1111101000" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1001 downto 32*32*m+999) & x(32*32*m+969 downto 32*32*m+967);
    --             when "1111101001" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1002 downto 32*32*m+1000) & x(32*32*m+970 downto 32*32*m+968);
    --             when "1111101010" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1003 downto 32*32*m+1001) & x(32*32*m+971 downto 32*32*m+969);
    --             when "1111101011" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1004 downto 32*32*m+1002) & x(32*32*m+972 downto 32*32*m+970);
    --             when "1111101100" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1005 downto 32*32*m+1003) & x(32*32*m+973 downto 32*32*m+971);
    --             when "1111101101" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1006 downto 32*32*m+1004) & x(32*32*m+974 downto 32*32*m+972);
    --             when "1111101110" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1007 downto 32*32*m+1005) & x(32*32*m+975 downto 32*32*m+973);
    --             when "1111101111" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1008 downto 32*32*m+1006) & x(32*32*m+976 downto 32*32*m+974);
    --             when "1111110000" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1009 downto 32*32*m+1007) & x(32*32*m+977 downto 32*32*m+975);
    --             when "1111110001" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1010 downto 32*32*m+1008) & x(32*32*m+978 downto 32*32*m+976);
    --             when "1111110010" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1011 downto 32*32*m+1009) & x(32*32*m+979 downto 32*32*m+977);
    --             when "1111110011" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1012 downto 32*32*m+1010) & x(32*32*m+980 downto 32*32*m+978);
    --             when "1111110100" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1013 downto 32*32*m+1011) & x(32*32*m+981 downto 32*32*m+979);
    --             when "1111110101" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1014 downto 32*32*m+1012) & x(32*32*m+982 downto 32*32*m+980);
    --             when "1111110110" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1015 downto 32*32*m+1013) & x(32*32*m+983 downto 32*32*m+981);
    --             when "1111110111" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1016 downto 32*32*m+1014) & x(32*32*m+984 downto 32*32*m+982);
    --             when "1111111000" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1017 downto 32*32*m+1015) & x(32*32*m+985 downto 32*32*m+983);
    --             when "1111111001" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1018 downto 32*32*m+1016) & x(32*32*m+986 downto 32*32*m+984);
    --             when "1111111010" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1019 downto 32*32*m+1017) & x(32*32*m+987 downto 32*32*m+985);
    --             when "1111111011" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1020 downto 32*32*m+1018) & x(32*32*m+988 downto 32*32*m+986);
    --             when "1111111100" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1021 downto 32*32*m+1019) & x(32*32*m+989 downto 32*32*m+987);
    --             when "1111111101" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1022 downto 32*32*m+1020) & x(32*32*m+990 downto 32*32*m+988);
    --             when "1111111110" => x_single(3*3*m+8 downto 3*3*m) <= "000" & x(32*32*m+1023 downto 32*32*m+1021) & x(32*32*m+991 downto 32*32*m+989);

    --             when "1111111111" => x_single(3*3*m+8 downto 3*3*m) <= "0000" & x(32*32*m+1023 downto 32*32*m+1022) & '0' & x(32*32*m+991 downto 32*32*m+990);--p8 the right bottom corner

    --             when others => x_single(3*3*m+8 downto 3*3*m) <= x(32*32*m+I+33 downto 32*32*m+I+31) & x(32*32*m+I+1 downto 32*32*m+I-1) & x(32*32*m+I-31 downto 32*32*m+I-33);--p4 the center part
    --         end case;
    --     end process;
    -- end generate;

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
