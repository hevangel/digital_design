# 02 — Boolean algebra and digital logic gates

**Study outcome:** move rigorously among truth tables, equations, gates, and hardware observations.

## Core laws

For bits a and b, `a + b` means Boolean OR (not integer addition), `ab` means AND, and a complement means NOT. De Morgan's theorems: ~(ab)=~a+~b; ~(a+b)=~a~b. Absorption: a+ab=a. Distribution is valid in both directions: a(b+c)=ab+ac; a+bc=(a+b)(a+c).

A minterm fixes every input variable (e.g. ~a b c); a maxterm is the complementary dual. Sum-of-products (SOP) ORs product terms; product-of-sums (POS) ANDs sum terms. NAND and NOR are universal; implementing all gates with one family requires systematic inversion/bubble accounting.

`XOR` is parity (a⊕b), and XNOR represents equality of single bits. A 3-input majority voter is `ab+ac+bc`: the output is 1 whenever at least two inputs are 1. It is also the carry-out function of a full adder with these inputs.

## Worked derivation

`ab + a~b = a(b + ~b) = a`. That identity reduces two ANDs and an OR to a wire, **if** the algebra describes the real logical function. Physical gate delays mean intermediate implementations can glitch even when the Boolean result is constant.

SV `logic` and VHDL `std_logic` are multi-valued simulation types. Neither gives every logic operator the same two-valued behavior in the presence of unknowns. Avoid `casex` for synthesizable decoding; an unknown input is a verification warning, not a don't-care in the specification.

## HDL laboratory

- [Three-input majority gate](../examples/README.md#boolean-logic) with exhaustive 8-vector test.
- Build NAND-only form and exhaustively compare all 8 input patterns.
- Distinguish combinational propagation delay (time) from number of gate levels (a rough proxy for delay).

**Edition connection:** core in editions 1–6; use [older graphic symbols](11-labs-symbols.md) when reading legacy schematics.
