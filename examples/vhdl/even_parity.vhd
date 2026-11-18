library ieee;
use ieee.std_logic_1164.all;

entity even_parity is
    port (
        data       : in  std_logic_vector(7 downto 0);
        parity_in  : in  std_logic;
        parity_out : out std_logic;
        error      : out std_logic
    );
end entity;

architecture rtl of even_parity is
begin
    process(all)
        variable p : std_logic;
    begin
        p := '0';
        for i in data'range loop
            p := p xor data(i);
        end loop;
        parity_out <= p;
        error      <= p xor parity_in;
    end process;
end architecture;

