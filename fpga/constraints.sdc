# Synopsys Design Constraints — constraints.sdc
#
# Only one real clock on the DE10-Lite: 50 MHz on CLOCK_50.
# The ALU is purely combinational, so this constraint just sets the
# reference clock for timing analysis (and future sequential logic).

create_clock -period 20.0 -name clk [get_ports {CLOCK_50}]

# Relax I/O timing for the combinational demo — adjust for real CPU use.
set_input_delay  -clock clk  2.0 [get_ports {SW[*]}]
set_output_delay -clock clk  2.0 [get_ports {LEDR[*]}]
