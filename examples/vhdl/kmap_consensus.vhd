library ieee;
use ieee.std_logic_1164.all;

entity kmap_consensus is
    port (
        a, b, c              : in std_logic;
        f_min, f_consensus   : out std_logic
    );
end entity;

architecture rtl of kmap_consensus is
begin
    f_min       <= ((not a) and b) or (a and c);
    f_consensus <= ((not a) and b) or (a and c) or (b and c);
end architecture;

