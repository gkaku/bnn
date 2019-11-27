library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.Numeric_Std.all;
library STD;
use STD.TEXTIO.ALL;
use std.env.all;

entity max_tb is
end;

architecture bench of max_tb is
  component max
    generic (
      bitwidth : integer
    );
    Port (
      x0 : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
      x1 : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
      x2 : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
      x3 : in STD_LOGIC_VECTOR(bitwidth-1 downto 0);
      z : out STD_LOGIC_VECTOR(bitwidth-1 downto 0)
    );
  end component;

signal x0, x1, x2, x3, z : STD_LOGIC_VECTOR(13 downto 0);

begin
  uut : max generic map(
    bitwidth => 14
  )
  port map(x0 => x0,
          x1 => x1,
          x2 => x2,
          x3 => x3,
          z => z );

  x0 <= "11111111111111";
  x1 <= "11111111111110";
  x2 <= "11111111111100";
  x3 <= "11111111111000";

  process is
      variable tmp_int : integer;
      variable tmp_line : line;
  begin
      wait for 100 ns;
      tmp_int := to_integer(signed(z));
      --write(tmp_line, tmp_int);
      write(tmp_line, z);
      writeline(output, tmp_line);
      finish;
  end process;

end;
