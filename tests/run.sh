#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"
for exe in iverilog vvp ghdl; do
    if ! command -v "$exe" >/dev/null 2>&1; then
        echo "ERROR: missing $exe (see tests/README.md)" >&2
        exit 127
    fi
done
BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD"' EXIT
for top in tb_combinational tb_sequential; do
    echo "[SV] $top"
    iverilog -g2012 -s "$top" -o "$BUILD/$top.vvp" \
        "$ROOT"/examples/systemverilog/*.sv "$ROOT/tests/systemverilog/$top.sv"
    vvp "$BUILD/$top.vvp"
done
(
    cd "$BUILD"
    ghdl -a --std=08 "$ROOT"/examples/vhdl/*.vhd \
        "$ROOT"/tests/vhdl/tb_combinational.vhd \
        "$ROOT"/tests/vhdl/tb_sequential.vhd
    for top in tb_combinational tb_sequential; do
        echo "[VHDL] $top"
        ghdl -e --std=08 "$top"
        ghdl -r --std=08 "$top" --assert-level=error --stop-time=500us
    done
)
echo "All HDL regressions passed."
