add wave /top/mem_intf/ACLK
add wave /top/mem_intf/ARESETn

add wave -vgroup {LITE_MEM/AW_Channel} \
	/top/mem_intf/AWVALID \
	/top/mem_intf/AWREADY \
	/top/mem_intf/AWADDR
add wave -vgroup {LITE_MEM/W_Channel} \
	/top/mem_intf/WVALID \
	/top/mem_intf/WREADY \
	/top/mem_intf/WDATA \
	/top/mem_intf/WSTRB
add wave -vgroup {LITE_MEM/B_Channel} \
	/top/mem_intf/BVALID \
	/top/mem_intf/BREADY \
	/top/mem_intf/BRESP
add wave -vgroup {LITE_MEM/AR_Channel} \
	/top/mem_intf/ARVALID \
	/top/mem_intf/ARREADY \
	/top/mem_intf/ARADDR
add wave -vgroup {LITE_MEM/R_Channel} \
	/top/mem_intf/RRESP \
	/top/mem_intf/RREADY \
	/top/mem_intf/RVALID \
	/top/mem_intf/RDATA

wv.time.unit.auto.set
wv.zoom.fit
