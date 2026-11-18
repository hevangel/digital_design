# Edition history (Mano *Digital Design*)

Scope: the continuously revised *Digital Design* textbook, not Mano's separate *Digital Logic and Computer Design* or *Computer System Architecture*. Numbered editions 1–6; international printings, ISBN variants, and eText releases are **not** extra numbered editions.

| Edition | Representative year | Author(s) | ISBN/example | What changed |
|---|---:|---|---|---|
| 1 | 1984 | M. Morris Mano | 9780132123334 | Foundation: number systems, Boolean algebra, minimization, combinational and sequential circuits, hardware-oriented lab practice. |
| 2 | 1991 | M. Morris Mano | 9780132129374 | Eight chapters substantially revised; new IEEE-91 graphic-symbol chapter; new problems and experiments. Specific alleged deleted topics are not individually substantiated. |
| 3 | 2002 (some copies ©2001) | M. Morris Mano | 9780130621214 | Adds distributed Verilog HDL coverage; consolidates combinational and memory/programmable-logic material; emphasizes D flops; rebuilds RTL chapter; HDL laboratory simulation. |
| 4 | 2007 | M. Morris Mano, Michael D. Ciletti | 9780131989245 | Expanded HDL, synthesis and FPGA-oriented labs; **still has** separate asynchronous sequential logic and digital IC circuits chapters. |
| 5 | 2013 (some catalogs ©2012) | M. Morris Mano, Michael D. Ciletti | 9780132774208 | Re-centers the course on digital-system/RTL design; **no standalone** asynchronous-sequential or digital-IC-family chapters; lab experiments and graphic symbols renumbered to chapters 9–10. |
| 6 | 2017 print (later global/reprint/eText dates) | M. Morris Mano, Michael D. Ciletti | 9780134549897 | Explicit parallel Verilog, VHDL, and SystemVerilog teaching tracks; chapter 8.13 becomes an introduction to SystemVerilog in published contents. |

**Confidence key:** `verified` means the cited publisher/catalog/preface explicitly supports the claim; `inferred-toc` means comparison of independently listed chapter headings; `unverified` means evidence is insufficient. See [changes.csv](changes.csv) and [sources](SOURCES.md).

## What “removed” means

A topic's *standalone chapter* may disappear while some of the concepts remain elsewhere. For example, the 5th's TOC omits chapter-length discussions of asynchronous sequential circuits and TTL/ECL/CMOS device-level behavior, but still includes latches, logic gates, hazards in relevant contexts, and basic integrated-circuit concepts. We preserve the earlier chapters as **historical extensions** in this repo, not pretend they are required chapters in later editions.

## Using edition notes

Read [e1](01-1984.md) → [e2](02-1991.md) → [e3](03-2002.md) → [e4](04-2007.md) → [e5](05-2013.md) → [e6](06-2017.md). Notes emphasize *differences*; the [shared curriculum](../notes/README.md) holds the technical teaching. For historic work, choose the edition-specific chapters while using both HDL tracks as modern translations.

## Missing evidence

Full section-level redlines for editions 1 vs 2 and 3 vs 4 require authoritative complete TOCs/prefaces for each distinct printing. We do **not** invent precise deletion lists from marketing summaries. Additional source scans should record ISBN, page, edition, chapter, and whether the claim is textually evidenced before changing `changes.csv`.
