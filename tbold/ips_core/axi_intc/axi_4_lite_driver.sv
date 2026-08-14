/* RAITON_COPYRIGHT_BEGIN                                                 */
/* This is an automatically generated prolog.                             */
/*                                                                        */
/* INT_CTRL/UVM_TB/axi_4_lite_driver.sv                                   */
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
class axi_4_lite_driver extends uvm_driver #(axi_4_lite_seq_item,axi_4_lite_seq_item);

   `uvm_component_utils (axi_4_lite_driver)
   virtual axi_4_lite_intf.axi_4_lite_driver_modport  drv_if;
 
   intc_config_obj cfg;
	 bit irq;
   function new (string name = "axi_4_lite_driver" , uvm_component parent);
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
   extern task reset_phase(uvm_phase phase);
   extern task read_data;
   extern task read_addr;
   extern task write_addr;
   extern task write_data;
   extern task write_resp;
endclass 

  function void axi_4_lite_driver :: build_phase (uvm_phase phase);
     super.build_phase (phase);
     `uvm_info ("driver::build" , phase.get_name() , UVM_MEDIUM)
  endfunction : build_phase

  function void axi_4_lite_driver :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     
     `uvm_info ("driver::connect" , phase.get_name() , UVM_MEDIUM)
  endfunction : connect_phase

  function void axi_4_lite_driver :: end_of_elaboration_phase (uvm_phase phase);
     super.end_of_elaboration_phase (phase);
      `uvm_info ("driver::elaboration" , phase.get_name() , UVM_MEDIUM)
  endfunction : end_of_elaboration_phase

  function void axi_4_lite_driver :: start_of_simulation_phase (uvm_phase phase);
     super.start_of_simulation_phase (phase);
      `uvm_info ("driver::start" , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  function void axi_4_lite_driver :: extract_phase (uvm_phase phase);
     super.extract_phase (phase);
      `uvm_info ("driver::extract" , phase.get_name() , UVM_MEDIUM)
  endfunction : extract_phase

  function void axi_4_lite_driver :: check_phase (uvm_phase phase);
     super.check_phase (phase);
      `uvm_info ("driver::check" , phase.get_name() , UVM_MEDIUM)
  endfunction : check_phase

  function void axi_4_lite_driver :: report_phase (uvm_phase phase);
     super.report_phase (phase);
      `uvm_info ("driver::report" , phase.get_name() , UVM_MEDIUM)
  endfunction : report_phase

  function void axi_4_lite_driver :: final_phase (uvm_phase phase);
     super.final_phase (phase);
      `uvm_info ("driver::final" , phase.get_name() , UVM_MEDIUM)
  endfunction : final_phase

  task axi_4_lite_driver :: run_phase (uvm_phase phase);

    forever begin
		
      @(drv_if.axi_4_lite_driver_cb);
      seq_item_port.get_next_item (req);
    
      //`uvm_info("axi_4_lite_driver", req.sprint(), UVM_LOW);

      if(req.trans_type==WRITE)
        begin
          fork
            write_addr();
            write_data();
            write_resp();
          join
        end
      if(req.trans_type==READ)
        begin
          fork
            read_addr();
            read_data();
          join
        end
			if(req.trans_type==READ_WRITE)
				begin
					fork
						write_addr();
            write_data();
            write_resp();
						read_addr();
            read_data();
					join
				end
      seq_item_port.item_done();
    `uvm_info("........driver.......run.......phase", "after item done", UVM_LOW);			
    end
    
  endtask : run_phase

  task axi_4_lite_driver :: reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    drv_if.axi_4_lite_driver_cb.axi_awaddr 	<= 0;
    drv_if.axi_4_lite_driver_cb.axi_awvalid <= 0; 
    drv_if.axi_4_lite_driver_cb.axi_wdata  	<= 0; 
    drv_if.axi_4_lite_driver_cb.axi_wstrb  	<= 0; 
    drv_if.axi_4_lite_driver_cb.axi_wvalid 	<= 0; 
    drv_if.axi_4_lite_driver_cb.axi_bready 	<= 0; 
    drv_if.axi_4_lite_driver_cb.axi_araddr 	<= 0;
    drv_if.axi_4_lite_driver_cb.axi_arvalid	<= 0; 
    drv_if.axi_4_lite_driver_cb.axi_rready 	<= 0; 
    wait(drv_if.areset_n);
    phase.drop_objection(this);
  endtask

  task axi_4_lite_driver :: read_addr();
    `uvm_info ("axi_4_lite_driver  :: read_addr_started ","",UVM_LOW)
    drv_if.axi_4_lite_driver_cb.axi_arvalid <= 1'b1;
    drv_if.axi_4_lite_driver_cb.axi_araddr 	<= req.axi_araddr;
		@(drv_if.axi_4_lite_driver_cb);
    `uvm_info("axi_4_lite_req",$sformatf("  addr = %0d", req.axi_araddr),UVM_LOW)
    wait(drv_if.axi_4_lite_driver_cb.axi_arready)
    drv_if.axi_4_lite_driver_cb.axi_arvalid <= 1'b0;
    `uvm_info ("axi_4_lite_driver  :: read_addr_ended ","",UVM_LOW)
  endtask

  task axi_4_lite_driver :: read_data();
    `uvm_info ("drv_axi_4_lite  :: read_data_started ","",UVM_LOW)
    drv_if.axi_4_lite_driver_cb.axi_rready 	<= 1'b0;
    wait(drv_if.axi_4_lite_driver_cb.axi_rvalid==1'b1)
    drv_if.axi_4_lite_driver_cb.axi_rready 	<= 1'b1;
		req.axi_rdata = drv_if.axi_4_lite_driver_cb.axi_rdata;
    @(drv_if.axi_4_lite_driver_cb);
    //wait(drv_if.axi_4_lite_driver_cb.axi_rvalid==1'b0)
    drv_if.axi_4_lite_driver_cb.axi_rready 	<= 1'b0;

		if(req.axi_araddr == 9'h00 || req.axi_araddr == 9'h18 || req.axi_araddr ==  9'h04)
			seq_item_port.put_response(req);

    `uvm_info ("axi_4_lite_driver  :: read_data_ended ","",UVM_LOW)
  endtask 

  task axi_4_lite_driver :: write_addr();
    drv_if.axi_4_lite_driver_cb.axi_awvalid <= 1'b1;
    drv_if.axi_4_lite_driver_cb.axi_awaddr 	<= req.axi_awaddr;
    @(drv_if.axi_4_lite_driver_cb);
    wait(drv_if.axi_4_lite_driver_cb.axi_awready)

    drv_if.axi_4_lite_driver_cb.axi_awvalid <= 1'b0;
  endtask

  task axi_4_lite_driver :: write_data();
    drv_if.axi_4_lite_driver_cb.axi_wvalid 	<= 1'b1;
    drv_if.axi_4_lite_driver_cb.axi_wdata 	<= req.axi_wdata;
		drv_if.axi_4_lite_driver_cb.axi_wstrb  	<= req.axi_wstrb;
    @(drv_if.axi_4_lite_driver_cb);
    wait(drv_if.axi_4_lite_driver_cb.axi_wready)

    drv_if.axi_4_lite_driver_cb.axi_wvalid 	<= 1'b0;
  endtask 

  task axi_4_lite_driver :: write_resp();
    drv_if.axi_4_lite_driver_cb.axi_bready 	<= 1'b0;
    `uvm_info ("drv_axi_4_lite  :: write_resp_started ","",UVM_LOW)
    wait(drv_if.axi_4_lite_driver_cb.axi_bvalid==1'b1)
    drv_if.axi_4_lite_driver_cb.axi_bready 	<= 1'b1;
    @(drv_if.axi_4_lite_driver_cb);
    drv_if.axi_4_lite_driver_cb.axi_bready 	<= 1'b0;
    `uvm_info ("axi_4_lite_driver :: write_resp_ended ","",UVM_LOW)
  endtask 

  

  
  

  
