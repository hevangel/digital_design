module mux4 (
    input  logic [3:0] data,
    input  logic [1:0] sel,
    output logic       y
);
    assign y = data[sel];
endmodule

