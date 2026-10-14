add wave /top/core_perif_if/ACLK
add wave /top/core_perif_if/ARESETn

add wave -vgroup {CORE_PERIF/AW_Channel} \
	/top/core_perif_if/AWVALID \
	/top/core_perif_if/AWREADY \
	/top/core_perif_if/AWADDR
add wave -vgroup {CORE_PERIF/W_Channel} \
	/top/core_perif_if/WVALID \
	/top/core_perif_if/WREADY \
	/top/core_perif_if/WDATA \
	/top/core_perif_if/WSTRB
add wave -vgroup {CORE_PERIF/B_Channel} \
	/top/core_perif_if/BVALID \
	/top/core_perif_if/BREADY \
	/top/core_perif_if/BRESP
add wave -vgroup {CORE_PERIF/AR_Channel} \
	/top/core_perif_if/ARVALID \
	/top/core_perif_if/ARREADY \
	/top/core_perif_if/ARADDR
add wave -vgroup {CORE_PERIF/R_Channel} \
	/top/core_perif_if/RRESP \
	/top/core_perif_if/RREADY \
	/top/core_perif_if/RVALID \
	/top/core_perif_if/RDATA

wv.time.unit.auto.set
wv.zoom.fit
