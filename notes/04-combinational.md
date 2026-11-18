# 04 — Combinational circuit design

**Study outcome:** specify a block, derive its logic, and verify corner cases before reusing it.

## Method

Define input/output widths, signedness, behavior for invalid inputs and expected delay/latency. Then create a truth table or algebraic contract, decompose into reusable blocks (decoder, mux, comparator, adder), implement, and test independently.

### Full adder

Sum = a⊕b⊕cin; carry = ab+acin+bcin. A ripple adder cascades carry N times; carry-lookahead computes propagate `p_i=a_i⊕b_i` and generate `g_i=a_i b_i` to shorten depth. This is logical architecture, not a substitute for real timing measurements.

### Combined adder/subtractor

For n-bit inputs A,B and control sub: `B_eff = B XOR {n{sub}}`, `result = A+B_eff+sub`. In subtraction mode, carry_out=1 means *no unsigned borrow* and borrow=~carry_out. Signed overflow occurs when the operand signs (of A and B_eff) agree but differ from result sign. Do **not** confuse carry-out with signed overflow.

### Decoder/mux/encoder

An n-to-2^n decoder gives a one-hot output when enabled. A mux chooses exactly one of many inputs based on select; incomplete `case` assignments infer latches. Priority encoder differs from ordinary encoder because multiple valid request bits can be present simultaneously.

## HDL laboratory

- [4-bit adder/subtractor](../examples/README.md#combinational) checks every A,B,sub triple.
- [4:1 mux](../examples/README.md#combinational) highlights selected-input behavior.
- Explain 4-state simulation handling and why `default` should specify behavior for invalid selection.

**Edition connection:** third edition consolidated combinational circuits into one chapter. In the fifth/sixth curriculum it remains chapter 4.
