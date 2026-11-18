module seq1011 (
    input  logic clk,
    input  logic rst,       // synchronous active-high reset
    input  logic din,       // sampled every rising edge
    output logic detected   // registered one-cycle pulse
);
    typedef enum logic [1:0] {S0, S1, S10, S101} state_t;
    state_t state, next_state;
    always_comb begin
        next_state = S0;
        case (state)
            S0:   next_state = din ? S1 : S0;
            S1:   next_state = din ? S1 : S10;
            S10:  next_state = din ? S101 : S0;
            S101: next_state = din ? S1 : S10;
            default: next_state = S0;
        endcase
    end
    always_ff @(posedge clk) begin
        if (rst) begin
            state    <= S0;
            detected <= 1'b0;
        end else begin
            state    <= next_state;
            detected <= (state == S101) && din;
        end
    end
endmodule

