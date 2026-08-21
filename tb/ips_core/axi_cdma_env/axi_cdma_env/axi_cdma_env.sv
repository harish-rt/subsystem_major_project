/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* AXI_INTERCONNECT_DESIGN/AXI_TB/axi_cdma_env.sv                                  */
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
class axi_cdma_env extends uvm_env;

   `uvm_component_utils (axi_cdma_env)
   axi_cdma_axi_env             env_h;
   axi_cdma_interrupt_agent 	i_agt;
   axi_cdma_scoreboard          scb;
   axi_cdma_coverage            cov;

   axi_cdma_config_obj          obj;

   rand cdma_reg_block m_reg_block;
   axi_cdma_reg2axi_adaptor m_reg2axi;
   uvm_reg_predictor #(axi_cdma_axi_master_seq_item) m_axi2reg_predictor;

   axi_cdma_descriptor_mem desc_mem;

   function new (string name = "axi_cdma_env" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);
   extern function void end_of_elaboration_phase (uvm_phase phase);

endclass :axi_cdma_env

  function void axi_cdma_env :: build_phase (uvm_phase phase);
     super.build_phase (phase);
     `uvm_info ("axi_cdma_env::build" , phase.get_name() , UVM_NONE)
     if (!uvm_config_db #(axi_cdma_config_obj) :: get (this , "*" , "axi_cdma_config_obj" , obj))
     `uvm_fatal(get_full_name(),"Config_obj get Failure");
          
     env_h = axi_cdma_axi_env :: type_id :: create ("env_h",this);
     i_agt = axi_cdma_interrupt_agent :: type_id :: create ("i_agt",this);

     scb = axi_cdma_scoreboard :: type_id :: create ("scb",this);
     cov = axi_cdma_coverage  :: type_id :: create ("cov",this);
     m_reg_block = cdma_reg_block::type_id::create("m_reg_block",this);
     m_reg2axi = axi_cdma_reg2axi_adaptor::type_id::create("m_reg2axi");
     m_axi2reg_predictor = uvm_reg_predictor#(axi_cdma_axi_master_seq_item) ::type_id::create("m_axi2reg_predictor",this); 
     m_reg_block.build();
     m_reg_block.default_map.set_auto_predict(0);
     m_reg_block.default_map.set_check_on_read(1);
     m_reg_block.lock_model();
     m_reg_block.reset();
     m_reg_block.print();
  endfunction : build_phase

  function void axi_cdma_env :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);

     m_axi2reg_predictor.map = m_reg_block.default_map;
     m_axi2reg_predictor.adapter = m_reg2axi;
     env_h.m_agt[0].mon.mon_ap.connect(m_axi2reg_predictor.bus_in);
     if (obj.mas_is_active[0] == UVM_ACTIVE) 
	     m_reg_block.default_map.set_sequencer(env_h.m_agt[0].sqr,m_reg2axi);

     `uvm_info ("axi_cdma_env::connect" , phase.get_name() , UVM_NONE)
     for(int i = 0 ; i < obj.no_of_masters ; i++) begin
        env_h.m_agt[i].mon.mon_ap.connect (cov.m_af[i].analysis_export);
        env_h.m_agt[i].mon.mon_ap.connect (scb.m_af[i].analysis_export);
     end
     
     for(int i = 0 ; i < obj.no_of_slaves ; i++) begin
        env_h.s_agt[i].mon.mon_ap.connect (cov.s_af[i].analysis_export);
        env_h.s_agt[i].mon.mon_ap.connect (scb.s_af[i].analysis_export);
     end

        i_agt.mon.mon_if = obj.intrpt_if;
        i_agt.mon.mon_ap.connect (cov.i_af.analysis_export);
        i_agt.mon.mon_ap.connect (scb.i_af.analysis_export);

  endfunction : connect_phase


 function void axi_cdma_env :: end_of_elaboration_phase (uvm_phase phase);
     super.end_of_elaboration_phase (phase);
     `uvm_info ("axi_cdma_env::elab" , phase.get_name() , UVM_MEDIUM)
      uvm_config_db #(cdma_reg_block)::set (uvm_root::get(), "*", "cdma_reg_block", m_reg_block);

//empty mem for slave use
      desc_mem = axi_cdma_descriptor_mem :: type_id :: create("desc_mem");
      uvm_config_db #(axi_cdma_descriptor_mem) :: set(null,"*","axi_cdma_descriptor_mem",desc_mem);
  endfunction : end_of_elaboration_phase

