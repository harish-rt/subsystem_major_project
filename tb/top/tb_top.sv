`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg :: *;

`include "../ips_core/axi_intc/lite_intc_interface.sv"
`include "../ips_core/axi_intc/intc_interface.sv"
import soc_package :: *;

module top;

    bit aclk;
    bit areset_n;

    wire axi_intr;
    wire axi_irq;

    axi4_intf master_if();
    axi4_intf slave_if();

    axi4_lite_intf lite_inst_if();
    axi4_lite_intf lite_data_if();

// AXI Interrupt Controller
    axi4_lite_intc_intf lite_intc_if(.aclk(aclk),.areset_n(areset_n));
    intc_intf           intc_if(.intc_procss_clk(aclk),.intc_procss_rst(areset_n));

    core_wrapper dut(
        .clk_i(aclk),
        .rst_n_i(areset_n),

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

    assign lite_intc_if.axi_araddr  = dut.IPS_CORE.axi_interconnect_0_M02_AXI_ARADDR;
    assign lite_intc_if.axi_arready = dut.IPS_CORE.axi_interconnect_0_M02_AXI_ARREADY;
    assign lite_intc_if.axi_arvalid = dut.IPS_CORE.axi_interconnect_0_M02_AXI_ARVALID;
    assign lite_intc_if.axi_awaddr  = dut.IPS_CORE.axi_interconnect_0_M02_AXI_AWADDR;
    assign lite_intc_if.axi_awready = dut.IPS_CORE.axi_interconnect_0_M02_AXI_AWREADY;
    assign lite_intc_if.axi_awvalid = dut.IPS_CORE.axi_interconnect_0_M02_AXI_AWVALID;
    assign lite_intc_if.axi_bready  = dut.IPS_CORE.axi_interconnect_0_M02_AXI_BREADY;
    assign lite_intc_if.axi_bresp   = dut.IPS_CORE.axi_interconnect_0_M02_AXI_BRESP;
    assign lite_intc_if.axi_bvalid  = dut.IPS_CORE.axi_interconnect_0_M02_AXI_BVALID;
    assign lite_intc_if.axi_rdata   = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RDATA;
    assign lite_intc_if.axi_rready  = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RREADY;
    assign lite_intc_if.axi_rresp   = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RRESP;
    assign lite_intc_if.axi_rvalid  = dut.IPS_CORE.axi_interconnect_0_M02_AXI_RVALID;
    assign lite_intc_if.axi_wdata   = dut.IPS_CORE.axi_interconnect_0_M02_AXI_WDATA;
    assign lite_intc_if.axi_wready  = dut.IPS_CORE.axi_interconnect_0_M02_AXI_WREADY;
    assign lite_intc_if.axi_wstrb   = dut.IPS_CORE.axi_interconnect_0_M02_AXI_WSTRB;
    assign lite_intc_if.axi_wvalid  = dut.IPS_CORE.axi_interconnect_0_M02_AXI_WVALID;

    assign intc_if.intc_irq         = dut.intr_ctrl_irq;
    assign intc_if.intc_intr        = dut.intr_0;

    initial begin
        run_test("base_test");
    end

    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk;
    end
    initial begin
        areset_n = 0;
        repeat(16)@(posedge aclk);
        areset_n = 1;
        #3000;
        $finish();
    end

    intc_config_obj                 obj;
    
    initial begin
        obj                     =   new("obj");
        obj.axi_lite_is_active  =   UVM_PASSIVE;
        obj.intc_is_active      =   UVM_PASSIVE;
        obj.lite_intc_intf      =   lite_intc_if;
        obj.intc_if             =   intc_if;
        uvm_config_db #(intc_config_obj)::set(null,"*","config_obj",obj);
    end
endmodule
