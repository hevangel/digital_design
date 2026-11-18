# 07 — Memory, programmable logic, and parity

**Study outcome:** define the address/data/clock protocol, not merely the array's capacity.

A memory with A address bits and W data bits has 2^A words and 2^A*W storage bits, plus decoder, read, write, and possibly ECC infrastructure. A synchronous RAM read makes data available after the sampling edge; an asynchronous read responds combinationally to address. FPGA block-RAM inference depends strongly on port semantics and target toolchain.

## Our single-port RAM contract

- At rising edge with `we=1`: memory[addr] gets din, and `dout` **holds**.
- At rising edge with `we=0`: `dout` gets memory[addr] after the edge.
- Memory cells and `dout` have **no defined power-up/reset values**.
- There is only one operation per cycle, so simultaneous read/write conflict is avoided. This is not a read-during-write-mode guarantee for different-port RAMs.

Different ASIC SRAM and FPGA memories support read-first, write-first or no-change collision policies; verify those before replacing behavioral arrays with macros.

## Decode a banked address

Suppose four chips each store eight 4-bit words. Use a 5-bit word address `A[4:0]` with `A[4:3]` selecting a bank and `A[2:0]` going to all four chips. An enabled 2-to-4 decoder asserts one active-high chip select. When the bank group is disabled it asserts none.

| `A[4:3]` | Asserted select when enabled | Word addresses (hex) |
| --- | --- | --- |
| `00` | `CS0` | `0x00–0x07` |
| `01` | `CS1` | `0x08–0x0F` |
| `10` | `CS2` | `0x10–0x17` |
| `11` | `CS3` | `0x18–0x1F` |

At address `0x07` the selected chip is bank 0 at local address 7. At `0x08` it is bank 1 at local address 0. The group holds `4 × 8 × 4 = 128` bits in 32 words. A read data multiplexer can select the same bank as the decoder. This address map specifies selection and capacity. The single-port example above specifies a separate clock and output-hold contract.

## Error detection

Even parity p=⊕ data, with a receive-side check `error = ⊕data ^ parity_in`. Every single-bit error flips parity, and any two-bit error leaves parity unchanged.

### Correct a single bit with extended Hamming(8,4)

Number transmitted bits 1 through 8 from left to right. Put the data bits at 3, 5, 6 and 7. Positions 1, 2 and 4 make these groups even, each including its own check bit.

| Check bit | Positions XORed at the receiver |
| --- | --- |
| 1 | 1, 3, 5, 7 |
| 2 | 2, 3, 6, 7 |
| 4 | 4, 5, 6, 7 |
| 8 (overall) | 1 through 8 |

For data `1011`, checks 1, 2 and 4 are `0, 1, 0`. The first seven bits contain four 1s, so bit 8 is 0 and the codeword is `01100110`. The received syndrome `s = s1 + 2×s2 + 4×s4` uses the first three XOR results. Let `p` be the XOR of all eight received bits.

| Flipped positions | Received bits | `s` | `p` | Outcome |
| --- | --- | ---: | ---: | --- |
| None | `01100110` | 0 | 0 | Accept |
| 6 (data) | `01100010` | 6 | 1 | Flip position 6 |
| 2 (check) | `00100110` | 2 | 1 | Flip position 2 |
| 8 (overall check) | `01100111` | 0 | 1 | Flip position 8 |
| 3 and 6 | `01000010` | 5 | 0 | Flag double error and withhold correction |

A flip in positions 1–7 toggles the syndrome group bits indicated by its binary position. Two distinct flips there give the XOR of two distinct positions, which is nonzero. A double error involving position 8 has the other flipped bit's nonzero syndrome. Either double error leaves overall parity even. Under the at-most-two-flip assumption, the four outcomes are accept, correct a data or group check bit, correct the overall check bit, and flag a double error. Single-error correction and double-error detection (SECDED) guarantees apply under that assumption.

## Implement one truth table three ways

Let `p = a AND b` and `q = (NOT a) AND c`. The desired outputs are `F = p OR q` and `G = p`.

| `abc` | `FG` |
| --- | --- |
| `000` | `00` |
| `001` | `10` |
| `010` | `00` |
| `011` | `10` |
| `100` | `00` |
| `101` | `00` |
| `110` | `11` |
| `111` | `11` |

| Device model | AND plane | OR plane or output connections | Implementation |
| --- | --- | --- | --- |
| ROM | Fixed address decoder generates all eight minterms | Contents determine which minterms contribute to each output | Store the two-bit word `FG` at address `abc` |
| PLA | Programmable product terms | Programmable OR connections | Build `p` and `q` once. Connect `p` to both outputs and `q` to `F` |
| PAL | Programmable product terms | Fixed OR groups per output | Allocate `p` and `q` in `F`'s group. Allocate a second copy of `p` in `G`'s group in this model without feedback |

Adding output registers and routing their outputs back into programmable logic lets a device implement an FSM. A CPLD can connect multiple logic blocks of registered or combinational macrocells through programmable interconnect. An FPGA LUT implements a small truth table locally and can feed a nearby flip-flop. Device organization determines where product terms, lookup inputs, feedback and routes are available.

## HDL laboratory

- [Synchronous RAM](../examples/README.md#memory--error-detection) and [parity generator/checker](../examples/README.md#memory--error-detection).
- Proposed checks include write/hold/read latency, isolation between two initialized addresses, and parity fault injection. Treat uninitialized RAM values as unspecified.

**Edition connection.** Mano, *Digital Design*, 1st ed. (1984 international printing, ISBN 0-13-212325-8), contents pp. vi–vii, lists ROM and PLA in §§5-7–5-8, pp. 182 and 189, and the memory unit and RAM examples in §§7-7–7-8, pp. 289 and 294. The 2nd ed. (1991), §§5-7–5-9 and §§7-8–7-9, starting on pp. 180 and 293, continues the split and includes error-correcting codes. The 3rd ed. (2002), Ch. 7, combines the topics, with sequential programmable devices in §7-8. For Hamming codes, see Mano and Ciletti, 5th ed. (©2013), §7.4, pp. 312–315. In the 6th ed., Global printing (©2019, ISBN 9781292231167), see §7.3, p. 402, for decoding, §7.4, pp. 407–410, for error detection and correction, and §§7.5–7.8, starting on pp. 410, 416, 420 and 424, for ROM, PLA, PAL and sequential programmable devices.
