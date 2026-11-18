# 09 — Asynchronous sequential logic (historical extension)

**Study outcome.** Use a flow table to identify stable conditions and evaluate whether a state assignment can produce a critical race.

## Circuits with memory but no global clock

A cross-coupled NAND SR latch has active-low `S_n` and `R_n`. With neither asserted it holds its state. Asserting `S_n` sets `Q=1`, and asserting `R_n` clears `Q=0`. Asserting both is forbidden because it drives both outputs high and simultaneous release can make the outcome depend on internal delays.

| S_n | R_n | Meaning |
|---|---|---|
| 1 | 1 | hold |
| 0 | 1 | set |
| 1 | 0 | reset |
| 0 | 0 | forbidden |

## Build and reduce a primitive flow table

Consider a two-input agreement element. Inputs `ab=00` clear stored bit `q`, `11` sets it, and `01` or `10` holds it. Start with `00` settled. Assume fundamental-mode operation, with one input bit changing at a time and both inputs held until the feedback has settled before either changes again.

The primitive table gives each stable combination of `ab` and `q` a row. A bold entry is the row's stable cell. A dash marks an input change of two bits from that stable cell. Each other entry names the state reached with the new input held. For example, from A at `00`, changing only `b` leaves `q=0`, so the target is B at `01`.

| State | Stable `q` | `00` | `01` | `11` | `10` |
| --- | --- | --- | --- | --- | --- |
| A | 0 | **A** | B | — | C |
| B | 0 | A | **B** | D | — |
| C | 0 | A | — | D | **C** |
| D | 1 | — | E | **D** | F |
| E | 1 | A | **E** | D | — |
| F | 1 | A | — | D | **F** |

A and B have the same output and agree in every shared column. C also agrees where specified, so the three can merge as P. Likewise D, E and F can merge as Q. The union of each group's specified destinations keeps every transition within the two groups. In the reduced table, `00` always selects P and `11` always selects Q. Both disagreement columns keep the current row.

| State | `q` | `00` | `01` | `11` | `10` |
| --- | --- | --- | --- | --- | --- |
| P | 0 | **P** | **P** | Q | **P** |
| Q | 1 | P | **Q** | **Q** | **Q** |

## Trace a critical race

To see the risk before merging, assign A=`000`, B=`011`, C=`100`, D=`101`, E=`001` and F=`110`. Complete the unused code `010` with a next value of `011` when `ab=01`. For the permitted input change from `00` to `01`, A calls for B and two state bits must rise. Assume the next-state logic responds to the first changed bit early enough to cancel the second transition if it is no longer requested. Inputs stay at `01`.

| First state bit to change | Path at fixed input `01` | Endpoint |
| --- | --- | --- |
| Middle bit | `000 → 010 → 011` | B holds `q=0`, the intended result |
| Least significant bit | `000 → 001` | E holds `q=1`. E's self-loop removes the request to raise the middle bit |

The different stable endpoints make this race critical. A noncritical race passes through different intermediate codes and settles to the same endpoint in every order. In the reduced table, assign P=`0` and Q=`1`. Each non-hold transition changes just one state bit, and disagreement never changes the state. The resulting update is `q_next = (a AND b) OR ((a OR b) AND q)`. This assignment resolves the illustrated state-variable race under the stated model.

### Hazards are timing phenomena

A static hazard is a momentary output change when the output should stay constant. A dynamic hazard causes multiple output changes when only one is intended. Both can arise from unequal delays in reconverging logic paths. An essential hazard involves relative delays along input and feedback paths in an asynchronous sequential circuit. The reduced assignment resolves the race shown above. Evaluating hazards requires the actual logic realization and its path-delay assumptions. See [the consensus example](03-minimization.md) for a static hazard and [HDL scheduling](08-rtl.md#schedule-the-observation-phase) for simulation event ordering.

## Verification limits

Zero-delay RTL feedback can lock at X/U, oscillate, or suppress glitches; timing, inertial effects, transistor properties and metastability affect real behavior. For chip design, physical-library timing and appropriate formal assumptions matter. Never implement a cross-coupled combinational loop in FPGA logic without target-specific support.

## HDL laboratory

- The [cross-coupled SR latch](../examples/README.md#historical-models) demonstrates set, reset, hold and the forbidden-input condition in a historical model. It is excluded from the automated example benches.
- Compare with a synchronous D flip-flop and explain why the clock changes the state update contract.
- Modern follow-up: analyze two-flop CDC synchronizer, handshake protocols, and asynchronous reset deassertion (not proof of metastability elimination).

**Edition connection.** Mano, *Digital Design*, 1st ed. (1984 international printing, ISBN 0-13-212325-8), contents p. vii, lists §§9-1–9-3, pp. 339, 341 and 349, as the route through latch circuits. The 2nd ed. (1991), §§9-5–9-7, pp. 366, 374 and 379, treats reduction, state assignment and hazards. The 3rd ed. (2002) retains Ch. 9, with analysis, race-free assignment and hazards in §§9-2, 9-6 and 9-7. In Mano and Ciletti, 4th ed. (2007), see §§9.2 and 9.4–9.8, pp. 417 and 433–457, for analysis, primitive tables, reduction, race-free assignment and hazards. The 5th ed. omits the standalone chapter. See the [edition matrix](../editions/README.md).
