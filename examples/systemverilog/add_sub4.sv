module add_sub4 (
    input  logic [3:0] a, b,
    input  logic       sub,
    output logic [3:0] result,
    output logic       carry_out, borrow, overflow
);
    logic [3:0] b_eff;
    logic [4:0] sum5;

    assign b_eff     = b ^ {4{sub}};
    assign sum5      = {1'b0, a} + {1'b0, b_eff} + {4'b0000, sub};
    assign result    = sum5[3:0];
    assign carry_out = sum5[4];
    assign borrow    = sub & ~sum5[4];
    assign overflow  = ~(a[3] ^ b_eff[3]) & (a[3] ^ result[3]);
endmodule

