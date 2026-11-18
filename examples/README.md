# Paired SystemVerilog/VHDL lab index

These independently authored examples support concepts presented across the editions. The SystemVerilog module and VHDL entity with the same file base share a port-level contract.

| Topic | File base (SV: `examples/systemverilog/*.sv`; VHDL: `examples/vhdl/*.vhd`) | Design contract |
|---|---|---|
| <a id="number-systems"></a>Number systems | [`bcd_excess3`](systemverilog/bcd_excess3.sv) | Valid BCD 0–9 maps to digit + 3. Invalid input clears the result and valid flag. |
| <a id="boolean-logic"></a>Boolean logic | [`majority3`](systemverilog/majority3.sv) | Three-input majority |
| <a id="minimization"></a>Minimization | [`kmap_consensus`](systemverilog/kmap_consensus.sv) | Equivalent minimized and consensus-term SOP functions |
| <a id="combinational"></a>Combinational | [`add_sub4`](systemverilog/add_sub4.sv), [`mux4`](systemverilog/mux4.sv), [`sevenseg_bcd`](systemverilog/sevenseg_bcd.sv) | Unsigned carry/borrow and signed overflow, 4-to-1 mux, common-anode seven-segment display |
| <a id="sequential"></a>Sequential | [`seq1011`](systemverilog/seq1011.sv) | Registered pulse after detecting overlapping 1011 |
| <a id="registers--counters"></a>Registers & counters | [`load_counter`](systemverilog/load_counter.sv), [`shift8`](systemverilog/shift8.sv) | Reset, load, then enable priority for the counter. Shift left with serial LSB insertion for the shift register. |
| <a id="memory--error-detection"></a>Memory & error detection | [`sync_ram16x8`](systemverilog/sync_ram16x8.sv), [`even_parity`](systemverilog/even_parity.sv) | Single-port RAM with clocked read, output hold on writes and uninitialized cells. Even parity generation and checking. |
| <a id="datapath--controller"></a>Datapath / controller | [`iter_mult4`](systemverilog/iter_mult4.sv) | 4×4 unsigned multiply with a `done` pulse after four compute edges |
| <a id="historical-models"></a>Historical models | [`sr_nand_latch`](systemverilog/sr_nand_latch.sv), [`open_drain`](systemverilog/open_drain.sv) | Combinational feedback latch and resolved open-drain I/O |

The first 12 pairs model synthesizable RTL. The feedback latch and external I/O-resolution model illustrate historical circuit behavior. Implementing either in FPGA fabric requires device-specific validation.

## Running examples

From the repository root:

```bash
bash tests/run.sh
```

The script uses `iverilog`, `vvp` and `ghdl` (VHDL-2008) to run the self-checking benches and exits nonzero on failure. [Test matrix](../tests/README.md)

## Edition mapping

- Editions 1–2. Use modern HDL to model gates, counters, code conversion and memory from the [early crosswalk](../editions/README.md#early-chapter-crosswalk).
- Edition 3. Follow the book's [Verilog route](../editions/03-2002.md#verilog-reading-route) alongside the companion adder/subtractor, sequence detector, RAM and multiplier.
- Editions 4–5. Pair the latch and open-drain illustrations with the historical [asynchronous design](../notes/09-asynchronous.md) and [logic-family](../notes/10-logic-families.md) notes.
- Edition 6. Choose Verilog or VHDL in the book, then compare the two companion implementations against a shared contract. [Edition 6 reading route](../editions/06-2017.md#language-neutral-reading-route)

## HDL reading route

| Design task | Verilog book reading | VHDL book reading | Modern companion pair |
| --- | --- | --- | --- |
| Write a truth table and check each binary input pattern | Global §§3.9–3.10, pp. 137 and 154, Verilog HDL and truth tables | Same sections, VHDL HDL and truth tables | Majority ([SV](systemverilog/majority3.sv), [VHDL](vhdl/majority3.vhd)) |
| Build a combinational model and bench with a settling interval | Global §§4.12–4.15, pp. 205–245, Verilog models and tests | Same sections, VHDL models and tests | Multiplexer ([SV](systemverilog/mux4.sv), [VHDL](vhdl/mux4.vhd)) |
| Specify clocked state, reset and update priority | Global §5.6, p. 291, and §6.6, p. 372, Verilog sequential and register models | Same sections, VHDL sequential and register models | Loadable counter ([SV](systemverilog/load_counter.sv), [VHDL](vhdl/load_counter.vhd)) |

The Global preface, pp. 9–10, presents the two book routes. Section 8.13, p. 549, is the optional SystemVerilog extension of the Verilog route. The companion uses SystemVerilog idioms such as `logic` and `always_ff`, and VHDL-2008 idioms such as `process(all)` where applicable. [Global printing](../editions/SOURCES.md#e6-global-print) · [Global section locators](../editions/SOURCES.md#e6-global-body)

### Shared binary contract

For the default four-bit loadable counter, drive a clean binary clock and use 0/1 on the data and control inputs. Start by asserting synchronous reset for a rising edge. Drive inputs before each rising edge and compare the settled output afterward. Multiple active controls establish priority.

| Rising edge | Reset | Load | Enable | Load data | Settled count |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | 1 | 1 | 0101 | 0000 |
| 2 | 0 | 1 | 1 | 1111 | 1111 |
| 3 | 0 | 0 | 1 | 0000 | 0000 |
| 4 | 0 | 0 | 0 | 1111 | 0000 |

The first row illustrates reset priority over both other controls. The existing benches check synchronous reset, load-over-enable priority, wrap and hold. The SystemVerilog bench samples after a delay and uses `!==` with `$fatal(1, ...)`. The VHDL bench waits 1 ns so the internal register and output signal can update before it executes `assert ... severity failure`. The runner configures GHDL to exit on assertion failures. Try the simultaneous-controls reset row as an additional check. [SystemVerilog bench](../tests/systemverilog/tb_sequential.sv) · [VHDL bench](../tests/vhdl/tb_sequential.vhd) · [Runner](../tests/run.sh)

This trace assumes binary controls and samples after scheduled updates. SystemVerilog `logic` values include X and Z, and nets can resolve multiple drivers. VHDL `std_logic` also resolves multiple drivers and includes U and weak values such as H. For an I/O model, spell out which values and strengths correspond, including how an undriven or pulled-up input is observed. For clocked tests, check after the SystemVerilog nonblocking update and the VHDL signal-update delta cycles. [Language comparison](../editions/06-2017.md#comparing-the-two-companion-languages)
