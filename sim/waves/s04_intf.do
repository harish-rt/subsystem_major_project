add wave /top/slave_if/ACLK
add wave /top/slave_if/ARESETn

add wave -vgroup {S04/AW_Channel} \
    /top/slave_if/AWID \
    /top/slave_if/AWADDR \
    /top/slave_if/AWLEN \
    /top/slave_if/AWSIZE \
    /top/slave_if/AWBURST \
    /top/slave_if/AWLOCK \
    /top/slave_if/AWCACHE \
    /top/slave_if/AWPROT \
    /top/slave_if/AWVALID \
    /top/slave_if/AWREADY

add wave -vgroup {S04/W_Channel} \
    /top/slave_if/WDATA \
    /top/slave_if/WSTRB \
    /top/slave_if/WLAST \
    /top/slave_if/WVALID \
    /top/slave_if/WREADY

add wave -vgroup {S04/B_Channel} \
    /top/slave_if/BID \
    /top/slave_if/BRESP \
    /top/slave_if/BVALID \
    /top/slave_if/BREADY

add wave -vgroup {S04/AR_Channel} \
    /top/slave_if/ARID \
    /top/slave_if/ARADDR \
    /top/slave_if/ARLEN \
    /top/slave_if/ARSIZE \
    /top/slave_if/ARBURST \
    /top/slave_if/ARLOCK \
    /top/slave_if/ARCACHE \
    /top/slave_if/ARPROT \
    /top/slave_if/ARVALID \
    /top/slave_if/ARREADY

add wave -vgroup {S04/R_Channel} \
    /top/slave_if/RID \
    /top/slave_if/RDATA \
    /top/slave_if/RRESP \
    /top/slave_if/RLAST \
    /top/slave_if/RVALID \
    /top/slave_if/RREADY

wv.time.unit.auto.set
wv.zoom.fit
