class cpu_driver extends uvm_driver#(axil_cpu_seq_item);
    `uvm_component_utils(cpu_driver)
    `NEW_COMP

    virtual axi4_lite_intf.DRIVER_MOD           axil_drv_if;
    
    axil_cpu_seq_item      pkt,rsp;

    function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        `uvm_info ("driver::build" , phase.get_name() , UVM_MEDIUM)
    endfunction : build_phase

    task reset_phase(uvm_phase phase);
        `uvm_info(get_full_name(), phase.get_name(), UVM_MEDIUM)
        `uvm_info(get_full_name(),"AXI-Lite reset_phase: Driving initial values to interface", UVM_LOW)
        if (axil_drv_if == null) begin
            `uvm_fatal("DRV_IF_NULL", "Virtual interface handle is NULL in lite_intc_driver!")
        end
        axil_drv_if.axil_drv_cb.AWADDR  <= 'b0;
        axil_drv_if.axil_drv_cb.AWVALID <= 'b0;
        axil_drv_if.axil_drv_cb.WDATA   <= 'b0;
        axil_drv_if.axil_drv_cb.WSTRB   <= 'b0;
        axil_drv_if.axil_drv_cb.WVALID  <= 'b0;
        axil_drv_if.axil_drv_cb.BREADY  <= 'b0;
        axil_drv_if.axil_drv_cb.ARADDR  <= 'b0;
        axil_drv_if.axil_drv_cb.ARVALID <= 'b0;
        axil_drv_if.axil_drv_cb.RREADY  <= 'b0;
    endtask : reset_phase

    task main_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "1. main_phase entered", UVM_LOW)
        
        wait(axil_drv_if.axil_drv_cb.ARESETn == 1'b1);
        `uvm_info(get_full_name(), "2. Reset is 1. Waiting for clock edge...", UVM_LOW)
        
        forever begin
            @(axil_drv_if.axil_drv_cb);
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
        axil_drv_if.axil_drv_cb.AWADDR  <= pkt.AWADDR;
        axil_drv_if.axil_drv_cb.AWVALID <= 1;
        //wait(axil_drv_if.axil_drv_cb.AWREADY == 1);
        do begin
            @(axil_drv_if.axil_drv_cb);
        end while (axil_drv_if.axil_drv_cb.AWREADY == 0);    
        //@(axil_drv_if.axil_drv_cb);
        axil_drv_if.axil_drv_cb.AWVALID <= 0;
        axil_drv_if.axil_drv_cb.AWADDR  <= 0;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- address handshake complete", UVM_LOW)
    endtask
    
    task drive_write_data();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- task triggered", UVM_LOW)
        axil_drv_if.axil_drv_cb.WDATA   <= pkt.WDATA;
        axil_drv_if.axil_drv_cb.WSTRB   <= pkt.WSTRB;        
        axil_drv_if.axil_drv_cb.WVALID  <= 1;
        //wait(axil_drv_if.axil_drv_cb.WREADY == 1);
        do begin
            @(axil_drv_if.axil_drv_cb);
        end while (axil_drv_if.axil_drv_cb.WREADY == 0); 
        //@(axil_drv_if.axil_drv_cb);
        axil_drv_if.axil_drv_cb.WVALID  <= 0;
        axil_drv_if.axil_drv_cb.WDATA   <= 0;
        axil_drv_if.axil_drv_cb.WSTRB   <= 0;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- data handshake complete", UVM_LOW)
    endtask
    
    task drive_write_resp();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- task triggered", UVM_LOW)
        axil_drv_if.axil_drv_cb.BREADY <= 1;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- waiting for BVALID", UVM_LOW)
        //wait(axil_drv_if.axil_drv_cb.BVALID == 1);
        do begin
            @(axil_drv_if.axil_drv_cb);
        end while (axil_drv_if.axil_drv_cb.BVALID == 0);
        pkt.BRESP = response_t'(axil_drv_if.axil_drv_cb.BRESP);    
        //@(axil_drv_if.axil_drv_cb);
        axil_drv_if.axil_drv_cb.BREADY <= 0;
        //seq_item_port.put_response(rsp);
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- transaction complete", UVM_LOW)
        `uvm_info("driver_pkt_from_write_resp",pkt.sprint(),UVM_MEDIUM)
    endtask
    
    
    task drive_read_add();
        `uvm_info(get_full_name(),"MI_drive_read_add -- task triggered", UVM_LOW)
        axil_drv_if.axil_drv_cb.ARADDR  <= pkt.ARADDR;
        axil_drv_if.axil_drv_cb.ARVALID <= 1;
        //wait(axil_drv_if.axil_drv_cb.ARREADY == 1);
        do begin
            @(axil_drv_if.axil_drv_cb);
        end while (axil_drv_if.axil_drv_cb.ARREADY == 0); 
        //@(axil_drv_if.axil_drv_cb);
        axil_drv_if.axil_drv_cb.ARVALID <= 0;
        axil_drv_if.axil_drv_cb.ARADDR  <= 'h0;
        `uvm_info(get_full_name(),"MI_drive_read_add -- address handshake complete", UVM_LOW)
    endtask
    
    task drive_read_data();
      `uvm_info(get_full_name(),"AXI-Lite drive_read_data -- task triggered", UVM_LOW)
        axil_drv_if.axil_drv_cb.RREADY <= 1;
        //wait(axil_drv_if.axil_drv_cb.RVALID == 1);
        do begin
            @(axil_drv_if.axil_drv_cb);
        end while (axil_drv_if.axil_drv_cb.RVALID == 0); 
        pkt.RDATA = axil_drv_if.axil_drv_cb.RDATA;
        pkt.RRESP = response_t'(axil_drv_if.axil_drv_cb.RRESP);
        //@(axil_drv_if.axil_drv_cb);
        axil_drv_if.axil_drv_cb.RREADY <= 0;
        //seq_item_port.put_response(rsp);    
        `uvm_info("driver_pkt_last",pkt.sprint(),UVM_MEDIUM)
    endtask
endclass : cpu_driver
