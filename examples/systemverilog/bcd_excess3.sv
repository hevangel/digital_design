module bcd_excess3 (
    input  logic [3:0] bcd,
    output logic [3:0] excess3,
    output logic       valid
);
    // Accepted digits: 0 through 9. Invalid patterns map to zero.
    always_comb begin
        valid   = (bcd <= 4'd9);
        excess3 = valid ? (bcd + 4'd3) : 4'd0;
    end
endmodule

