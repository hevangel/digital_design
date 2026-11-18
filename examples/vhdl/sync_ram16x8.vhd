library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_ram16x8 is
    port (
        clk  : in  std_logic;
        we   : in  std_logic;
        addr : in  std_logic_vector(3 downto 0);
        din  : in  std_logic_vector(7 downto 0);
        dout : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of sync_ram16x8 is
    type mem_t is array (0 to 15) of std_logic_vector(7 downto 0);
    signal mem : mem_t;   -- intentionally uninitialized
    signal data_q : std_logic_vector(7 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                mem(to_integer(unsigned(addr))) <= din;
            else
                data_q <= mem(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;
    dout <= data_q;
end architecture;

