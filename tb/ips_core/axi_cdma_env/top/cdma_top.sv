`include "uvm_pkg.sv"
`include "reg_block.sv"
`include "package.sv"
`timescale 1ns/1ps
`include "master_intf.sv"
`include "slave_intf.sv"
`include "../axi_cdma_interrupt_agent/axi_cdma_interrupt_interface.sv"
`include "uvm_macros.svh"

module top;
import  uvm_pkg :: *;
import  axi_package :: *;
   
   reg                   aclk;
   reg                   areset_n;
   reg                   s_clk,m_clk;

      // Instantiate AXI_CDMA Design

  /*design_1_wrapper DUT (
                       
                              //gobal signals
                            .cdma_introut_0(m_axi_lite_if.cdma_introut),
                            .m_axi_aclk_0(m_clk),
                            .s_axi_lite_aclk_0(s_clk),
                            .s_axi_lite_aresetn_0(areset_n),

                             //slave interface signals   
                            .M_AXI_0_araddr(s_axi_if .araddr),
                            .M_AXI_0_arburst(s_axi_if .arburst),
                            .M_AXI_0_arcache(s_axi_if .arcache),
                            .M_AXI_0_arlen(s_axi_if .arlen),
                            .M_AXI_0_arprot(s_axi_if .arprot),
                            .M_AXI_0_arready(s_axi_if .arready),
                            .M_AXI_0_arsize(s_axi_if .arsize),
                            .M_AXI_0_arvalid(s_axi_if .arvalid),
                            .M_AXI_0_awaddr(s_axi_if .awaddr),
                            .M_AXI_0_awburst(s_axi_if .awburst),
                            .M_AXI_0_awcache(s_axi_if .awcache),
                            .M_AXI_0_awlen(s_axi_if .awlen),
                            .M_AXI_0_awprot(s_axi_if .awprot),
                            .M_AXI_0_awready(s_axi_if .awready),
                            .M_AXI_0_awsize(s_axi_if .awsize),
                            .M_AXI_0_awvalid(s_axi_if .awvalid),
                            .M_AXI_0_bready(s_axi_if .bready),
                            .M_AXI_0_bresp(s_axi_if .bresp),
                            .M_AXI_0_bvalid(s_axi_if .bvalid),
                            .M_AXI_0_rdata(s_axi_if .rdata[127:0]),
                            .M_AXI_0_rlast(s_axi_if .rlast),
                            .M_AXI_0_rready(s_axi_if .rready),
                            .M_AXI_0_rresp(s_axi_if .rresp),
                            .M_AXI_0_rvalid(s_axi_if .rvalid),
                            .M_AXI_0_wdata(s_axi_if .wdata[127:0]),
                            .M_AXI_0_wlast(s_axi_if .wlast),
                            .M_AXI_0_wready(s_axi_if .wready),
                            .M_AXI_0_wstrb(s_axi_if .wstrobe[15:0]),
                            .M_AXI_0_wvalid(s_axi_if .wvalid),
        
                            //sg slave interface signals
     .M_AXI_SG_0_araddr(s_axi_sg_if.araddr),
     .M_AXI_SG_0_arburst(s_axi_sg_if.arburst),
    .M_AXI_SG_0_arcache(s_axi_sg_if .arcache),
    .M_AXI_SG_0_arlen(s_axi_sg_if .arlen),
    .M_AXI_SG_0_arprot(s_axi_sg_if .arprot),
    .M_AXI_SG_0_arready(s_axi_sg_if .arready),
    .M_AXI_SG_0_arsize(s_axi_sg_if .arsize),
    .M_AXI_SG_0_arvalid(s_axi_sg_if .arvalid),
    .M_AXI_SG_0_awaddr(s_axi_sg_if .awaddr),
    .M_AXI_SG_0_awburst(s_axi_sg_if .awburst),
    .M_AXI_SG_0_awcache(s_axi_sg_if .awcache),
    .M_AXI_SG_0_awlen(s_axi_sg_if .awlen),
    .M_AXI_SG_0_awprot(s_axi_sg_if .awprot),
    .M_AXI_SG_0_awready(s_axi_sg_if .awready),
    .M_AXI_SG_0_awsize(s_axi_sg_if .awsize),
    .M_AXI_SG_0_awvalid(s_axi_sg_if .awvalid),
    .M_AXI_SG_0_bready(s_axi_sg_if .bready),
    .M_AXI_SG_0_bresp(s_axi_sg_if .bresp),
    .M_AXI_SG_0_bvalid(s_axi_sg_if .bvalid),
    .M_AXI_SG_0_rdata(s_axi_sg_if .rdata[31:0]),
    .M_AXI_SG_0_rlast(s_axi_sg_if .rlast),
    .M_AXI_SG_0_rready(s_axi_sg_if .rready),
    .M_AXI_SG_0_rresp(s_axi_sg_if .rresp),
    .M_AXI_SG_0_rvalid(s_axi_sg_if .rvalid),
    .M_AXI_SG_0_wdata(s_axi_sg_if .wdata[31:0]),
    .M_AXI_SG_0_wlast(s_axi_sg_if .wlast),
    .M_AXI_SG_0_wready(s_axi_sg_if .wready),
    .M_AXI_SG_0_wstrb(s_axi_sg_if .wstrobe[3:0]),
    .M_AXI_SG_0_wvalid(s_axi_sg_if .wvalid),


    //lite interface signals
    .S_AXI_LITE_0_araddr(m_axi_lite_if .araddr[5:0]),
    .S_AXI_LITE_0_arready(m_axi_lite_if .arready),
    .S_AXI_LITE_0_arvalid(m_axi_lite_if .arvalid),
    .S_AXI_LITE_0_awaddr(m_axi_lite_if .awaddr[5:0]),
    .S_AXI_LITE_0_awready(m_axi_lite_if .awready),
    .S_AXI_LITE_0_awvalid(m_axi_lite_if .awvalid),
    .S_AXI_LITE_0_bready(m_axi_lite_if .bready),
    .S_AXI_LITE_0_bresp(m_axi_lite_if .bresp),
    .S_AXI_LITE_0_bvalid(m_axi_lite_if .bvalid),
    .S_AXI_LITE_0_rdata(m_axi_lite_if .rdata[31:0]),
    .S_AXI_LITE_0_rready(m_axi_lite_if .rready),
    .S_AXI_LITE_0_rresp(m_axi_lite_if .rresp),
    .S_AXI_LITE_0_rvalid(m_axi_lite_if .rvalid),
    .S_AXI_LITE_0_wdata(m_axi_lite_if .wdata[31:0]),
    .S_AXI_LITE_0_wready(m_axi_lite_if .wready),
    .S_AXI_LITE_0_wvalid(m_axi_lite_if.wvalid));*/


