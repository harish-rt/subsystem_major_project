add wave /top/cdma_data_mov_intf/aclk
add wave /top/cdma_data_mov_intf/areset_n

add wave -vgroup {CDMA_DM/AW_Channel} \
    /top/cdma_data_mov_intf/awid \
    /top/cdma_data_mov_intf/awaddr \
    /top/cdma_data_mov_intf/awlen \
    /top/cdma_data_mov_intf/awsize \
    /top/cdma_data_mov_intf/awburst \
    /top/cdma_data_mov_intf/awlock \
    /top/cdma_data_mov_intf/awcache \
    /top/cdma_data_mov_intf/awprot \
    /top/cdma_data_mov_intf/awvalid \
    /top/cdma_data_mov_intf/awready

add wave -vgroup {CDMA_DM/W_Channel} \
    /top/cdma_data_mov_intf/wdata \
    /top/cdma_data_mov_intf/wstrobe \
    /top/cdma_data_mov_intf/wlast \
    /top/cdma_data_mov_intf/wvalid \
    /top/cdma_data_mov_intf/wready

add wave -vgroup {CDMA_DM/B_Channel} \
    /top/cdma_data_mov_intf/bid \
    /top/cdma_data_mov_intf/bresp \
    /top/cdma_data_mov_intf/bvalid \
    /top/cdma_data_mov_intf/bready

add wave -vgroup {CDMA_DM/AR_Channel} \
    /top/cdma_data_mov_intf/arid \
    /top/cdma_data_mov_intf/araddr \
    /top/cdma_data_mov_intf/arlen \
    /top/cdma_data_mov_intf/arsize \
    /top/cdma_data_mov_intf/arburst \
    /top/cdma_data_mov_intf/arlock \
    /top/cdma_data_mov_intf/arcache \
    /top/cdma_data_mov_intf/arprot \
    /top/cdma_data_mov_intf/arvalid \
    /top/cdma_data_mov_intf/arready

add wave -vgroup {CDMA_DM/R_Channel} \
    /top/cdma_data_mov_intf/rid \
    /top/cdma_data_mov_intf/rdata \
    /top/cdma_data_mov_intf/rresp \
    /top/cdma_data_mov_intf/rlast \
    /top/cdma_data_mov_intf/rvalid \
    /top/cdma_data_mov_intf/rready

wv.time.unit.auto.set
wv.zoom.fit
