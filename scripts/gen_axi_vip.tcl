# ================================
# Args from Makefile
# ================================
set IP_NAME   axi_vip_0
set IP_DIR    ./ip
set PART      xczu5ev-sfvc784-1-e

# ================================
# Create temp project
# ================================
create_project vip_proj ./vivado_vip -part $PART -force

set_property target_language SystemVerilog [current_project]

# ================================
# Create AXI VIP
# ================================
create_ip \
  -name axi_vip \
  -vendor xilinx.com \
  -library ip \
  -version 1.1 \
  -module_name $IP_NAME \
  -dir $IP_DIR

# ================================
# Configure (EDIT THESE)
# ================================
set_property -dict [list \
  CONFIG.INTERFACE_MODE {SLAVE} \
  CONFIG.PROTOCOL {AXI4} \
  CONFIG.DATA_WIDTH {32} \
  CONFIG.ADDR_WIDTH {32} \
] [get_ips $IP_NAME]

# ================================
# Generate outputs
# ================================
generate_target all [get_ips $IP_NAME]

export_ip_user_files \
  -of_objects [get_ips $IP_NAME] \
  -no_script \
  -sync \
  -force

export_simulation \
  -of_objects [get_ips $IP_NAME] \
  -directory ./ip_user_files/sim_scripts \
  -force

puts "AXI VIP generated."
exit
