/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/package.sv                              */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2022                       */
/*                                                                        */
/* All Rights Reserved                                                    */
/*                                                                        */
/* NOTICE: All information contained herein is, and remains the           */
/* property of Raiton semiconductor PVT. LTD. and its suppliers           */
/* ,if any.  The intellectual and  technical concepts contained           */
/* herein  are proprietary to  Raiton  semiconductor  PVT. LTD.           */
/* they are protected  by trade secrets and / or copyright law.           */
/* Dissemination of this  information  or reproduction of  this           */
/* material or code is strictly forbidden unless  prior written           */
/* permission is obtained from Raiton semiconductor PVT. LTD.             */
/*                                                                        */
/* RAITON_COPYRIGHT_END                                                   */
`ifndef uvm_object_new
  `define uvm_object_new \
    function new (string name=""); \
      super.new(name); \
    endfunction : new
`endif

`ifndef uvm_component_new
  `define uvm_component_new \
    function new (string name="", uvm_component parent=null); \
      super.new(name, parent); \
    endfunction : new
`endif

`include "uvm_macros.svh"
`include "./axi_cdma_ral/axi_cdma_regblock_pkg.sv";
`include "./axi_cdma_interrupt_agent/axi_cdma_interrupt_interface.sv"

package axi_cdma_env_pkg;
  import uvm_pkg :: *;
  import axi_cdma_regblock_pkg :: *;

 `include "axi_cdma_axi_parameters.sv"
 `include "axi_cdma_axi_base_sequence_item.sv"
 `include "axi_cdma_axi_master_seq_item.sv"
 `include "axi_cdma_axi_slave_seq_item.sv"
 `include "axi_cdma_reg_seq_item.sv"
 `include "axi_cdma_descriptor_seq_item.sv"
 `include "axi_cdma_descriptor_mem.sv"
 `include "axi_cdma_config_obj.sv"

 `include "./axi_cdma_ral/axi_cdma_ral_adaptor.sv"

 `include "./axi_cdma_axi_master_agent/axi_cdma_axi_master_sequence.sv"

 `include "./axi_cdma_axi_slave_agent/axi_cdma_axi_slave_sequencer.sv"
 `include "./axi_cdma_axi_slave_agent/axi_cdma_axi_slave_sequence.sv"

 `include "./axi_cdma_axi_master_agent/axi_cdma_axi_master_driver.sv"
 `include "./axi_cdma_extended_callbacks.sv"

 `include "./axi_cdma_axi_master_agent/axi_cdma_axi_master_monitor.sv"
 `include "./axi_cdma_axi_master_agent/axi_cdma_axi_master_sequencer.sv"
 `include "./axi_cdma_axi_master_agent/axi_cdma_axi_master_agent.sv"

 `include "./axi_cdma_axi_slave_agent/axi_cdma_axi_slave_driver.sv"
 `include "./axi_cdma_axi_slave_agent/axi_cdma_axi_slave_monitor.sv"
 `include "./axi_cdma_axi_slave_agent/axi_cdma_axi_slave_agent.sv"

 `include "./axi_cdma_interrupt_agent/axi_cdma_interrupt_seq_item.sv"
 `include "./axi_cdma_interrupt_agent/axi_cdma_interrupt_monitor.sv"
 `include "./axi_cdma_interrupt_agent/axi_cdma_interrupt_agent.sv"

 `include "./axi_cdma_axi_env/axi_cdma_axi_coverage.sv"
 `include "./axi_cdma_axi_env/axi_cdma_axi_scoreboard.sv"

 //`include "axi_cdma_virtual_sequencer.sv"
 //`include "axi_cdma_virtual_sequence.sv"

 `include "./axi_cdma_axi_env/axi_cdma_axi_env.sv"

 `include "./axi_cdma_env/axi_cdma_coverage.sv"
 `include "./axi_cdma_env/axi_cdma_scoreboard.sv"
 `include "./axi_cdma_env/axi_cdma_env.sv"

// function to decode slave_index from address
 function int decode_slave_index(input address_t address);
 int slave_index;
    case(address[31:16]) //decode slave index
    16'h44A0 : slave_index = 0;
    16'h44A1 : slave_index = 1;
    16'h44A2 : slave_index = 2;
    16'h44A3 : slave_index = 3;
    default  : `uvm_error("Scoreboard :: predict_slave_pkt","address_decoding_fail - unexpected_address")
    endcase
   return slave_index;
 endfunction
// properties for assertions
  property valid_handshake(logic clk,reset_n,valid,ready);
  @(posedge clk) disable iff(!reset_n) valid && !(ready) |=> valid;
  endproperty
  property signal_stable(logic clk,reset_n,valid,ready, logic [255:0] signal);
  @(posedge clk) disable iff(!reset_n) valid && !(ready) |=> $stable(signal);
  endproperty

endpackage

`include "./axi_cdma_axi_master_intf.sv"
`include "./axi_cdma_axi_slave_intf.sv"
