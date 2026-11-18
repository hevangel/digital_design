# 05 — Synchronous sequential circuits and finite-state machines

**Study outcome:** derive transition/output functions, eliminate ambiguities about reset and event ordering.

A clocked circuit samples D at the active edge; Q changes after that edge in RTL simulation. Setup and hold are *analog library timing constraints* external to behavioral RTL. Latches are **level** sensitive: when enabled, Q follows D; accidentally incomplete combinational assignments can infer a latch.

## Machine design workflow

1. Write event timing: input sampled at the rising edge, active-high synchronous reset, one-cycle output pulse or combinational (Mealy) output?
2. Write a state diagram/table, including reset and illegal state behavior.
3. Minimize states only when they have equivalent future observable behavior (not just identical immediate outputs).
4. Choose encoding: binary for few bits, one-hot for simpler decode in some libraries, tool-selected in FPGA flows.
5. Separate state updates and next-state/output logic or use a well-defined single clocked process; do not multiply-drive a register.

## Flip-flop excitation

An excitation table works backward from a required state transition to the input choices of a flip-flop. A D flip-flop copies D at the edge. A JK flip-flop holds for `00`, resets for `01`, sets for `10` and toggles for `11`. A T flip-flop holds for T=0 and toggles for T=1.

| Present Q | Required Q⁺ | D | J | K | T |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 0 | 0 | 0 | 0 | – | 0 |
| 0 | 1 | 1 | 1 | – | 1 |
| 1 | 0 | 0 | – | 1 | 1 |
| 1 | 1 | 1 | – | 0 | 0 |

A dash permits either binary value. For example, both `JK=01` and `JK=11` take Q=1 to Q⁺=0, by reset and toggle respectively. For T, `Q XOR Q⁺` computes the required excitation.

## Analyze and reduce a two-flip-flop circuit

Two rising-edge D flip-flops share a synchronous reset to `00`. With reset inactive, wire the first D input `D1=x`, the second `D0=Q1`, and drive the combinational output `z=Q1 AND x`. Read the state as `Q1 Q0`. Since D is sampled directly, `Q1⁺ Q0⁺ = x Q1`, giving the complete transition table.

| Present state | `x=0`: next / z | `x=1`: next / z |
| --- | --- | --- |
| 00 | 00 / 0 | 10 / 0 |
| 01 | 00 / 0 | 10 / 0 |
| 10 | 01 / 0 | 11 / 1 |
| 11 | 01 / 0 | 11 / 1 |

For example, from `10` and `x=0`, the D input pair is `01` and the current output is 0. A reset edge overrides both D equations to clear Q.

Treat rows as abstract states during reduction. States 00 and 01 have identical future actions for each input, so merge them as A. States 10 and 11 also have identical actions and merge as B. A and B remain distinct since `x=1` gives different outputs. This produces the following reduced machine.

| State | `x=0`: next / z | `x=1`: next / z |
| --- | --- | --- |
| A (reset) | A / 0 | B / 0 |
| B | A / 0 | B / 1 |

Only after reducing do we choose codes. Assign A=0 and B=1. Then `D=x` and `z=Q AND x`. The removed flip-flop stored an older sample that made no difference to any future output.

## Mealy, Moore and registered output timing

Use the reduced machine to detect two consecutive high samples. The combinational Mealy output is `Q AND x`. A Moore version uses states M0 (no trailing ones), M1 (one trailing one) and M2 (at least two trailing ones). An input of 0 goes to M0 from every state. An input of 1 takes M0 to M1, M1 to M2 and M2 to itself. Its state decode gives 1 in M2. A registered transition-output version keeps the A/B state and clocks a separate output flip-flop with `Q AND x` on each edge. The Moore state and the registered output clear on reset.

After reset, drive `x=1` before E1, keep it high through E2, and drop it between E2 and E3. Values just after edges or input changes are shown after propagation or RTL scheduling has settled.

| Observation | x | Mealy z | Moore state / z | Registered z |
| --- | ---: | ---: | --- | ---: |
| Before E1 | 1 | 0 | M0 / 0 | 0 |
| After E1 | 1 | 1 | M1 / 0 | 0 |
| Before E2 | 1 | 1 | M1 / 0 | 0 |
| After E2 | 1 | 1 | M2 / 1 | 1 |
| After x drops, before E3 | 0 | 0 | M2 / 1 | 1 |
| After E3 | 0 | 0 | M0 / 0 | 0 |

At E2 the Mealy output is already high and can be sampled by a downstream flip-flop if it meets setup and hold. The Moore output is decoded from the state reached at E2. The registered version takes the pre-edge Mealy value into an output flip-flop at E2. A decoded Moore output can still glitch while multiple state bits change, depending on the encoding and gate delays.

## Worked example — overlapping “1011” detector

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

**Edition connection.** The [second-edition](../editions/02-1991.md) preface, pp. ix–xi, reports increased use of D flip-flop examples. Its §6-6, p. 231, presents excitation tables. The [third edition](../editions/03-2002.md) continues the D approach and retains JK and T treatments in §§5-3 and 5-7. Its §5-6 covers state reduction and assignment. See the [sixth Global edition](../editions/06-2017.md), §§5.5 and 5.7–5.8, pp. 277, 316 and 321, for clocked analysis, state reduction and design.