//------------- CLOCK GENERATION --------------//
   initial begin
      aclk = 0;
      forever #5 aclk = ~aclk;
   end
  initial begin
      m_clk = 0;
      forever #5 m_clk = ~m_clk;
   end
initial begin
      s_clk = 0;
      forever #5 s_clk = ~s_clk;
   end
//RESET CONDITION
  initial begin
      areset_n = 0;
      #200 areset_n = 1;
   end
  // Interface
   axi_cdma_master_intf  m_axi_lite_if (.aclk(m_clk),  .areset_n(areset_n));
   axi_cdma_slave_intf   s_axi_sg_if (.aclk(s_clk), .areset_n(areset_n));
   axi_cdma_slave_intf   s_axi_if (.aclk(s_clk), .areset_n(areset_n));
   axi_cdma_interrupt_intf interrupt_intf(.aclk(aclk));


      axi_cdma_config_obj obj;
    initial begin
      //total_trans=new[4]; //set no of txns for each master
      obj = axi_cdma_config_obj :: type_id :: create ("obj");
      obj.mas_if         = new[1];
      obj.slv_if         = new[2];
      obj.mas_if[0]      = m_axi_lite_if;
      obj.slv_if[0]      = s_axi_sg_if;
      obj.slv_if[1]      = s_axi_if;
      obj.no_of_masters=1;
      obj.no_of_slaves =2;
      obj.mas_is_active= new[1];
      obj.mas_is_active = '{1{UVM_ACTIVE}};//set agent active/passive
      obj.slv_is_active= new[2];
      obj.slv_is_active = '{2{UVM_ACTIVE}};//set agent active/passive
      obj.intr_intf=interrupt_intf;
      uvm_config_db #(axi_cdma_config_obj) :: set (null , "*" , "axi_cdma_config_obj" , obj);
    end
    initial begin
   
              run_test ("cdma_base_test");
              //run_test("ral_reset_test");
              //run_test("ral_reset_inter_test");
              //run_test("bit_bash_test");
              //run_test("config_sa_test");
              //run_test("cdma_reg_access_test");
              //run_test("btt_1_test");
              //run_test("btt_16_test");
              //run_test("btt_16_test1");
              //run_test("simple_mode_inc_4k_test");
              //run_test("simple_mode_inc_4kcross_test");
              //run_test("simple_mode_fixed_4ktest");
              //run_test("simple_mode_inc_test");
              //run_test("keyhole_read_inc_write_test");
              //run_test("keyhole_write_test");
              //run_test("keyhole_rd_wr_test");
              //run_test("slave_err_test");
              //run_test("slave_error_test");
              //run_test("decode_err_test");
              //run_test("dma_decode_err_test");
              //run_test("dma_internal_err_test");
              //run_test("unaligned_test");
              //run_test("multiple_transfer_test");
              //run_test("soft_reset_test");
              //run_test("random_test");
              //run_test("max_btt_test");
              //run_test("multiple_trans_test");
              //run_test("fixed_trans_test");
              
