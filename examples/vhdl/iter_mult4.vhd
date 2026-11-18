library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iter_mult4 is
    port (
        clk, rst, start : in std_logic;
        a, b            : in std_logic_vector(3 downto 0);
        product         : out std_logic_vector(7 downto 0);
        busy, done      : out std_logic
    );
end entity;

architecture rtl of iter_mult4 is
    signal acc, mcand, product_r : unsigned(7 downto 0);
    signal mult : unsigned(3 downto 0);
    signal round_idx : integer range 0 to 3;
    signal busy_r, done_r : std_logic;
begin
    process(clk)
        variable addend : unsigned(7 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                acc       <= (others => '0');
                mcand     <= (others => '0');
                mult      <= (others => '0');
                round_idx <= 0;
                product_r <= (others => '0');
                busy_r    <= '0';
                done_r    <= '0';
            else
                done_r <= '0';
                if busy_r = '0' then
                    if start = '1' then
                        acc       <= (others => '0');
                        mcand     <= resize(unsigned(a), 8);
                        mult      <= unsigned(b);
                        round_idx <= 0;
                        busy_r    <= '1';
                    end if;
                else
                    if mult(0) = '1' then
                        addend := mcand;
                    else
                        addend := (others => '0');
                    end if;
                    acc   <= acc + addend;
                    mcand <= shift_left(mcand, 1);
                    mult  <= shift_right(mult, 1);
                    if round_idx = 3 then
                        product_r <= acc + addend; -- old acc plus final partial product
                        busy_r    <= '0';
                        done_r    <= '1';
                        round_idx <= 0;
                    else
                        round_idx <= round_idx + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    product <= std_logic_vector(product_r);
    busy    <= busy_r;
    done    <= done_r;
end architecture;

