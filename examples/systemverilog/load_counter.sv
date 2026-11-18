module load_counter #(
    parameter int WIDTH = 4
) (
    input  logic             clk,
    input  logic             rst,     // synchronous active-high
    input  logic             load,
    input  logic             enable,
    input  logic [WIDTH-1:0] load_data,
    output logic [WIDTH-1:0] count
);
    always_ff @(posedge clk) begin
        if (rst)          count <= '0;
        else if (load)    count <= load_data;
        else if (enable)  count <= count + 1'b1;
    end
endmodule

