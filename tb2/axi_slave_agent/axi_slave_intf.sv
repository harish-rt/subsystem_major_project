/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_slave_intf.sv                           */
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
 `include "uvm_macros.svh"
interface axi_slave_intf(input aclk, areset_n);
 import uvm_pkg::*;
 import axi_parameter_pkg::*;

    //Write_interface signals
   
   logic [ADDR_WIDTH-1 : 0]     awaddr;
   logic                        awvalid;
   logic                        awready;
   logic [RESPONSE_WIDTH-1 : 0] bresp;
   logic                        bvalid;
   logic                        bready;
   logic [DATA_WIDTH-1 : 0]     wdata;
   logic [(DATA_WIDTH/8)-1 : 0] wstrobe;   
   logic                        wvalid;
   logic                        wready;

   //Read interface signals

   logic [ADDR_WIDTH-1 : 0]     araddr;
   logic                        arvalid;
   logic                        arready;
   logic [RESPONSE_WIDTH-1:0]   rresp;
   logic [DATA_WIDTH-1 : 0]     rdata;
   logic                        rvalid;
   logic                        rready;

clocking slv_drv_cb @(posedge aclk);
     default input #1 output #0;
       input    araddr;
       output   arready;
       input    arvalid;
       output   rdata;
       input    rready;
       output   rresp;
       output   rvalid;
       input    awaddr;
       output   awready;
       input    awvalid;
       input    bready;
       output   bresp;
       output   bvalid;
       input    wdata;
       output   wready;
       input    wstrobe;
       input    wvalid;
endclocking:slv_drv_cb

clocking  slv_mon_cb @(posedge aclk);
      default input #1 output #0;
      input     araddr;
      input     arvalid;
      input     arready;
      input     rdata;
      input     rvalid;
      input     rready;
      input     rresp;
      input     awaddr;
      input     awvalid;
      input     awready;
      input     bresp;
      input     bvalid;
      input     bready;
      input     wdata;
      input     wstrobe;
      input     wvalid;
      input     wready;
endclocking:slv_mon_cb

    modport DRV_MOD_slave (clocking slv_drv_cb,input areset_n);
    modport MON_MOD_slave (clocking slv_mon_cb,input areset_n);

  
//Importing properties from package
  /*import axi_parameter_pkg :: valid_handshake;
  import axi_parameter_pkg :: signal_stable;
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

endinterface : axi_slave_intf
