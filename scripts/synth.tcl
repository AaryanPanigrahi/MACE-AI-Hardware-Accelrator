# ===== Arguments from Makefile =====
set top        [lindex $argv 0]
set rtl_file   [lindex $argv 1]
set part       [lindex $argv 2]
set out_dir    [lindex $argv 3]

puts "Top      : $top"
puts "RTL file : $rtl_file"
puts "Part     : $part"
puts "Out dir  : $out_dir"

file mkdir $out_dir
cd $out_dir

# ===== Create in-memory project =====
create_project -in_memory -part $part

# ===== Add RTL =====
read_verilog -sv $rtl_file

# ===== Synthesis =====
synth_design -top $top

# ===== Reports =====
report_timing_summary -file timing.rpt
report_utilization     -file utilization.rpt

# ===== Save checkpoint =====
write_checkpoint -force post_synth.dcp

puts "Synthesis complete."
exit
