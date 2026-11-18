# 08 — Register-transfer design: controller + datapath

**Study outcome:** distinguish a behavior spec, a schedule of micro-operations, and a cycle-accurate implementation.

RTL is a state-update model: at a clock edge, a set of registers receives functions of the *old* register values and inputs. An ASM/ASMD chart links controller states and decision conditions to datapath transfers; it is not a software control-flow graph executed instantaneously.

## Iterative unsigned multiply (4×4 → 8 bits)

At `start` while idle:
- store zero accumulator, an 8-bit zero-extended multiplicand, and the 4-bit multiplier;
- perform 4 rounds; when current multiplier LSB is 1, add the current multiplicand into accumulator;
- each round shift multiplicand left and multiplier right;
- assert `done` for one cycle after the **fourth compute edge**; keep `product` until next completed operation.

An implementation needs a controller (busy/count/done) and datapath (accumulator, add, shifters). Note the trap with nonblocking assignments: `acc <= acc + ...` cannot be followed by `product <= acc` on the same edge because `acc` there means the **old** accumulator. Calculate the final sum explicitly.

Latency contract: an idle `start` edge initializes. The next four rising edges perform rounds, and `done` rises immediately following the fourth. `start` while busy is ignored; reset cancels a pending operation. The max result is 15×15=225, fitting 8 bits.

## Integration and verification

Write a cycle-level scoreboard with reset, start, busy, done, product. Compare against combinational golden `a*b` only upon `done`. Test 0, 1, all-ones, and random. Run lint for undriven signals, combinational loops, and width casts.

## HDL laboratory

- [Iterative multiplier](../examples/README.md#datapath--controller) in SystemVerilog and VHDL.

**Edition connection:** third edition largely replaced chapter 8 with RTL teaching; fourth through sixth keep RTL/ASM and HDL datapath examples. No claim is made that this multiplier reproduces any textbook figure or solution.
