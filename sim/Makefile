IVERILOG ?= iverilog
VVP      ?= vvp
GTKWAVE  ?= gtkwave
VERILATOR?= verilator

SRC   = ../rtl/alu.sv
TB    = tb_alu.sv
BIN   = tb_alu.vvp
WAVE  = tb_alu.vcd

.PHONY: sim wave lint lint-v clean

# Default: compile + run
sim: $(WAVE)

$(WAVE): $(TB) $(SRC)
	$(IVERILOG) -g2012 -Wall -o $(BIN) $(TB) $(SRC)
	$(VVP) $(BIN)

# Open waveform (requires GTKWave)
wave: $(WAVE)
	$(GTKWAVE) $(WAVE) &

# Lint with Verilator (fast, no simulation)
lint:
	$(VERILATOR) --lint-only -Wall -sv $(SRC)

# Full Verilator simulation (generates C++ model)
lint-v: $(SRC) $(TB)
	$(VERILATOR) --binary -Wall -sv --top-module tb_alu \
	    -o ../build/sim_tb $(TB) $(SRC)

clean:
	rm -f $(BIN) $(WAVE)
	rm -rf ../build/
