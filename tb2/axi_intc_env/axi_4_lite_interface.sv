/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/axi_4_lite_interface.sv                                */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2023                       */
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

interface axi_4_lite_intf(input bit aclk, logic areset_n);

`include "uvm_macros.svh"

 import uvm_pkg :: *;


  logic [8:0]  axi_awaddr;                
  logic axi_awvalid;               
  logic axi_awready;                
  logic [31:0] axi_wdata;               
  logic [3:0] axi_wstrb;                   
  logic axi_wvalid;                  
  logic axi_wready;                  
  logic [1:0] axi_bresp;                
  logic axi_bvalid;                  
  logic axi_bready;               
  logic [8:0] axi_araddr;                
  logic axi_arvalid;
  logic axi_arready;                                
  logic [31:0]axi_rdata;                   
  logic [1:0] axi_rresp;                   
  logic axi_rvalid;                 
  logic axi_rready;

	logic [31:0] dut_isr, dut_iar, dut_ier, dut_imr;

//driver_clocking block//

clocking axi_4_lite_driver_cb@(posedge aclk);
  default input #1 output #0;
  output axi_awaddr;
  output axi_awvalid;      
  input  axi_awready;      
  output axi_wdata;
  output axi_wstrb;
  output axi_wvalid;
  input  axi_wready;
  output axi_bready;
  input  axi_bresp;
  input  axi_bvalid;
  output axi_araddr;  
  output axi_arvalid;      
  input  axi_arready;      
  input  axi_rdata;   
  input  axi_rresp;  
  input  axi_rvalid;       
  output axi_rready;
endclocking 

//monitor clocking block//
clocking axi_4_lite_monitor_cb@(posedge aclk);
  default input #1 output #0;  
  input axi_awaddr;
  input axi_awvalid;      
  input axi_awready;      
  input axi_wdata;
  input axi_wstrb;
  input axi_wvalid;
  input axi_wready;
  input axi_bready;
  input axi_bresp;
  input axi_bvalid;
  input axi_araddr;  
  input axi_arvalid;      
  input axi_arready;      
  input axi_rdata;   
  input axi_rresp;  
  input axi_rvalid;       
  input axi_rready;
endclocking

  modport axi_4_lite_driver_modport(clocking axi_4_lite_driver_cb,output areset_n);
  modport axi_4_lite_monitor_modport(clocking axi_4_lite_monitor_cb,input areset_n);

	property aw_addr;
		@(posedge aclk) axi_awvalid |=> $stable(axi_awaddr) ##[1:$] axi_awready ##1 (!axi_awvalid); 
	endproperty

	property ar_addr;
		@(posedge aclk) axi_arvalid |=> $stable(axi_araddr) ##[1:$] axi_arready ##1 (!axi_arvalid); 
	endproperty
	
	property w_data;
		@(posedge aclk) axi_wvalid |=> $stable(axi_wdata) ##[1:$] axi_wready ##1 (!axi_wvalid); 
	endproperty

	property r_data;
		@(posedge aclk) axi_rvalid |=> $stable(axi_rdata) && $stable(axi_rresp) ##[1:$] axi_rready ##1 (!axi_rvalid); 
	endproperty

	property b_resp;
		@(posedge aclk) axi_bvalid |=> $stable(axi_bresp) ##[1:$](axi_bready) ##1 (!axi_bready);
	endproperty


/*
	AWVALID:assert property (aw_addr)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================AWVALID ASSERTION PASSED\n",$time),UVM_MEDIUM)
	ARVALID:assert property (ar_addr)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================ARVALID ASSERTION PASSED\n",$time),UVM_MEDIUM)
	WVALID:assert property (w_data)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================WVALID  ASSERTION PASSED\n",$time),UVM_MEDIUM)
	RVALID:assert property (r_data)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================RVALID  ASSERTION PASSED\n",$time),UVM_MEDIUM)
	BVALID:assert property (b_resp)
		`uvm_info("INTERFACE",$sformatf("@%0t===============================================BVALID  ASSERTION PASSED\n",$time),UVM_MEDIUM)
	
	CG_AWVALID:cover property (aw_addr);*/

endinterface
