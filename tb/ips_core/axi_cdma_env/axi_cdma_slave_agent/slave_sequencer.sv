/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/slave_sequencer.sv                      */
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
class slave_sequencer extends uvm_sequencer #(slave_seq_item,slave_seq_item);
   `uvm_component_utils (slave_sequencer)
    uvm_tlm_analysis_fifo #(slave_seq_item) resp_af;

   function new (string name = "slave_sequencer" , uvm_component parent);
      super.new(name,parent);
     resp_af = new ("resp_af",this);
   endfunction

   extern task main_phase (uvm_phase phase);
endclass :slave_sequencer

task slave_sequencer :: main_phase (uvm_phase phase);
     `uvm_info (get_full_name(),"slave_sequencer :: main_phase Triggred"  , UVM_MEDIUM)
  endtask : main_phase
