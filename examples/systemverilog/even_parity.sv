module even_parity (
    input  logic [7:0] data,
    input  logic       parity_in,
    output logic       parity_out,
    output logic       error
);
    // parity_out makes (data, parity_out) even parity.
    assign parity_out = ^data;
    assign error      = parity_out ^ parity_in;
endmodule

