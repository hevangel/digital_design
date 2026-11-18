# 02 — Boolean algebra and digital logic gates

**Study outcome:** move rigorously among truth tables, equations, gates, and hardware observations.

## Core laws

For bits a and b, `a + b` means Boolean OR (not integer addition), `ab` means AND, and a complement means NOT. De Morgan's theorems: ~(ab)=~a+~b; ~(a+b)=~a~b. Absorption: a+ab=a. Distribution is valid in both directions: a(b+c)=ab+ac; a+bc=(a+b)(a+c).

A minterm is an AND of every input literal and is 1 on exactly one row. The same-index maxterm is its complement, an OR of every input literal that is 0 on that row. Sum-of-products (SOP) ORs product terms. Product-of-sums (POS) ANDs sum terms. NAND and NOR are universal gates, and a single-family implementation needs systematic inversion and bubble accounting.

`XOR` is parity (a⊕b), and XNOR represents equality of single bits. A 3-input majority voter is `ab+ac+bc`: the output is 1 whenever at least two inputs are 1. It is also the carry-out function of a full adder with these inputs.

## Worked derivation

`ab + a~b = a(b + ~b) = a`. That identity reduces two ANDs and an OR to a wire, **if** the algebra describes the real logical function. Physical gate delays mean intermediate implementations can glitch even when the Boolean result is constant.

SV `logic` and VHDL `std_logic` are multi-valued simulation types. Neither gives every logic operator the same two-valued behavior in the presence of unknowns. Avoid `casex` for synthesizable decoding; an unknown input is a verification warning, not a don't-care in the specification.

### Index a truth table and build a NAND circuit

For an original function F, let the index be the binary value of `abc`, with `a` most significant. Canonical SOP lists the indexes where F = 1. Canonical POS lists the indexes where F = 0.

- F = Σm(1, 2, 6) = `~a ~b c + ~a b ~c + a b ~c`.
- F = ΠM(0, 3, 4, 5, 7) = `(a+b+c)(a+~b+~c)(~a+b+c)(~a+b+~c)(~a+~b+~c)`.

At index 2 (`010`), `~a b ~c` is the only canonical product that evaluates to 1. At index 3 (`011`), the sum `a+~b+~c` is 0, making the whole POS 0. The table evaluates both forms for every row.

| Index | `abc` | Specified F | Canonical SOP | Canonical POS | Dual Fᵈ |
| ---: | --- | ---: | ---: | ---: | ---: |
| 0 | 000 | 0 | 0 | 0 | 1 |
| 1 | 001 | 1 | 1 | 1 | 0 |
| 2 | 010 | 1 | 1 | 1 | 1 |
| 3 | 011 | 0 | 0 | 0 | 1 |
| 4 | 100 | 0 | 0 | 0 | 1 |
| 5 | 101 | 0 | 0 | 0 | 0 |
| 6 | 110 | 1 | 1 | 1 | 0 |
| 7 | 111 | 0 | 0 | 0 | 1 |

Combine the two products with the shared factor `b ~c` to get F = `~a ~b c + b ~c`. Implement the input inversions with tied-input NANDs `a_n = NAND(a,a)`, `b_n = NAND(b,b)` and `c_n = NAND(c,c)`. These three nets are high when their inputs are low. The product signals `p_n = NAND(a_n,b_n,c)` and `q_n = NAND(b,c_n)` are active low. The output `F = NAND(p_n,q_n)` is active high and asserts when either product net is low. In a bubble diagram the two product output bubbles match the input bubbles of the final OR-equivalent gate.

To form the dual, swap OR with AND and 0 with 1 wherever those constants occur, keeping each literal's polarity. The dual of the simplified expression is Fᵈ = `(~a+~b+c)(b+~c)`. The last column also follows from Fᵈ(`a,b,c`) = `~F(~a,~b,~c)`. For instance, 010 complements to 101, whose F is 0, so the dual is 1 at 010.

The NAND list specifies Boolean behavior. In a physical implementation, use the device's input thresholds, output voltage limits and load ratings when wiring gates together. [Electrical examples](10-logic-families.md)

## HDL laboratory

- [Three-input majority gate](../examples/README.md#boolean-logic) with exhaustive 8-vector test.
- Build NAND-only form and exhaustively compare all 8 input patterns.
- Distinguish combinational propagation delay (time) from number of gate levels (a rough proxy for delay).

**Edition connection.** The [sixth Global edition](../editions/06-2017.md) introduces canonical forms in §2.6, p. 72, and covers gates and ICs in §§2.8–2.9, pp. 83 and 89. The [second edition](../editions/02-1991.md), §2-5, also covers minterms, maxterms and conversion to standard forms. See [older graphic symbols](11-labs-symbols.md) for legacy schematics.
