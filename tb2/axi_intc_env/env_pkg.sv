/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/intc_env_pkg.sv                                        */
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

package intc_env_pkg;
  import uvm_pkg :: *;
  `include "uvm_macros.svh"
  typedef enum logic[1:0] {WRITE,READ,READ_WRITE}	trans;
	typedef enum			{INTR_INPUT,ACK} 							seq_type_t;

	enum {total,fast,nested,nested_fast,opt_reg_test,basic}test_type;
		
		int total_intr	= 32;
		int nest_intr;
		int imr_data;
		int ier_data		= 32'hFFFF_FFFF;
		bit complete;
		bit nested_mode	= 0;
	
   `include "config_obj.sv"
   `include "axi_4_lite_seq_item.sv"
   `include "intc_seq_item.sv"
   `include "base_sequence.sv"
	 `include "intc_sequence.sv"
   `include "axi_4_lite_seqr.sv"
   `include "intc_sequencer.sv"
   `include "axi_4_lite_driver.sv"
   `include "intc_driver.sv"
   `include "axi_4_lite_monitor.sv"
   `include "intc_monitor.sv"
   `include "axi_4_lite_agent.sv"
   `include "intc_agent.sv"
   `include "virtual_sequencer.sv"
   `include "scoreboard.sv"
   `include "coverage.sv"
   `include "env.sv"
  
endpackage : intc_env_pkg
