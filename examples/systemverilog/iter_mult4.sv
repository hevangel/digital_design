module iter_mult4 (
    input  logic       clk,
    input  logic       rst,        // synchronous active-high
    input  logic       start,      // accepted only while idle
    input  logic [3:0] a, b,
    output logic [7:0] product,    // retained until next completion
    output logic       busy,
    output logic       done        // one-cycle registered completion pulse
);
    logic [7:0] acc, mcand, addend;
    logic [3:0] mult;
    logic [2:0] round_idx;

    assign addend = mult[0] ? mcand : 8'd0;

    always_ff @(posedge clk) begin
        if (rst) begin
            acc       <= 8'd0;
            mcand     <= 8'd0;
            mult      <= 4'd0;
            round_idx <= 3'd0;
            product   <= 8'd0;
            busy      <= 1'b0;
            done      <= 1'b0;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                if (start) begin
                    acc       <= 8'd0;
                    mcand     <= {4'd0, a};
                    mult      <= b;
                    round_idx <= 3'd0;
                    busy      <= 1'b1;
                end
            end else begin
                acc       <= acc + addend;
                mcand     <= mcand << 1;
                mult      <= mult >> 1;
                round_idx <= round_idx + 3'd1;
                if (round_idx == 3'd3) begin
                    product <= acc + addend; // include final round
                    done    <= 1'b1;
                    busy    <= 1'b0;
                end
            end
        end
    end
endmodule

