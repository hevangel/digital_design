# 10 — Digital integrated circuits and physical logic families (historical extension)

**Study outcome.** Check the DC compatibility of two devices and distinguish a Boolean function from the electrical behavior that implements it.

## Logical truth vs electrical operation

A Boolean NAND truth table does not determine VOH/VOL, VIH/VIL, source/sink current, rise/fall time, dynamic power, static power, fan-out, or propagation delay. Those parameters depend on process, voltage, temperature, load, and cell construction.

- **TTL** (bipolar) and **ECL** are historic implementations with different switching/power characteristics; an ECL design can trade increased static power for rapid switching.
- **CMOS** uses complementary n-channel and p-channel devices. The charging of capacitive loads, brief current during switching, and leakage all contribute to power.

## Check noise margin and fan-out

Assume a hypothetical 3.3 V driver and identical receivers, with common ground, negligible wiring drop and no additional DC load. All voltages are relative to ground. The driver voltage guarantees apply at the listed current limits. Currents below are positive magnitudes, with direction given separately.

| Specification | High level | Low level |
| --- | --- | --- |
| Guaranteed driver output | `VOH(min)=2.90 V` | `VOL(max)=0.25 V` |
| Guaranteed receiver threshold | `VIH(min)=2.10 V` | `VIL(max)=0.90 V` |
| Driver current limit at that output guarantee | Sources `2.40 mA` out of its pin | Sinks `6.00 mA` into its pin |
| Worst-case current per receiver input | Takes `0.15 mA` from the line | Delivers `0.80 mA` to the line |

The high noise margin is `VOH(min) − VIH(min) = 0.80 V` against a downward voltage disturbance. The low noise margin is `VIL(max) − VOL(max) = 0.65 V` against an upward disturbance. Both are positive at the specified loads.

The high-state current allows `floor(2.40 / 0.15) = 16` inputs. The low-state current allows `floor(6.00 / 0.80) = 7`, making 7 the DC fan-out. Seven inputs draw `1.05 mA` at high and require `5.60 mA` of sinking at low. Eight require `6.40 mA` at low, outside the low-voltage guarantee. Maximum rise time, capacitive load or propagation delay could require fewer inputs.

## Compare output drivers and switches

| Driver | Logic 0 | Logic 1 | Shared-line behavior |
| --- | --- | --- | --- |
| Push-pull | Actively sinks | Actively sources | Opposing active drives contend |
| Open-collector or open-drain | Sinks when enabled | Releases to high impedance | An external pull-up establishes high when every device releases. Any active device pulls low |
| Tri-state | Actively sinks when output is enabled | Actively sources when output is enabled | Disabled output is high impedance. Enable at most one push-pull driver at a time |

In a CMOS transmission gate, place one nMOS and one pMOS in parallel between nodes A and B. Drive their control gates with complementary values.

| Enable `E` | nMOS gate | pMOS gate | A–B path in the switch model |
| --- | --- | --- | --- |
| 0 | 0 | 1 | Both off, path open |
| 1 | 1 | 0 | Both on, bidirectional connection |

The complementary devices pass both logic levels more effectively than a single pass transistor. A switch-level model can represent connectivity, floating nodes and resolved contention with the strengths supported by the model. For quantitative behavior, the device on-resistance, leakage, voltage-dependent current and load capacitance matter.

### Estimate CMOS load power

Suppose a CMOS driver swings a lumped `12 pF` load between 0 and `1.8 V`, with full settling between transitions. A `20 MHz` clock defines the interval, and the output charges from 0 to 1 in one quarter of those intervals on average. The supply delivers `CV² = 38.88 pJ` per charging event. At `5 million` charging events per second, the load-switching power is about `194 µW`. This estimate includes the specified capacitive load and excludes internal switching, short-circuit current and leakage.

## Modern flow translation

RTL → gates mapped to a characterized standard-cell library → timing and power analysis → physical signoff. A behavioral `assign` cannot model a TSMC library cell's corner tables. ASIC/FPGA tri-state support is platform-dependent and often only at I/O; internal FPGA fabric tri-states are frequently synthesized as muxes or rejected.

## HDL laboratory

- The [open-drain model](../examples/README.md#historical-models) uses resolved `0` and `Z` drives. `Z` represents a released driver. A separate pull-up establishes a logic level.
- On a board, use device data to check sink current at the specified low voltage, input thresholds and leakage. The pull-up resistance and measured total load capacitance determine the rise time. Smaller resistance speeds the rise and increases sink current when low.

**Edition connection.** Mano, *Digital Design*, 2nd ed. (1991), §§10-2 and 10-9, pp. 401 and 430, treats electrical limits and CMOS transmission gates. The 3rd ed. (2002) retains Ch. 10, with electrical specifications in §10-2. Mano and Ciletti, 4th ed. (2007), Ch. 10, covers electrical specifications in §10.2, pp. 473–476, TTL in §10.5, p. 484, and CMOS and switch-level modeling in §§10.8–10.10, pp. 498–505. The standalone chapter disappears in the 5th ed. (©2013), with an IC overview in §2.9, p. 66, and transmission gates and switch-level modeling in the appendix, pp. 514–519. In the 6th ed., Global printing (©2019, ISBN 9781292231167), see §2.9, p. 89, and the appendix beginning on p. 640.
