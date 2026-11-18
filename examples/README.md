# Paired SystemVerilog/VHDL lab index

Each row is a **new, independently authored example** supporting topics appearing in one or more editions. Identically named SV `module` and VHDL `entity` share a port-level contract. These are **concept examples**, not published textbook listings or exercise solutions.

| Topic | File base (SV: `examples/systemverilog/*.sv`; VHDL: `examples/vhdl/*.vhd`) | Design contract |
|---|---|---|
| <a id="number-systems"></a>Number systems | `bcd_excess3` | Valid BCD 0–9 maps to digit+3; invalid => 0 and valid=0 |
| <a id="boolean-logic"></a>Boolean logic | `majority3` | 3-input majority |
| <a id="minimization"></a>Minimization | `kmap_consensus` | Equivalent minimized and consensus-term SOP functions |
| <a id="combinational"></a>Combinational | `add_sub4`, `mux4`, `sevenseg_bcd` | Unsigned carry/borrow and signed overflow; 4-to-1 mux; common-anode seven-segment |
| <a id="sequential"></a>Sequential | `seq1011` | Registered pulse after detecting overlapping 1011 |
| <a id="registers--counters"></a>Registers & counters | `load_counter`, `shift8` | Reset>load>enable; shift left with serial LSB insertion |
| <a id="memory--error-detection"></a>Memory & error detection | `sync_ram16x8`, `even_parity` | Single-port clocked read/hold on write, uninitialized cells; even parity checker |
| <a id="datapath--controller"></a>Datapath / controller | `iter_mult4` | Four iteration 4×4 unsigned multiply; `done` pulse after 4 compute edges |
| <a id="historical-models"></a>Historical models | `sr_nand_latch`, `open_drain` | Feedback/latch and resolved open-drain I/O models; **NOT normal synthesis targets** |

**Design intent:** The first 12 pairs are ordinary synthesizable RTL (sevenseg included). `sr_nand_latch` is a deliberately combinational-feedback schematic, and `open_drain` is an external I/O-resolution model. Neither is recommended as portable internal FPGA fabric logic, and they should not be put through automated synthesis acceptance without vendor-specific justification.

## Running examples

From the repository root:

```bash
bash tests/run.sh
```

Requires `iverilog`, `vvp`, and `ghdl` (VHDL-2008). See [test matrix](../tests/README.md). The bash script runs all self-checking examples and reports a nonzero exit on failure. This commit **provides tests but does not assert they were executed** in the authoring environment; check CI results or run them locally.

## Edition mapping

- Ed. 1–2: use the same modern HDL examples for gates, counters, code conversion, memory, and physical-lab concepts; original editions are **not** claimed to contain these languages.
- Ed. 3: put special attention on `add_sub4`, `seq1011`, `sync_ram16x8`, `iter_mult4` alongside original Verilog/RTL progression.
- Ed. 4: extend to `sr_nand_latch` and `open_drain` **conceptually** for chapters about asynchronous state and circuit families.
- Ed. 5: keep the historical supplements even though its TOC omits their standalone chapters.
- Ed. 6: read every SV/VHDL pair in parallel, comparing typing, process semantics and generated hardware.

**Important:** VHDL `std_logic` uses a richer resolution system than SV's four-state nets; Z/H/pull-up semantics need explicit verification in real I/O contexts.
