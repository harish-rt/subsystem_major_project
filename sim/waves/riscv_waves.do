wave {/top/axil_riscv_if[0]/ACLK}
wave {/top/axil_riscv_if[0]/ARESETn}

# AW Channel Subgroup
wave -vgroup {S00/AW_Channel} \
	{/top/axil_riscv_if[0]/AWVALID} \
	{/top/axil_riscv_if[0]/AWREADY} \
	{/top/axil_riscv_if[0]/AWADDR}

# W Channel Subgroup
wave -vgroup {S00/W_Channel} \
	{/top/axil_riscv_if[0]/WVALID} \
	{/top/axil_riscv_if[0]/WREADY} \
	{/top/axil_riscv_if[0]/WDATA} \
	{/top/axil_riscv_if[0]/WSTRB}

# B Channel Subgroup
wave -vgroup {S00/B_Channel} \
	{/top/axil_riscv_if[0]/BVALID} \
	{/top/axil_riscv_if[0]/BREADY} \
	{/top/axil_riscv_if[0]/BRESP}

# AR Channel Subgroup
wave -vgroup {S00/AR_Channel} \
	{/top/axil_riscv_if[0]/ARVALID} \
	{/top/axil_riscv_if[0]/ARREADY} \
	{/top/axil_riscv_if[0]/ARADDR}

# R Channel Subgroup
wave -vgroup {S00/R_Channel} \
	{/top/axil_riscv_if[0]/RRESP} \
	{/top/axil_riscv_if[0]/RREADY} \
	{/top/axil_riscv_if[0]/RVALID} \
	{/top/axil_riscv_if[0]/RDATA}

# Riviera-PRO specific waveform adjustments
wv.time.unit.auto.set
wv.zoom.fit


add wave {/top/axil_riscv_if[1]/ACLK}
add wave {/top/axil_riscv_if[1]/ARESETn}

add wave -vgroup {S02/AW_Channel} \
	{/top/axil_riscv_if[1]/AWVALID} \
	{/top/axil_riscv_if[1]/AWREADY} \
	{/top/axil_riscv_if[1]/AWADDR}
add wave -vgroup {S02/W_Channel} \
	{/top/axil_riscv_if[1]/WVALID} \
	{/top/axil_riscv_if[1]/WREADY} \
	{/top/axil_riscv_if[1]/WDATA} \
	{/top/axil_riscv_if[1]/WSTRB}
add wave -vgroup {S02/B_Channel} \
	{/top/axil_riscv_if[1]/BVALID} \
	{/top/axil_riscv_if[1]/BREADY} \
	{/top/axil_riscv_if[1]/BRESP}
add wave -vgroup {S02/AR_Channel} \
	{/top/axil_riscv_if[1]/ARVALID} \
	{/top/axil_riscv_if[1]/ARREADY} \
	{/top/axil_riscv_if[1]/ARADDR}
add wave -vgroup {S02/R_Channel} \
	{/top/axil_riscv_if[1]/RRESP} \
	{/top/axil_riscv_if[1]/RREADY} \
	{/top/axil_riscv_if[1]/RVALID} \
	{/top/axil_riscv_if[1]/RDATA}

wv.time.unit.auto.set
wv.zoom.fit
