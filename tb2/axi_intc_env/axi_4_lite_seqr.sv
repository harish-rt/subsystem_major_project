/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/axi_4_lite_seqr.sv                                     */
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
class axi_4_lite_seqr extends uvm_sequencer #(axi_4_lite_seq_item);

  `uvm_component_utils (axi_4_lite_seqr)

	uvm_tlm_analysis_fifo	#(axi_4_lite_seq_item) 	seqr_fifo_h;

  function new (string name = "axi_4_lite_seqr" , uvm_component parent);
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

endclass 

  function void axi_4_lite_seqr :: build_phase (uvm_phase phase);
    super.build_phase (phase);
		seqr_fifo_h = new("seqr_fifo_h",this);
    `uvm_info(get_full_name(),phase.get_name(),UVM_MEDIUM)
  endfunction : build_phase

  function void axi_4_lite_seqr :: connect_phase (uvm_phase phase);
    super.connect_phase (phase);
    `uvm_info(get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : connect_phase

  function void axi_4_lite_seqr :: end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase (phase);
    `uvm_info(get_full_name() , phase.get_name(), UVM_MEDIUM)
  endfunction : end_of_elaboration_phase

  function void axi_4_lite_seqr :: start_of_simulation_phase (uvm_phase phase);
    super.start_of_simulation_phase (phase);
    `uvm_info(get_full_name() ,phase.get_name() ,UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  function void axi_4_lite_seqr :: extract_phase (uvm_phase phase);
     super.extract_phase (phase);
      `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : extract_phase

  function void axi_4_lite_seqr :: check_phase (uvm_phase phase);
     super.check_phase (phase);
      `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : check_phase

  function void axi_4_lite_seqr :: report_phase (uvm_phase phase);
     super.report_phase (phase);
      `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : report_phase

  function void axi_4_lite_seqr :: final_phase (uvm_phase phase);
     super.final_phase (phase);
      `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : final_phase

  task axi_4_lite_seqr :: run_phase (uvm_phase phase);
      `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endtask : run_phase
