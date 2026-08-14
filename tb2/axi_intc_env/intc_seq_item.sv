/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/intc_seq_item.sv                                       */
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
class intc_seq_item extends uvm_sequence_item;   

  		 	logic 				intc_procss_rst;
	rand 	logic [31:0] 	intc_intr;
  			logic 				intc_irq;
  rand 	logic [1:0] 	intc_procss_acklg;
  			logic [31:0] 	intc_intr_addr;
  			logic 				intc_irq_in;
  			logic [31:0] 	intc_intr_addr_in;
  			logic	[1:0] 	intc_procss_ack_out;
	rand 	seq_type_t		seq_type;
	rand 	int 					cmd_2_cmd_d;

  			int 					iar,ier,ipr,isr,ilr,ivr,imr,sie,cie;
				int 					ivar[32];
  			bit 	[1:0] 	mer;			
				bit 					nested;

   
  `uvm_object_utils_begin (intc_seq_item)  
  `uvm_field_int (intc_intr,UVM_ALL_ON)
  `uvm_field_int (intc_procss_acklg,UVM_ALL_ON)
  `uvm_field_int (intc_intr_addr,UVM_ALL_ON)
  `uvm_field_int (intc_irq_in,UVM_ALL_ON)
  `uvm_field_int (intc_procss_ack_out,UVM_ALL_ON)
  `uvm_field_int (intc_irq,UVM_ALL_ON)
  `uvm_object_utils_end

  constraint intc_intr_c 					{soft intc_intr inside {[32'h00000000:32'hFFFFFFFF]};}
  constraint intc_procss_acklg_c 	{soft intc_procss_acklg inside {0,1,2,3};}
  constraint intc_irq_in_c 				{soft intc_irq_in == 1;}
	constraint ack_delay						{cmd_2_cmd_d inside{[5:8]};}
  

  extern function new(string name = "intc_seq_item");  

endclass : intc_seq_item 

  function intc_seq_item :: new(string name = "intc_seq_item");
    super.new(name);
  endfunction






 
