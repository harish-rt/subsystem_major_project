/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_slave_agent.sv                          */
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


class axi_slave_agent extends uvm_agent;

   `uvm_component_utils (axi_slave_agent)
   axi_slave_monitor    mon;
   axi_slave_driver     drv;
   axi_slave_sequencer  sqr;
   axi_slave_agent_cfg  cfg;
   uvm_active_passive_enum is_active ; // value set by env
   function new (string name = "axi_slave_agent" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);
endclass :axi_slave_agent

function void axi_slave_agent :: build_phase (uvm_phase phase);
     if (!uvm_config_db #(axi_slave_agent_cfg) :: get (this ,"" ,"axi_slave_agent_cfg", cfg)) begin
       `uvm_fatal("\t PLEASE SET THE CONFIG OBJECT","axi_slave_agent");
     end
     is_active = cfg.is_active; 
     if (!uvm_config_db #(virtual axi_slave_intf) :: get (this ,"" ,"vif", cfg.axi_slave_vif)) begin
       `uvm_fatal("\t PLEASE SET THE CONFIG OBJECT","axi_slave_agent");
     end
     super.build_phase (phase);
     `uvm_info ("axi_slave_agent" , phase.get_name() , UVM_MEDIUM)
     mon = axi_slave_monitor :: type_id :: create ("mon",this);
     if (is_active == UVM_ACTIVE) begin
        drv = axi_slave_driver :: type_id :: create ("drv",this);
        sqr = axi_slave_sequencer   :: type_id :: create ("sqr",this);
     end
  endfunction : build_phase

  function void axi_slave_agent :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     `uvm_info ("axi_slave_agent::connect" , phase.get_name() , UVM_MEDIUM)
     mon.slave_mon_intf = cfg.axi_slave_vif;
     if (is_active == UVM_ACTIVE) begin
        //mon.resp_ap.connect(sqr.resp_af.analysis_export);
        drv.seq_item_port.connect(sqr.seq_item_export);
        mon.addr_ph_port.connect(sqr.addr_ph_port.analysis_export);
        drv.slave_drv_intf = cfg.axi_slave_vif;
        sqr.cfg = cfg;
     end
  endfunction : connect_phase

