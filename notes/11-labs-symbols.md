# 11 — Laboratory work, graphic symbols, and implementation evidence

The second edition introduced a chapter covering ANSI/IEEE 91 logic graphical symbols. The fourth has laboratories in chapter 11 and graphic symbols in chapter 12; the fifth/sixth use chapters 9 and 10 respectively. The **chapter numbering is not stable**.

## How to read a schematic

A rectangular IEC/IEEE-style symbol encodes function and inversion/edge qualifiers, but different drawing conventions exist. Always resolve active-low bubble, clock edge, asynchronous set/reset, output enable, bus width, and truth-table reference instead of trusting a generic box labeled “register.” A synchronous reset is not an asynchronous pin merely because both are drawn near a flip-flop.

## A reproducible lab notebook

Each experiment in this repository should state:
1. Function and assumptions (including invalid input encodings).
2. Predicted truth/transition table and observable latency.
3. Compilable independent SystemVerilog/VHDL implementations.
4. Self-checking vectors and evidence of pass/fail.
5. Gate-level/synthesis checks where tool/library available.
6. Any device-specific timing, fan-out, metastability or constraints **not** modeled by RTL.

## Sample progression

- Experiment A: enumerate all BCD patterns, convert BCD to Excess-3.
- B: truth-table minimize the majority and mux functions.
- C: exhaustive 4-bit add/sub test, including overflow/borrow.
- D: observe registered pulse timing in a sequence detector.
- E: verify write/read latency of a synchronous memory and inject parity faults.
- F: time a four-round multiplier and distinguish product-valid from product storage.
- G (historical): physically compare TTL vs CMOS logic noise margins using **datasheets and safe laboratory equipment**, not RTL.

When an edition labels an exercise “Experiment 18,” that historical numbering is not automatically reused here. No publisher exercise text is copied.

**Edition connection:** see [changes.csv](../editions/changes.csv) for labs/symbols add/renumber transitions.
