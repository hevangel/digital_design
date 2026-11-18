# 06 — Registers, shift registers, and counters

**Study outcome:** distinguish data storage, controlled movement, and modular counting.

An N-bit register holds 2^N states. A shift register advances bits according to a defined direction and serial-input position. A counter implements a specific next-state function such as `q_next=(q+1) mod 2^N`. A ripple counter chains clock edges across flop outputs and is **not** interchangeable with a synchronous counter for CDC/timing analysis.

## Priority matters

For a synchronous enable/load counter:
1. Reset to zero.
2. Else load the parallel input if `load=1`.
3. Else increment if `enable=1`.
4. Else hold.

Write the priority in the specification *before* writing RTL. For an all-ones 4-bit value, increment produces 0000 by modular arithmetic. Replacing this with saturating behavior is a specification change.

For shift registers define whether `shift_en` causes a left shift `q <= {q[N-2:0], serial_in}`, and whether the shifted-out bit is observable. For width=1, slicing `[N-2:0]` is invalid; use concatenation/shift expressions that deliberately support width 1 or constrain parameters.

## Parallel load and bidirectional shift

This 4-bit example uses a rising-edge clock and a synchronous active-high reset. Bit 3 is the most significant bit. With reset low, the mode bits select the next value. The table uses the same starting value `q=1010` for each row.

| Mode | Operation | Next `q[3:0]` | Example |
| --- | --- | --- | --- |
| `00` | Hold | `q[3:0]` | `1010` |
| `01` | Shift right, toward bit 0 | `{serial_msb, q[3:1]}` | `1101` with `serial_msb=1` |
| `10` | Shift left, toward bit 3 | `{q[2:0], serial_lsb}` | `0101` with `serial_lsb=1` |
| `11` | Parallel load | `parallel_in[3:0]` | `0011` with `parallel_in=0011` |

An edge with reset high writes `0000` for any mode. When the register shifts, the outgoing bit is the old bit 0 for a right shift and the old bit 3 for a left shift. A serial consumer can sample that bit on the same edge.

## Ring count and ripple timing

A separate 3-bit ring counter uses synchronous reset to seed `001`. Each later rising edge rotates left, with `q_next = {q[1:0], q[2]}`. It visits `001 → 010 → 100 → 001`. Rotation preserves the number of 1s, so `000` stays at zero and an illegal state such as `011` cycles through `110 → 101 → 011`. These are lockout cases. This design recovers when reset is sampled. A self-starting design needs an explicit route from illegal states to the seed.

For a different design, take a 3-bit binary ripple up-counter in which the first stage toggles on the external count edge and each higher stage toggles on its predecessor's falling output edge. With positive propagation delay at every stage, a count from 7 to 0 proceeds `111 → 110 → 100 → 000`. A decoder connected to the outputs could briefly see 6 and 4 before 0. The times depend on the stages and load. Treat the count as settled only after allowing propagation through the chain.

## Verification

Check simultaneous load+enable, enable=0 hold, reset during activity, all-ones wrap, and shift direction. A self-checking reference model is preferable to visual waveform inspection.

## HDL laboratory

- [Loadable modulo counter](../examples/README.md#registers--counters) has configurable width and explicit priority.
- [8-bit shift register](../examples/README.md#registers--counters) shifts left, includes serial input, and resets to zero.

**Edition connection.** Mano, *Digital Design*, 2nd ed. (1991), §§7-3–7-6, pp. 264–285, covers shift registers, ripple and synchronous counters, and timing sequences. For the modern reading route, see Mano and Ciletti, 6th ed., Global printing (©2019, ISBN 9781292231167), §§6.2–6.5, pp. 346–367. For a serial arithmetic extension, use a shift register per operand and retain a carry bit between edges. See the 6th Global edition, §9.13, p. 600.
