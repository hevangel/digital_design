# 07 — Memory, programmable logic, and parity

**Study outcome:** define the address/data/clock protocol, not merely the array's capacity.

A memory with A address bits and W data bits has 2^A words and 2^A*W storage bits, plus decoder, read, write, and possibly ECC infrastructure. A synchronous RAM read makes data available after the sampling edge; an asynchronous read responds combinationally to address. FPGA block-RAM inference depends strongly on port semantics and target toolchain.

## Our single-port RAM contract

- At rising edge with `we=1`: memory[addr] gets din, and `dout` **holds**.
- At rising edge with `we=0`: `dout` gets memory[addr] after the edge.
- Memory cells and `dout` have **no defined power-up/reset values**.
- There is only one operation per cycle, so simultaneous read/write conflict is avoided. This is not a read-during-write-mode guarantee for different-port RAMs.

Different ASIC SRAM and FPGA memories support read-first, write-first or no-change collision policies; verify those before replacing behavioral arrays with macros.

A ROM implements an address→data function; PLA/PAL represent structured SOP implementation. These matter historically because physical constraints on product terms and pins may dominate an elegant Boolean expression.

## Error detection

Even parity p=⊕ data, with a receive-side check `error = ⊕data ^ parity_in`. Every single-bit error flips parity, but a two-bit error goes undetected. Hamming SEC and SECDED add structured check bits and require explicit syndrome logic; parity is not ECC correction.

## HDL laboratory

- [Synchronous RAM](../examples/README.md#memory--error-detection) and [parity generator/checker](../examples/README.md#memory--error-detection).
- Test write/hold/read latency, storage isolation, and fault injection. Don't test uninitialized RAM values as known.

**Edition connection:** third edition combined memory and programmable logic into one chapter; fifth/sixth present this as chapter 7.
