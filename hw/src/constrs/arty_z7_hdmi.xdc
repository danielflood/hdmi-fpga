############################################################
# Arty Z7-20 HDMI - Minimal Constraints
############################################################

############################
# PL clock (H16)
############################
set_property PACKAGE_PIN H16 [get_ports clk_100mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100mhz]
# Do NOT create_clock here; clk_wiz_0.xdc already does it

############################
# Optional reset button (BTNU)
############################
set_property PACKAGE_PIN N15 [get_ports rst_btn]
set_property IOSTANDARD LVCMOS33 [get_ports rst_btn]
set_property PULLDOWN true [get_ports rst_btn]

############################
# HDMI TMDS Clock
############################
set_property PACKAGE_PIN L16 [get_ports hdmi_tx_clk_p]
set_property PACKAGE_PIN L17 [get_ports hdmi_tx_clk_n]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_clk_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_clk_n]

############################
# HDMI TMDS Data Lane 0 (Blue)
############################
set_property PACKAGE_PIN K17 [get_ports hdmi_tx_d0_p]
set_property PACKAGE_PIN K18 [get_ports hdmi_tx_d0_n]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_d0_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_d0_n]

############################
# HDMI TMDS Data Lane 1 (Green)
############################
set_property PACKAGE_PIN K19 [get_ports hdmi_tx_d1_p]
set_property PACKAGE_PIN J19 [get_ports hdmi_tx_d1_n]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_d1_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_d1_n]

############################
# HDMI TMDS Data Lane 2 (Red)
############################
set_property PACKAGE_PIN J18 [get_ports hdmi_tx_d2_p]
set_property PACKAGE_PIN H18 [get_ports hdmi_tx_d2_n]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_d2_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_tx_d2_n]