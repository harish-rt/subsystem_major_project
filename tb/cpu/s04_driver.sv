class master_driver_callback extends uvm_callback;
    `uvm_object_utils(master_driver_callback)
    `NEW_OBJ

    virtual task pre_drive(s04_seq_item pkt);
        `uvm_info(get_full_name(), "pre_drive :: executing s04_driver callback", UVM_LOW)
    endtask : pre_drive

    virtual task post_drive(s04_seq_item pkt);
        `uvm_info(get_full_name(), "post_drive :: executing s04_driver callback", UVM_LOW)
    endtask : post_drive
endclass : master_driver_callback


class s04_driver extends uvm_driver #(s04_seq_item, s04_seq_item);
    `uvm_component_utils(s04_driver)
    `uvm_register_cb(s04_driver, master_driver_callback)

    virtual axi4_tb_intf        drv_intf;

    int                         drv_burst_count;
    s04_seq_item                pkt;
    bit disable_cpu_fork    =   0;

    `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    	void'(uvm_config_db#(bit)::get(this,"","DCF",disable_cpu_fork));
        //if (!uvm_config_db#(virtual axi4_tb_intf.DRIVER_MOD)::get(this,"","S04",drv_intf)) begin
        //    `uvm_fatal(get_full_name(), "virtual axi4_tb_intf get failed from config_db!")
        //end
    endfunction

    extern task reset_phase      (uvm_phase phase);
    extern task main_phase       (uvm_phase phase);
    extern task drive_write_addr  (s04_seq_item pkt);
    extern task drive_write_data (s04_seq_item pkt);
    extern task drive_write_resp (s04_seq_item pkt);
    extern task drive_read_add   (s04_seq_item pkt);
    extern task drive_read_data  (s04_seq_item pkt);
endclass : s04_driver


