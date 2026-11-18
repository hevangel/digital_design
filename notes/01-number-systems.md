# 01 — Digital systems, binary arithmetic, and codes

**Study outcome:** represent the *same mathematical quantity* under different radices and bit-width conventions; detect when hardware representations lose information.

## Core ideas

For unsigned n-bit words, the range is 0 to 2^n−1. Two's-complement n-bit signed range is −2^(n−1) to 2^(n−1)−1. A bit pattern is not intrinsically signed: `8'b11111111` denotes 255 unsigned and −1 signed. Algebraic addition is modulo 2^n until carry and overflow flags are interpreted.

To convert 43 decimal: divide by 2 repeatedly to get 101011₂; group 4 bits to get 0x2B. One's complement inverts bits; two's complement negates by invert+1. Beware the asymmetric signed range: the most negative number cannot be negated at the same width. For subtraction A−B on n bits implement A+~B+1 and distinguish unsigned *borrow* from signed *overflow*.

Binary-coded decimal (BCD) stores each base-10 digit as 4 bits 0000–1001, leaving six invalid patterns. Excess-3 digit encoding adds 0011 to each valid BCD digit, useful for historical code conversion. Gray code changes one bit at a time *between adjacent integers*, but does not eliminate metastability; synchronized Gray-coded pointers remain subject to CDC constraints.

## Worked check

On 4 bits, 7+3 = 1010₂. It has no unsigned carry, but it **does** overflow signed (+7+3 exceeds +7). Meanwhile 15+1 = 0000₂ with carry=1 and **no** signed overflow (interpreted −1+1=0).

A simple parity bit over a word is XOR reduction; it detects every odd count of bit flips, not every even count. For real RAM protection, study ECC as a separate subject.

## HDL laboratory

- [BCD → Excess-3](../examples/README.md#number-systems), includes `valid` output and deterministic invalid-code handling.
- [Adder/subtractor](../examples/README.md#combinational) contrasts carry, borrow and signed overflow.
- [Parity](../examples/README.md#memory--error-detection) validates even parity.

**Exercise:** enumerate all 16 BCD input patterns and confirm valid=1 only for 0..9; test −8−1 at width 4 and explain wrap/overflow. Extension: build a signed saturating adder that clamps on overflow.

**Edition connection:** foundational throughout editions 1–6; the HDL implementations are modern companions, not reconstructions of 1984 source code.
