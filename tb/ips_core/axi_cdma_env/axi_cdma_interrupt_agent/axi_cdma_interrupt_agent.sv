/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* HOME/AXI_CDMA/tb/axi_cdma_interrupt_agent.sv                                    */
/*                                                                        */
/* RAITON CONFIDENTIAL                                                    */
/*                                                                        */
/* COPYRIGHT RAITON SEMICONDUCTOR PVT LTD 2018,2021                       */
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
class axi_cdma_interrupt_agent extends uvm_agent;

   `uvm_component_utils(axi_cdma_interrupt_agent)
  // axi_config_obj cfg;
   axi_cdma_interrupt_monitor mon;
   
   //uvm_analysis_port #(axi_cdma_interrupt_seq_item) mon_ap;

   function new(string name="axi_cdma_interrupt_agent", uvm_component parent);
       super.new(name,parent);
   endfunction


   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);
   
endclass : axi_cdma_interrupt_agent


function void axi_cdma_interrupt_agent::build_phase(uvm_phase phase);
   `uvm_info("AGENT:BUILD","BUILD Phase of AGENT",UVM_NONE);

     //if(!(uvm_config_db #(axi_config_obj)::get(this,"","axi_config_obj",cfg))) begin
       //`uvm_fatal("AGENT:CONFIG","Cannot Get the CONFIG OBJECT from test");
     //end
     super.build_phase(phase);
       mon = axi_cdma_interrupt_monitor::type_id::create("mon",this);

endfunction : build_phase


function void axi_cdma_interrupt_agent::connect_phase(uvm_phase phase);
   `uvm_info("AGENT:CONNECT","CONNECT Phase of AGENT",UVM_NONE);
      super.connect_phase(phase);
      //mon.mon_if = cfg.vif;

endfunction : connect_phase
