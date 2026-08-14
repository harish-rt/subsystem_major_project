/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_slave_sequencer.sv                      */
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
class axi_slave_sequencer extends uvm_sequencer #(axi_slave_seq_item,axi_slave_seq_item);
    
    `uvm_component_utils (axi_slave_sequencer)

    uvm_tlm_analysis_fifo #(axi_slave_seq_item) addr_ph_port;
    axi_slave_agent_cfg cfg;
    uvm_tlm_analysis_fifo #(axi_slave_seq_item) resp_af;

   function new (string name = "axi_slave_sequencer" , uvm_component parent);
      super.new(name,parent);
      addr_ph_port = new("addr_ph_port_sequencer", this);
      resp_af = new ("resp_af",this);
   endfunction

   // On reset, empty the tlm fifo
   function void reset();
     addr_ph_port.flush();
   endfunction

   extern task main_phase (uvm_phase phase);
endclass :axi_slave_sequencer

task axi_slave_sequencer :: main_phase (uvm_phase phase);
   `uvm_info (get_full_name(),"axi_slave_sequencer :: main_phase Triggred"  , UVM_MEDIUM)
endtask : main_phase
