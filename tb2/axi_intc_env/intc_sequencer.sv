/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/intc_sequencer.sv                                      */
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
class intc_sequencer extends uvm_sequencer #(intc_seq_item);
 
   `uvm_component_utils(intc_sequencer)

	 uvm_tlm_analysis_fifo #(intc_seq_item) seqr_fifo_h;
   
   extern function new(string name  = "intc_sequencer", uvm_component parent);
   extern function void build_phase (uvm_phase phase);
   extern function void connect_phase (uvm_phase phase);

endclass :intc_sequencer

     function intc_sequencer :: new(string name = "intc_sequencer", uvm_component parent);
       super.new(name, parent);
			 seqr_fifo_h = new("seqr_fifo_h",this);
     endfunction 
   
     function void intc_sequencer :: build_phase (uvm_phase phase);
       super .build_phase(phase);
    
     `uvm_info ("intc_sequencer :: build_phase ","",UVM_NONE)
     endfunction

     function void intc_sequencer :: connect_phase (uvm_phase phase);
       super.connect_phase(phase);
     `uvm_info ("intc_sequencer  :: connect_phase ", "",UVM_NONE)
     endfunction

    
