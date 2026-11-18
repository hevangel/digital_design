module sr_nand_latch (
    input  wire set_n, reset_n,
    output wire q, q_bar
);
    // HISTORICAL / SIMULATION-ONLY: intentional combinational feedback.
    // set_n=reset_n=0 forbidden; power-up can remain X.
    wire qi, qbi;
    assign qi  = ~(set_n   & qbi);
    assign qbi = ~(reset_n & qi);
    assign q = qi;
    assign q_bar = qbi;
endmodule

