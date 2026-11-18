# 11 — Laboratory work, graphic symbols, and implementation evidence

**Study outcome.** Read a register symbol as a pin-level contract and record which stage of a lab verifies each part of that contract.

The second edition adds a chapter on standard graphic symbols. The third and fourth editions use Ch. 11 for laboratories and Ch. 12 for graphic symbols. The fifth and sixth editions use Ch. 9 and Ch. 10.

## How to read a schematic

A rectangular logic symbol can use qualifiers to specify function or pin behavior and numbered dependencies to show which pins affect one another.

This annotated pin table describes the equivalent of a two-bit parallel register with a rising-edge clock and active-low output enable. The example has no reset, so treat stored bits as unspecified until the first captured value.

| Pin | Marks on a rectangular symbol | Decode |
| --- | --- | --- |
| `clk` | Dynamic-input triangle, `C1` | A rising transition clocks the inputs marked with dependency 1 |
| `d[1:0]` | `1D` on each data input | Both data bits are captured on the edge identified by `C1` |
| `oe_n` | Active-low bubble in positive logic, `EN2` | A low level enables the outputs marked with dependency 2 |
| `q[1:0]` | Dependency `2` and a three-state qualifier on each output | Each output drives its stored bit when enabled and releases to high impedance when disabled |

For example, sample `d=10` on the rising edge with `oe_n=1`. Both outputs are high impedance while the register stores `10`. Lower `oe_n` between edges and the outputs drive `10` after enable propagation. Changing `d` between edges leaves the stored value unchanged. The numbers in `C1` and `EN2` identify dependencies, independent of pin numbers and bus indexes.

## A reproducible lab notebook

Use this worksheet for a proposed experiment. Record the design revision, device or simulator, tool versions and commands so another reader can reproduce the result.

| Evidence | Record | Register example |
| --- | --- | --- |
| Prediction | Function table, stimulus, initialization and observation phase | Predict `Z` while disabled and `10` after enabling the stored value |
| RTL trace | Bench vectors, expected and observed values, assertion result, waveform or log | Capture a word while disabled, then assert that enabling exposes it between clock edges |
| Synthesis report | Target, inferred resources, reported warnings, report path | Check for two register bits and whether the target implements three-state behavior at the pins |
| Pin and clock constraints | Board pin map, I/O standard, clock source and period, tool report confirming constraints | Record pin assignments and clock timing for the test setup |
| Physical observation | Board and instrument settings, test point, applied load and measured values | Observe driven levels with a scope and use a known weak bias to observe pin release |

For each row, record the result and any assumptions or limitations of that measurement. A planned physical observation stays pending until the board measurement is recorded.

## Proposed experiment sequence

- Experiment A: enumerate all BCD patterns, convert BCD to Excess-3.
- B: truth-table minimize the majority and mux functions.
- C: exhaustive 4-bit add/sub test, including overflow/borrow.
- D: observe registered pulse timing in a sequence detector.
- E: verify write/read latency of a synchronous memory and inject parity faults.
- F: time a four-round multiplier and distinguish product-valid from product storage.
- G (historical): physically compare TTL vs CMOS logic noise margins using **datasheets and safe laboratory equipment**, not RTL.

In the 4th ed. (2007), §11.19, p. 553, Experiment 18 covers asynchronous sequential circuits. Use the companion's flow table and race analysis to prepare for that historical reading. [Asynchronous sequential logic](09-asynchronous.md)

The 4th ed. also includes HDL simulation and FPGA prototyping in §11.20, p. 553. The 5th ed. goes from Experiment 17 in §9.18, p. 478, to Verilog simulation and FPGA prototyping in §9.19, p. 480. The 6th Global edition uses the broader HDL wording in §9.19, p. 615.

**Edition connection.** Mano, *Digital Design*, 2nd ed. (1991), §§12-2–12-3, pp. 482 and 484, describes qualifiers and dependencies, and §12-8, p. 496, applies them to RAM. The 3rd ed. (2002), §11-19, covers Verilog lab simulation, with body material on p. 481. For dependency notation, see Mano and Ciletti, 4th ed., §12.3, p. 564, and 5th ed. (©2013), §10.3, p. 493. The 5th ed. applies the notation to RAM in §10.8, p. 504. In the 6th ed., Global printing (©2019, ISBN 9781292231167), see §§10.2–10.3, pp. 624 and 626, for qualifiers and dependencies and §§10.5–10.6, pp. 630 and 632, for flip-flop and register symbols. [Edition change ledger](../editions/changes.csv)
