/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_axi_slave_intf.sv                           */
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
interface   axi_cdma_axi_slave_intf (input aclk, areset_n);
   import  uvm_pkg :: *;
    //Write_interface signals
   logic [6:0]                    awid;
   logic [`ADDR_WIDTH-1 : 0]      awaddr;
   logic [`LEN_WIDTH-1 : 0]       awlen;
   logic [`BURST_WIDTH-1 : 0]     awburst;
   logic [`SIZE_WIDTH-1 : 0]      awsize;
   logic                         awvalid;
   logic                         awready;
   logic [6 : 0]                  bid;
   logic [`RESPONSE_WIDTH-1 : 0]  bresp;
   logic                         bvalid;
   logic                         bready;
   logic [`DATA_WIDTH-1 : 0]      wdata;
   logic [(`DATA_WIDTH/8)-1 : 0] wstrobe;
   logic                         wlast;
   logic                         wvalid;
   logic                         wready;
   logic                         awlock;
   logic [2 : 0]                 awprot;
   logic [3 : 0]                 awqos;
   logic [3 : 0]                 awregion;
   logic [3 : 0]                 awcache;
   //Read interface signals
   logic [6 : 0]                 arid;
   logic [`ADDR_WIDTH-1 : 0]     araddr;
   logic [`LEN_WIDTH-1 : 0]      arlen;
   logic [`BURST_WIDTH-1 : 0]    arburst;
   logic [`SIZE_WIDTH-1 : 0]     arsize;
   logic                        arvalid;
   logic                        arready;
   logic [6 : 0]                 rid;
   logic [`RESPONSE_WIDTH-1:0]   rresp;
   logic [`DATA_WIDTH-1 : 0]     rdata;
   logic                        rlast;
   logic                        rvalid;
   logic                        rready;
   logic                        arlock;
   logic [2:0]                  arprot;
   logic [3:0]                  arqos;
   logic [3:0]                  arregion;
   logic [3:0]                  arcache;


clocking slv_drv_cb @(posedge aclk);
     default input #1 output #0;
       input    araddr;
       input    arburst;
       input    arcache;
       input    arlen;
       input    arlock;
       input    arprot;
       input    arid;
       input    arqos;
       output   arready;
       input    arregion;
       input    arsize;
       input    arvalid;
       output   rdata;
       output   rid;
       output   rlast;
       input    rready;
       output   rresp;
       output   rvalid;
       input    awaddr;
       input    awburst;
       input    awcache;
       input    awid;
       input    awlen;
       input    awlock;
       input    awprot;
       input    awqos;
       output   awready;
       input    awregion;
       input    awsize;
       input    awvalid;
       input    bready;
       output   bresp;
       output   bid;
       output   bvalid;
       input    wdata;
       input    wlast;
       output   wready;
       input    wstrobe;
       input    wvalid;
endclocking:slv_drv_cb

clocking  slv_mon_cb @(posedge aclk);
       default input #1 output #0;
       input     arid;
       input     araddr;
       input     arlen;
       input     arburst;
       input     arsize;
       input     arvalid;
       input     rready;
       input     arready;
       input     rid;
       input     rresp;
       input     rdata;
       input     rlast;
       input     rvalid;
       input     arlock;
       input     arprot;
       input     arqos;
       input     arregion;
       input     arcache;
      input      awid;
      input      awaddr;
      input      awlen;
      input      awburst;
      input      awsize;
      input      awvalid;
      input      awready;
      input      bid;
      input      bresp;
      input      bvalid;
      input      bready;
      input      wdata;
      input      wstrobe;
      input      wlast;
      input      wvalid;
      input      wready;
      input       awlock;
      input       awprot;
      input       awqos;
      input       awregion;
      input       awcache;
endclocking:slv_mon_cb

    modport DRV_MOD_slave (clocking slv_drv_cb,input areset_n);
    modport MON_MOD_slave (clocking slv_mon_cb,input areset_n);
//Importing properties from package
  import axi_cdma_env_pkg :: valid_handshake;
  import axi_cdma_env_pkg :: signal_stable;
  //assert valid handshake on all 5 channels
  assert property (valid_handshake(aclk,areset_n,awvalid,awready)) else `uvm_error("AXI_Protocol_check","Invalid awvalid-ready_handshake")
  assert property (valid_handshake(aclk,areset_n,wvalid,wready))   else `uvm_error("AXI_Protocol_check","Invalid wvalid-ready_handshake");
  assert property (valid_handshake(aclk,areset_n,bvalid,bready))   else `uvm_error("AXI_Protocol_check","Invalid bvalid-ready_handshake");
  assert property (valid_handshake(aclk,areset_n,arvalid,arready)) else `uvm_error("AXI_Protocol_check","Invalid arvalid-ready_handshake");
  assert property (valid_handshake(aclk,areset_n,rvalid,rready))   else `uvm_error("AXI_Protocol_check","Invalid rvalid-ready_handshake");
  //assert data stable for read/write data channels
  assert property (signal_stable(aclk,areset_n,rvalid,rready,rdata))    else `uvm_error("AXI_Protocol_check","rdata must be stable till Handshake");
  assert property (signal_stable(aclk,areset_n,wvalid,wready,wdata))    else `uvm_error("AXI_Protocol_check","wdata must be stable till Handshake");
  assert property (signal_stable(aclk,areset_n,awvalid,awready,awaddr)) else `uvm_error("AXI_Protocol_check","awaddr must be stable till Handshake");
  assert property (signal_stable(aclk,areset_n,arvalid,arready,araddr)) else `uvm_error("AXI_Protocol_check","araddr must be stable till Handshake");
  assert property (signal_stable(aclk,areset_n,bvalid,bready,bresp))    else `uvm_error("AXI_Protocol_check","bresp must be stable till Handshake");

endinterface : axi_cdma_axi_slave_intf
