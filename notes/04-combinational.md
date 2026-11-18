# 04 — Combinational circuit design

**Study outcome:** specify a block, derive its logic, and verify corner cases before reusing it.

## Method

Define input/output widths, signedness, behavior for invalid inputs and expected delay/latency. Then create a truth table or algebraic contract, decompose into reusable blocks (decoder, mux, comparator, adder), implement, and test independently.

### Full adder

Sum = a⊕b⊕cin; carry = ab+acin+bcin. A ripple adder cascades carry N times; carry-lookahead computes propagate `p_i=a_i⊕b_i` and generate `g_i=a_i b_i` to shorten depth. This is logical architecture, not a substitute for real timing measurements.

For a four-bit lookahead block, number the bits from 0 (least significant). Start from `c_(i+1) = g_i + p_i c_i` and substitute for each preceding carry.

```text
c1 = g0 + p0 c0
c2 = g1 + p1 g0 + p1 p0 c0
c3 = g2 + p2 g1 + p2 p1 g0 + p2 p1 p0 c0
c4 = g3 + p3 g2 + p3 p2 g1 + p3 p2 p1 g0 + p3 p2 p1 p0 c0
```

Each sum bit is `p_i XOR c_i`. For `A=1111`, `B=0001` and `c0=0`, bit 0 generates a carry and bits 1 through 3 propagate it. The `p3 p2 p1 g0` term gives `c4=1` and the low sum is `0000`. The lookahead expressions compute carries in parallel at the cost of wider gates or additional grouping logic. Propagation delay and area depend on the mapped circuit. The iterative multiplier reuses its datapath and measures its latency in clock edges. [Iterative multiplier trace](08-rtl.md)

### Combined adder/subtractor

For n-bit inputs A,B and control sub: `B_eff = B XOR {n{sub}}`, `result = A+B_eff+sub`. In subtraction mode, carry_out=1 means *no unsigned borrow* and borrow=~carry_out. Signed overflow occurs when the operand signs (of A and B_eff) agree but differ from result sign. Do **not** confuse carry-out with signed overflow.

### One-digit BCD addition

Accept two valid BCD nibbles and a one-bit decimal carry-in. First form the five-bit binary sum `r4 r3 r2 r1 r0`, with values 0–19. For sums 10–15, the low nibble is invalid BCD. A sum of 16–19 sets `r4` and also needs correction. Detect both with `adjust = r4 OR (r3 AND (r2 OR r1))`. When `adjust=1`, add 6 to the five-bit word. The corrected high bit is the decimal carry, and the corrected nibble is the units digit. Adding 6 bridges the difference between the base-10 boundary and the base-16 nibble boundary.

| Digits and carry-in | Raw sum | Adjust? | Corrected carry and digit |
| --- | --- | ---: | --- |
| 2 + 6 + 0 | `0_1000` | 0 | `0_1000` (8) |
| 5 + 7 + 0 | `0_1100` | 1 | `1_0010` (12) |
| 8 + 7 + 1 | `1_0000` | 1 | `1_0110` (16) |

### Decoder/mux/encoder

An n-to-2^n decoder gives a one-hot output when enabled. For example, an enabled two-to-four decoder with address `10` drives `y[3:0]=0100`. Its disabled output can be defined as `0000`. A mux chooses one input based on a select value. A priority encoder chooses a winner even if several request bits are set.

## Self-checking testbench

Specify a two-request encoder with bit 1 taking priority. `valid` marks a request and `multi` marks simultaneous requests. The index is forced to 0 on an empty request, and the consumer uses `valid` to tell that case from a real request on bit 0.

| `req[1:0]` | `valid` | `multi` | `index` |
| --- | ---: | ---: | ---: |
| 00 | 0 | 0 | 0 |
| 01 | 1 | 0 | 0 |
| 10 | 1 | 0 | 1 |
| 11 | 1 | 1 | 1 |

Implement the binary contract with complete combinational assignments. An exact `case` preserves the distinction between known bits and X/Z in simulation. This example drives X on all outputs outside its binary input domain, so a binary functional check can flag an unexpected unknown. The hardware contract covers binary requests. Synthesis may optimize the X assignment.

```systemverilog
`timescale 1ns/1ps
module priority2 (
    input  logic [1:0] req,
    output logic       valid, multi, index
);
    always_comb begin
        case (req)
            2'b00: {valid, multi, index} = 3'b000;
            2'b01: {valid, multi, index} = 3'b100;
            2'b10: {valid, multi, index} = 3'b101;
            2'b11: {valid, multi, index} = 3'b111;
            default: {valid, multi, index} = 3'bxxx;
        endcase
    end
endmodule
```

Drive each input vector, let the model react, then compare with the expected tuple taken from the truth table. Input changes and dependent output updates can run in separate scheduler events. In VHDL, signal assignments schedule updates, and combinational signal chains can take more than one delta cycle at the same simulation time. This bench waits 1 ns to let the zero-delay model settle. A timing-annotated model needs an observation interval based on its modeled delay.

For a separate scheduling exercise, start with `01` settled and issue the SystemVerilog nonblocking drive `req <= 2'b10`. An immediate read in the same process observes the old value because the input update is still scheduled. The table compares both phases with the truth-table expectation for the new vector. The main bench uses blocking drives followed by an explicit wait.

| Phase | Current `req` | Expected for new input | Observed `{valid,multi,index}` |
| --- | --- | --- | --- |
| Immediately after scheduling the drive, before yielding | `01` | `101` | `100` (previous vector) |
| At the check, 1 ns after drive | `10` | `101` | `101` |

```systemverilog
`timescale 1ns/1ps
module tb_priority2;
    logic [1:0] req;
    logic valid, multi, index;

    priority2 dut (.req(req), .valid(valid), .multi(multi), .index(index));

    task automatic check(input logic [1:0] stimulus, input logic [2:0] expected);
        req = stimulus;
        #1;
        if ({valid, multi, index} !== expected)
            $fatal(1, "req=%b expected=%b observed=%b",
                   stimulus, expected, {valid, multi, index});
    endtask

    initial begin
        check(2'b00, 3'b000);
        check(2'b01, 3'b100);
        check(2'b10, 3'b101);
        check(2'b11, 3'b111);
        check(2'bx1, 3'bxxx);
        check(2'b1z, 3'bxxx);
        $finish;
    end
endmodule
```

Case inequality (`!==`) fails on an unknown or high-impedance bit where the table requires a binary value. The last two vectors deliberately exercise the simulation fallback. For edge-triggered observation and races, see the [register-transfer design trace](08-rtl.md).

## HDL laboratory

- [4-bit adder/subtractor](../examples/README.md#combinational) checks every A,B,sub triple.
- [4:1 mux](../examples/README.md#combinational) highlights selected-input behavior.
- Explain 4-state simulation handling and why `default` should specify behavior for invalid selection.

**Edition connection.** The [second edition](../editions/02-1991.md) groups lookahead, decimal addition, comparison and encoders in §§5-2–5-5, pp. 154–166 (section starts). The [third edition](../editions/03-2002.md) consolidated combinational circuits in Chapter 4. For the modern reading path, see the [sixth Global edition](../editions/06-2017.md), §§4.5–4.11, pp. 172–198 (section starts), on combinational building blocks, and §§3.10, 4.13–4.15, pp. 154 and 231–245 (section starts), on HDL truth tables, behavioral modeling, testbenches and simulation.
