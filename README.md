# Vivado Project (Portable Workflow)

Use the checked-in scripts to recreate, build, and program the Vivado project.
The bash wrappers keep Vivado logs and generated files under `hw/vivado`.

## Recreate the project

Run from the repository root:

```bash
hw/scripts/recreate_project.sh
```

This generates `hw/vivado/project.xpr` and Vivado run metadata locally.

## Build the bitstream

Run from the repository root:

```bash
hw/scripts/build_bitstream.sh
```

This recreates the project, runs implementation through `write_bitstream`, and
writes the bitstream to:

```text
hw/vivado/project.runs/impl_1/hdmi_top.bit
```

## Open in GUI

After recreating:

```bash
hw/scripts/open_project.sh
```

## Program the board

After generating the bitstream, connect the Arty Z7-20 over USB/JTAG:

```bash
hw/scripts/program_device.sh
```

This programs:

```text
hw/vivado/project.runs/impl_1/hdmi_top.bit
```

You can also program from Vivado GUI:

```bash
hw/scripts/open_project.sh
```

Then use `Open Hardware Manager`, `Open Target`, `Auto Connect`, and `Program
Device`.

## Notes

- The script always uses `set_part xc7z020clg400-1` and the checked-in XDC.
- Vivado Tcl lives under `hw/tcl`; user-facing wrappers live under `hw/scripts`.
- The Arty Z7-20 board definition is checked in under `hw/board_files`, and the recreate Tcl registers that board repo before setting `board_part`.
