# 10 — Digital integrated circuits and physical logic families (historical extension)

**Why keep this?** Fourth edition includes a digital-IC chapter describing bipolar/MOS logic families; fifth edition omits the standalone chapter.

## Logical truth vs electrical operation

A Boolean NAND truth table does not determine VOH/VOL, VIH/VIL, source/sink current, rise/fall time, dynamic power, static power, fan-out, or propagation delay. Those parameters depend on process, voltage, temperature, load, and cell construction.

- **TTL** (bipolar) and **ECL** are historic implementations with different switching/power characteristics; an ECL design can trade increased static power for rapid switching.
- **CMOS** has dynamic power approximately `alpha*C*V^2*f` plus leakage/short-circuit power. The equation is a rough design estimate, not a substitute for activity-aware signoff.
- A **CMOS transmission gate** uses complementary pass devices; logic-level behavior alone omits resistance, body effect and analog constraints.
- **Open-collector/open-drain** means a device sinks current for 0 and releases a shared line for 1. An external pull-up establishes high, and rise time depends on RC loading. Two outputs can share a net *only* if electrical discipline permits it; ordinary push-pull outputs cannot be shorted together.

## Modern flow translation

RTL → gates mapped to a characterized standard-cell library → timing and power analysis → physical signoff. A behavioral `assign` cannot model a TSMC library cell's corner tables. ASIC/FPGA tri-state support is platform-dependent and often only at I/O; internal FPGA fabric tri-states are frequently synthesized as muxes or rejected.

## HDL laboratory

- [Open-drain model](../examples/README.md#historical-models) uses resolved 0/Z drives. It is **for simulation and I/O semantics**, not an implementation recipe for on-chip bidirectional routing.
- External pull-up and bus contention should be tested explicitly; line=`Z` alone is **not** logical 1.

**Edition connection:** edition 4 chapter 10 remains important if reconstructing chips of the 1970s–1990s.
