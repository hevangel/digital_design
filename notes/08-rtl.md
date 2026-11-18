# 08 — Register-transfer design: controller + datapath

**Study outcome:** distinguish a behavior spec, a schedule of micro-operations, and a cycle-accurate implementation.

RTL is a state-update model: at a clock edge, a set of registers receives functions of the *old* register values and inputs. An ASM/ASMD chart links controller states and decision conditions to datapath transfers; it is not a software control-flow graph executed instantaneously.

## Iterative unsigned multiply (4×4 → 8 bits)

At `start` while idle:
- store zero accumulator, an 8-bit zero-extended multiplicand, and the 4-bit multiplier;
- perform 4 rounds; when current multiplier LSB is 1, add the current multiplicand into accumulator;
- each round shift multiplicand left and multiplier right;
- assert `done` for one cycle after the **fourth compute edge**. Keep `product` until the next completion or a reset.

An implementation needs a controller (busy/count/done) and datapath (accumulator, add, shifters). Note the trap with nonblocking assignments: `acc <= acc + ...` cannot be followed by `product <= acc` on the same edge because `acc` there means the **old** accumulator. Calculate the final sum explicitly.

Latency contract: an idle `start` edge initializes. The next four rising edges perform rounds, and `done` rises immediately following the fourth. `start` while busy is ignored; reset cancels a pending operation. The max result is 15×15=225, fitting 8 bits.

### ASMD decisions and register enables

Idle and Compute correspond to `busy=0` and `busy=1`. Each table row describes a path through one state and its decisions. Evaluate the decisions from pre-edge values and commit the enabled writes together on that edge. Let `sum = acc + (mult[0] ? mcand : 0)`. The accumulator writes that sum on every compute edge, including a round with a zero addend.

| Present state | Sampled condition, in priority order | Datapath registers written | Next state and pulse |
| --- | --- | --- | --- |
| Either | `rst=1` | Clear `acc`, `mcand`, `mult`, `round_idx` and `product` | Idle, `done=0` |
| Idle | `rst=0, start=0` | None | Idle, `done=0` |
| Idle | `rst=0, start=1` | Set `acc` and `round_idx` to 0. Load zero-extended `a` into `mcand` and `b` into `mult` | Compute, `done=0` |
| Compute | `rst=0, round_idx<3` | Write `sum` into `acc`, shift `mcand` left and `mult` right, increment `round_idx` | Compute, `done=0` |
| Compute | `rst=0, round_idx=3` | Write `sum` into both `acc` and `product`, shift both operands, update `round_idx` | Idle, `done=1` |

For `a=7, b=11`, the trace starts after a reset edge. Values are decimal except for the sampled bits. Edges C1–C4 are the four compute rounds.

| Edge | Sampled decision | `(acc, mcand, mult)` old → new | `(busy, done, product)` old → new |
| --- | --- | --- | --- |
| Start | Idle, `start=1` | `(0,0,0) → (0,7,11)` | `(0,0,0) → (1,0,0)` |
| C1 | Index 0, LSB 1 adds 7 | `(0,7,11) → (7,14,5)` | `(1,0,0) → (1,0,0)` |
| C2 | Index 1, LSB 1 adds 14, `start=1` ignored | `(7,14,5) → (21,28,2)` | `(1,0,0) → (1,0,0)` |
| C3 | Index 2, LSB 0 adds 0 | `(21,28,2) → (21,56,1)` | `(1,0,0) → (1,0,0)` |
| C4 | Index 3, LSB 1 adds 56 | `(21,56,1) → (77,112,0)` | `(1,0,0) → (0,1,77)` |
| Next | Idle, `start=0` | `(77,112,0) → (77,112,0)` | `(0,1,77) → (0,0,77)` |

At C4 the SystemVerilog index advances to 4 and the VHDL index returns to 0. Both reinitialize it on the next accepted start. A reset sampled on C4 instead takes the first ASMD path, clears the outputs and suppresses completion. A start asserted on C4 is ignored because Compute was the sampled state. If start remains high at the following idle edge, it launches a new operation then.

### Schedule the observation phase

These are the expected readings for the trace above. The example compares a read in the edge-triggered phase before scheduled signal updates with a read after the updates and output propagation have settled.

| Edge | Expected post-edge `(busy, done, product)` | Read before scheduled updates | Read after updates settle |
| --- | --- | --- | --- |
| C4 | `(0,1,77)` | `(1,0,0)` | `(0,1,77)` |
| Next | `(0,0,77)` | `(0,1,77)` | `(0,0,77)` |

In SystemVerilog the nonblocking writes become visible after the active region. In VHDL, clocked signal assignments update in later delta cycles and the visible ports driven by those signals can need further deltas. Drive inputs before the sampling edge, and sample outputs after settling, for example on the falling edge of this rising-edge-only design. An HDL event race occurs when two processes access a shared signal in the same scheduling phase and the result depends on execution order, such as a bench making a blocking write to `start` as the clocked RTL reads it. A deterministic early read can also fail an assertion by observing the previous cycle.

An incomplete assignment in combinational RTL has a different consequence. If a process assigns `addend` only when `mult[0]=1`, it must retain its previous value when the bit is 0. Synthesis can implement that retention with a latch. Supply zero on that branch to realize the combinational function. See [the self-checking testbench](04-combinational.md#self-checking-testbench) for complete output assignment and drive/observe phases, and [asynchronous state races](09-asynchronous.md#trace-a-critical-race) for the physical feedback case.

## Integration and verification

The existing benches exercise all 256 pairs with a fixed start sequence. As an extension, write a cycle-level scoreboard that records operands on accepted start, checks the `busy` and `done` schedule, compares `product` with `a*b` on completion, and checks product retention between completions. Add a start pulse while busy and a reset during computation.

## HDL laboratory

- [Iterative multiplier](../examples/README.md#datapath--controller) in SystemVerilog and VHDL.

**Edition connection.** Mano, *Digital Design*, 1st ed. (1984 international printing, ISBN 0-13-212325-8), contents p. vii, lists ASM charts, timing and controller design in §§8-2–8-5, pp. 306–322. For earlier treatments see the 2nd ed. (1991), §§8-2–8-6, starting on pp. 309–330, and the 3rd ed. (2002), §§8-3–8-4, pp. 303 and 307. Mano and Ciletti, 5th ed. (©2013), §§8.4–8.5, pp. 363 and 371, covers ASM decisions and their datapath transfers. In the 6th ed., Global printing (©2019, ISBN 9781292231167), see §§8.4–8.5, pp. 466 and 475, for ASM/ASMD, §§4.14–4.15, pp. 239 and 245, for testbenches and simulation, and §§8.11–8.12, pp. 545 and 548, for HDL races and latch inference.
