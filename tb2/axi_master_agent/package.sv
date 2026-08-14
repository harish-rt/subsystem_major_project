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
`ifndef AXI_PACKAGE
`define AXI_PACKAGE
package axi_package;
   import  uvm_pkg :: *;
   `include "uvm_macros.svh"

  
  typedef logic [6:0]       id_t;
typedef logic [31:0]      address_t;
typedef logic [0:0]       valid_t;
typedef logic [0:0]       ready_t;
typedef logic [7:0]       burst_len_t;
typedef logic [2:0]       burst_size_t;
typedef logic [255:0]     data_t;
typedef logic [31:0]      strobe_t;
typedef logic [0:0]       last_t;
typedef logic [3:0]       region_t;
typedef logic [3:0]       cache_t;
typedef logic [2:0]       prot_t;
typedef logic [3:0]       qos_t;
typedef logic [0:0]       lock_t;

parameter ID_WIDTH = 7;
parameter ADDR_WIDTH = 32;
parameter BURST_LENGTH = 8;
parameter BURST_SIZE = 3;
parameter DATA_WIDTH = 32;
parameter STROBE_WIDTH = 4;
parameter REGION_WIDTH = 4;
parameter CACHE_WIDTH = 4;
parameter PROT_WIDTH = 3;
parameter QOS_WIDTH = 4;


typedef enum {FIXED,INCR,WRAP}              burst_type_t;
typedef enum {OKAY,EXOKAY,SLVERR,DECERR}    response_t;
typedef enum {WRITE,READ}                   command_t;
typedef int  delay_t;
typedef enum {NO_RESET,RESET_ASSERTED,RESET_DEASSERTED}    reset_info_t;
typedef enum bit {SIMPLE_DMA,SG_DMA}dma_mode_t;
typedef enum bit [1:0]{SA_INCR_DA_INCR=2'd0,SA_FIXED_DA_INCR=2'd1,SA_INCR_DA_FIXED=2'd2,SA_FIXED_DA_FIXED=2'd3}dma_burst_type_t;
typedef enum bit [31:0]{CNTRL_REG_ADDR    ='h00,
              STATUS_REG_ADDR   = 'h04,
              CURDESC_LSB_ADDR  = 'h08,
              CURDESC_MSB_ADDR  = 'h0C,
              TAILDESC_LSB_ADDR = 'h10,
              TAILDESC_MSB_ADDR = 'h14,
              SA_LSB_ADDR       = 'h18,
              SA_MSB_ADDR       = 'h1C,
              DA_LSB_ADDR       = 'h20,
              DA_MSB_ADDR       = 'h24,
              BTT_ADDR          = 'h28}offset_address_t;

 //`include "axi_parameters.sv"
 `include "axi_base_sequence_item.sv"
 `include "master_seq_item.sv"
 `include "config_obj.sv"
 `include "master_sequence.sv"
 `include "master_driver.sv"
 `include "master_monitor.sv"
 `include "master_sequencer.sv"
 `include "master_agent.sv"

 `include "c_sequence.sv"

// properties for assertions

  /*property valid_handshake(logic clk,reset_n,valid,ready);
  @(posedge clk) disable iff(!reset_n) valid && !(ready) |=> valid;
  endproperty
  property signal_stable(logic clk,reset_n,valid,ready, logic [255:0] signal);
  @(posedge clk) disable iff(!reset_n) valid && !(ready) |=> $stable(signal);
  endproperty

  //assert valid handshake on all 5 channels
  assert property (valid_handshake(aclk,areset_n,awvalid,awready)) else `uvm_error("AXI_Protocol_check","Invalid awvalid-ready_handshake");
  assert property (valid_handshake(aclk,areset_n,wvalid,wready))   else `uvm_error("AXI_Protocol_check","Invalid wvalid-ready_handshake");
  assert property (valid_handshake(aclk,areset_n,bvalid,bready))   else `uvm_error("AXI_Protocol_check","Invalid bvalid-ready_handshake");
  assert property (valid_handshake(aclk,areset_n,arvalid,arready)) else `uvm_error("AXI_Protocol_check","Invalid arvalid-ready_handshake");
  assert property (valid_handshake(aclk,areset_n,rvalid,rready))   else `uvm_error("AXI_Protocol_check","Invalid rvalid-ready_handshake");
  //assert data stable for read/write data channels
  assert property (signal_stable(aclk,areset_n,rvalid,rready,rdata))    else `uvm_error("AXI_Protocol_check","rdata must be stable till Handshake");
  assert property (signal_stable(aclk,areset_n,wvalid,wready,wdata))    else `uvm_error("AXI_Protocol_check","wdata must be stable till Handshake");
  assert property (signal_stable(aclk,areset_n,awvalid,awready,awaddr)) else `uvm_error("AXI_Protocol_check","awaddr must be stable till Handshake");
  assert property (signal_stable(aclk,areset_n,arvalid,arready,araddr)) else `uvm_error("AXI_Protocol_check","araddr must be stable till Handshake");
  assert property (signal_stable(aclk,areset_n,bvalid,bready,bresp))    else `uvm_error("AXI_Protocol_check","bresp must be stable till Handshake");*/

endpackage
`endif
