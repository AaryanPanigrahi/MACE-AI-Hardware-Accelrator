# ===== ModelSim (Windows, called from WSL) =====
MODELSIM_BIN := /mnt/c/intelFPGA/18.1/modelsim_ase/win32aloem
VLOG := $(MODELSIM_BIN)/vlog.exe
VSIM := $(MODELSIM_BIN)/vsim.exe
VLIB := $(MODELSIM_BIN)/vlib.exe

# ===== Project paths (Linux) =====
PROJ_DIR_LINUX := $(PWD)
RTL_DIR_LINUX  := $(PROJ_DIR_LINUX)/rtl
TB_DIR_LINUX   := $(PROJ_DIR_LINUX)/tb
VIP_SIM_DIR := ip_user_files/sim_scripts/axi_vip_0/modelsim
VIP_COMPILE_DO := $(VIP_SIM_DIR)/compile.do
VIP_COMPILE_DO_WIN := $(shell wslpath -w $(VIP_COMPILE_DO))

# ===== Convert to Windows paths =====
RTL_DIR_WIN := $(shell wslpath -w $(RTL_DIR_LINUX))
TB_DIR_WIN  := $(shell wslpath -w $(TB_DIR_LINUX))

WORK_LIB := work

# ===== Grab argument: make sim adder.sv =====
# ===== Grab argument only for sim =====
ifeq ($(firstword $(MAKECMDGOALS)),sim)

ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

ifeq ($(strip $(ARGS)),)
$(error Usage: make sim <design>.sv)
endif

DESIGN_SV := $(firstword $(ARGS))
DESIGN    := $(basename $(notdir $(DESIGN_SV)))
TOP       := $(DESIGN)_tb

endif


DESIGN_SV := $(firstword $(ARGS))
DESIGN    := $(basename $(notdir $(DESIGN_SV)))
TOP       := $(DESIGN)_tb

RTL_FILE_WIN := $(RTL_DIR_WIN)\\$(DESIGN).sv
TB_FILE_WIN  := $(TB_DIR_WIN)\\$(TOP).sv

.PHONY: sim wav clean

sim:
	@echo "=== Design: $(DESIGN) ==="

	@if [ ! -d $(WORK_LIB) ]; then $(VLIB) $(WORK_LIB); fi

	# Compile AXI VIP first
	@if [ -f $(VIP_COMPILE_DO) ]; then \
		echo "=== Compiling AXI VIP ==="; \
		$(VSIM) -c -do "do $(VIP_COMPILE_DO_WIN); quit"; \
	fi

	# Compile RTL + TB
	$(VLOG) -sv "$(RTL_FILE_WIN)" "$(TB_FILE_WIN)"

	# Run sim
	$(VSIM) -c $(TOP) -do "run -all; quit"

wav:
	@echo "=== Launching ModelSim GUI ==="
	$(VSIM) $(TOP)

clean:
	rm -rf $(WORK_LIB) transcript vsim.wlf

# Swallow extra args
%:
	@:

# ===== Vivado =====
VIVADO_ENV := C:\\AMDDesignTools\\vivado_env.cmd
VIVADO_TCL := scripts/synth.tcl

PART := xczu5ev-sfvc784-1-e # Zynq UltraScale+ zu5EV genesis board

# Convert paths
RTL_FILE_WIN := $(shell wslpath -w $(RTL_DIR_LINUX)/$(DESIGN).sv)
SYNTH_OUT_WIN := $(shell wslpath -w $(PROJ_DIR_LINUX)/build/$(DESIGN))

.PHONY: synth

synth:
	@echo "=== Vivado Synthesis: $(DESIGN) ==="
	cmd.exe /c $(VIVADO_ENV) vivado -mode batch \
		-source $(VIVADO_TCL) \
		-tclargs $(DESIGN) "$(RTL_FILE_WIN)" $(PART) "$(SYNTH_OUT_WIN)"

# ===== AXI VIP Generation =====
VIP_TCL := scripts/gen_axi_vip.tcl

.PHONY: gen_vip

gen_vip:
	@echo "=== Generating AXI VIP ==="
	cmd.exe /c $(VIVADO_ENV) vivado -mode batch \
		-source $(VIP_TCL)
