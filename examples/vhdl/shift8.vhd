library ieee;
use ieee.std_logic_1164.all;

entity shift8 is
    port (
        clk, rst, shift_en, serial_in : in std_logic;
        q : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of shift8 is
    signal r : std_logic_vector(7 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                r <= (others => '0');
            elsif shift_en = '1' then
                r <= r(6 downto 0) & serial_in;
            end if;
        end if;
    end process;
    q <= r;
end architecture;

