add wave /top/cdma_reg_intf/aclk
add wave /top/cdma_reg_intf/areset_n

add wave -vgroup {CDMA_REG/aw_Channel} \
	/top/cdma_reg_intf/awvalid \
	/top/cdma_reg_intf/awready \
	/top/cdma_reg_intf/awaddr
add wave -vgroup {CDMA_REG/W_Channel} \
	/top/cdma_reg_intf/wvalid \
	/top/cdma_reg_intf/wready \
	/top/cdma_reg_intf/wdata \
add wave -vgroup {CDMA_REG/B_Channel} \
	/top/cdma_reg_intf/bvalid \
	/top/cdma_reg_intf/bready \
	/top/cdma_reg_intf/bresp
add wave -vgroup {CDMA_REG/ar_Channel} \
	/top/cdma_reg_intf/arvalid \
	/top/cdma_reg_intf/arready \
	/top/cdma_reg_intf/araddr
add wave -vgroup {CDMA_REG/R_Channel} \
	/top/cdma_reg_intf/rresp \
	/top/cdma_reg_intf/rready \
	/top/cdma_reg_intf/rvalid \
	/top/cdma_reg_intf/rdata

wv.time.unit.auto.set
wv.zoom.fit
