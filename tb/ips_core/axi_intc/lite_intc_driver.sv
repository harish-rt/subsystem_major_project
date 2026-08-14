class lite_intc_driver extends uvm_driver#(lite_intc_seq_item);
    `uvm_component_utils(lite_intc_driver)
    `NEW_COMP
    
    virtual axi4_lite_intf          drv_if;
    //virtual lite_intc_interface.lite_intc_driver_modport    drv_if;
    
    mailbox #(lite_intc_seq_item)waddress_mbx, wdata_mbx, raddress_mbx, rdata_mbx, wresponse_mbx;

    lite_intc_seq_item      pkt,rsp;

    function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        `uvm_info ("driver::build" , phase.get_name() , UVM_MEDIUM)
        waddress_mbx   = new();
        wdata_mbx      = new();
        wresponse_mbx  = new();
        raddress_mbx   = new();
        rdata_mbx      = new();
    endfunction : build_phase

    task reset_phase(uvm_phase phase);
      `uvm_info(get_full_name(), phase.get_name(), UVM_MEDIUM)
      `uvm_info(get_full_name(),"AXI-Lite reset_phase: Driving initial values to interface", UVM_LOW)
      if (drv_if == null) begin
        `uvm_fatal("DRV_IF_NULL", "Virtual interface handle is NULL in lite_intc_driver!")
      end
        drv_if.AWADDR  <= 'b0;
        drv_if.AWVALID <= 'b0;
        drv_if.WDATA   <= 'b0;
        drv_if.WSTRB   <= 'b0;
        drv_if.WVALID  <= 'b0;
        drv_if.BREADY  <= 'b0;
        drv_if.ARADDR  <= 'b0;
        drv_if.ARVALID <= 'b0;
        drv_if.RREADY  <= 'b0;
    endtask : reset_phase

    task main_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "1. main_phase entered", UVM_LOW)
        
        wait(drv_if.areset_n == 1'b1);
        `uvm_info(get_full_name(), "2. Reset is 1. Waiting for clock edge...", UVM_LOW)
        
        forever begin
            @(drv_if);
            `uvm_info(get_full_name(), "3. Clock ticked! Asking sequencer for item...", UVM_LOW)
            
            seq_item_port.get_next_item(pkt);
            `uvm_info(get_full_name(), $sformatf("4. Got packet! Operation: %s", pkt.write.name()), UVM_LOW)
            
            if (pkt.write == WRITE) begin
                fork
                    drive_write_add();
                    drive_write_data();
                    drive_write_resp();
                join
            end else begin
                fork
                    drive_read_add();
                    drive_read_data();
                join
            end
            seq_item_port.item_done(pkt);
        end
    endtask: main_phase


    task drive_write_add();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- task triggered", UVM_LOW)
        drv_if.awaddr  <= pkt.awaddr;
        drv_if.awvalid <= 1;
        //wait(drv_if.awready == 1);
        do begin
            @(drv_if);
        end while (drv_if.awready == 0);    
        //@(drv_if);
        drv_if.awvalid <= 0;
        drv_if.awaddr  <= 0;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- address handshake complete", UVM_LOW)
    endtask
    
    task drive_write_data();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- task triggered", UVM_LOW)
        drv_if.wdata   <= pkt.wdata[0];
        drv_if.wvalid  <= 1;
        //wait(drv_if.wready == 1);
        do begin
            @(drv_if);
        end while (drv_if.wready == 0); 
        //@(drv_if);
        drv_if.wvalid  <= 0;
        drv_if.wdata   <= 0;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- data handshake complete", UVM_LOW)
    endtask
    
    task drive_write_resp();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- task triggered", UVM_LOW)
        drv_if.bready <= 1;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- waiting for BVALID", UVM_LOW)
        //wait(drv_if.bvalid == 1);
        do begin
            @(drv_if);
        end while (drv_if.bvalid == 0);
        pkt.bresp = response_t'(drv_if.bresp);    
        //@(drv_if);
        drv_if.bready <= 0;
        //seq_item_port.put_response(rsp);
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- transaction complete", UVM_LOW)
        `uvm_info("driver_pkt_from_write_resp",pkt.sprint(),UVM_MEDIUM)
    endtask
    
    
    task drive_read_add();
        `uvm_info(get_full_name(),"MI_drive_read_add -- task triggered", UVM_LOW)
        drv_if.araddr  <= pkt.araddr;
        drv_if.arvalid <= 1;
        //wait(drv_if.arready == 1);
        do begin
            @(drv_if);
        end while (drv_if.arready == 0); 
        //@(drv_if);
        drv_if.arvalid <= 0;
        drv_if.araddr  <= 'h0;
        `uvm_info(get_full_name(),"MI_drive_read_add -- address handshake complete", UVM_LOW)
    endtask
    
    task drive_read_data();
      `uvm_info(get_full_name(),"AXI-Lite drive_read_data -- task triggered", UVM_LOW)
        drv_if.rready <= 1;
        //wait(drv_if.rvalid == 1);
        do begin
            @(drv_if);
        end while (drv_if.rvalid == 0); 
        pkt.rdata[0] = drv_if.rdata;
        pkt.rresp[0] = response_t'(drv_if.rresp);
        //@(drv_if);
        drv_if.rready <= 0;
        //seq_item_port.put_response(rsp);    
        `uvm_info("driver_pkt_last",pkt.sprint(),UVM_MEDIUM)
    endtask
endclass :lite_intc_driver

/* 
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
      `uvm_info ("driver::run", phase.get_name(), UVM_MEDIUM)

    forever begin
      `uvm_info ("driver_run_bf_cb", phase.get_name(), UVM_MEDIUM)
      @(drv_if.lite_intc_driver_cb);
      `uvm_info ("driver_run_af_cb", phase.get_name(), UVM_MEDIUM)
      seq_item_port.get_next_item (req);
    
      `uvm_info("pkt_lite_intc_driver", req.sprint(), UVM_LOW)

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
    `uvm_info("........driver.......run.......phase", "after item done", UVM_LOW)			
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
    `uvm_info("read_pkt_lite_intc_driver", req.sprint(), UVM_LOW)
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
  */
