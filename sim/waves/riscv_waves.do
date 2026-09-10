add wave /top/axil_riscv_if/ACLK
add wave /top/axil_riscv_if/ARESETn

add wave -vgroup {RISCV/AW_Channel} \
	/top/axil_riscv_if/AWVALID \
	/top/axil_riscv_if/AWREADY \
	/top/axil_riscv_if/AWADDR
add wave -vgroup {RISCV/W_Channel} \
	/top/axil_riscv_if/WVALID \
	/top/axil_riscv_if/WREADY \
	/top/axil_riscv_if/WDATA \
	/top/axil_riscv_if/WSTRB
add wave -vgroup {RISCV/B_Channel} \
	/top/axil_riscv_if/BVALID \
	/top/axil_riscv_if/BREADY \
	/top/axil_riscv_if/BRESP
add wave -vgroup {RISCV/AR_Channel} \
	/top/axil_riscv_if/ARVALID \
	/top/axil_riscv_if/ARREADY \
	/top/axil_riscv_if/ARADDR
add wave -vgroup {RISCV/R_Channel} \
	/top/axil_riscv_if/RRESP \
	/top/axil_riscv_if/RREADY \
	/top/axil_riscv_if/RVALID \
	/top/axil_riscv_if/RDATA

wv.time.unit.auto.set
wv.zoom.fit
