# 03 — Karnaugh maps, minimization, and hazards

**Study outcome:** minimize a function without confusing algebraic equivalence with physical hazard-free implementation.

## K-map procedure

1. List minterms and don't-cares separately; Gray-code the map axes so adjacent cells differ in exactly one input.
2. Cover all 1-cells (SOP) with power-of-two groups 1,2,4,8,... including wraparound adjacency; use don't-cares **only** when convenient.
3. Identify essential prime implicants, then cover remaining 1-cells; simplify by eliminating variables changing within a group.
4. For POS, group zero-cells instead, keeping input-polarity rules straight.
5. Verify each resulting formula against the full truth table, excluding only *truly* invalid input cases.

## Five- and six-variable maps

Split a five-variable map into two four-variable planes with `a=0` and `a=1`. The index order is `abcde`, with `a` most significant. Within each plane, both axes use the order 00, 01, 11, 10. The function below has ones at indexes 9, 11, 25 and 27.

| | **a=0** | | | | **a=1** | | | |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **bc \\ de** | **00** | **01** | **11** | **10** | **00** | **01** | **11** | **10** |
| 00 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 01 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 11 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 10 | 0 | 1 | 1 | 0 | 0 | 1 | 1 | 0 |

Cells at the same row and column in the two planes differ only in `a`. Combine columns 01 and 11 of row 10 in both planes to cover four cells. Both `a` and `d` vary, leaving `b ~c e`.

With six variables ordered `uvbcde`, use four planes with `uv` = 00, 01, 11, 10. The first and last planes are adjacent. If the only 1 in each plane is row `bc=10`, column `de=11`, the indexes are 11, 27, 59 and 43 in plane order. A single group across the four planes eliminates both `u` and `v` and yields `b ~c d e`. Corresponding cells in planes 00 and 11 alone would differ in two bits and could not be paired.

## Exact SOP by tabulation

For indexes `abcd`, define the on-set {5, 6, 7, 13, 15}, the off-set {0, 1, 3, 4, 8, 9, 10, 11, 12, 14}, and the don't-care set {2}. Assume index 2 is excluded by the input contract. Cost is fewest product terms first, then fewest total literals.

Group the on-set and don't-care indexes by their number of 1 bits. The groups are {2}, {5, 6}, {7, 13}, and {15} in increasing order. Merge terms that differ in exactly one bit, replacing that bit with a dash. For later merges, the dash positions must already match.

| Adjacent indexes | First-round term |
| --- | --- |
| 2, 6 | `0-10` |
| 5, 7 | `01-1` |
| 5, 13 | `-101` |
| 6, 7 | `011-` |
| 7, 15 | `-111` |
| 13, 15 | `11-1` |

Merge `01-1` with `11-1` and `-101` with `-111`. Both pairs yield `-1-1`, so keep one copy. No further merges are possible. The unmerged terms from each round give the prime implicants. In the chart, only required 1-cells need coverage.

| Prime | Product | 5 | 6 | 7 | 13 | 15 |
| --- | --- | --- | --- | --- | --- | --- |
| `-1-1` | `bd` | ✓ | | ✓ | ✓ | ✓ |
| `011-` | `~a b c` | | ✓ | ✓ | | |
| `0-10` | `~a c ~d` | | ✓ | | | |

Index 5 is covered only by `bd`, so that term is essential. It leaves index 6 uncovered. Either of the two remaining primes covers 6, giving F₁ = `bd + ~a b c` or F₂ = `bd + ~a c ~d`. Both have two terms and five literals. The complete prime chart rules out a one-term cover or a shorter two-term one. A nonprime term could always be expanded to a prime without increasing the cost.

| Index | `abcd` | Specification | F₁ | F₂ |
| ---: | --- | ---: | ---: | ---: |
| 0 | 0000 | 0 | 0 | 0 |
| 1 | 0001 | 0 | 0 | 0 |
| 2 | 0010 | don't-care | 0 | 1 |
| 3 | 0011 | 0 | 0 | 0 |
| 4 | 0100 | 0 | 0 | 0 |
| 5 | 0101 | 1 | 1 | 1 |
| 6 | 0110 | 1 | 1 | 1 |
| 7 | 0111 | 1 | 1 | 1 |
| 8 | 1000 | 0 | 0 | 0 |
| 9 | 1001 | 0 | 0 | 0 |
| 10 | 1010 | 0 | 0 | 0 |
| 11 | 1011 | 0 | 0 | 0 |
| 12 | 1100 | 0 | 0 | 0 |
| 13 | 1101 | 1 | 1 | 1 |
| 14 | 1110 | 0 | 0 | 0 |
| 15 | 1111 | 1 | 1 | 1 |

The choice affects a two-level SOP realization. During the single-input transition 6 ↔ 7, `~a b c` in F₁ stays high. In F₂ the two terms hand off as `d` changes. Unequal delays may momentarily deactivate both paths and cause a static-1 glitch. The next example shows how an additional product can keep the output high through such a handoff.

### Example: mux equation and static-1 hazard

Let F(a,b,c)=~a b + a c, so a selects b or c. Ones at minterms m2,m3,m5,m7 with variable order abc. The two implicants give a minimum two-level SOP.

When b=c=1, F must stay 1 as a toggles. With unequal inverter/gate delays, the two paths may both be briefly false: a **static-1 hazard**. The redundant consensus product bc makes `~a b + a c + b c` logically identical but may remove that hazard in a suitable two-level gate realization. Real hazard analysis still depends on technology and timing; a Boolean testbench cannot prove analog glitch freedom.

A don't-care is permission from a *system-level valid-input constraint*, never “a value I don't want to test.” Document that assumption.

## HDL laboratory

- Compare [minimal and consensus-term forms](../examples/README.md#minimization), exercising all 8 patterns.
- Add gate delays in a **simulation-only** experiment and vary input skew; don't claim gate-delay simulation is a signoff check.
- Think about multi-level factoring, which may reintroduce hazards despite the same function.

**Edition connection.** The [first edition](../editions/01-1984.md) contents p. vi lists larger maps in §3-4, p. 80, and tabulation in §§3-9–3-12, pp. 102–110. The [second edition](../editions/02-1991.md) covers five-variable maps in §3-4, p. 82, and tabulation in §§3-9–3-12, pp. 102–109. The [third edition](../editions/03-2002.md) teaches the two-plane map in §3-3 and closes Chapter 3's instruction with §3-9 on Verilog. The [fourth edition](../editions/04-2007.md) has a standalone five-variable map section, §3.4, p. 81. The [fifth edition](../editions/05-2013.md) sets its limit for Chapter 3 map instruction at four variables in §3.3 and still references five-variable maps in its §8.5 design workflow. The [sixth Global edition](../editions/06-2017.md) has a separate section on HDL truth tables, §3.10, p. 154. [Edition crosswalk](../editions/README.md)
