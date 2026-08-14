`include "uvm_macros.svh"
import uvm_pkg :: *;

`include "../ips_core/axi_intc/lite_intc_interface.sv"
import soc_package :: *;

module top;

    bit clk;
    bit rst;

    wire axi_intr;
    wire axi_irq;

    axi4_intf master_if();
    axi4_intf slave_if();

    axi4_lite_intf lite_inst_if();
    axi4_lite_intf lite_data_if();	

// AXI Interrupt Controller
    lite_intc_interface lite_intc_intf(.aclk(clk),.areset_n(rst));

    core_wrapper dut(
        .clk_i(clk),
        .rst_n_i(rst),

        //peripherals
        .spi_clk_o(),
        .spi_cs_o(),
        .spi_miso_i(),
        .spi_mosi_o(),

        .uart_rx_i(),
        .uart_tx_o(),

        .gpio_input_i(),
        .gpio_output_o(),
        .gpio_output_enable_o(),

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

        .ext_axi4_master(master_if),
        .ext_axi4_slave(slave_if),

//instructions and data interfaces
        //S00
        .inst_bridge2axi_int(lite_inst_if),
        //S02
        .data_bridge2axi_int(lite_data_if)
    );

    //intr and irq inerfaces comes here
    assign axi_intr                 = dut.IPS_CORE.intr_0_1;
    assign axi_irq                  = dut.IPS_CORE.axi_intc_0_irq;    

    // =========================================================================
    // 1. Master Outputs (Driven by UVM TB into the Design Interconnect)
    // =========================================================================
    assign dut.IPS_CORE.axi_interconnect_0_M02_AXI_ARADDR   = lite_intc_intf.araddr;
    assign dut.IPS_CORE.axi_interconnect_0_M02_AXI_ARVALID  = lite_intc_intf.arvalid;
    assign dut.IPS_CORE.axi_interconnect_0_M02_AXI_AWADDR   = lite_intc_intf.awaddr;
    assign dut.IPS_CORE.axi_interconnect_0_M02_AXI_AWVALID  = lite_intc_intf.awvalid;
    assign dut.IPS_CORE.axi_interconnect_0_M02_AXI_BREADY   = lite_intc_intf.bready;
    assign dut.IPS_CORE.axi_interconnect_0_M02_AXI_RREADY   = lite_intc_intf.rready;
    assign dut.IPS_CORE.axi_interconnect_0_M02_AXI_WDATA    = lite_intc_intf.wdata;
    assign dut.IPS_CORE.axi_interconnect_0_M02_AXI_WSTRB    = lite_intc_intf.wstrb;
    assign dut.IPS_CORE.axi_interconnect_0_M02_AXI_WVALID   = lite_intc_intf.wvalid;

    // =========================================================================
    // 2. Slave Outputs (Driven by Design Interconnect back into the UVM TB)
    // =========================================================================
    assign lite_intc_intf.arready       = dut.IPS_CORE.axi_interconnect_0_M02_AXI_ARREADY;
    assign lite_intc_intf.awready       = dut.IPS_CORE.axi_interconnect_0_M02_AXI_AWREADY;
    assign lite_intc_intf.bresp         = dut.IPS_CORE.axi_interconnect_0_M02_AXI_BRESP;
    assign lite_intc_intf.bvalid        = dut.IPS_CORE.axi_interconnect_0_M02_AXI_BVALID;
    assign lite_intc_intf.rdata         = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RDATA;
    assign lite_intc_intf.rresp         = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RRESP;
    assign lite_intc_intf.rvalid        = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RVALID;
    assign lite_intc_intf.wready        = dut.IPS_CORE.axi_interconnect_0_M02_AXI_WREADY;

/*
    assign lite_intc_intf.araddr    = dut.IPS_CORE.axi_interconnect_0_M02_AXI_ARADDR;
    assign lite_intc_intf.arready   = dut.IPS_CORE.axi_interconnect_0_M02_AXI_ARREADY;
    assign lite_intc_intf.arvalid   = dut.IPS_CORE.axi_interconnect_0_M02_AXI_ARVALID;
    assign lite_intc_intf.awaddr    = dut.IPS_CORE.axi_interconnect_0_M02_AXI_AWADDR;
    assign lite_intc_intf.awready   = dut.IPS_CORE.axi_interconnect_0_M02_AXI_AWREADY;
    assign lite_intc_intf.awvalid   = dut.IPS_CORE.axi_interconnect_0_M02_AXI_AWVALID;
    assign lite_intc_intf.bready    = dut.IPS_CORE.axi_interconnect_0_M02_AXI_BREADY;
    assign lite_intc_intf.bresp     = dut.IPS_CORE.axi_interconnect_0_M02_AXI_BRESP;
    assign lite_intc_intf.bvalid    = dut.IPS_CORE.axi_interconnect_0_M02_AXI_BVALID;
    assign lite_intc_intf.rdata     = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RDATA;
    assign lite_intc_intf.rready    = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RREADY;
    assign lite_intc_intf.rresp     = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RRESP;
    assign lite_intc_intf.rvalid    = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RVALID;
    assign lite_intc_intf.wdata     = dut.IPS_CORE.axi_interconnect_0_M02_AXI_WDATA;
    assign lite_intc_intf.wready    = dut.IPS_CORE.axi_interconnect_0_M02_AXI_WREADY;
    assign lite_intc_intf.wstrb     = dut.IPS_CORE.axi_interconnect_0_M02_AXI_WSTRB;
    assign lite_intc_intf.wvalid    = dut.IPS_CORE.axi_interconnect_0_M02_AXI_WVALID;
*/

    initial begin
        run_test("lite_intc_read_test");
        //  run_test("base_test");
    end

    initial begin
        forever #5 clk = ~clk;
    end
    initial begin
        rst = 0;
        repeat(16)@(posedge clk);
        rst = 1;
        //#1000;
        //$finish();
    end

    intc_config_obj             obj;
    
    initial begin
        obj = intc_config_obj::type_id::create("obj");
        obj.lite_intc_active    = UVM_ACTIVE;
        obj.intr_active         = UVM_ACTIVE;
        uvm_config_db #(intc_config_obj)::set(null,"*","config_obj",obj);
    end
    initial begin
        uvm_config_db #(virtual lite_intc_interface)::set(null,"*","lite_intc_if",lite_intc_intf);
    end
endmodule
