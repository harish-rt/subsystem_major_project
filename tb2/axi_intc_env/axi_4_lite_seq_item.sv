/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/axi_4_lite_seq_item.sv                                 */
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

class axi_4_lite_seq_item extends uvm_sequence_item; 
 
			 logic axi_areset_n; 
       logic [8:0]  axi_awaddr;           		// input wire [8 : 0] s_axi_awaddr 
       logic axi_awvalid;                 		// input wire s_axi_awvalid 
       logic axi_awready;                 		// output wire s_axi_awready 
  rand logic [31:0] axi_wdata;                // input wire [31 : 0] s_axi_wdata 
  rand logic [3:0] axi_wstrb;                 // input wire [3 : 0] s_axi_wstrb 
       logic axi_wvalid;                  		// input wire s_axi_wvalid 
       logic axi_wready;                  		// output wire s_axi_wready 
       logic [1:0] axi_bresp;                	// output wire [1 : 0] s_axi_bresp 
       logic axi_bvalid;                  		// output wire s_axi_bvalid 
       logic axi_bready;                			// input wire s_axi_bready 
       logic [8:0] axi_araddr;                // input wire [8 : 0] s_axi_araddr 
       logic axi_arvalid;                			// input wire s_axi_arvalid 
       logic axi_arready;                			// output wire s_axi_arready 
       logic [31:0]axi_rdata;                 // output wire [31 : 0] s_axi_rdata 
       logic [1:0] axi_rresp;                 // output wire [1 : 0] s_axi_rresp 
       logic axi_rvalid;                  		// output wire s_axi_rvalid 
       logic axi_rready; 
       trans trans_type;
			 typedef enum {IVAR,ISR,IPR,IER,IAR,CIE,SIE,MER,IVR,ILR,IMR}register_t;
			 rand register_t register;
 
  constraint c_w_strobe {axi_wstrb == 4'b1111;}
 
  `uvm_object_utils_begin (axi_4_lite_seq_item) 
  `uvm_field_int (axi_awaddr,UVM_ALL_ON) 
  `uvm_field_int (axi_awvalid,UVM_ALL_ON + UVM_NOPRINT) 
  `uvm_field_int (axi_awready,UVM_ALL_ON + UVM_NOPRINT) 
  `uvm_field_int (axi_wdata,UVM_ALL_ON) 
  `uvm_field_int (axi_wstrb,UVM_ALL_ON) 
  `uvm_field_int (axi_wvalid,UVM_ALL_ON + UVM_NOPRINT) 
  `uvm_field_int (axi_wready,UVM_ALL_ON + UVM_NOPRINT) 
  `uvm_field_int (axi_bresp,UVM_ALL_ON) 
  `uvm_field_int (axi_bready,UVM_ALL_ON + UVM_NOPRINT) 
  `uvm_field_int (axi_bvalid,UVM_ALL_ON + UVM_NOPRINT) 
  `uvm_field_int (axi_araddr,UVM_ALL_ON) 
  `uvm_field_int (axi_arready,UVM_ALL_ON + UVM_NOPRINT) 
  `uvm_field_int (axi_arvalid,UVM_ALL_ON + UVM_NOPRINT) 
  `uvm_field_int (axi_rdata,UVM_ALL_ON) 
  `uvm_field_int (axi_rready,UVM_ALL_ON) 
  `uvm_field_int (axi_rvalid,UVM_ALL_ON) 
  `uvm_field_int (axi_rresp,UVM_ALL_ON) 
  `uvm_field_enum (trans,trans_type,UVM_ALL_ON)
	`uvm_field_enum (register_t,register,UVM_ALL_ON)
 
  
  `uvm_object_utils_end 
 
extern function new(string name="axi_4_lite_seq_item"); 
  
endclass : axi_4_lite_seq_item
 
  function axi_4_lite_seq_item :: new(string name ="axi_4_lite_seq_item"); 
     super.new(name); 
  endfunction