/////////////////////SGMODE TESTCASES//////////////
              //run_test("sg_mode_test");
              //run_test("sg_mode_random_test");
              //run_test("sg_mode_fixed_rd_inc_wr_test");
              //run_test("sg_inc_read_fixed_wr_test");
              //run_test("sg_fixed_rd_wr_test");
              //run_test("dly_interrupt_test");
              //run_test("sg_internal_err_test");
              //run_test("sg_decode_err_test");
              //run_test("sg_decode_error_test");
              //run_test("sg_slave_error_test");
              //run_test("sg_slave_err_test");
              //run_test("sg_dma_internal_error_test");
              //run_test("sg_dma_slave_err_test");
              //run_test("sg_dma_slave_error_test");
              //run_test("sg_dma_decode_error_test");
              //run_test("sg_dma_decode_err_test");
              //run_test("sg_threshold_interrupt_test");
               //run_test("cyclic_bd_test");
               //run_test("multiple_sg_mode_trans_test");
              //run_test("sbd_verify_test");
     end

    //write address channel
   assign m_axi_lite_if.awid     = 0;
   assign m_axi_lite_if.awlen    = 0;
   assign m_axi_lite_if.awsize   = 0;
    
   assign m_axi_lite_if.awlock   = 0;
   assign m_axi_lite_if.awprot   = 0;
   assign m_axi_lite_if.awqos    = 0;
   assign m_axi_lite_if.awregion = 0;
   assign m_axi_lite_if.awcache  = 0;
    
   assign m_axi_lite_if.bid      = 0;
  
   assign m_axi_lite_if.wlast    = 1;
    
   assign m_axi_lite_if.arid     = 0;
   assign m_axi_lite_if.arlen    = 0;
   assign m_axi_lite_if.arsize   = 0;
   
   assign m_axi_lite_if.arlock   = 0;
   assign m_axi_lite_if.arprot   = 0;
   assign m_axi_lite_if.arqos    = 0;
   assign m_axi_lite_if.arregion = 0;
   assign m_axi_lite_if.arcache  = 0;
   
   assign m_axi_lite_if.rid      = 0;
   assign m_axi_lite_if.rlast    = 1;
   assign m_axi_lite_if.rdata[255:32]=0;
    
   assign s_axi_if.arid=0;
   assign s_axi_if.awid=0;

   assign  s_axi_sg_if.arid=0;
   assign  s_axi_sg_if.awid=0;
endmodule:top


