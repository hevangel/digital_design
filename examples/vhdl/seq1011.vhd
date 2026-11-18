library ieee;
use ieee.std_logic_1164.all;

entity seq1011 is
    port (
        clk, rst, din : in std_logic;
        detected      : out std_logic
    );
end entity;

architecture rtl of seq1011 is
    type state_t is (s0, s1, s10, s101);
    signal state, next_state : state_t;
begin
    process(all)
    begin
        case state is
            when s0   => if din = '1' then next_state <= s1;   else next_state <= s0;   end if;
            when s1   => if din = '1' then next_state <= s1;   else next_state <= s10;  end if;
            when s10  => if din = '1' then next_state <= s101; else next_state <= s0;   end if;
            when s101 => if din = '1' then next_state <= s1;   else next_state <= s10;  end if;
        end case;
    end process;
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state    <= s0;
                detected <= '0';
            else
                state    <= next_state;
                if state = s101 and din = '1' then
                    detected <= '1';
                else
                    detected <= '0';
                end if;
            end if;
        end if;
    end process;
end architecture;

