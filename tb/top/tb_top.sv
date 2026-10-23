`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg :: *;

//import cpu_package ::*;
//import axi_cdma_env_pkg ::*;
//import mem_package :: *;
//import intc_package ::*;
////import uart_pkg ::*;
////import gpio_pkg ::*;
////import spi_pkg ::*;
//import core_perif_pkg ::*;
//import soc_package ::*;
module top;
    
    import soc_addr_pkg ::*;
    import cpu_package ::*;
    import axi_cdma_env_pkg ::*;
    import mem_package :: *;
    import intc_package ::*;
    import core_perif_pkg ::*;
    import soc_package ::*;

    bit aclk;
    bit areset_n;

    bit disable_cpu_fork;

    wire intc_proc_rst;

    wire axi_intr;
    wire axi_irq;

    axi4_tb_intf       master_if();
    axi4_tb_intf       slave_if();

// BRAM interface
    axi4_tb_intf       axi4_bram_if();

// S00 - S02
    axi4_lite_tb_intf  axil_riscv_if[2]();
//// S02
//    axi4_lite_tb_intf  lite_data_if();

// memory interface
    axi4_lite_tb_intf  mem_intf();

// core peripherals monitor
    axi4_lite_tb_intf              core_perif_if();

// AXI Interrupt Controller
    axi4_lite_tb_intf           lite_intc_if();
    assign intc_proc_rst    =   ~areset_n;
    intc_intf                   intc_if(.intc_procss_clk(aclk),.intc_procss_rst(intc_proc_rst));
     
//axi cdma interfaces 
    axi_cdma_axi_master_intf    cdma_reg_intf       (.aclk(aclk),.areset_n(areset_n));
    axi_cdma_axi_slave_intf     cdma_sg_intf        (.aclk(aclk),.areset_n(areset_n));
    axi_cdma_axi_slave_intf     cdma_data_mov_intf  (.aclk(aclk),.areset_n(areset_n));
    axi_cdma_interrupt_intf     cdma_interrupt_intf (.aclk(aclk));

// UART interface
    uart_slave_if   uart_if(.clk(aclk),.rst_n(intc_proc_rst));
// GPIO interface
    gpio_slave_if   gpio_if(.clk(aclk),.rst_n(intc_proc_rst));
// SPI interface
    spi_slave_if    spi_if(.clk(aclk),.rst_n(intc_proc_rst));

    initial begin
        uvm_config_db#(virtual uart_slave_if)   ::set(null, "", "vif", uart_if);
        uvm_config_db#(virtual spi_slave_if)    ::set(null, "", "vif", spi_if);
        uvm_config_db#(virtual gpio_slave_if)   ::set(null, "", "vif", gpio_if);
    end
    
    core_wrapper dut(
        .clk_i(aclk),
        .rst_n_i(areset_n),

        //peripherals
        .spi_clk_o(spi_if.sclk),
        .spi_cs_o(spi_if.cs_n),
        .spi_miso_i(spi_if.miso),
        .spi_mosi_o(spi_if.mosi),

        .uart_rx_i(uart_if.tx_o),
        .uart_tx_o(uart_if.rx_i),

        .gpio_input_i(gpio_if.gpio_out),
        .gpio_output_o(gpio_if.gpio_in),
        .gpio_output_enable_o(gpio_if.gpio_oe),

        .ext1_cfg_araddr_o(),
        .ext1_cfg_arready_i(),
        .ext1_cfg_arvalid_o(),
        .ext1_cfg_awaddr_o(),
        .ext1_cfg_awready_i(),
        .ext1_cfg_awvalid_o(),
        .ext1_cfg_bready_o(),
        .ext1_cfg_bresp_i(),
        .ext1_cfg_bvalid_i(),
        .ext1_cfg_rdata_i(),
        .ext1_cfg_rready_o(),
        .ext1_cfg_rresp_i(),
        .ext1_cfg_rvalid_i(),
        .ext1_cfg_wdata_o(),
        .ext1_cfg_wready_i(),
        .ext1_cfg_wstrb_o(),
        .ext1_cfg_wvalid_o(),
        .ext1_irq_i(),

        .ext2_cfg_araddr_o(),
        .ext2_cfg_arready_i(),
        .ext2_cfg_arvalid_o(),
        .ext2_cfg_awaddr_o(),
        .ext2_cfg_awready_i(),
        .ext2_cfg_awvalid_o(),
        .ext2_cfg_bready_o(),
        .ext2_cfg_bresp_i(),
        .ext2_cfg_bvalid_i(),
        .ext2_cfg_rdata_i(),
        .ext2_cfg_rready_o(),
        .ext2_cfg_rresp_i(),
        .ext2_cfg_rvalid_i(),
        .ext2_cfg_wdata_o(),
        .ext2_cfg_wready_i(),
        .ext2_cfg_wstrb_o(),
        .ext2_cfg_wvalid_o(),
        .ext2_irq_i(),

        .ext3_cfg_araddr_o(),
        .ext3_cfg_arready_i(),
        .ext3_cfg_arvalid_o(),
        .ext3_cfg_awaddr_o(),
        .ext3_cfg_awready_i(),
        .ext3_cfg_awvalid_o(),
        .ext3_cfg_bready_o(),
        .ext3_cfg_bresp_i(),
        .ext3_cfg_bvalid_i(),
        .ext3_cfg_rdata_i(),
        .ext3_cfg_rready_o(),
        .ext3_cfg_rresp_i(),
        .ext3_cfg_rvalid_i(),
        .ext3_cfg_wdata_o(),
        .ext3_cfg_wready_i(),
        .ext3_cfg_wstrb_o(),
        .ext3_cfg_wvalid_o(),
        .ext3_irq_i(),

        .rsta_busy_0(),
        .rstb_busy_0(),


    //instructions and data interfaces
        //S00
        .inst_bridge2axi_int(axil_riscv_if[0]),
        //S02
        .data_bridge2axi_int(axil_riscv_if[1]),
        //.data_bridge2axi_int(lite_data_if),
        //M05
        .ext_axi4_master(master_if),
        //S04
        .ext_axi4_slave(slave_if)
    );

    // S04
    assign slave_if.ACLK            = aclk;
    assign slave_if.ARESETn         = areset_n;
    
    //// S02
    //assign lite_data_if.ACLK       = aclk;
    //assign lite_data_if.ARESETn    = areset_n;

    // S00
    assign axil_riscv_if[0].ACLK       = aclk;
    assign axil_riscv_if[0].ARESETn    = areset_n;
    // S02
    assign axil_riscv_if[1].ACLK       = aclk;
    assign axil_riscv_if[1].ARESETn    = areset_n;

    // Core Peripherals
    assign core_perif_if.ACLK       = aclk;
    assign core_perif_if.ARESETn    = areset_n;

    assign core_perif_if.AWADDR  = dut.axi_int2core_peri.AWADDR;
    assign core_perif_if.AWVALID = dut.axi_int2core_peri.AWVALID;
    assign core_perif_if.AWREADY = dut.axi_int2core_peri.AWREADY;
    assign core_perif_if.WDATA   = dut.axi_int2core_peri.WDATA;
    assign core_perif_if.WSTRB   = dut.axi_int2core_peri.WSTRB;
    assign core_perif_if.WVALID  = dut.axi_int2core_peri.WVALID;
    assign core_perif_if.WREADY  = dut.axi_int2core_peri.WREADY;
    assign core_perif_if.BRESP   = dut.axi_int2core_peri.BRESP;
    assign core_perif_if.BVALID  = dut.axi_int2core_peri.BVALID;
    assign core_perif_if.BREADY  = dut.axi_int2core_peri.BREADY;

    assign core_perif_if.ARADDR  = dut.axi_int2core_peri.ARADDR;
    assign core_perif_if.ARVALID = dut.axi_int2core_peri.ARVALID;
    assign core_perif_if.ARREADY = dut.axi_int2core_peri.ARREADY;
    assign core_perif_if.RDATA   = dut.axi_int2core_peri.RDATA;
    assign core_perif_if.RRESP   = dut.axi_int2core_peri.RRESP;
    assign core_perif_if.RVALID  = dut.axi_int2core_peri.RVALID;
    assign core_perif_if.RREADY  = dut.axi_int2core_peri.RREADY;
    //defparam dut.IPS_CORE.axi_cdma_0.U0.C_M_AXI_MAX_BURST_LEN = 64;

    // Interrupt controller
    assign lite_intc_if.ACLK        = aclk;
    assign lite_intc_if.ARESETn     = areset_n;
    // --- Write Channels (AW) ---
    assign lite_intc_if.AWADDR  = dut.IPS_CORE.axi_intc_0.s_axi_awaddr;
    assign lite_intc_if.AWVALID = dut.IPS_CORE.axi_intc_0.s_axi_awvalid;
    assign lite_intc_if.AWREADY = dut.IPS_CORE.axi_intc_0.s_axi_awready;
    
    // --- Write Data Channel (W) ---
    assign lite_intc_if.WDATA   = dut.IPS_CORE.axi_intc_0.s_axi_wdata;
    assign lite_intc_if.WSTRB   = dut.IPS_CORE.axi_intc_0.s_axi_wstrb;
    assign lite_intc_if.WVALID  = dut.IPS_CORE.axi_intc_0.s_axi_wvalid;
    assign lite_intc_if.WREADY  = dut.IPS_CORE.axi_intc_0.s_axi_wready;
    
    // --- Write Response Channel (B) ---
    assign lite_intc_if.BRESP   = dut.IPS_CORE.axi_intc_0.s_axi_bresp;
    assign lite_intc_if.BVALID  = dut.IPS_CORE.axi_intc_0.s_axi_bvalid;
    assign lite_intc_if.BREADY  = dut.IPS_CORE.axi_intc_0.s_axi_bready;
    
    // --- Read Channels (AR) ---
    assign lite_intc_if.ARADDR  = dut.IPS_CORE.axi_intc_0.s_axi_araddr;
    assign lite_intc_if.ARVALID = dut.IPS_CORE.axi_intc_0.s_axi_arvalid;
    assign lite_intc_if.ARREADY = dut.IPS_CORE.axi_intc_0.s_axi_arready;
    
    // --- Read Data Channel (R) ---
    assign lite_intc_if.RDATA   = dut.IPS_CORE.axi_intc_0.s_axi_rdata;
    assign lite_intc_if.RRESP   = dut.IPS_CORE.axi_intc_0.s_axi_rresp;
    assign lite_intc_if.RVALID  = dut.IPS_CORE.axi_intc_0.s_axi_rvalid;
    assign lite_intc_if.RREADY  = dut.IPS_CORE.axi_intc_0.s_axi_rready;

    // Interrupt Wires
    assign intc_if.intc_intr        = dut.IPS_CORE.intr_0;   //CDMA is 26 | Core Peri is 27
    assign intc_if.intc_irq         = dut.IPS_CORE.irq_0;

    //cdma connect

    assign cdma_reg_intf.arready=dut.IPS_CORE.axi_interconnect_0_M00_AXI_ARREADY;
    assign cdma_reg_intf.arvalid=dut.IPS_CORE.axi_interconnect_0_M00_AXI_ARVALID;
    assign cdma_reg_intf.araddr=dut.IPS_CORE.axi_interconnect_0_M00_AXI_ARADDR;

    assign cdma_reg_intf.rdata=dut.IPS_CORE.axi_interconnect_0_M00_AXI_RDATA;
    assign cdma_reg_intf.rvalid=dut.IPS_CORE.axi_interconnect_0_M00_AXI_RVALID;
    assign cdma_reg_intf.rready=dut.IPS_CORE.axi_interconnect_0_M00_AXI_RREADY;
    assign cdma_reg_intf.rresp=dut.IPS_CORE.axi_interconnect_0_M00_AXI_RRESP;
    
    assign cdma_reg_intf.awaddr=dut.IPS_CORE.axi_interconnect_0_M00_AXI_AWADDR;
    assign cdma_reg_intf.awvalid=dut.IPS_CORE.axi_interconnect_0_M00_AXI_AWVALID;
    assign cdma_reg_intf.awready=dut.IPS_CORE.axi_interconnect_0_M00_AXI_AWREADY;
    
    assign cdma_reg_intf.wdata=dut.IPS_CORE.axi_interconnect_0_M00_AXI_WDATA;
    assign cdma_reg_intf.wvalid=dut.IPS_CORE.axi_interconnect_0_M00_AXI_WVALID;
    assign cdma_reg_intf.wready=dut.IPS_CORE.axi_interconnect_0_M00_AXI_WREADY;
    
    assign cdma_reg_intf.bvalid=dut.IPS_CORE.axi_interconnect_0_M00_AXI_BVALID;
    assign cdma_reg_intf.bready=dut.IPS_CORE.axi_interconnect_0_M00_AXI_BREADY;
    assign cdma_reg_intf.bresp=dut.IPS_CORE.axi_interconnect_0_M00_AXI_BRESP;

    assign cdma_sg_intf.awaddr=dut.IPS_CORE.S01_AXI_1_AWADDR;
    assign cdma_sg_intf.awlen=dut.IPS_CORE.S01_AXI_1_AWLEN;
    assign cdma_sg_intf.awsize=dut.IPS_CORE.S01_AXI_1_AWSIZE;
    assign cdma_sg_intf.awburst=dut.IPS_CORE.S01_AXI_1_AWBURST;
    assign cdma_sg_intf.awvalid=dut.IPS_CORE.S01_AXI_1_AWVALID;
    assign cdma_sg_intf.awready=dut.IPS_CORE.S01_AXI_1_AWREADY;
    assign cdma_sg_intf.awcache=dut.IPS_CORE.S01_AXI_1_AWCACHE;
    assign cdma_sg_intf.awprot=dut.IPS_CORE.S01_AXI_1_AWPROT;
        
    assign cdma_sg_intf.bresp=dut.IPS_CORE.S01_AXI_1_BRESP;
    assign cdma_sg_intf.bvalid=dut.IPS_CORE.S01_AXI_1_BVALID;
    assign cdma_sg_intf.bready=dut.IPS_CORE.S01_AXI_1_BREADY;

    assign cdma_sg_intf.wdata=dut.IPS_CORE.S01_AXI_1_WDATA;
    assign cdma_sg_intf.wstrobe=dut.IPS_CORE.S01_AXI_1_WSTRB;
    assign cdma_sg_intf.wlast=dut.IPS_CORE.S01_AXI_1_WLAST;
    assign cdma_sg_intf.wvalid=dut.IPS_CORE.S01_AXI_1_WVALID;
    assign cdma_sg_intf.wready=dut.IPS_CORE.S01_AXI_1_WREADY;

    assign cdma_sg_intf.araddr=dut.IPS_CORE.S01_AXI_1_ARADDR;
    assign cdma_sg_intf.arlen=dut.IPS_CORE.S01_AXI_1_ARLEN;
    assign cdma_sg_intf.arsize=dut.IPS_CORE.S01_AXI_1_ARSIZE;
    assign cdma_sg_intf.arburst=dut.IPS_CORE.S01_AXI_1_ARBURST;
    assign cdma_sg_intf.arvalid=dut.IPS_CORE.S01_AXI_1_ARVALID;
    assign cdma_sg_intf.arready=dut.IPS_CORE.S01_AXI_1_ARREADY;
    assign cdma_sg_intf.arcache=dut.IPS_CORE.S01_AXI_1_ARCACHE;
    assign cdma_sg_intf.arprot=dut.IPS_CORE.S01_AXI_1_ARPROT;
    assign cdma_sg_intf.rvalid=dut.IPS_CORE.S01_AXI_1_RVALID;
    assign cdma_sg_intf.rready=dut.IPS_CORE.S01_AXI_1_RREADY;
    assign cdma_sg_intf.rdata=dut.IPS_CORE.S01_AXI_1_RDATA;
    assign cdma_sg_intf.rlast=dut.IPS_CORE.S01_AXI_1_RLAST;
    assign cdma_sg_intf.rresp=dut.IPS_CORE.S01_AXI_1_RRESP;

    assign cdma_data_mov_intf.awlen=dut.IPS_CORE.S03_AXI_1_AWLEN;
    assign cdma_data_mov_intf.awsize=dut.IPS_CORE.S03_AXI_1_AWSIZE;
    assign cdma_data_mov_intf.awaddr=dut.IPS_CORE.S03_AXI_1_AWADDR;
    assign cdma_data_mov_intf.awburst=dut.IPS_CORE.S03_AXI_1_AWBURST;
    assign cdma_data_mov_intf.awvalid=dut.IPS_CORE.S03_AXI_1_AWVALID;
    assign cdma_data_mov_intf.awready=dut.IPS_CORE.S03_AXI_1_AWREADY;
    assign cdma_data_mov_intf.awprot=dut.IPS_CORE.S03_AXI_1_AWPROT;
    assign cdma_data_mov_intf.awcache=dut.IPS_CORE.S03_AXI_1_AWCACHE;
    
    assign cdma_data_mov_intf.bresp=dut.IPS_CORE.S03_AXI_1_BRESP;
    assign cdma_data_mov_intf.bvalid=dut.IPS_CORE.S03_AXI_1_BVALID;
    assign cdma_data_mov_intf.bready=dut.IPS_CORE.S03_AXI_1_BREADY;

    assign cdma_data_mov_intf.wdata=dut.IPS_CORE.S03_AXI_1_WDATA;
    assign cdma_data_mov_intf.wstrobe=dut.IPS_CORE.S03_AXI_1_WSTRB;
    assign cdma_data_mov_intf.wlast=dut.IPS_CORE.S03_AXI_1_WLAST;
    assign cdma_data_mov_intf.wvalid=dut.IPS_CORE.S03_AXI_1_WVALID;
    assign cdma_data_mov_intf.wready=dut.IPS_CORE.S03_AXI_1_WREADY;
    assign cdma_data_mov_intf.araddr=dut.IPS_CORE.S03_AXI_1_ARADDR;
    assign cdma_data_mov_intf.arlen=dut.IPS_CORE.S03_AXI_1_ARLEN;
    assign cdma_data_mov_intf.arsize=dut.IPS_CORE.S03_AXI_1_ARSIZE;
    assign cdma_data_mov_intf.arburst=dut.IPS_CORE.S03_AXI_1_ARBURST;
    assign cdma_data_mov_intf.arvalid=dut.IPS_CORE.S03_AXI_1_ARVALID;
    assign cdma_data_mov_intf.arready=dut.IPS_CORE.S03_AXI_1_ARREADY;
    assign cdma_data_mov_intf.rdata=dut.IPS_CORE.S03_AXI_1_RDATA;
    assign cdma_data_mov_intf.rvalid=dut.IPS_CORE.S03_AXI_1_RVALID;
    assign cdma_data_mov_intf.rresp=dut.IPS_CORE.S03_AXI_1_RRESP;
    assign cdma_data_mov_intf.rready=dut.IPS_CORE.S03_AXI_1_RREADY;
    assign cdma_data_mov_intf.rlast=dut.IPS_CORE.S03_AXI_1_RLAST;
    assign cdma_data_mov_intf.arprot=dut.IPS_CORE.S03_AXI_1_ARPROT;
    assign cdma_data_mov_intf.arcache=dut.IPS_CORE.S03_AXI_1_ARCACHE;
    assign cdma_interrupt_intf.interrupt_out=dut.IPS_CORE.cdma_introut_0;

        //unused signals in axi cdma
    assign cdma_reg_intf.awid=0;
    assign cdma_reg_intf.awlen=0;
    assign cdma_reg_intf.awburst=0;
    assign cdma_reg_intf.awsize=0;
    assign cdma_reg_intf.awlock=0;
    assign cdma_reg_intf.awcache=0;
    assign cdma_reg_intf.awprot=0;
    assign cdma_reg_intf.awqos=0;
    assign cdma_reg_intf.awregion=0;
    assign cdma_reg_intf.bid=0;
    assign cdma_reg_intf.arid=0;
    assign cdma_reg_intf.rid=0;
    assign cdma_reg_intf.arlen=0;
    assign cdma_reg_intf.arsize=0;
    assign cdma_reg_intf.arlock=0;
    assign cdma_reg_intf.arcache=0;
    assign cdma_reg_intf.arprot=0;
    assign cdma_reg_intf.arregion=0;
    assign cdma_reg_intf.arqos=0;
    assign cdma_reg_intf.arburst=0;
    assign cdma_reg_intf.wstrobe=0;
    assign cdma_reg_intf.wlast=1;
    assign cdma_reg_intf.rlast=1;
    assign cdma_sg_intf.awid=0;
    assign cdma_sg_intf.bid=0;
    assign cdma_sg_intf.arid=0;

    assign cdma_data_mov_intf.arlock=0;
    assign cdma_data_mov_intf.awid=0;
    assign cdma_data_mov_intf.bid=0;
    assign cdma_data_mov_intf.arid=0;
    assign cdma_data_mov_intf.rid=0;
    assign cdma_sg_intf.rid=0;
    assign cdma_sg_intf.awlock=0;
    assign cdma_sg_intf.awqos=0;
    assign cdma_sg_intf.awregion=0;
    assign cdma_sg_intf.arqos= 0;  
    assign cdma_sg_intf.arregion=0;
    assign cdma_sg_intf.arlock=0;
    assign cdma_data_mov_intf.arqos=0;
    assign cdma_data_mov_intf.arregion=0;
    assign cdma_data_mov_intf.awqos=0;
    assign cdma_data_mov_intf.awregion=0;
    assign cdma_data_mov_intf.awlock=0;

    // BRAM MEMORY
    // CLK RESET
    assign axi4_bram_if.ACLK        = aclk;
    assign axi4_bram_if.ARESETn     = areset_n;
    // --- Write Address Channel (AW) ---
    assign axi4_bram_if.AWADDR   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awaddr;
    assign axi4_bram_if.AWBURST  = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awburst;
    assign axi4_bram_if.AWCACHE  = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awcache;
    assign axi4_bram_if.AWID     = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awid;
    assign axi4_bram_if.AWLEN    = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awlen;
    assign axi4_bram_if.AWLOCK   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awlock;
    assign axi4_bram_if.AWPROT   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awprot;
    assign axi4_bram_if.AWREADY  = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awready;
    assign axi4_bram_if.AWSIZE   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awsize;
    assign axi4_bram_if.AWVALID  = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awvalid;
    // --- Write Data Channel (W) ---
    assign axi4_bram_if.WDATA    = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wdata;
    assign axi4_bram_if.WLAST    = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wlast;
    assign axi4_bram_if.WREADY   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wready;
    assign axi4_bram_if.WSTRB    = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wstrb;
    assign axi4_bram_if.WVALID   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wvalid;
    // --- Write Response Channel (B) ---
    assign axi4_bram_if.BID      = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_bid;
    assign axi4_bram_if.BRESP    = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_bresp;
    assign axi4_bram_if.BVALID   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_bvalid;
    assign axi4_bram_if.BREADY   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_bready;
    
    // --- Read Address Channel (AR) ---
    assign axi4_bram_if.ARADDR   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_araddr;
    assign axi4_bram_if.ARBURST  = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_arburst;
    assign axi4_bram_if.ARCACHE  = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_arcache;
    assign axi4_bram_if.ARID     = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_arid;
    assign axi4_bram_if.ARLEN    = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_arlen;
    assign axi4_bram_if.ARLOCK   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_arlock;
    assign axi4_bram_if.ARPROT   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_arprot;
    assign axi4_bram_if.ARREADY  = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_arready;
    assign axi4_bram_if.ARSIZE   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_arsize;
    assign axi4_bram_if.ARVALID  = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_arvalid;
    // --- Read Data Channel (R) ---
    assign axi4_bram_if.RDATA    = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_rdata;
    assign axi4_bram_if.RID      = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_rid;
    assign axi4_bram_if.RLAST    = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_rlast;
    assign axi4_bram_if.RRESP    = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_rresp;
    assign axi4_bram_if.RVALID   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_rvalid;
    assign axi4_bram_if.RREADY   = dut.IPS_CORE.axi_bram_ctrl_0.s_axi_rready;

    // SLAVE_MEM 
    assign mem_intf.ACLK    = aclk;
    assign mem_intf.ARESETn = areset_n;

    // Lite Memory assignment
    assign mem_intf.ARADDR  = dut.AXI_SLAVE_MEM.s_axi_intf.ARADDR;   
    assign mem_intf.ARREADY = dut.AXI_SLAVE_MEM.s_axi_intf.ARREADY;  
    assign mem_intf.ARVALID = dut.AXI_SLAVE_MEM.s_axi_intf.ARVALID;
    assign mem_intf.AWADDR  = dut.AXI_SLAVE_MEM.s_axi_intf.AWADDR;   
    assign mem_intf.AWREADY = dut.AXI_SLAVE_MEM.s_axi_intf.AWREADY;  
    assign mem_intf.AWVALID = dut.AXI_SLAVE_MEM.s_axi_intf.AWVALID; 
    assign mem_intf.BREADY  = dut.AXI_SLAVE_MEM.s_axi_intf.BREADY;   
    assign mem_intf.BRESP   = dut.AXI_SLAVE_MEM.s_axi_intf.BRESP;    
    assign mem_intf.BVALID  = dut.AXI_SLAVE_MEM.s_axi_intf.BVALID;   
    assign mem_intf.RDATA   = dut.AXI_SLAVE_MEM.s_axi_intf.RDATA;    
    assign mem_intf.RREADY  = dut.AXI_SLAVE_MEM.s_axi_intf.RREADY;   
    assign mem_intf.RRESP   = dut.AXI_SLAVE_MEM.s_axi_intf.RRESP;    
    assign mem_intf.RVALID  = dut.AXI_SLAVE_MEM.s_axi_intf.RVALID;   
    assign mem_intf.WDATA   = dut.AXI_SLAVE_MEM.s_axi_intf.WDATA;    
    assign mem_intf.WREADY  = dut.AXI_SLAVE_MEM.s_axi_intf.WREADY;   
    assign mem_intf.WSTRB   = dut.AXI_SLAVE_MEM.s_axi_intf.WSTRB;    
    assign mem_intf.WVALID  = dut.AXI_SLAVE_MEM.s_axi_intf.WVALID;   

    initial begin
        //run_test("load_bram_256_test");             //find the interconnect issue
        //run_test("core_perif_master_test");
        //run_test("spi_write_data_test");
        //run_test("perif_gap_interconnect_test");
        //run_test("interconnect_gaps_test");
        //run_test("gap_pre_system_test");
        //run_test("uart_write_data_test");         //`SET_CPU_FORK_DISABLE(1) in test
        //run_test("perif_reg_read_test");          //`SET_CPU_FORK_DISABLE(1) in test
        //run_test("cdma_boundary_check_test");
        //run_test("intc_sw_irq_test");
        //run_test("intc_reg_write_read_test");
        //run_test("cdma_reg_write_read_test");
        //run_test("reg_read_test");
        //run_test("soc_master_test");
        run_test("bram_address_range_test");
        //run_test("bram_upper_invalid_addr_test");
        //run_test("bram_lower_invalid_addr_test");
        //run_test("bram_multiple_write_read_test");
        //run_test("config_cdma_ral_test");
        //run_test("cpu_base_test");
        //run_test("cdma_wr_rd_test");
        //run_test("mem_wr_rd_test");
        //run_test("cdma_sg_test");
    end

    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end
    initial begin
        areset_n = 0;
        repeat(16)@(posedge aclk);
        areset_n = 1;
        //#3000;
        //$finish();
    end
    // checking b channel by bypassing the interconnect
    // find why interconnect not passign these signals
    //initial begin
    //    force slave_if.BID      = dut.IPS_CORE.axi_interconnect_0_M03_AXI_BID;
    //    force slave_if.BVALID   = dut.IPS_CORE.axi_interconnect_0_M03_AXI_BVALID;
    //    force slave_if.BREADY   = dut.IPS_CORE.axi_interconnect_0_M03_AXI_BREADY;
    //    force slave_if.BRESP    = dut.IPS_CORE.axi_interconnect_0_M03_AXI_BRESP;
    //end

    always @(posedge aclk) begin
        if (dut.IPS_CORE.axi_interconnect_0_M03_AXI_AWVALID && dut.IPS_CORE.axi_interconnect_0_M03_AXI_AWREADY)
        $display("%t M03 AWID=%b (width %0d)", $time, dut.IPS_CORE.axi_interconnect_0_M03_AXI_AWID, $bits(dut.IPS_CORE.axi_interconnect_0_M03_AXI_AWID));
        if (dut.IPS_CORE.axi_interconnect_0_M03_AXI_BVALID && dut.IPS_CORE.axi_interconnect_0_M03_AXI_BREADY)
        $display("%t M03 BID=%b", $time, dut.IPS_CORE.axi_interconnect_0_M03_AXI_BID);
    end

    initial begin
    	uvm_config_db#(virtual axi4_lite_tb_intf)::set(null,"*","CP_MON",core_perif_if);
    	//uvm_config_db#(virtual axi4_lite_tb_intf.MONITOR_MOD)::set(null,"*","MON",mem_intf);
    	//uvm_config_db#(virtual axi4_tb_intf.MONITOR_MOD)::set(null,"*","BRAM_MON",axi4_bram_if);
    	uvm_config_db#(virtual axi4_tb_intf.DRIVER_MOD)::set(null,"*","S04",slave_if);
    	uvm_config_db#(virtual axi4_tb_intf.MONITOR_MOD)::set(null,"*","S04_MON",slave_if);
    end

    //initial begin
    //	uvm_config_db#(virtual spi_intf.SPI_MON)::set(null,"*","SPI_MON",spi_if);
    //end
   
    initial begin
        //$value$plusargs("DISABLE_CPU_FORK=%b", disable_cpu_fork);

    `ifdef SBD_COMPONENTS
        sb_config sb_cfg;
        sb_cfg = sb_config::type_id::create("sb_cfg");
        sb_cfg.perif_addr    = new[8];
        sb_cfg.perif_addr[0] = '{BRAM, BRAM_BASE, BRAM_END};
        sb_cfg.perif_addr[1] = '{LITE_MEM, LITE_MEM_BASE, LITE_MEM_END};
        sb_cfg.perif_addr[2] = '{CDMA, CDMA_BASE, CDMA_END};
        sb_cfg.perif_addr[3] = '{INTC, INTC_BASE, INTC_END};
        sb_cfg.perif_addr[4] = '{CORE_INTC, IRQ_BASE, IRQ_END};
        sb_cfg.perif_addr[5] = '{UART, UART_BASE, UART_END};
        sb_cfg.perif_addr[6] = '{SPI, SPI_BASE, SPI_END};
        sb_cfg.perif_addr[7] = '{GPIO, GPIO_BASE, GPIO_END};
	    uvm_config_db #(sb_config)::set(null,"*","SB_CFG",sb_cfg);
    `endif
        //sb_cfg.perif_addr[0] = '{BRAM, 32'h7100_0000, 32'h713F_FFFF};
        //sb_cfg.perif_addr[1] = '{LITE_MEM, 32'h8000_0000, 32'h9FFF_FFFF};
        //sb_cfg.perif_addr[2] = '{CDMA, 32'h7000_0000, 32'h7000_0FFF};
        //sb_cfg.perif_addr[3] = '{INTC, 32'h7000_1000, 32'h7000_1FFF};
        //sb_cfg.perif_addr[4] = '{CORE_PERIF, 32'hA000_0000, 32'hBFFF_FFFF};
    end

    soc_config     soc_config_obj;
    
    initial begin
        //soc_config
        soc_config_obj=soc_config::type_id::create("soc_config_obj");

        //INTC
        soc_config_obj.intc_obj = intc_config_obj::type_id::create("intc_obj");
        soc_config_obj.intc_obj.axi_lite_is_active  =   UVM_PASSIVE;
        soc_config_obj.intc_obj.lite_intc_intf      =   lite_intc_if;
        soc_config_obj.intc_obj.intc_is_active      =   UVM_PASSIVE;
        soc_config_obj.intc_obj.intc_if             =   intc_if;
        uvm_config_db #(intc_config_obj)::set(null,"*","intc_config_obj",soc_config_obj.intc_obj);

        //CPU
        soc_config_obj.cpu_obj = cpu_config_obj :: type_id :: create ("obj");
        soc_config_obj.cpu_obj.no_of_masters  = 2;
        soc_config_obj.cpu_obj.cpu_i    = new[2];
        soc_config_obj.cpu_obj.cpu_i[0] = axil_riscv_if[0];     // S00
        soc_config_obj.cpu_obj.cpu_i[1] = axil_riscv_if[1];     // S02
        soc_config_obj.cpu_obj.mas_is_active = 1;        // agent active
        uvm_config_db #(cpu_config_obj)::set(null,"*","cpu_config_obj",soc_config_obj.cpu_obj);

        //Lite MEM - BRAM
        soc_config_obj.mem_obj = mem_config_obj :: type_id :: create ("mem_obj");
        soc_config_obj.mem_obj.mem_intf         = mem_intf;
        soc_config_obj.mem_obj.bram_intf        = axi4_bram_if;
        soc_config_obj.mem_obj.mem_is_active    = UVM_PASSIVE;
        soc_config_obj.mem_obj.bram_is_active   = UVM_PASSIVE;
        uvm_config_db #(mem_config_obj)::set(null,"*","mem_config_obj",soc_config_obj.mem_obj);

        //CDMA
        soc_config_obj.cdma_config_obj=axi_cdma_config_obj::type_id::create("cdma_config_obj");
        soc_config_obj.cdma_config_obj.no_of_masters=1;
        soc_config_obj.cdma_config_obj.no_of_slaves=2;
        soc_config_obj.cdma_config_obj.enable_scoreboard=0;

        soc_config_obj.cdma_config_obj.mas_if=new[1];
        soc_config_obj.cdma_config_obj.mas_if[0]=cdma_reg_intf;

        soc_config_obj.cdma_config_obj.slv_if=new[2];
        soc_config_obj.cdma_config_obj.slv_if[0]=cdma_sg_intf;
        soc_config_obj.cdma_config_obj.slv_if[1]=cdma_data_mov_intf;

        soc_config_obj.cdma_config_obj.intrpt_if=cdma_interrupt_intf;

        soc_config_obj.cdma_config_obj.mas_is_active=new[1];
        soc_config_obj.cdma_config_obj.mas_is_active='{1{UVM_PASSIVE}};

        soc_config_obj.cdma_config_obj.slv_is_active=new[2];
        soc_config_obj.cdma_config_obj.slv_is_active='{2{UVM_PASSIVE}};

        uvm_config_db#(axi_cdma_config_obj)::set(null,"*","axi_cdma_config_obj",soc_config_obj.cdma_config_obj);
    end
    //BRAM MEMORY
    /*
    initial begin
        // 1. Wait for system reset to clear completely
        @(posedge aclk);
        while (dut.IPS_CORE.axi_bram_ctrl_0.s_axi_aresetn == 0) @(posedge aclk);
        
        $display("[TB_BURST_WRITE] Forcefully driving 256-Byte Burst Write to BRAM...");
    
        // 2. FORCE Drive the Address Channel 
        @(posedge aclk);
        force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awaddr   = 'h7100_0000;
        force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awvalid  = 1'b1;
        force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awlen    = 8'h3F;   // 64 beats
        force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awsize   = 3'b010;  // 32-bit bus
        force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awburst  = 2'b01;   // INCR
    
        // 3. Wait for the Slave to accept the command address, then RELEASE valid
        fork
            begin
                do
                    @(posedge aclk);
                while (dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awready === 0);
                force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awvalid = 1'b0;
            end
        join_none
    
        // 4. Drive the 64 Write Data Beats sequentially using force
        for (int beat = 0; beat < 64; beat++) begin
            force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wdata   = $urandom;
            force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wstrb   = 4'b1111;
            force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wvalid  = 1'b1;
            
            if (beat == 63) begin
                force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wlast = 1'b1;
            end else begin
                force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wlast = 1'b0;
            end
    
            // Wait for handshake
            do
                @(posedge aclk);
            while (dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wready === 0);
        end
    
        // 5. Clear the Data Channel signals after the final beat completes
        force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wvalid = 1'b0;
        force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_wlast  = 1'b0;
    
        // 6. Catch the Write Response acknowledgment (B Channel)
        $display("[TB_BURST_WRITE] Data stream finished. Waiting for Write Response...");
        do
            @(posedge aclk);
        while (dut.IPS_CORE.axi_bram_ctrl_0.s_axi_bvalid === 0);
        
        force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_bready = 1'b1;
        @(posedge aclk);
        force dut.IPS_CORE.axi_bram_ctrl_0.s_axi_bready = 1'b0;
        
        // Release all driven nets to prevent bus locking
        release dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awaddr;
        release dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awlen;
        release dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awburst;
        release dut.IPS_CORE.axi_bram_ctrl_0.s_axi_awsize;
        
        $display("[TB_BURST_WRITE] SUCCESS: 256 Bytes processed cleanly!");
        $finish();
    end
*/
endmodule
