# 01 — Digital systems, binary arithmetic, and codes

**Study outcome:** represent the *same mathematical quantity* under different radices and bit-width conventions; detect when hardware representations lose information.

## Core ideas

For unsigned n-bit words, the range is 0 to 2^n−1. Two's-complement n-bit signed range is −2^(n−1) to 2^(n−1)−1. A bit pattern is not intrinsically signed: `8'b11111111` denotes 255 unsigned and −1 signed. Algebraic addition is modulo 2^n until carry and overflow flags are interpreted.

To convert 43 decimal: divide by 2 repeatedly to get 101011₂; group 4 bits to get 0x2B. One's complement inverts bits; two's complement negates by invert+1. Beware the asymmetric signed range: the most negative number cannot be negated at the same width. For subtraction A−B on n bits implement A+~B+1 and distinguish unsigned *borrow* from signed *overflow*.

Binary-coded decimal (BCD) stores each base-10 digit as 4 bits 0000–1001, leaving six invalid patterns. Excess-3 digit encoding adds 0011 to each valid BCD digit, useful for historical code conversion. Gray code changes one bit at a time *between adjacent integers*, but does not eliminate metastability; synchronized Gray-coded pointers remain subject to CDC constraints.

## Worked check

On 4 bits, 7+3 = 1010₂. It has no unsigned carry, but it **does** overflow signed (+7+3 exceeds +7). Meanwhile 15+1 = 0000₂ with carry=1 and **no** signed overflow (interpreted −1+1=0).

A simple parity bit over a word is XOR reduction; it detects every odd count of bit flips, not every even count. For real RAM protection, study ECC as a separate subject.

### Fractional conversion and rounding

Convert 13.3₁₀ to an unsigned fixed-point word with four integer bits and four fractional bits. The integer part is 1101₂. For the fraction, multiply each remainder by 2 and record the integer part of the result as the next bit.

| Current remainder | Doubled | Next bit | New remainder |
| --- | --- | --- | --- |
| 0.3 | 0.6 | 0 | 0.6 |
| 0.6 | 1.2 | 1 | 0.2 |
| 0.2 | 0.4 | 0 | 0.4 |
| 0.4 | 0.8 | 0 | 0.8 |
| 0.8 | 1.6 | 1 | 0.6 |

The remainder 0.6 recurs, so the exact expansion is 1101.0100110011…₂. Truncating to four fractional bits stores `1101_0100`, which represents 13.25 and has error −0.05. Rounding to nearest stores `1101_0101`, which represents 13 + 5/16 = 13.3125 and has error +0.0125. Equivalently, 0.3 × 16 = 4.8 is closer to 5 than to 4. The implied binary point establishes the scale of the stored integer.

### Radix-complement subtraction

For a width of n digits in radix r, the radix complement of B is `(r^n − B) mod r^n`. At three decimal digits, the 10's complement of 285 is 715. Add `473 + 715 = 1188` and discard the carry beyond three digits. The residue 188 is the difference, and the carry indicates that this unsigned subtraction needed no borrow. Reverse the operands to check the wraparound case. The complement of 473 is 527, so `285 + 527 = 812` has no carry. Taking the complement of this residue gives the magnitude 188, so the mathematical difference is −188. A three-digit residue alone cannot distinguish this case from a positive 812.

### ASCII with an agreed parity bit

Lowercase `k` has the seven-bit ASCII code `1101011` (hexadecimal 6B). Its five set bits require a 1 in bit 7 of an eight-bit frame whose most significant bit carries even parity. The transmitted byte is `11101011` (hexadecimal EB). The receiver XOR-reduces all eight bits to check for 0, then decodes the low seven bits as ASCII. If bit 0 flips, `11101010` has five ones and fails the check. The integer value 107 is an index for the character code. The parity rule applies to the transmitted representation of that code.

## HDL laboratory

- [BCD → Excess-3](../examples/README.md#number-systems), includes `valid` output and deterministic invalid-code handling.
- [Adder/subtractor](../examples/README.md#combinational) contrasts carry, borrow and signed overflow.
- [Parity](../examples/README.md#memory--error-detection) validates even parity.

**Exercise:** enumerate all 16 BCD input patterns and confirm valid=1 only for 0..9; test −8−1 at width 4 and explain wrap/overflow. Extension: build a signed saturating adder that clamps on overflow.

**Edition connection.** Read the [second edition](../editions/02-1991.md), §§1-3, 1-5 and 1-7, pp. 6, 10 and 17, or the [sixth Global edition](../editions/06-2017.md), §§1.3–1.7, pp. 22–38 (section starts), for conversions, complements and code conventions. The sixth Global ASCII and parity discussion is in §1.7, pp. 44–46.
