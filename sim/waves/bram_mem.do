add wave /top/axi4_bram_if/ACLK
add wave /top/axi4_bram_if/ARESETn

add wave -vgroup {BRAM/AW_Channel} \
    /top/axi4_bram_if/AWID \
    /top/axi4_bram_if/AWADDR \
    /top/axi4_bram_if/AWLEN \
    /top/axi4_bram_if/AWSIZE \
    /top/axi4_bram_if/AWBURST \
    /top/axi4_bram_if/AWLOCK \
    /top/axi4_bram_if/AWCACHE \
    /top/axi4_bram_if/AWPROT \
    /top/axi4_bram_if/AWVALID \
    /top/axi4_bram_if/AWREADY

add wave -vgroup {BRAM/W_Channel} \
    /top/axi4_bram_if/WDATA \
    /top/axi4_bram_if/WSTRB \
    /top/axi4_bram_if/WLAST \
    /top/axi4_bram_if/WVALID \
    /top/axi4_bram_if/WREADY

add wave -vgroup {BRAM/B_Channel} \
    /top/axi4_bram_if/BID \
    /top/axi4_bram_if/BRESP \
    /top/axi4_bram_if/BVALID \
    /top/axi4_bram_if/BREADY

add wave -vgroup {BRAM/AR_Channel} \
    /top/axi4_bram_if/ARID \
    /top/axi4_bram_if/ARADDR \
    /top/axi4_bram_if/ARLEN \
    /top/axi4_bram_if/ARSIZE \
    /top/axi4_bram_if/ARBURST \
    /top/axi4_bram_if/ARLOCK \
    /top/axi4_bram_if/ARCACHE \
    /top/axi4_bram_if/ARPROT \
    /top/axi4_bram_if/ARVALID \
    /top/axi4_bram_if/ARREADY

add wave -vgroup {BRAM/R_Channel} \
    /top/axi4_bram_if/RID \
    /top/axi4_bram_if/RDATA \
    /top/axi4_bram_if/RRESP \
    /top/axi4_bram_if/RLAST \
    /top/axi4_bram_if/RVALID \
    /top/axi4_bram_if/RREADY

wv.time.unit.auto.set
wv.zoom.fit
