#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hw_dir="$(cd "$script_dir/.." && pwd)"

cd "$hw_dir/vivado"

exec vivado -mode batch -source "$hw_dir/tcl/program_device.tcl"
