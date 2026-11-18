library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub4 is
    port (
        a, b      : in  std_logic_vector(3 downto 0);
        sub       : in  std_logic;
        result    : out std_logic_vector(3 downto 0);
        carry_out : out std_logic;
        borrow    : out std_logic;
        overflow  : out std_logic
    );
end entity;

architecture rtl of add_sub4 is
    signal b_eff : std_logic_vector(3 downto 0);
    signal sum5  : unsigned(4 downto 0);
begin
    b_eff <= b xor (3 downto 0 => sub);
    process(all)
        variable t : unsigned(4 downto 0);
    begin
        t := ('0' & unsigned(a)) + ('0' & unsigned(b_eff));
        if sub = '1' then
            t := t + to_unsigned(1, t'length);
        end if;
        sum5 <= t;
    end process;
    result    <= std_logic_vector(sum5(3 downto 0));
    carry_out <= sum5(4);
    borrow    <= sub and (not sum5(4));
    overflow  <= (not (a(3) xor b_eff(3))) and (a(3) xor sum5(3));
end architecture;

