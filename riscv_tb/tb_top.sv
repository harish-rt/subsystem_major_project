`timescale 1ns/1ps
`include "package.sv"
`include "core_wrapper_env/proc_agent/proc_intf.sv"
`include "uvm_macros.svh"
module top;
   import  uvm_pkg ::*;
   import  soc_package ::*;
  // Clock and Reset
    logic clk_i;
    logic rst_n_i;

  // AXI4 Interfaces
    axi4_intf ext_axi4_slave ();
    axi4_intf ext_axi4_master ();

    axi4_lite_intf inst_bridge2axi_int();	
    axi4_lite_intf data_bridge2axi_int();
    
    config_obj obj;
    cpu_intf   cpu_i(.aclk(clk_i),.areset_n(rst_n_i)); 

  core_wrapper dut (
    // Clock & Reset
    .clk_i              (clk_i),
    .rst_n_i            (rst_n_i),
    
    //SPI
    .spi_clk_o(),
    .spi_cs_o(),
    .spi_miso_i(),
    .spi_mosi_o(),

    //UART
    .uart_rx_i(),
    .uart_tx_o(),

    //GPIO
    .gpio_input_i(),
    .gpio_output_o(),
    .gpio_output_enable_o(),

    // EXT1 AXI-Lite
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

    // EXT2 AXI-Lite
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

    // EXT3 AXI-Lite
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

    // Additional ports
    .rsta_busy_0(),
    .rstb_busy_0(),

    // AXI4 Interfaces 
     .ext_axi4_slave (ext_axi4_slave),
     .ext_axi4_master (ext_axi4_master),
    //s00
    .inst_bridge2axi_int (inst_bridge2axi_int),
    //s02
    .data_bridge2axi_int (data_bridge2axi_int));

    // ---------------- Global ----------------
    assign inst_bridge2axi_int.ACLK    = cpu_i.aclk;
    assign inst_bridge2axi_int.ARESETn = cpu_i.areset_n;
    // ---------------- Read Channel ----------------
    assign inst_bridge2axi_int.ARADDR  = cpu_i.araddr;
    assign inst_bridge2axi_int.ARVALID = cpu_i.arvalid;
    assign inst_bridge2axi_int.ARREADY = cpu_i.arready;
    assign inst_bridge2axi_int.RDATA   = cpu_i.rdata;
    assign inst_bridge2axi_int.RRESP   = cpu_i.rresp;
    assign inst_bridge2axi_int.RVALID  = cpu_i.rvalid;
    assign inst_bridge2axi_int.RREADY  = cpu_i.rready;
    // ---------------- Write Channel ----------------
    assign inst_bridge2axi_int.AWADDR  = cpu_i.awaddr;
    assign inst_bridge2axi_int.AWVALID = cpu_i.awvalid;
    assign inst_bridge2axi_int.AWREADY = cpu_i.awready;
    assign inst_bridge2axi_int.WDATA   = cpu_i.wdata;
    assign inst_bridge2axi_int.WSTRB   = cpu_i.wstrobe;
    assign inst_bridge2axi_int.WVALID  = cpu_i.wvalid;
    assign inst_bridge2axi_int.WREADY  = cpu_i.wready;
    assign inst_bridge2axi_int.BRESP   = cpu_i.bresp;
    assign inst_bridge2axi_int.BVALID  = cpu_i.bvalid;
    assign inst_bridge2axi_int.BREADY  = cpu_i.bready;
    
 
//------------- CLOCK GENERATION --------------//
  initial begin
      clk_i = 0;
      forever #5 clk_i = ~clk_i;
   end

 // Reset
   initial begin
       rst_n_i = 0;
       #50 rst_n_i = 1;
   end
 initial begin
      obj = config_obj :: type_id :: create ("obj");
      obj.cpu_i  = cpu_i;
      obj.mas_is_active = 1;        // agent active
      uvm_config_db #(config_obj) :: set (null , "*" , "config_obj" , obj);
    end


initial begin
run_test("base_test");
end

endmodule
