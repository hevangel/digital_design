module shift8 (
    input  logic       clk,
    input  logic       rst,        // synchronous
    input  logic       shift_en,
    input  logic       serial_in,
    output logic [7:0] q
);
    always_ff @(posedge clk) begin
        if (rst) q <= 8'd0;
        else if (shift_en) q <= {q[6:0], serial_in};
    end
endmodule

