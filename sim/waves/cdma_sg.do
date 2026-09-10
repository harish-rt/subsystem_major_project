add wave /top/cdma_sg_intf/aclk
add wave /top/cdma_sg_intf/areset_n

add wave -vgroup {CDMA_SG/AW_Channel} \
    /top/cdma_sg_intf/awid \
    /top/cdma_sg_intf/awaddr \
    /top/cdma_sg_intf/awlen \
    /top/cdma_sg_intf/awsize \
    /top/cdma_sg_intf/awburst \
    /top/cdma_sg_intf/awlock \
    /top/cdma_sg_intf/awcache \
    /top/cdma_sg_intf/awprot \
    /top/cdma_sg_intf/awvalid \
    /top/cdma_sg_intf/awready

add wave -vgroup {CDMA_SG/W_Channel} \
    /top/cdma_sg_intf/wdata \
    /top/cdma_sg_intf/wstrobe \
    /top/cdma_sg_intf/wlast \
    /top/cdma_sg_intf/wvalid \
    /top/cdma_sg_intf/wready

add wave -vgroup {CDMA_SG/B_Channel} \
    /top/cdma_sg_intf/bid \
    /top/cdma_sg_intf/bresp \
    /top/cdma_sg_intf/bvalid \
    /top/cdma_sg_intf/bready

add wave -vgroup {CDMA_SG/AR_Channel} \
    /top/cdma_sg_intf/arid \
    /top/cdma_sg_intf/araddr \
    /top/cdma_sg_intf/arlen \
    /top/cdma_sg_intf/arsize \
    /top/cdma_sg_intf/arburst \
    /top/cdma_sg_intf/arlock \
    /top/cdma_sg_intf/arcache \
    /top/cdma_sg_intf/arprot \
    /top/cdma_sg_intf/arvalid \
    /top/cdma_sg_intf/arready

add wave -vgroup {CDMA_SG/R_Channel} \
    /top/cdma_sg_intf/rid \
    /top/cdma_sg_intf/rdata \
    /top/cdma_sg_intf/rresp \
    /top/cdma_sg_intf/rlast \
    /top/cdma_sg_intf/rvalid \
    /top/cdma_sg_intf/rready

wv.time.unit.auto.set
wv.zoom.fit
