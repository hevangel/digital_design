# 03 — Karnaugh maps, minimization, and hazards

**Study outcome:** minimize a function without confusing algebraic equivalence with physical hazard-free implementation.

## K-map procedure

1. List minterms and don't-cares separately; Gray-code the map axes so adjacent cells differ in exactly one input.
2. Cover all 1-cells (SOP) with power-of-two groups 1,2,4,8,... including wraparound adjacency; use don't-cares **only** when convenient.
3. Identify essential prime implicants, then cover remaining 1-cells; simplify by eliminating variables changing within a group.
4. For POS, group zero-cells instead, keeping input-polarity rules straight.
5. Verify each resulting formula against the full truth table, excluding only *truly* invalid input cases.

### Example: mux equation and static-1 hazard

Let F(a,b,c)=~a b + a c, so a selects b or c. Ones at minterms m2,m3,m5,m7 with variable order abc. The two implicants give a minimum two-level SOP.

When b=c=1, F must stay 1 as a toggles. With unequal inverter/gate delays, the two paths may both be briefly false: a **static-1 hazard**. The redundant consensus product bc makes `~a b + a c + b c` logically identical but may remove that hazard in a suitable two-level gate realization. Real hazard analysis still depends on technology and timing; a Boolean testbench cannot prove analog glitch freedom.

A don't-care is permission from a *system-level valid-input constraint*, never “a value I don't want to test.” Document that assumption.

## HDL laboratory

- Compare [minimal and consensus-term forms](../examples/README.md#minimization), exercising all 8 patterns.
- Add gate delays in a **simulation-only** experiment and vary input skew; don't claim gate-delay simulation is a signoff check.
- Think about multi-level factoring, which may reintroduce hazards despite the same function.

**Edition connection:** 4th TOC lists a five-variable map; later TOCs emphasize four-variable maps. This is a **heading difference**, not proof larger maps disappeared from all teaching.
