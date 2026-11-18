# 09 — Asynchronous sequential logic (historical extension)

**Why keep this?** It had its own chapter in edition 4 and is no longer a standalone chapter by edition 5. Reading old TTL designs and debugging resets/clock-domain crossings still requires the concepts.

## Circuits with memory but no global clock

A cross-coupled NAND SR latch has active-low `S_n` and `R_n`. With neither asserted (1,1) it holds state; S_n=0 sets Q=1; R_n=0 clears Q=0. S_n=R_n=0 is the **forbidden input** because both outputs are driven to 1, making release behavior potentially unstable. This is not fixed by adding a default in RTL.

| S_n | R_n | Meaning |
|---|---|---|
| 1 | 1 | hold |
| 0 | 1 | set |
| 1 | 0 | reset |
| 0 | 0 | forbidden |

Asynchronous state transition analysis distinguishes stable states, primitive flow tables, fundamental-mode operation (one input changes and circuit settles before the next), critical races, and static/dynamic hazards.

## Why simulation is not signoff

Zero-delay RTL feedback can lock at X/U, oscillate, or suppress glitches; timing, inertial effects, transistor properties and metastability affect real behavior. For chip design, physical-library timing and appropriate formal assumptions matter. Never implement a cross-coupled combinational loop in FPGA logic without target-specific support.

## HDL laboratory

- [Cross-coupled SR latch](../examples/README.md#historical-models) is explicitly **illustrative, not a production synthesizable IP block**, excluded from the normal synthesis/examples tests.
- Compare with a synchronous D flip-flop and explain why the clock changes the state update contract.
- Modern follow-up: analyze two-flop CDC synchronizer, handshake protocols, and asynchronous reset deassertion (not proof of metastability elimination).

**Edition connection:** compare 4th chapter 9 against 5th edition TOC; see [edition matrix](../editions/README.md).
