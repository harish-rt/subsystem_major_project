/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_axi_slave_sequencer.sv                      */
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
class axi_cdma_axi_slave_sequencer extends uvm_sequencer #(axi_cdma_axi_slave_seq_item,axi_cdma_axi_slave_seq_item);
   `uvm_component_utils (axi_cdma_axi_slave_sequencer)
    uvm_tlm_analysis_fifo #(axi_cdma_axi_slave_seq_item) resp_af;

   function new (string name = "axi_cdma_axi_slave_sequencer" , uvm_component parent);
      super.new(name,parent);
     resp_af = new ("resp_af",this);
   endfunction

   extern task main_phase (uvm_phase phase);
endclass :axi_cdma_axi_slave_sequencer

task axi_cdma_axi_slave_sequencer :: main_phase (uvm_phase phase);
     `uvm_info (get_full_name(),"axi_cdma_axi_slave_sequencer :: main_phase Triggred"  , UVM_MEDIUM)
  endtask : main_phase
