# Digital Design — Mano, across six editions

**Original study companion** to M. Morris Mano's *Digital Design* (editions 1–3) and Mano/Ciletti (editions 4–6). This is an independent learning project, **not** a reproduction of the textbooks, their exercise solutions, diagrams, or publisher HDL.

## Start here

1. [Edition-by-edition additions, omissions, and reorganization](editions/README.md), with [machine-readable history](editions/changes.csv) and [source links](editions/SOURCES.md).
2. [Concept notes](notes/README.md): common curriculum plus historically important topics no longer presented as standalone chapters.
3. [HDL example index](examples/README.md): **paired SystemVerilog and VHDL** implementing the same specifications.
4. [Running tests](tests/README.md): coverage and setup for self-checking simulations with Icarus Verilog and GHDL.
5. [Edition coverage review](review/edition-coverage.md): source audit and implementation record.

## Browser reader

Serve this repository with Node.js and open `http://127.0.0.1:4181/`.
The hosted reader is available at <https://hevangel.github.io/digital_design/>.

```sh
node scripts/serve.mjs
```

The reader's [entry point](index.html) renders the Markdown library and highlights SystemVerilog and VHDL examples and testbenches. Use the filter to find a document or design, and switch languages from the code view. URLs retain the selected file and section. The app uses ordinary static HTTP hosting and reads files from this checkout.

The [library catalog](assets/library.json) lists the files presented in the reader. When adding a document or HDL pair, update that list. The app uses local copies of Marked 18.1.0 ([license](assets/vendor/marked.LICENSE)) and Prism 1.30.0 with its Verilog/SystemVerilog and VHDL grammars ([license](assets/vendor/prism.LICENSE)).

To read the original textbook, place your local PDFs in `textbooks/` under this directory, or point that folder at your local `learning/textbooks/DigitalDesign/` checkout. Use the filenames listed in the [textbook catalog](data/textbooks.json). When the reader finds a PDF, **Show original** opens the mapped page beside the notes. The two panes scroll independently and stack on narrow screens. Use **Hide Browse** to make more room for reading and **Show Browse** to reopen the library. Use the edition picker to see the same section in another available edition. **Hide original** expands the notes and keeps your reading position.

The catalog lists one-based PDF page numbers in edition order. Its source files are identified in the [evidence ledger](editions/SOURCES.md). The third-edition scan uses two printed pages per PDF page. A null entry indicates that there is no mapped reading in that edition. Keep the PDFs in the local checkout. The reader uses PDF.js 5.4.624 ([license](assets/vendor/pdfjs/LICENSE)) to render pages on demand and retain opened editions until the reader is reloaded.

## Curriculum

| Topic | Original notes | Representative implementation |
|---|---|---|
| Binary arithmetic, codes | [01](notes/01-number-systems.md) | BCD-to-Excess-3 |
| Boolean algebra and gates | [02](notes/02-boolean-algebra.md) | Majority voter |
| Minimization and hazards | [03](notes/03-minimization.md) | Minimized function |
| Combinational modules | [04](notes/04-combinational.md) | Adder/subtractor, mux |
| Synchronous state machines | [05](notes/05-sequential.md) | Overlapping sequence detector |
| Registers/counters | [06](notes/06-registers.md) | Enable/load counter, shift register |
| Memory/programmable logic | [07](notes/07-memory.md) | Synchronous RAM, parity |
| RTL/datapath-controller | [08](notes/08-rtl.md) | Iterative multiplier |
| Historical asynchronous design | [09](notes/09-asynchronous.md) | SR latch (illustrative) |
| Historical IC logic families | [10](notes/10-logic-families.md) | Open-drain modelling guidance |
| Laboratories and symbols | [11](notes/11-labs-symbols.md) | Self-checking labs and diagrams |

The companion covers common concepts and selected historical topics across all six editions. Its SystemVerilog and VHDL-2008 examples use modern HDL idioms to teach designs from earlier editions.

## Design rules

- Every example specifies widths, reset, latency, and intended synthesizability.
- Each HDL pair implements the same externally observable behavior.
- IEEE `std_logic_1164` and `numeric_std` for VHDL; synthesizable SV subset with `always_comb` / `always_ff`.
- X/Z semantics, latches, physical timing, and vendor primitives are **not** interchangeable with Boolean equations.
- Tests are original and separate from the source RTL; no proprietary exercise answers or reproduced textbook pages.
- Treat edition changes as documented deltas **only where sources support them**, distinguishing a missing standalone chapter from a completely deleted subject.

## License and attribution

This repository keeps its existing [LICENSE](LICENSE). The authors' book titles and editions are used for identification. Notes, designs, and tests are independently authored. No claim of Pearson endorsement.
