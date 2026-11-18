library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity load_counter is
    generic (WIDTH : positive := 4);
    port (
        clk, rst, load, enable : in  std_logic;
        load_data              : in  std_logic_vector(WIDTH-1 downto 0);
        count                  : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture rtl of load_counter is
    signal q : unsigned(WIDTH-1 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q <= (others => '0');
            elsif load = '1' then
                q <= unsigned(load_data);
            elsif enable = '1' then
                q <= q + to_unsigned(1, WIDTH);
            end if;
        end if;
    end process;
    count <= std_logic_vector(q);
end architecture;

