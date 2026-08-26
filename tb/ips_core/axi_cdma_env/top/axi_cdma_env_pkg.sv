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
`include "axi_cdma_master_intf.sv"
`include "axi_cdma_slave_intf.sv"
`include "../axi_cdma_interrupt_agent/axi_cdma_interrupt_interface.sv"
`include "cdma_reg_block.sv"
package axi_cdma_env_pkg;
 `include "uvm_macros.svh"
  import  uvm_pkg :: *;
  import axi_cdma_regblock_pkg::*;
 `include "axi_parameters.sv"
 `include "../axi_cdma_master_agent/axi_base_sequence_item.sv"
 `include "axi_cdma_config_obj.sv"

 `include "descriptor_seq_item.sv"
 `include "memory.sv"
 `include "axi_cdma_reg_seq_item.sv"
 `include "../axi_cdma_master_agent/master_seq_item.sv"
 `include "../axi_cdma_master_agent/master_sequence.sv"
 `include "axi_adopter.sv"
 `include "../axi_cdma_slave_agent/slave_seq_item.sv"
 `include "../axi_cdma_slave_agent/slave_sequencer.sv"
 `include "../axi_cdma_slave_agent/slave_sequence.sv"

`include "../axi_cdma_master_agent/master_driver.sv"
 
 `include "../axi_cdma_master_agent/master_monitor.sv"
 `include "../axi_cdma_master_agent/master_sequencer.sv"
 `include "../axi_cdma_master_agent/master_agent.sv"
 `include "../axi_cdma_slave_agent/slave_driver.sv"
 `include "../axi_cdma_slave_agent/slave_monitor.sv"
 `include "../axi_cdma_slave_agent/slave_agent.sv"
 `include "../axi_cdma_interrupt_agent/axi_cdma_interrupt_seq_item.sv"
 `include "../axi_cdma_interrupt_agent/axi_cdma_interrupt_monitor.sv"
 `include "../axi_cdma_interrupt_agent/axi_cdma_interrupt_agent.sv"
 `include "../axi_cdma_axi_env/axi_cdma_cov.sv"

 
 `include "axi_cdma_reg_seq.sv"
 `include "virtual_sequencer.sv"
 `include "virtual_sequence.sv"
 `include "../axi_cdma_axi_env/axi_cdma_scoreboard.sv"
 `include "../axi_cdma_axi_env/axi_cdma_env.sv"  
 `include "cdma_base_test.sv"


// function to decode slave_index from address
 //function int decode_slave_index(input address_t address);
 //automatic int slave_index = -1;
   // case(address[31:16]) //decode slave index
    //16'h44A0 : slave_index = 0;
    //16'h44A1 : slave_index = 1;
    //16'h44A2 : slave_index = 2;
    //16'h44A3 : slave_index = 3;
    //default  : `uvm_error("Scoreboard :: predict_slave_pkt","address_decoding_fail - unexpected_address")
    //endcase
   //return slave_index;
 //endfunction

// properties for assertions
  property valid_handshake(logic clk,reset_n,valid,ready);
  @(posedge clk) disable iff(!reset_n) valid && !(ready) |=> valid;
  endproperty
  property signal_stable(logic clk,reset_n,valid,ready, logic [255:0] signal);
  @(posedge clk) disable iff(!reset_n) valid && !(ready) |=> $stable(signal);
  endproperty

endpackage
