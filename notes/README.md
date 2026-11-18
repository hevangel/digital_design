# Study notes: one shared concept track, six edition perspectives

Study order (each note contains a specification, calculations, trade-offs, and a hardware lab):

1. [Numbers and codes](01-number-systems.md)
2. [Boolean algebra](02-boolean-algebra.md)
3. [Minimization and hazards](03-minimization.md)
4. [Combinational circuits](04-combinational.md)
5. [Synchronous sequential design](05-sequential.md)
6. [Registers and counters](06-registers.md)
7. [Memory and programmable logic](07-memory.md)
8. [RTL, datapaths, and FSM controllers](08-rtl.md)
9. [Asynchronous sequential circuits (historical)](09-asynchronous.md)
10. [Digital IC families (historical)](10-logic-families.md)
11. [Lab experiments and IEEE graphic symbols](11-labs-symbols.md)

Edition chapters 1–8 are the *modern common core*. Earlier chapters 9–10 about asynchronous/physical implementation are explicitly preserved. Actual chapter numbers for older editions differ, so don't equate a canonical note number with a historical page/chapter reference.

For every lab: (a) make a truth/transition table, (b) prove or exhaustively check a small instance, (c) simulate SV and VHDL independently, (d) compare signedness, reset, and latency, and (e) inspect synthesis netlist/timing on a real target where available. A passing RTL test is not a proof of timing closure.
