set script_dir [file normalize [file dirname [info script]]]
set hw_dir [file normalize [file join $script_dir ".."]]

set project_name "project"
set project_dir [file join $hw_dir "vivado"]
set part_name "xc7z020clg400-1"
set board_part_name "digilentinc.com:arty-z7-20:part0:1.0"
set board_repo_dir [file join $hw_dir "board_files"]

if {[file isdirectory $board_repo_dir]} {
  set_param board.repoPaths [list $board_repo_dir]
}

create_project $project_name $project_dir -part $part_name -force

# Use manual source management to prevent Vivado from auto-disabling files.
set_property source_mgmt_mode None [current_project]
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

# Keep board part when available (helps with board-customized IP), but don't hard-fail.
if {[llength [get_board_parts -quiet $board_part_name]] > 0} {
  set_property board_part $board_part_name [current_project]
} else {
  puts "WARNING: Board part '$board_part_name' not found; continuing with part-only project."
}

add_files -norecurse [list \
  [file join $hw_dir "src/sources/verilog/hdmi_core.v"] \
  [file join $hw_dir "src/sources/verilog/pixel_gen.v"] \
  [file join $hw_dir "src/sources/verilog/popcount8.v"] \
  [file join $hw_dir "src/sources/verilog/tmds_encoder.v"] \
  [file join $hw_dir "src/sources/verilog/tmds_out.v"] \
  [file join $hw_dir "src/sources/verilog/tmds_stage_0.v"] \
  [file join $hw_dir "src/sources/verilog/tmds_stage_1.v"] \
  [file join $hw_dir "src/sources/verilog/tmds_stage_2.v"] \
  [file join $hw_dir "src/sources/verilog/video_timer.v"] \
  [file join $hw_dir "src/sources/verilog/hdmi_top.v"] \
]

add_files -fileset constrs_1 -norecurse [list \
  [file join $hw_dir "src/constrs/arty_z7_hdmi.xdc"] \
]

add_files -fileset sim_1 -norecurse [list \
  [file join $hw_dir "src/sim/tmds_encoder_tb.v"] \
  [file join $hw_dir "src/sim/tmds_stage_0_tb.v"] \
  [file join $hw_dir "src/sim/tmds_stage_1_tb.v"] \
  [file join $hw_dir "src/sim/tmds_stage_2_tb.v"] \
  [file join $hw_dir "src/sim/video_timer_tb.v"] \
]

add_files -fileset sources_1 -norecurse [list \
  [file join $hw_dir "src/sources/ip/clk_wiz_0.xci"] \
]

# Explicitly enable files so project recreation is deterministic.
set_property is_enabled true [get_files -of_objects [get_filesets sources_1]]
set_property is_enabled true [get_files -of_objects [get_filesets sim_1]]

set_property top hdmi_top [get_filesets sources_1]
set_property top tmds_encoder_tb [get_filesets sim_1]

puts "Recreated Vivado project at [file join $project_dir ${project_name}.xpr]"
