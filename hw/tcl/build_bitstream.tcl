set script_dir [file normalize [file dirname [info script]]]
set hw_dir [file normalize [file join $script_dir ".."]]
set project_dir [file join $hw_dir "vivado"]
set project_name "project"
set top_name "hdmi_top"

source [file join $script_dir "recreate_project.tcl"]

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
if {![string match "*Complete*" $impl_status]} {
  puts "ERROR: impl_1 did not complete successfully: $impl_status"
  exit 1
}

set bitstream_path [file join $project_dir "${project_name}.runs" "impl_1" "${top_name}.bit"]
if {![file exists $bitstream_path]} {
  puts "ERROR: Expected bitstream was not generated: $bitstream_path"
  exit 1
}

puts "Generated bitstream: $bitstream_path"
