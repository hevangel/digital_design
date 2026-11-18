library ieee;
use ieee.std_logic_1164.all;

entity open_drain is
    port (
        pull_low : in std_logic;
        bus_line : inout std_logic
    );
end entity;

architecture illustrative_io of open_drain is
begin
    -- Drive low or release. The testbench/board must provide the pull-up.
    bus_line <= '0' when pull_low = '1' else 'Z';
end architecture;

