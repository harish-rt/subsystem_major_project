class lite_intc_driver extends uvm_driver#(lite_intc_seq_item);
    `uvm_component_utils(lite_intc_driver)
    `NEW_COMP
    
    virtual lite_intc_interface                             base_if;
    virtual lite_intc_interface.lite_intc_driver_modport    drv_if;
 
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

  function void lite_intc_driver :: build_phase (uvm_phase phase);
        super.build_phase (phase);
        `uvm_info ("driver::build" , phase.get_name() , UVM_MEDIUM)
        if(!uvm_config_db #(virtual lite_intc_interface)::get(this,"","lite_intc_if",base_if))begin
            `uvm_fatal("\t SET THE INTC INTF","intc_driver")
        end
        drv_if = base_if;
  endfunction : build_phase

  function void lite_intc_driver :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     
     `uvm_info ("driver::connect" , phase.get_name() , UVM_MEDIUM)
  endfunction : connect_phase

  function void lite_intc_driver :: end_of_elaboration_phase (uvm_phase phase);
     super.end_of_elaboration_phase (phase);
      `uvm_info ("driver::elaboration" , phase.get_name() , UVM_MEDIUM)
  endfunction : end_of_elaboration_phase

  function void lite_intc_driver :: start_of_simulation_phase (uvm_phase phase);
     super.start_of_simulation_phase (phase);
      `uvm_info ("driver::start" , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  function void lite_intc_driver :: extract_phase (uvm_phase phase);
     super.extract_phase (phase);
      `uvm_info ("driver::extract" , phase.get_name() , UVM_MEDIUM)
  endfunction : extract_phase

  function void lite_intc_driver :: check_phase (uvm_phase phase);
     super.check_phase (phase);
      `uvm_info ("driver::check" , phase.get_name() , UVM_MEDIUM)
  endfunction : check_phase

  function void lite_intc_driver :: report_phase (uvm_phase phase);
     super.report_phase (phase);
      `uvm_info ("driver::report" , phase.get_name() , UVM_MEDIUM)
  endfunction : report_phase

  function void lite_intc_driver :: final_phase (uvm_phase phase);
     super.final_phase (phase);
      `uvm_info ("driver::final", phase.get_name(), UVM_MEDIUM)
  endfunction : final_phase

  task lite_intc_driver :: run_phase (uvm_phase phase);

    forever begin
		
      @(drv_if.lite_intc_driver_cb);
      seq_item_port.get_next_item (req);
    
      `uvm_info("pkt_lite_intc_driver", req.sprint(), UVM_LOW);

      if(req.write==WRITE)
        begin
          fork
            write_addr();
            write_data();
            write_resp();
          join
        end
      if(req.write==READ)
        begin
          fork
            read_addr();
            read_data();
          join
        end
		seq_item_port.item_done();
    `uvm_info("........driver.......run.......phase", "after item done", UVM_LOW);			
    end
    
  endtask : run_phase

  task lite_intc_driver :: reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    drv_if.lite_intc_driver_cb.awaddr 	<= 0;
    drv_if.lite_intc_driver_cb.awvalid <= 0; 
    drv_if.lite_intc_driver_cb.wdata  	<= 0; 
    drv_if.lite_intc_driver_cb.wstrb  	<= 0; 
    drv_if.lite_intc_driver_cb.wvalid 	<= 0; 
    drv_if.lite_intc_driver_cb.bready 	<= 0; 
    drv_if.lite_intc_driver_cb.araddr 	<= 0;
    drv_if.lite_intc_driver_cb.arvalid	<= 0; 
    drv_if.lite_intc_driver_cb.rready 	<= 0; 
    wait(drv_if.areset_n);
    phase.drop_objection(this);
  endtask

  task lite_intc_driver :: read_addr();
    `uvm_info("read_pkt_lite_intc_driver", req.sprint(), UVM_LOW);
    `uvm_info ("lite_intc_driver  :: read_addr_started ","",UVM_LOW)
    drv_if.lite_intc_driver_cb.arvalid <= 1'b1;
    drv_if.lite_intc_driver_cb.araddr 	<= req.araddr;
		@(drv_if.lite_intc_driver_cb);
    `uvm_info("lite_req",$sformatf("  addr = %0d", req.araddr),UVM_LOW)
    wait(drv_if.lite_intc_driver_cb.arready)
    drv_if.lite_intc_driver_cb.arvalid <= 1'b0;
    `uvm_info ("lite_intc_driver  :: read_addr_ended ","",UVM_LOW)
  endtask

  task lite_intc_driver :: read_data();
    `uvm_info ("drv_lite  :: read_data_started ","",UVM_LOW)
    drv_if.lite_intc_driver_cb.rready 	<= 1'b0;
    wait(drv_if.lite_intc_driver_cb.rvalid==1'b1)
    drv_if.lite_intc_driver_cb.rready 	<= 1'b1;
		req.rdata = drv_if.lite_intc_driver_cb.rdata;
    @(drv_if.lite_intc_driver_cb);
    //wait(drv_if.lite_intc_driver_cb.rvalid==1'b0)
    drv_if.lite_intc_driver_cb.rready 	<= 1'b0;

		if(req.araddr == 9'h00 || req.araddr == 9'h18 || req.araddr ==  9'h04)
			seq_item_port.put_response(req);

    `uvm_info ("lite_intc_driver  :: read_data_ended ","",UVM_LOW)
  endtask 

  task lite_intc_driver :: write_addr();
    drv_if.lite_intc_driver_cb.awvalid <= 1'b1;
    drv_if.lite_intc_driver_cb.awaddr 	<= req.awaddr;
    @(drv_if.lite_intc_driver_cb);
    wait(drv_if.lite_intc_driver_cb.awready)

    drv_if.lite_intc_driver_cb.awvalid <= 1'b0;
  endtask

  task lite_intc_driver :: write_data();
    drv_if.lite_intc_driver_cb.wvalid 	<= 1'b1;
    drv_if.lite_intc_driver_cb.wdata 	<= req.wdata;
		drv_if.lite_intc_driver_cb.wstrb  	<= req.wstrb;
    @(drv_if.lite_intc_driver_cb);
    wait(drv_if.lite_intc_driver_cb.wready)

    drv_if.lite_intc_driver_cb.wvalid 	<= 1'b0;
  endtask 

  task lite_intc_driver :: write_resp();
    drv_if.lite_intc_driver_cb.bready 	<= 1'b0;
    `uvm_info ("drv_lite  :: write_resp_started ","",UVM_LOW)
    wait(drv_if.lite_intc_driver_cb.bvalid==1'b1)
    drv_if.lite_intc_driver_cb.bready 	<= 1'b1;
    @(drv_if.lite_intc_driver_cb);
    drv_if.lite_intc_driver_cb.bready 	<= 1'b0;
    `uvm_info ("lite_intc_driver :: write_resp_ended ","",UVM_LOW)
  endtask 