// Reset Phase
task s04_driver::reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), "reset_phase: Driving bus to safe defaults...", UVM_LOW)

    // Wait until reset is actively low, then wait for clean release
    wait(drv_intf.ARESETn === 1'b0);
    @(posedge drv_intf.ACLK iff drv_intf.ARESETn === 1'b1);

    drv_intf.axi4_drv_cb.AWADDR   <= '0;
    drv_intf.axi4_drv_cb.AWBURST  <= '0;
    drv_intf.axi4_drv_cb.AWCACHE  <= '0;
    drv_intf.axi4_drv_cb.AWID     <= '0;
    drv_intf.axi4_drv_cb.AWLEN    <= '0;
    drv_intf.axi4_drv_cb.AWLOCK   <= '0;
    drv_intf.axi4_drv_cb.AWPROT   <= '0;
    drv_intf.axi4_drv_cb.AWQOS    <= '0;
    drv_intf.axi4_drv_cb.AWREGION <= '0;
    drv_intf.axi4_drv_cb.AWSIZE   <= '0;
    drv_intf.axi4_drv_cb.AWVALID  <= 1'b0;

    drv_intf.axi4_drv_cb.WDATA    <= '0;
    drv_intf.axi4_drv_cb.WSTRB    <= '0;
    drv_intf.axi4_drv_cb.WLAST    <= 1'b0;
    drv_intf.axi4_drv_cb.WVALID   <= 1'b0;

    drv_intf.axi4_drv_cb.BREADY   <= 1'b0;

    drv_intf.axi4_drv_cb.ARADDR   <= '0;
    drv_intf.axi4_drv_cb.ARBURST  <= '0;
    drv_intf.axi4_drv_cb.ARCACHE  <= '0;
    drv_intf.axi4_drv_cb.ARID     <= '0;
    drv_intf.axi4_drv_cb.ARLEN    <= '0;
    drv_intf.axi4_drv_cb.ARLOCK   <= '0;
    drv_intf.axi4_drv_cb.ARPROT   <= '0;
    drv_intf.axi4_drv_cb.ARQOS    <= '0;
    drv_intf.axi4_drv_cb.ARREGION <= '0;
    drv_intf.axi4_drv_cb.ARSIZE   <= '0;
    drv_intf.axi4_drv_cb.ARVALID  <= 1'b0;

    drv_intf.axi4_drv_cb.RREADY   <= 1'b0;

    @(drv_intf.axi4_drv_cb);
    `uvm_info(get_full_name(), "reset_phase: Bus reset complete.", UVM_LOW)
    phase.drop_objection(this);
endtask : reset_phase


// Main Phase
task s04_driver::main_phase(uvm_phase phase);
    `uvm_info(get_full_name(), "main_phase running", UVM_MEDIUM)

    forever begin
        seq_item_port.get_next_item(pkt);

        `uvm_do_callbacks(s04_driver, master_driver_callback, pre_drive(pkt));

        if (pkt.operation == WRITE) begin
            if(disable_cpu_fork) begin
                drive_write_addr(pkt);
                drive_write_data(pkt);
                drive_write_resp(pkt);
            end
            else begin
                fork
                    drive_write_addr(pkt);
                    drive_write_data(pkt);
                    drive_write_resp(pkt);
                join
            end
        end 
        else if (pkt.operation == READ) begin
            if(disable_cpu_fork) begin
                drive_read_add(pkt);
                drive_read_data(pkt);
            end
            else begin
                fork
                    drive_read_add(pkt);
                    drive_read_data(pkt);
                join
            end
        end

        `uvm_do_callbacks(s04_driver, master_driver_callback, post_drive(pkt));
        seq_item_port.item_done(pkt);
    end
endtask : main_phase


// Channel Drivers
task s04_driver::drive_write_addr(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.AWADDR   <= pkt.AWADDR;
    drv_intf.axi4_drv_cb.AWBURST  <= pkt.AWBURST;
    drv_intf.axi4_drv_cb.AWCACHE  <= pkt.AWCACHE;
    drv_intf.axi4_drv_cb.AWID     <= pkt.AWID;
    drv_intf.axi4_drv_cb.AWLEN    <= pkt.AWLEN;
    drv_intf.axi4_drv_cb.AWSIZE   <= pkt.AWSIZE;
    drv_intf.axi4_drv_cb.AWQOS    <= pkt.AWQOS;
    drv_intf.axi4_drv_cb.AWVALID  <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
    end while (drv_intf.axi4_drv_cb.AWREADY !== 1'b1);

    drv_intf.axi4_drv_cb.AWVALID  <= 1'b0;
endtask : drive_write_addr


task s04_driver::drive_write_data(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    for (int i = 0; i <= pkt.AWLEN; i++) begin
        drv_intf.axi4_drv_cb.WDATA  <= pkt.WDATA[i];
        drv_intf.axi4_drv_cb.WSTRB  <= pkt.WSTRB[i];
        drv_intf.axi4_drv_cb.WVALID <= 1'b1;
        drv_intf.axi4_drv_cb.WLAST  <= (i == pkt.AWLEN) ? 1'b1 : 1'b0;

        do begin
            @(drv_intf.axi4_drv_cb);
        end while (drv_intf.axi4_drv_cb.WREADY !== 1'b1);
    end
    drv_intf.axi4_drv_cb.WVALID <= 1'b0;
    drv_intf.axi4_drv_cb.WLAST  <= 1'b0;
endtask : drive_write_data


task s04_driver::drive_write_resp(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.BREADY <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
    end while (drv_intf.axi4_drv_cb.BVALID !== 1'b1);
    pkt.BID     = drv_intf.axi4_drv_cb.BID;
    pkt.BRESP   = response_t'(drv_intf.axi4_drv_cb.BRESP);

    drv_intf.axi4_drv_cb.BREADY <= 1'b0;
    drv_burst_count++;
endtask : drive_write_resp


task s04_driver::drive_read_add(s04_seq_item pkt);
    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.ARADDR   <= pkt.ARADDR;
    drv_intf.axi4_drv_cb.ARBURST  <= pkt.ARBURST;
    drv_intf.axi4_drv_cb.ARCACHE  <= pkt.ARCACHE;
    drv_intf.axi4_drv_cb.ARID     <= pkt.ARID;
    drv_intf.axi4_drv_cb.ARLEN    <= pkt.ARLEN;
    drv_intf.axi4_drv_cb.ARSIZE   <= pkt.ARSIZE;
    drv_intf.axi4_drv_cb.ARQOS    <= pkt.ARQOS;
    drv_intf.axi4_drv_cb.ARVALID  <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
    end while (drv_intf.axi4_drv_cb.ARREADY !== 1'b1);

    drv_intf.axi4_drv_cb.ARVALID  <= 1'b0;
endtask : drive_read_add


task s04_driver::drive_read_data(s04_seq_item pkt);
    bit rlast = 1'b0;
    int beat  = 0;

    @(drv_intf.axi4_drv_cb);
    drv_intf.axi4_drv_cb.RREADY <= 1'b1;

    do begin
        @(drv_intf.axi4_drv_cb);
        if (drv_intf.axi4_drv_cb.RVALID === 1'b1) begin
            pkt.RDATA[beat] = drv_intf.axi4_drv_cb.RDATA;
            pkt.RRESP[beat] = response_t'(drv_intf.axi4_drv_cb.RRESP);
            beat++;
            if (drv_intf.axi4_drv_cb.RLAST === 1'b1) begin
                rlast = 1'b1;
            end
        end
    end while (!rlast);

    drv_intf.axi4_drv_cb.RREADY <= 1'b0;
endtask : drive_read_data
