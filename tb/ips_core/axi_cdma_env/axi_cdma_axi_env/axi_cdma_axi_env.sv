/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_axi_env.sv                                  */
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
class axi_cdma_axi_env extends uvm_env;

   `uvm_component_utils (axi_cdma_axi_env)
   axi_cdma_axi_master_agent        m_agt[];
   axi_cdma_axi_master_subscriber   m_sub[];
   axi_cdma_axi_slave_agent         s_agt[];
   axi_cdma_axi_slave_subscriber    s_sub[];
   axi_cdma_axi_scoreboard          scb;
 //  axi_cdma_axi_coverage          cov;
   axi_cdma_config_obj          obj;

   function new (string name = "axi_cdma_axi_env" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern task main_phase                        (uvm_phase phase);

endclass :axi_cdma_axi_env

  function void axi_cdma_axi_env :: build_phase (uvm_phase phase);
     super.build_phase (phase);
     `uvm_info ("axi_cdma_axi_env::build" , phase.get_name() , UVM_MEDIUM)
     if (!uvm_config_db #(axi_cdma_config_obj) :: get (null , "*" , "axi_cdma_config_obj" , obj))
     `uvm_fatal(get_full_name(),"Config_obj get Failure");
     m_agt = new[obj.no_of_masters];
     m_sub = new[obj.no_of_masters];
     s_agt = new[obj.no_of_slaves];
     s_sub = new[obj.no_of_slaves];
     for(int i = 0 ; i < obj.no_of_masters ; i++) begin
        m_agt[i] = axi_cdma_axi_master_agent :: type_id :: create ($sformatf("m_agt[%0d]",i),this);
        m_sub[i] = axi_cdma_axi_master_subscriber :: type_id :: create ($sformatf("m_sub[%0d]",i),this);
        m_agt[i].agt_active = obj.mas_is_active[i];
     end
     for(int i = 0 ; i < obj.no_of_slaves ; i++) begin
        s_agt[i] = axi_cdma_axi_slave_agent :: type_id :: create ($sformatf("s_agt[%0d]",i),this);
        s_sub[i] = axi_cdma_axi_slave_subscriber :: type_id :: create ($sformatf("s_sub[%0d]",i),this);
        s_agt[i].agt_active = obj.slv_is_active[i];
     end
     if(obj.scoreboard_enable == 1)
     scb = axi_cdma_axi_scoreboard :: type_id :: create ("scb",this);
  // cov = axi_cdma_axi_coverage :: type_id :: create ("cov",this);
  endfunction : build_phase

  function void axi_cdma_axi_env :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     `uvm_info ("axi_cdma_axi_env::connect" , phase.get_name() , UVM_MEDIUM)
     for(int i = 0 ; i < obj.no_of_masters ; i++) begin
        m_agt[i].mon.master_mon_intf = obj.mas_if[i];
        if(obj.mas_is_active[i] == UVM_ACTIVE)  begin
          m_agt[i].drv.master_drv_intf = obj.mas_if[i];
          m_agt[i].drv.seq_item_port.connect(m_agt[i].sqr.seq_item_export);
        end
     // m_agt[i].mon.mon_ap.connect (cov.analysis_export);
     if(obj.scoreboard_enable == 1)
        m_agt[i].mon.mon_ap.connect (scb.m_af[i].analysis_export);
        m_agt[i].mon.mon_ap.connect (m_sub[i].analysis_export);
        m_sub[i].cvg.axi_cg.option.name = $sformatf("Master_subscriber-%d",i);
     end
            for(int i = 0 ; i < obj.no_of_slaves ; i++) begin
        s_agt[i].mon.slave_mon_intf = obj.slv_if[i];
        if(obj.slv_is_active[i] == UVM_ACTIVE)  begin
          s_agt[i].drv.slave_drv_intf = obj.slv_if[i];
          s_agt[i].drv.seq_item_port.connect(s_agt[i].sqr.seq_item_export);
        end
     // s_agt[i].mon.mon_ap.connect (cov.analysis_export);
     if(obj.scoreboard_enable == 1)
        s_agt[i].mon.mon_ap.connect (scb.s_af[i].analysis_export);
        s_agt[i].mon.mon_ap.connect (s_sub[i].analysis_export);
        s_sub[i].cvg.axi_cg.option.name = $sformatf("Slave_subscriber-%d",i);
     end
        endfunction : connect_phase

  function void axi_cdma_axi_env :: start_of_simulation_phase (uvm_phase phase);
     super.start_of_simulation_phase (phase);
     `uvm_info ("axi_cdma_axi_env::sim" , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  task axi_cdma_axi_env :: main_phase (uvm_phase phase);
     `uvm_info ("axi_cdma_axi_env::main" , phase.get_name() , UVM_MEDIUM)
  endtask : main_phase
