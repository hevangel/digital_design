library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4 is
    port (
        data : in  std_logic_vector(3 downto 0);
        sel  : in  std_logic_vector(1 downto 0);
        y    : out std_logic
    );
end entity;

architecture rtl of mux4 is
begin
    y <= data(to_integer(unsigned(sel)));
end architecture;

