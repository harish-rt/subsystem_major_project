`timescale 1ns/1ps
//`include "env_pkg.sv"
`include "master_interface.sv"
`include "slave_interface.sv"
`include "uart_slaveP_intf.sv"
`include "uart_slaveA_intf.sv"
`include "dist_intf.sv"
`include "ip_intf.sv"

module top;
   `include "uvm_macros.svh"
   import uvm_pkg::*;
//   import env_pkg::*;
   config_obj obj;
   //GLOBAL SIGNALS DECLARATION
   reg clk_i;
   reg rst_i;

   master_interface m_if1(.clk_i(clk_i), .rst_i(rst_i));
   master_interface m_if2(.clk_i(clk_i), .rst_i(rst_i));
   master_interface m_if3(.clk_i(clk_i), .rst_i(rst_i));
   master_interface m_if4(.clk_i(clk_i), .rst_i(rst_i));
   slave_interface  s_if1(.clk_i(clk_i), .rst_i(rst_i));
   slave_interface  s_if2(.clk_i(clk_i), .rst_i(rst_i));
   slave_interface  s_if3(.clk_i(clk_i), .rst_i(rst_i));
   slave_interface  s_if4(.clk_i(clk_i), .rst_i(rst_i));
   slaveP_intf d_if(.clk_i(clk_i), .rst_i(rst_i));
   uart_Aslave_intf  a_if(.clk_i(clk_i), .rst_i(rst_i));
   uart_Pslave_intf  p_if(.clk_i(clk_i), .rst_i(rst_i));
   ip_intf i_if1(.clk_i(clk_i), .rst_i(rst_i));
   ip_intf i_if2(.clk_i(clk_i), .rst_i(rst_i));

   core_soc soc_DUT_master(
   			 .clk_i(clk_i),
			 .rst_i(rst_i),
           	 .inport_awvalid_i(m_if1.awvalid), 
		     .inport_awaddr_i(m_if1.awaddr),
             .inport_wvalid_i(m_if1.wvalid), 
		     .inport_wdata_i(m_if1.wdata), 
		     .inport_wstrb_i(m_if1.wstrb),
		     .inport_bready_i(m_if1.bready), 
		     .inport_arvalid_i(m_if1.arvalid), 
		     .inport_araddr_i(m_if1.araddr),
		     .inport_rready_i(m_if1.rready), 
		     .spi_miso_i(i_if1.spi_miso_i), 
		     .uart_rx_i(i_if1.uart_rx_i), 
		     .gpio_input_i(i_if1.gpio_input_i),
		     .ext1_cfg_awready_i(m_if2.awready), 
		     .ext1_cfg_wready_i(m_if2.wready), 
		     .ext1_cfg_bvalid_i(m_if2.bvalid),
		     .ext1_cfg_bresp_i(m_if2.bresp), 
		     .ext1_cfg_arready_i(m_if2.arready), 
		     .ext1_cfg_rvalid_i(m_if2.rvalid),
		     .ext1_cfg_rdata_i(m_if2.rdata), 
		     .ext1_cfg_rresp_i(m_if2.rresp), 
		     .ext1_irq_i(i_if1.ext1_irq_i),
		     .ext2_cfg_awready_i(m_if3.awready), 
		     .ext2_cfg_wready_i(m_if3.wready), 
		     .ext2_cfg_bvalid_i(m_if3.bvalid),
		     .ext2_cfg_bresp_i(m_if3.bresp), 
		     .ext2_cfg_arready_i(m_if3.arready), 
		     .ext2_cfg_rvalid_i(m_if3.rvalid),
		     .ext2_cfg_rdata_i(m_if3.rdata), 
		     .ext2_cfg_rresp_i(m_if3.rresp), 
		     .ext2_irq_i(i_if1.ext2_irq_i),
		     .ext3_cfg_awready_i(m_if4.awready), 
		     .ext3_cfg_wready_i(m_if4.wready), 
		     .ext3_cfg_bvalid_i(m_if4.bvalid),
		     .ext3_cfg_bresp_i(m_if4.bresp), 
		     .ext3_cfg_arready_i(m_if4.arready), 
		     .ext3_cfg_rvalid_i(m_if4.rvalid),
		     .ext3_cfg_rdata_i(m_if4.rdata), 
		     .ext3_cfg_rresp_i(m_if4.rresp), 
		     .ext3_irq_i(i_if1.ext3_irq_i),
		     .intr_o(i_if1.intr_o), 
		     .inport_awready_o(m_if1.awready), 
		     .inport_wready_o(m_if1.wready),
		     .inport_bresp_o(m_if1.bresp), 
		     .inport_arready_o(m_if1.arready), 
		     .inport_rvalid_o(m_if1.rvalid),
		     .inport_rdata_o(m_if1.rdata), 
		     .inport_rresp_o(m_if1.rresp), 
		     .spi_clk_o(i_if1.spi_clk_o), 
		     .spi_mosi_o(i_if1.spi_mosi_o), 
		     .spi_cs_o(i_if1.spi_cs_o), 
		     .uart_tx_o(i_if1.uart_tx_o), 
		     .gpio_output_o(i_if1.gpio_output_o),
		     .gpio_output_enable_o(i_if1.gpio_output_enable_o),
		     .ext1_cfg_awvalid_o(m_if2.awvalid), 
		     .ext1_cfg_awaddr_o(m_if2.awaddr), 
		     .ext1_cfg_wvalid_o(m_if2.wvalid),
		     .ext1_cfg_wdata_o(m_if2.wdata), 
		     .ext1_cfg_wstrb_o(m_if2.wstrb), 
		     .ext1_cfg_bready_o(m_if2.bready),
		     .ext1_cfg_arvalid_o(m_if2.arvalid), 
		     .ext1_cfg_araddr_o(m_if2.araddr), 
		     .ext1_cfg_rready_o(m_if2.rready),
		     .ext2_cfg_awvalid_o(m_if3.awvalid), 
		     .ext2_cfg_awaddr_o(m_if3.awaddr), 
		     .ext2_cfg_wvalid_o(m_if3.wvalid),
		     .ext2_cfg_wdata_o(m_if3.wdata), 
		     .ext2_cfg_wstrb_o(m_if3.wstrb), 
		     .ext2_cfg_bready_o(m_if3.bready),
		     .ext2_cfg_arvalid_o(m_if3.arvalid), 
		     .ext2_cfg_araddr_o(m_if3.araddr), 
		     .ext2_cfg_rready_o(m_if3.rready),
		     .ext3_cfg_awvalid_o(m_if4.awvalid), 
		     .ext3_cfg_awaddr_o(m_if4.awaddr), 
		     .ext3_cfg_wvalid_o(m_if4.wvalid),
		     .ext3_cfg_wdata_o(m_if4.wdata), 
		     .ext3_cfg_wstrb_o(m_if4.wstrb), 
		     .ext3_cfg_bready_o(m_if4.bready),
		     .ext3_cfg_arvalid_o(m_if4.arvalid), 
		     .ext3_cfg_araddr_o(m_if4.araddr), 
		     .ext3_cfg_rready_o(m_if4.rready)
		     );

   
core_soc soc_DUT_slave(
			 .clk_i(clk_i),
			 .rst_i(rst_i),
			 .inport_awvalid_i(s_if1.awvalid), 
		     .inport_awaddr_i(s_if1.awaddr),
           	 .inport_wvalid_i(s_if1.wvalid), 
		     .inport_wdata_i(s_if1.wdata), 
		     .inport_wstrb_i(s_if1.wstrb),
		     .inport_bready_i(s_if1.bready), 
		     .inport_arvalid_i(s_if1.arvalid), 
		     .inport_araddr_i(s_if1.araddr),
		     .inport_rready_i(s_if1.rready), 
		     .spi_miso_i(i_if2.spi_miso_i), 
		     .uart_rx_i(i_if2.uart_rx_i), 
		     .gpio_input_i(i_if2.gpio_input_i),
		     .ext1_cfg_awready_i(s_if2.awready), 
		     .ext1_cfg_wready_i(s_if2.wready), 
		     .ext1_cfg_bvalid_i(s_if2.bvalid),
		     .ext1_cfg_bresp_i(s_if2.bresp), 
		     .ext1_cfg_arready_i(s_if2.arready), 
		     .ext1_cfg_rvalid_i(s_if2.rvalid),
		     .ext1_cfg_rdata_i(s_if2.rdata), 
		     .ext1_cfg_rresp_i(s_if2.rresp), 
		     .ext1_irq_i(i_if2.ext1_irq_i),
		     .ext2_cfg_awready_i(s_if3.awready), 
		     .ext2_cfg_wready_i(s_if3.wready), 
		     .ext2_cfg_bvalid_i(s_if3.bvalid),
		     .ext2_cfg_bresp_i(s_if3.bresp), 
		     .ext2_cfg_arready_i(s_if3.arready), 
		     .ext2_cfg_rvalid_i(s_if3.rvalid),
		     .ext2_cfg_rdata_i(s_if3.rdata), 
		     .ext2_cfg_rresp_i(m_if3.rresp), 
		     .ext2_irq_i(i_if2.ext2_irq_i),
		     .ext3_cfg_awready_i(s_if4.awready), 
		     .ext3_cfg_wready_i(s_if4.wready), 
		     .ext3_cfg_bvalid_i(s_if4.bvalid),
		     .ext3_cfg_bresp_i(s_if4.bresp), 
		     .ext3_cfg_arready_i(s_if4.arready), 
		     .ext3_cfg_rvalid_i(s_if4.rvalid),
		     .ext3_cfg_rdata_i(s_if4.rdata), 
		     .ext3_cfg_rresp_i(s_if4.rresp), 
		     .ext3_irq_i(i_if2.ext3_irq_i),
		     .intr_o(i_if2.intr_o), 
		     .inport_awready_o(s_if1.awready), 
		     .inport_wready_o(s_if1.wready),
		     .inport_bresp_o(s_if1.bresp), 
		     .inport_arready_o(s_if1.arready), 
		     .inport_rvalid_o(s_if1.rvalid),
		     .inport_rdata_o(s_if1.rdata), 
		     .inport_rresp_o(s_if1.rresp), 
		     .spi_clk_o(i_if2.spi_clk_o), 
		     .spi_mosi_o(i_if2.spi_mosi_o), 
		     .spi_cs_o(i_if2.spi_cs_o), 
		     .uart_tx_o(i_if2.uart_tx_o), 
		     .gpio_output_o(i_if2.gpio_output_o),
		     .gpio_output_enable_o(i_if2.gpio_output_enable_o),
		     .ext1_cfg_awvalid_o(s_if2.awvalid), 
		     .ext1_cfg_awaddr_o(s_if2.awaddr), 
		     .ext1_cfg_wvalid_o(s_if2.wvalid),
		     .ext1_cfg_wdata_o(s_if2.wdata), 
		     .ext1_cfg_wstrb_o(s_if2.wstrb), 
		     .ext1_cfg_bready_o(s_if2.bready),
		     .ext1_cfg_arvalid_o(s_if2.arvalid), 
		     .ext1_cfg_araddr_o(s_if2.araddr), 
		     .ext1_cfg_rready_o(s_if2.rready),
		     .ext2_cfg_awvalid_o(s_if3.awvalid), 
		     .ext2_cfg_awaddr_o(s_if3.awaddr), 
		     .ext2_cfg_wvalid_o(s_if3.wvalid),
		     .ext2_cfg_wdata_o(s_if3.wdata), 
		     .ext2_cfg_wstrb_o(s_if3.wstrb), 
		     .ext2_cfg_bready_o(s_if3.bready),
		     .ext2_cfg_arvalid_o(s_if3.arvalid), 
		     .ext2_cfg_araddr_o(s_if3.araddr), 
		     .ext2_cfg_rready_o(s_if3.rready),
		     .ext3_cfg_awvalid_o(s_if4.awvalid), 
		     .ext3_cfg_awaddr_o(s_if4.awaddr), 
		     .ext3_cfg_wvalid_o(s_if4.wvalid),
		     .ext3_cfg_wdata_o(s_if4.wdata), 
		     .ext3_cfg_wstrb_o(s_if4.wstrb), 
		     .ext3_cfg_bready_o(s_if4.bready),
		     .ext3_cfg_arvalid_o(s_if4.arvalid), 
		     .ext3_cfg_araddr_o(s_if4.araddr), 
		     .ext3_cfg_rready_o(s_if4.rready)
		     );





//-------------------CLOCK GENERATION---------------------//   
   initial begin
      clk_i = 0;
      forever #10 clk_i = ~clk_i;
   end
   
//-------------------RESET GENERATION--------------------//
   initial begin
      repeat(10) @(posedge clk_i) rst_i = 0;
      @(posedge clk_i) rst_i = 1;
   end

//-------------------SETTING VIRTUAL INTERFACE------------------//

//   config_obj obj;
   int has_no_m_of_agents = 1;
   int has_no_s_of_agents = 4;
   
   initial begin
      obj = config_obj :: type_id :: create("obj");
  //    obj.is_active = UVM_ACTIVE;
  //    obj.s_if = new();
  //    obj.s_if = new();
  //    obj.p_if = new();
  //    obj.a_if = new();
 //     obj.m_if = m_if;
 //     obj.s_if = s_if;
 //     obj.p_if = p_if;
 //     obj.a_if = a_if;
      
  //    obj.m_obj = new[has_no_m_of_agents];
  //    obj.s_obj = new[has_no_s_of_agents];

   
//      foreach(obj.m_obj[i]) obj.obj[i].is_active = UVM_ACTIVE;

//      foreach(obj.s_obj[i]) begin
//         obj.s_obj[i].is_active = UVM_ACTIVE;
//         if(i==0 || i==1) obj.s_obj[i].is_active = UVM_PASSIVE;
//      end
   
      obj.has_no_m_of_agents = has_no_m_of_agents;
      obj.has_no_s_of_agents = has_no_s_of_agents;

      uvm_config_db#(config_obj) :: set(null,"*","config_obj",obj);

      run_test("soc_base_test");
   end

initial begin
   #100;
   $finish();
end

endmodule
