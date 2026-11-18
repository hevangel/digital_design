`timescale 1ns/1ps
module tb_sequential;
    logic clk = 0;
    always #5 clk = ~clk;

    logic rst, din, detected;
    seq1011 u_seq (.clk(clk), .rst(rst), .din(din), .detected(detected));

    logic load, enable;
    logic [3:0] load_data, count;
    load_counter #(.WIDTH(4)) u_count (
        .clk(clk), .rst(rst), .load(load), .enable(enable),
        .load_data(load_data), .count(count)
    );

    logic shift_en, serial_in;
    logic [7:0] shift_q;
    shift8 u_shift (.clk(clk), .rst(rst), .shift_en(shift_en),
                    .serial_in(serial_in), .q(shift_q));

    logic we;
    logic [3:0] addr;
    logic [7:0] din_ram, dout_ram;
    sync_ram16x8 u_mem (.clk(clk), .we(we), .addr(addr),
                         .din(din_ram), .dout(dout_ram));

    logic start, busy, done;
    logic [3:0] a, b;
    logic [7:0] product;
    iter_mult4 u_mult (.clk(clk), .rst(rst), .start(start), .a(a), .b(b),
                       .product(product), .busy(busy), .done(done));

    task automatic step;
        @(posedge clk);
        #1;
    endtask

    task automatic feed(input bit bitval, input bit expect_pulse);
        @(negedge clk); din = bitval;
        step();
        if (detected !== expect_pulse)
            $fatal(1, "seq1011 bit=%b expected pulse=%b", bitval, expect_pulse);
    endtask

    task automatic check_mult(input integer ai, bi);
        @(negedge clk);
        a = ai; b = bi; start = 1'b1;
        step();
        if (busy !== 1'b1 || done !== 1'b0) $fatal(1, "mult start");
        @(negedge clk); start = 1'b0;
        repeat (3) begin
            step();
            if (busy !== 1'b1 || done !== 1'b0)
                $fatal(1, "mult early done a=%0d b=%0d", ai, bi);
        end
        step();
        if (busy !== 1'b0 || done !== 1'b1 || product !== ai*bi)
            $fatal(1, "mult finish a=%0d b=%0d got=%0d", ai, bi, product);
    endtask

    integer i, j;
    initial begin
        rst = 1; din = 0; load = 0; enable = 0; load_data = 0;
        shift_en = 0; serial_in = 0;
        we = 0; addr = 0; din_ram = 0;
        start = 0; a = 0; b = 0;
        step();
        if (count !== 0 || shift_q !== 0 || busy !== 0 || done !== 0)
            $fatal(1, "synchronous reset");

        @(negedge clk); rst = 0; load = 1; enable = 1; load_data = 4'hF;
        step();
        if (count !== 4'hF) $fatal(1, "counter load priority");
        @(negedge clk); load = 0;
        step();
        if (count !== 0) $fatal(1, "counter wrap");
        @(negedge clk); enable = 0;
        step();
        if (count !== 0) $fatal(1, "counter hold");

        @(negedge clk); shift_en = 1; serial_in = 1;
        step();
        if (shift_q !== 8'h01) $fatal(1, "shift first bit");
        @(negedge clk); serial_in = 0;
        step();
        if (shift_q !== 8'h02) $fatal(1, "shift second bit");
        @(negedge clk); shift_en = 0;
        step();
        if (shift_q !== 8'h02) $fatal(1, "shift hold");

        // Sequence 1011011 has an overlapping 1011 twice (indices 3 and 6).
        feed(1, 0); feed(0, 0); feed(1, 0); feed(1, 1);
        feed(0, 0); feed(1, 0); feed(1, 1); feed(0, 0);

        @(negedge clk); we = 1; addr = 4'h3; din_ram = 8'h5A;
        step();
        @(negedge clk); we = 0;
        step();
        if (dout_ram !== 8'h5A) $fatal(1, "RAM write then registered read");
        @(negedge clk); we = 1; addr = 4'h3; din_ram = 8'hC7;
        step();
        if (dout_ram !== 8'h5A) $fatal(1, "RAM output must hold on write");
        @(negedge clk); we = 0;
        step();
        if (dout_ram !== 8'hC7) $fatal(1, "RAM updated content");

        for (i = 0; i < 16; i = i+1)
            for (j = 0; j < 16; j = j+1)
                check_mult(i, j);

        $display("PASS SV sequential (FSM, counter, shift, RAM, 256 multiplications)");
        $finish;
    end
endmodule

