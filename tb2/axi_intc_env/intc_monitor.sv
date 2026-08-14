/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/intc_monitor.sv                                        */
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

class intc_monitor extends uvm_monitor;

  `uvm_component_utils(intc_monitor)
	
  virtual intc_intf.intc_mon_mod 			mon_intc_intf;
  
	uvm_analysis_port #(intc_seq_item) 	mon_intc_ap;
  uvm_analysis_port #(intc_seq_item) 	mon_seqr_ap;

	intc_seq_item 											tx_h;
	intc_seq_item												dummy_seq;

	intc_config_obj 													cfg;

  function new (string name = "intc_monitor",uvm_component parent);
    super.new(name,parent);
  endfunction
	
  extern function void build_phase		(uvm_phase phase);
  extern function void connect_phase 	(uvm_phase phase);
  extern task run_phase								(uvm_phase phase);
  extern task collections							();
	extern task irq_capture							();
endclass 
      
  function void intc_monitor :: build_phase (uvm_phase phase);
    `uvm_info ("intc_monitor :: build_phase started  ", "",UVM_LOW)
    super.build_phase(phase);
    mon_intc_ap = new("mon_intc_ap", this);
		mon_seqr_ap = new("mon_seqr_ap", this);
    `uvm_info ("intc_monitor  :: build_phase ended ", "",UVM_LOW)
  endfunction 
   
  function void intc_monitor :: connect_phase (uvm_phase phase);
   `uvm_info ("intc_monitor :: connect_phase started  ", "",UVM_LOW)
    super.connect_phase(phase);
   `uvm_info ("intc_monitor  :: connect_phase ended ", "",UVM_LOW)
  endfunction

  task intc_monitor :: run_phase(uvm_phase phase);
		
		wait(mon_intc_intf.intc_procss_rst==0)
    `uvm_info ("intc_monitor :: run_phase started  ", "",UVM_LOW)
    
		tx_h = intc_seq_item :: type_id :: create("tx_h");
		fork    
			forever
		    collections();
			forever
				irq_capture();
		join
		
   `uvm_info ("mon_intc :: main_phase ended ", "",UVM_LOW) 
  endtask


  task intc_monitor :: collections();
  	
    @(mon_intc_intf.intc_interface_monitor_cb);
		@(mon_intc_intf.intc_procss_rst,
			mon_intc_intf.intc_interface_monitor_cb.intc_intr,
			mon_intc_intf.intc_interface_monitor_cb.intc_irq,
			mon_intc_intf.intc_interface_monitor_cb.intc_procss_acklg);
		
		tx_h.intc_procss_rst	 = mon_intc_intf.intc_procss_rst;
    tx_h.intc_intr_addr    = mon_intc_intf.intc_interface_monitor_cb.intc_intr_addr;
    tx_h.intc_intr         = mon_intc_intf.intc_interface_monitor_cb.intc_intr;
    tx_h.intc_irq          = mon_intc_intf.intc_interface_monitor_cb.intc_irq; 
    tx_h.intc_procss_acklg = mon_intc_intf.intc_interface_monitor_cb.intc_procss_acklg;

    mon_intc_ap.write(tx_h);

  endtask
	
	task intc_monitor :: irq_capture();
		@(mon_intc_intf.intc_interface_monitor_cb);
		@(posedge mon_intc_intf.intc_interface_monitor_cb.intc_irq)
			begin
				mon_seqr_ap.write(dummy_seq);
			end

		@(mon_intc_intf.intc_interface_monitor_cb);	
		@(negedge mon_intc_intf.intc_interface_monitor_cb.intc_irq)
			begin
				mon_seqr_ap.write(dummy_seq);
			end

	endtask
