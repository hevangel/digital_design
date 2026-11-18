library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_excess3 is
    port (
        bcd     : in  std_logic_vector(3 downto 0);
        excess3 : out std_logic_vector(3 downto 0);
        valid   : out std_logic
    );
end entity;

architecture rtl of bcd_excess3 is
begin
    process(all)
    begin
        if unsigned(bcd) <= to_unsigned(9, 4) then
            valid   <= '1';
            excess3 <= std_logic_vector(unsigned(bcd) + to_unsigned(3, 4));
        else
            valid   <= '0';
            excess3 <= (others => '0');
        end if;
    end process;
end architecture;

