set script_dir [file normalize [file dirname [info script]]]
set hw_dir [file normalize [file join $script_dir ".."]]
set bitstream_path [file join $hw_dir "vivado" "project.runs" "impl_1" "hdmi_top.bit"]

if {![file exists $bitstream_path]} {
  puts "ERROR: Bitstream not found: $bitstream_path"
  puts "Run hw/scripts/build_bitstream.sh before programming the device."
  exit 1
}

open_hw_manager
connect_hw_server
open_hw_target

set devices [get_hw_devices xc7z020*]
if {[llength $devices] == 0} {
  puts "ERROR: No xc7z020 hardware device found. Check USB/JTAG connection and board power."
  exit 1
}

set device [lindex $devices 0]
current_hw_device $device
refresh_hw_device $device

set_property PROGRAM.FILE $bitstream_path $device
program_hw_devices $device

puts "Programmed $device with $bitstream_path"
