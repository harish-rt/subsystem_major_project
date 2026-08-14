/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/axi_4_lite_agent.sv                                    */
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
class axi_4_lite_agent extends uvm_agent;

   `uvm_component_utils (axi_4_lite_agent)
   intc_config_obj cfg;
   axi_4_lite_monitor    mon;
   axi_4_lite_driver     drv;
   axi_4_lite_seqr       sqr;
   uvm_active_passive_enum is_active;
   
   function new (string name = "axi_4_lite_agent" , uvm_component parent);
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

endclass : axi_4_lite_agent

  function void axi_4_lite_agent :: build_phase (uvm_phase phase);
    if (!uvm_config_db #(intc_config_obj) :: get (this , "" , "intc_config_object" ,cfg)) begin
      `uvm_fatal("\t PLEASE SET THE CONFIG OBJECT","agent");
    end
    else begin
      is_active = cfg.axi_active;

      mon = axi_4_lite_monitor :: type_id :: create ("mon",this); 
      if(is_active == UVM_ACTIVE) begin
        drv = axi_4_lite_driver :: type_id :: create ("drv",this);
        sqr = axi_4_lite_seqr :: type_id :: create ("sqr",this);
      end
    end
  endfunction : build_phase

  function void axi_4_lite_agent :: connect_phase (uvm_phase phase);
      mon.mon_if 	= cfg.a_if;
			mon.intc_if	= cfg.c_if; 
      if(is_active == UVM_ACTIVE) begin
        drv.drv_if  = cfg.a_if;
        drv.seq_item_port.connect (sqr.seq_item_export);
        mon.mon_seqr_ap.connect (sqr.seqr_fifo_h.analysis_export);
      end
  endfunction : connect_phase

  function void axi_4_lite_agent :: end_of_elaboration_phase (uvm_phase phase);
     super.end_of_elaboration_phase (phase);
     `uvm_info ("agent" , phase.get_name() , UVM_MEDIUM)
  endfunction : end_of_elaboration_phase

  function void axi_4_lite_agent :: start_of_simulation_phase (uvm_phase phase);
     super.start_of_simulation_phase (phase);
      `uvm_info ("agent" , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  function void axi_4_lite_agent :: extract_phase (uvm_phase phase);
     super.extract_phase (phase);
     `uvm_info ("agent" , phase.get_name() , UVM_MEDIUM)
  endfunction : extract_phase

  function void axi_4_lite_agent :: check_phase (uvm_phase phase);
     super.check_phase (phase);
      `uvm_info ("agent" , phase.get_name() , UVM_MEDIUM)
  endfunction : check_phase

  function void axi_4_lite_agent :: report_phase (uvm_phase phase);
     super.report_phase (phase);
      `uvm_info ("agent" , phase.get_name() , UVM_MEDIUM)
  endfunction : report_phase

  function void axi_4_lite_agent :: final_phase (uvm_phase phase);
     super.final_phase (phase);
      `uvm_info ("agent" , phase.get_name() , UVM_MEDIUM)
  endfunction : final_phase

  task axi_4_lite_agent :: run_phase (uvm_phase phase);
     `uvm_info ("agent" , phase.get_name() , UVM_MEDIUM)
  endtask : run_phase
