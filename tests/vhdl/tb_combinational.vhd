library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity tb_combinational is end entity;

architecture sim of tb_combinational is
    signal bcd, ex3  : std_logic_vector(3 downto 0);
    signal valid     : std_logic;
    signal ma, mb, mc, my, kmin, kcons : std_logic;
    signal a4, b4, result : std_logic_vector(3 downto 0);
    signal sub, carry_out, borrow, overflow : std_logic;
    signal data4 : std_logic_vector(3 downto 0);
    signal sel   : std_logic_vector(1 downto 0);
    signal mux_y : std_logic;
    signal byte_data : std_logic_vector(7 downto 0);
    signal pin, pout, err : std_logic;
    signal segments : std_logic_vector(6 downto 0);
begin
    u_bcd  : entity work.bcd_excess3 port map(bcd, ex3, valid);
    u_maj  : entity work.majority3 port map(ma, mb, mc, my);
    u_kmap : entity work.kmap_consensus port map(ma, mb, mc, kmin, kcons);
    u_math : entity work.add_sub4 port map(a4, b4, sub, result, carry_out, borrow, overflow);
    u_mux  : entity work.mux4 port map(data4, sel, mux_y);
    u_par  : entity work.even_parity port map(byte_data, pin, pout, err);
    u_seg  : entity work.sevenseg_bcd port map(bcd, segments);

    process
        variable expected_result, sa, sb_signed, signed_expected : integer;
        variable p, bitcount : integer;
    begin
        for i in 0 to 15 loop
            bcd <= std_logic_vector(to_unsigned(i, 4));
            wait for 1 ns;
            if i <= 9 then
                assert valid = '1' and ex3 = std_logic_vector(to_unsigned(i+3, 4))
                    report "BCD conversion" severity failure;
            else
                assert valid = '0' and ex3 = "0000"
                    report "Invalid BCD" severity failure;
                assert segments = "1111111"
                    report "Blank invalid seven-segment digit" severity failure;
            end if;
            if i = 0 then
                assert segments = "0000001" report "7seg 0" severity failure;
            elsif i = 8 then
                assert segments = "0000000" report "7seg 8" severity failure;
            end if;
        end loop;

        for i in 0 to 7 loop
            if (i/4) mod 2 = 1 then ma <= '1'; else ma <= '0'; end if;
            if (i/2) mod 2 = 1 then mb <= '1'; else mb <= '0'; end if;
            if i mod 2 = 1 then mc <= '1'; else mc <= '0'; end if;
            wait for 1 ns;
            bitcount := ((i/4) mod 2) + ((i/2) mod 2) + (i mod 2);
            if bitcount >= 2 then
                assert my = '1' report "majority true" severity failure;
            else
                assert my = '0' report "majority false" severity failure;
            end if;
            assert kmin = kcons report "K-map/consensus differ" severity failure;
            assert kmin = (((not ma) and mb) or (ma and mc))
                report "K-map truth" severity failure;
        end loop;

        for mode in 0 to 1 loop
          if mode = 0 then sub <= '0'; else sub <= '1'; end if;
          for ai in 0 to 15 loop
            for bi in 0 to 15 loop
                a4 <= std_logic_vector(to_unsigned(ai, 4));
                b4 <= std_logic_vector(to_unsigned(bi, 4));
                if mode = 0 then expected_result := ai + bi;
                else expected_result := ai - bi; end if;
                if ai >= 8 then sa := ai-16; else sa := ai; end if;
                if bi >= 8 then sb_signed := bi-16; else sb_signed := bi; end if;
                if mode = 0 then signed_expected := sa+sb_signed;
                else signed_expected := sa-sb_signed; end if;
                wait for 1 ns;
                assert result = std_logic_vector(to_unsigned((expected_result+32) mod 16, 4))
                    report "4-bit arithmetic result" severity failure;
                if signed_expected < -8 or signed_expected > 7 then
                    assert overflow = '1' report "signed overflow expected" severity failure;
                else
                    assert overflow = '0' report "spurious signed overflow" severity failure;
                end if;
                if mode = 0 then
                    assert borrow = '0' report "add must have no borrow" severity failure;
                    if ai + bi >= 16 then
                        assert carry_out = '1' report "carry expected" severity failure;
                    else
                        assert carry_out = '0' report "spurious carry" severity failure;
                    end if;
                else
                    if ai < bi then
                        assert borrow = '1' and carry_out = '0'
                            report "borrow expected" severity failure;
                    else
                        assert borrow = '0' and carry_out = '1'
                            report "unexpected borrow" severity failure;
                    end if;
                end if;
            end loop;
          end loop;
        end loop;

        for i in 0 to 15 loop
          for j in 0 to 3 loop
            data4 <= std_logic_vector(to_unsigned(i, 4));
            sel <= std_logic_vector(to_unsigned(j, 2));
            wait for 1 ns;
            assert mux_y = data4(j) report "mux output" severity failure;
          end loop;
        end loop;

        for i in 0 to 255 loop
            byte_data <= std_logic_vector(to_unsigned(i, 8));
            p := 0;
            for bit_index in 0 to 7 loop
                if ((i / (2**bit_index)) mod 2) = 1 then
                    p := (p + 1) mod 2;
                end if;
            end loop;
            if p = 1 then pin <= '1'; else pin <= '0'; end if;
            wait for 1 ns;
            if p = 1 then
                assert pout = '1' report "odd byte parity" severity failure;
            else
                assert pout = '0' report "even byte parity" severity failure;
            end if;
            assert err = '0' report "false parity error" severity failure;
            pin <= not pin;
            wait for 1 ns;
            assert err = '1' report "missed parity error" severity failure;
        end loop;

        report "PASS VHDL combinational";
        stop;
        wait;
    end process;
end architecture;

