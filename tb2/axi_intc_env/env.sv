/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/axi_intc_env.sv                                                 */
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
class axi_intc_env extends uvm_env;

   `uvm_component_utils (axi_intc_env)
   
	 axi_4_lite_agent		axi_4_lite_agt_h;
   intc_agent					intc_agent_h;
   virtual_sequencer  vseqr;
   scoreboard   			scb_h;
   coverage     			cvg_h;
   intc_config_obj 				cfg_obj;

   function new (string name = "axi_intc_env" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);
   extern function void end_of_elaboration_phase (uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern function void extract_phase            (uvm_phase phase);
   extern function void check_phase              (uvm_phase phase);
   extern function void report_phase             (uvm_phase phase);
   extern function void final_phase              (uvm_phase phase);
   extern task run_phase                         (uvm_phase phase);

endclass :axi_intc_env

  function void axi_intc_env :: build_phase (uvm_phase phase);
     `uvm_info ("axi_intc_env::build" , phase.get_name() , UVM_MEDIUM)

     if (!uvm_config_db #(intc_config_obj) :: get (this , "" , "intc_config_object" ,cfg_obj ))
		 	begin
       `uvm_fatal("\t PLEASE SET THE CONFIG OBJECT","agent");
     	end
     else
		 	begin
      	if(cfg_obj.has_axi_agent)
					begin
       			axi_4_lite_agt_h = axi_4_lite_agent :: type_id :: create ("axi_4_lite_agt_h",this);
					end
				if(cfg_obj.has_intc_agent)
					begin
		      	intc_agent_h = intc_agent :: type_id :: create ("intc_agent_h",this);
       		end

        vseqr = virtual_sequencer::type_id::create("vseqr",this);
				scb_h = scoreboard :: type_id ::create ("scb_h" ,this);
       	cvg_h = coverage :: type_id :: create("cvg_h" ,this);
       	`uvm_info ( "axi_intc_env  :: build_phase ended","",UVM_MEDIUM)
     	end
  endfunction : build_phase

  function void axi_intc_env :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     `uvm_info ("axi_intc_env::connect" , phase.get_name() , UVM_MEDIUM)
		 if(cfg_obj.has_axi_agent)
		 	begin
				axi_4_lite_agt_h.mon.mon_ap.connect (scb_h.axi_fifo_h.analysis_export);
				axi_4_lite_agt_h.mon.mon_ap.connect (cvg_h.axi_cvg_af.analysis_export);
        if(cfg_obj.axi_active == UVM_ACTIVE)
          vseqr.axi_sqr   = axi_4_lite_agt_h.sqr;
			end
		if(cfg_obj.has_intc_agent)
			begin
     		intc_agent_h.mon.mon_intc_ap.connect (scb_h.intc_fifo_h.analysis_export);    
     		intc_agent_h.mon.mon_intc_ap.connect (cvg_h.intc_cvg_af.analysis_export);
        if(cfg_obj.intc_active == UVM_ACTIVE) begin
          vseqr.intc_sqr  = intc_agent_h.sqr;
          intc_agent_h.mon.mon_seqr_ap.connect (intc_agent_h.sqr.seqr_fifo_h.analysis_export);
        end
			end
     
     `uvm_info ("axi_intc_env  :: connect_phase", "",UVM_MEDIUM)
 
  endfunction : connect_phase

  function void axi_intc_env :: end_of_elaboration_phase (uvm_phase phase);
     super.end_of_elaboration_phase (phase);
     `uvm_info ("axi_intc_env::elab" , phase.get_name() , UVM_MEDIUM)
  endfunction : end_of_elaboration_phase

  function void axi_intc_env :: start_of_simulation_phase (uvm_phase phase);
     super.start_of_simulation_phase (phase);
     `uvm_info ("axi_intc_env::sim" , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  function void axi_intc_env :: extract_phase (uvm_phase phase);
     super.extract_phase (phase);
     `uvm_info ("axi_intc_env::ext" , phase.get_name() , UVM_MEDIUM)
  endfunction : extract_phase

  function void axi_intc_env :: check_phase (uvm_phase phase);
     super.check_phase (phase);
     `uvm_info ("axi_intc_env::check" , phase.get_name() , UVM_MEDIUM)
  endfunction : check_phase

  function void axi_intc_env :: report_phase (uvm_phase phase);
     super.report_phase (phase);
     `uvm_info ("axi_intc_env::report", phase.get_name() , UVM_MEDIUM)
  endfunction : report_phase

  function void axi_intc_env :: final_phase (uvm_phase phase);
     super.final_phase (phase);
     `uvm_info ("axi_intc_env::final" , phase.get_name() , UVM_MEDIUM)
  endfunction : final_phase

  task axi_intc_env :: run_phase (uvm_phase phase);
     `uvm_info ("axi_intc_env::run" , phase.get_name() , UVM_MEDIUM)
  endtask : run_phase
