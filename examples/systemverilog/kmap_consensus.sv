module kmap_consensus (
    input  logic a, b, c,
    output logic f_min, f_consensus
);
    // Both equations have the same truth table.
    // The bc consensus term can help avoid a gate-level static-1 hazard.
    assign f_min       = (~a & b) | (a & c);
    assign f_consensus = (~a & b) | (a & c) | (b & c);
endmodule

