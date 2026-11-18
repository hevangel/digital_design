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

## Verification

Check simultaneous load+enable, enable=0 hold, reset during activity, all-ones wrap, and shift direction. A self-checking reference model is preferable to visual waveform inspection.

## HDL laboratory

- [Loadable modulo counter](../examples/README.md#registers--counters) has configurable width and explicit priority.
- [8-bit shift register](../examples/README.md#registers--counters) shifts left, includes serial input, and resets to zero.

**Edition connection:** shared foundational topics, chapters 5–6 in modern printings; physical ripple counters are pedagogically useful but clock-domain-safe synchronous RTL is the default design style.
