module open_drain (
    input  wire pull_low,
    inout  wire bus_line
);
    // Models an external open-drain pin. A high requires a pull-up elsewhere.
    assign bus_line = pull_low ? 1'b0 : 1'bz;
endmodule

