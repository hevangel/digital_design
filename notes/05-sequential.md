# 05 — Synchronous sequential circuits and finite-state machines

**Study outcome:** derive transition/output functions, eliminate ambiguities about reset and event ordering.

A clocked circuit samples D at the active edge; Q changes after that edge in RTL simulation. Setup and hold are *analog library timing constraints* external to behavioral RTL. Latches are **level** sensitive: when enabled, Q follows D; accidentally incomplete combinational assignments can infer a latch.

## Machine design workflow

1. Write event timing: input sampled at the rising edge, active-high synchronous reset, one-cycle output pulse or combinational (Mealy) output?
2. Write a state diagram/table, including reset and illegal state behavior.
3. Minimize states only when they have equivalent future observable behavior (not just identical immediate outputs).
4. Choose encoding: binary for few bits, one-hot for simpler decode in some libraries, tool-selected in FPGA flows.
5. Separate state updates and next-state/output logic or use a well-defined single clocked process; do not multiply-drive a register.

### Worked example — overlapping “1011” detector

Keep the *longest suffix of the received stream that is a prefix of 1011*:
- S0: none.
- S1: matched `1`.
- S10: matched `10`.
- S101: matched `101`.

On bit 1 while in S101, emit a one-cycle registered `detected` pulse and go to S1 (suffix “1” of the just-received 1011). On bit 0 from S101, go to S10. This allows overlapping matches in stream `1011011`. The output appears **after the accepting edge**, not as a Mealy output before it.

## HDL laboratory

- [Sequence detector](../examples/README.md#sequential).
- Confirm reset priority and test back-to-back matches, shifted streams, and an input with no matches.
- Write a temporal assertion: a pulse only follows the right four received samples; ensure reset disables antecedents.

**Edition connection:** third edition emphasized D flip-flops; SV `always_ff` and VHDL `rising_edge` are modern representations of the same state-transition model.
