add wave /top/mem4_intf/ACLK
add wave /top/mem4_intf/ARESETn

add wave -vgroup {AXI4_MEM/AW_Channel} \
    /top/mem4_intf/AWID \
    /top/mem4_intf/AWADDR \
    /top/mem4_intf/AWLEN \
    /top/mem4_intf/AWSIZE \
    /top/mem4_intf/AWBURST \
    /top/mem4_intf/AWLOCK \
    /top/mem4_intf/AWCACHE \
    /top/mem4_intf/AWPROT \
    /top/mem4_intf/AWVALID \
    /top/mem4_intf/AWREADY

add wave -vgroup {AXI4_MEM/W_Channel} \
    /top/mem4_intf/WDATA \
    /top/mem4_intf/WSTRB \
    /top/mem4_intf/WLAST \
    /top/mem4_intf/WVALID \
    /top/mem4_intf/WREADY

add wave -vgroup {AXI4_MEM/B_Channel} \
    /top/mem4_intf/BID \
    /top/mem4_intf/BRESP \
    /top/mem4_intf/BVALID \
    /top/mem4_intf/BREADY

add wave -vgroup {AXI4_MEM/AR_Channel} \
    /top/mem4_intf/ARID \
    /top/mem4_intf/ARADDR \
    /top/mem4_intf/ARLEN \
    /top/mem4_intf/ARSIZE \
    /top/mem4_intf/ARBURST \
    /top/mem4_intf/ARLOCK \
    /top/mem4_intf/ARCACHE \
    /top/mem4_intf/ARPROT \
    /top/mem4_intf/ARVALID \
    /top/mem4_intf/ARREADY

add wave -vgroup {AXI4_MEM/R_Channel} \
    /top/mem4_intf/RID \
    /top/mem4_intf/RDATA \
    /top/mem4_intf/RRESP \
    /top/mem4_intf/RLAST \
    /top/mem4_intf/RVALID \
    /top/mem4_intf/RREADY

wv.time.unit.auto.set
wv.zoom.fit
