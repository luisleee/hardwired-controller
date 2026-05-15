IVERILOG  ?= iverilog
VVP       ?= vvp
GTKWAVE   ?= gtkwave
VERILATOR ?= verilator

RTL_DIR := ../rtl
TB_GLOB := tb_*.sv
SRCS    := $(sort $(wildcard $(RTL_DIR)/*.sv))
TBS     := $(sort $(wildcard $(TB_GLOB)))

TB ?= $(firstword $(TBS))
TB_BASE := $(basename $(TB))
BIN     := $(TB_BASE).vvp
WAVE    := $(TB_BASE).vcd

.PHONY: sim wave lint list clean help

help:
	@echo "make list                    # 列出所有 testbench"
	@echo "make sim TB=tb_xxx.sv        # 运行指定 testbench"
	@echo "make tb_xxx.vcd              # 直接构建并运行某个 testbench"
	@echo "make wave TB=tb_xxx.sv       # 打开指定波形"
	@echo "make lint                    # Verilator lint 全部 RTL"
	@echo "make clean                   # 删除 *.vvp *.vcd obj_dir"

list:
	@printf '%s\n' $(TBS)

sim:
	$(IVERILOG) -g2012 -Wall -I$(RTL_DIR) -o $(BIN) $(TB) $(SRCS)
	$(VVP) $(BIN)

%.vcd: %.sv $(SRCS)
	$(IVERILOG) -g2012 -Wall -I$(RTL_DIR) -o $*.vvp $< $(SRCS)
	$(VVP) $*.vvp

$(WAVE): $(TB) $(SRCS)
	$(IVERILOG) -g2012 -Wall -I$(RTL_DIR) -o $(BIN) $(TB) $(SRCS)
	$(VVP) $(BIN)

wave: $(WAVE)
	$(GTKWAVE) $(WAVE) &

lint:
	$(VERILATOR) --lint-only -Wall -sv $(SRCS)

clean:
	rm -f ./*.vvp ./*.vcd
	rm -rf ./obj_dir
