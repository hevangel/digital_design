library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity tb_sequential is end entity;

architecture sim of tb_sequential is
    signal clk : std_logic := '0';
    signal rst, din, detected : std_logic := '0';
    signal load, enable : std_logic := '0';
    signal load_data, count : std_logic_vector(3 downto 0) := (others => '0');
    signal shift_en, serial_in : std_logic := '0';
    signal shift_q : std_logic_vector(7 downto 0);
    signal we : std_logic := '0';
    signal addr : std_logic_vector(3 downto 0) := (others => '0');
    signal din_ram : std_logic_vector(7 downto 0) := (others => '0');
    signal dout_ram : std_logic_vector(7 downto 0);
    signal start, busy, done : std_logic := '0';
    signal a, b : std_logic_vector(3 downto 0) := (others => '0');
    signal product : std_logic_vector(7 downto 0);
    constant bits : std_logic_vector(6 downto 0) := "1011011";
begin
    clk <= not clk after 5 ns;
    u_seq  : entity work.seq1011 port map(clk, rst, din, detected);
    u_cnt  : entity work.load_counter generic map(WIDTH => 4)
             port map(clk, rst, load, enable, load_data, count);
    u_shft : entity work.shift8 port map(clk, rst, shift_en, serial_in, shift_q);
    u_mem  : entity work.sync_ram16x8 port map(clk, we, addr, din_ram, dout_ram);
    u_mult : entity work.iter_mult4 port map(clk, rst, start, a, b, product, busy, done);

    process
        procedure step is
        begin
            wait until rising_edge(clk);
            wait for 1 ns;
        end procedure;
    begin
        rst <= '1';
        step;
        assert count = "0000" and shift_q = x"00" and busy = '0' and done = '0'
            report "reset" severity failure;

        wait until falling_edge(clk);
        rst <= '0'; load <= '1'; enable <= '1'; load_data <= "1111";
        step;
        assert count = "1111" report "counter load priority" severity failure;
        wait until falling_edge(clk); load <= '0';
        step;
        assert count = "0000" report "counter wrap" severity failure;
        wait until falling_edge(clk); enable <= '0';
        step;
        assert count = "0000" report "counter hold" severity failure;

        wait until falling_edge(clk); shift_en <= '1'; serial_in <= '1';
        step;
        assert shift_q = x"01" report "shift bit 1" severity failure;
        wait until falling_edge(clk); serial_in <= '0';
        step;
        assert shift_q = x"02" report "shift bit 2" severity failure;
        wait until falling_edge(clk); shift_en <= '0';
        step;
        assert shift_q = x"02" report "shift hold" severity failure;

        for i in 0 to 6 loop
            wait until falling_edge(clk);
            din <= bits(6-i);
            step;
            if i = 3 or i = 6 then
                assert detected = '1' report "sequence pulse missing" severity failure;
            else
                assert detected = '0' report "sequence false pulse" severity failure;
            end if;
        end loop;
        wait until falling_edge(clk); din <= '0';
        step;
        assert detected = '0' report "sequence pulse not cleared" severity failure;

        wait until falling_edge(clk);
        we <= '1'; addr <= "0011"; din_ram <= x"5A";
        step;
        wait until falling_edge(clk); we <= '0';
        step;
        assert dout_ram = x"5A" report "RAM first read" severity failure;
        wait until falling_edge(clk); we <= '1'; din_ram <= x"C7";
        step;
        assert dout_ram = x"5A" report "RAM held output on write" severity failure;
        wait until falling_edge(clk); we <= '0';
        step;
        assert dout_ram = x"C7" report "RAM updated data" severity failure;

        for ai in 0 to 15 loop
          for bi in 0 to 15 loop
            wait until falling_edge(clk);
            a <= std_logic_vector(to_unsigned(ai, 4));
            b <= std_logic_vector(to_unsigned(bi, 4));
            start <= '1';
            step;
            assert busy = '1' and done = '0' report "start busy" severity failure;
            wait until falling_edge(clk); start <= '0';
            for round_id in 0 to 2 loop
                step;
                assert busy = '1' and done = '0'
                    report "premature multiplier finish" severity failure;
            end loop;
            step;
            assert busy = '0' and done = '1' and
                   product = std_logic_vector(to_unsigned(ai*bi, 8))
                report "wrong multiplier output or latency" severity failure;
          end loop;
        end loop;
        report "PASS VHDL sequential";
        stop;
        wait;
    end process;
end architecture;

