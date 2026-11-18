`timescale 1ns/1ps
module tb_combinational;
    logic [3:0] bcd, ex3;
    logic valid;
    bcd_excess3 u_bcd (.bcd(bcd), .excess3(ex3), .valid(valid));

    logic ma, mb, mc, my, kmin, kcons;
    majority3 u_maj (.a(ma), .b(mb), .c(mc), .y(my));
    kmap_consensus u_kmap (.a(ma), .b(mb), .c(mc), .f_min(kmin), .f_consensus(kcons));

    logic [3:0] a4, b4, result;
    logic sub, carry_out, borrow, overflow;
    add_sub4 u_math (.a(a4), .b(b4), .sub(sub), .result(result),
                     .carry_out(carry_out), .borrow(borrow), .overflow(overflow));

    logic [3:0] data4;
    logic [1:0] sel;
    logic mux_y;
    mux4 u_mux (.data(data4), .sel(sel), .y(mux_y));

    logic [7:0] byte_data;
    logic pin, pout, error;
    even_parity u_par (.data(byte_data), .parity_in(pin), .parity_out(pout), .error(error));

    logic [6:0] segments;
    sevenseg_bcd u_seg (.digit(bcd), .seg(segments));

    integer ai, bi, sb, expected_result, sa, sbi, sexp;
    integer i, j, p;
    integer expected_carry, expected_borrow, expected_overflow;
    initial begin
        // All 16 BCD patterns, including the six invalid encodings.
        for (i = 0; i < 16; i = i+1) begin
            bcd = i;
            #1;
            if (valid !== (i <= 9)) $fatal(1, "BCD validity failed: %0d", i);
            if (ex3 !== ((i <= 9) ? i+3 : 0)) $fatal(1, "BCD value failed: %0d", i);
            if (i == 0 && segments !== 7'b0000001) $fatal(1, "7seg zero");
            if (i == 8 && segments !== 7'b0000000) $fatal(1, "7seg eight");
            if (i > 9 && segments !== 7'b1111111) $fatal(1, "7seg invalid");
        end

        for (i = 0; i < 8; i = i+1) begin
            {ma, mb, mc} = i;
            #1;
            if (my !== (((i>>2)&1) + ((i>>1)&1) + (i&1) >= 2))
                $fatal(1, "majority failed: %0d", i);
            if (kmin !== kcons) $fatal(1, "consensus function mismatch: %0d", i);
            if (kmin !== ((~ma & mb) | (ma & mc)))
                $fatal(1, "K-map failed: %0d", i);
        end

        // Verify arithmetic against software integer model: 16*16*2 cases.
        for (sb = 0; sb < 2; sb = sb+1)
          for (ai = 0; ai < 16; ai = ai+1)
            for (bi = 0; bi < 16; bi = bi+1) begin
                sub = sb; a4 = ai; b4 = bi;
                expected_result = sb ? ai-bi : ai+bi;
                sa = ai >= 8 ? ai-16 : ai;
                sbi = bi >= 8 ? bi-16 : bi;
                sexp = sb ? sa-sbi : sa+sbi;
                expected_carry = sb ? (ai >= bi) : (ai+bi >= 16);
                expected_borrow = sb && (ai < bi);
                expected_overflow = (sexp < -8) || (sexp > 7);
                #1;
                if (result !== (expected_result & 15))
                    $fatal(1, "result a=%0d b=%0d sub=%0d", ai, bi, sb);
                if (carry_out !== expected_carry || borrow !== expected_borrow ||
                    overflow !== expected_overflow)
                    $fatal(1, "flags a=%0d b=%0d sub=%0d", ai, bi, sb);
            end

        for (i = 0; i < 16; i = i+1)
          for (j = 0; j < 4; j = j+1) begin
              data4 = i; sel = j; #1;
              if (mux_y !== ((i >> j) & 1)) $fatal(1, "mux failed");
          end

        for (i = 0; i < 256; i = i+1) begin
            byte_data = i;
            p = 0;
            for (j = 0; j < 8; j = j+1) p = p ^ ((i >> j) & 1);
            pin = p;
            #1;
            if (pout !== p || error !== 1'b0) $fatal(1, "parity clean %0d", i);
            pin = ~pin;
            #1;
            if (error !== 1'b1) $fatal(1, "parity corrupted %0d", i);
        end
        $display("PASS SV combinational (BCD, majority, K-map, arithmetic, mux, parity, 7seg)");
        $finish;
    end
endmodule

