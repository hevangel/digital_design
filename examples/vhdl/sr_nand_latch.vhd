library ieee;
use ieee.std_logic_1164.all;

entity sr_nand_latch is
    port (
        set_n, reset_n : in std_logic;
        q, q_bar : out std_logic
    );
end entity;

architecture illustrative_only of sr_nand_latch is
    signal qi, qbi : std_logic;
begin
    -- Intentional combinational feedback; do not infer production FPGA RTL.
    qi  <= not (set_n and qbi);
    qbi <= not (reset_n and qi);
    q <= qi;
    q_bar <= qbi;
end architecture;

