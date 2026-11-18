# Portable HDL tests

The script `bash tests/run.sh` checks which tools are installed, creates a temporary build directory and runs:

- **SystemVerilog**: `tb_combinational.sv`, `tb_sequential.sv` using Icarus Verilog `-g2012`.
- **VHDL-2008**: `tb_combinational.vhd`, `tb_sequential.vhd` using GHDL `--std=08`.
- Both languages cover exhaustive four-bit adder/subtractor operands and all 256 four-bit multiply operands, plus focused register, memory and FSM checks.
- Historical feedback/open-drain examples are *not* automatically simulated in the main RTL regression: their electrical/feedback semantics require technology-specific test conditions.

**Expected limits:** logic simulation proves only simulated properties. It does not certify synthesis QoR, glitches, metastability, SRAM macro compatibility, gate timing, or analog IO behavior. The repository's model-vs-model tests are not formal proof.

## Install (Ubuntu)

```bash
sudo apt-get update
sudo apt-get install -y iverilog ghdl
bash tests/run.sh
```

No proprietary tools are required. For larger verification, extend with SymbiYosys assertions, Yosys synthesis smoke tests, or a dual-language equivalence miter; GHDL+Icarus tests are separate independent reference-vector checks and not a cross-language co-simulation.

## CI

A GitHub Actions workflow at `.github/workflows/hdl.yml` runs the same `tests/run.sh` script on pushes and pull requests. Look at the latest Actions status rather than assuming code correctness from the presence of test files.
