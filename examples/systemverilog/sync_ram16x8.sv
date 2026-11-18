module sync_ram16x8 (
    input  logic       clk,
    input  logic       we,
    input  logic [3:0] addr,
    input  logic [7:0] din,
    output logic [7:0] dout
);
    // No reset/power-up initialization is specified.
    // A write does not change dout; a read updates dout on the clock edge.
    logic [7:0] mem [0:15];
    always_ff @(posedge clk) begin
        if (we)
            mem[addr] <= din;
        else
            dout <= mem[addr];
    end
endmodule

