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

    virtual axi4_tb_intf.DRIVER_MOD master_drv_intf;

    int                          drv_burst_count;
    s04_seq_item                 pkt;
    bit disable_cpu_fork       = 0;

    `NEW_COMP

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    	void'(uvm_config_db#(bit)::get(this,"","DCF",disable_cpu_fork));
        if (!uvm_config_db#(virtual axi4_tb_intf.DRIVER_MOD)::get(this,"","S04",master_drv_intf)) begin
            `uvm_fatal(get_full_name(), "virtual axi4_tb_intf get failed from config_db!")
        end
    endfunction

    extern task reset_phase      (uvm_phase phase);
    extern task main_phase       (uvm_phase phase);
    extern task drive_write_add  (s04_seq_item pkt);
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
    wait(master_drv_intf.ARESETn === 1'b0);
    @(posedge master_drv_intf.ACLK iff master_drv_intf.ARESETn === 1'b1);

    master_drv_intf.axi4_drv_cb.AWADDR   <= '0;
    master_drv_intf.axi4_drv_cb.AWBURST  <= '0;
    master_drv_intf.axi4_drv_cb.AWCACHE  <= '0;
    master_drv_intf.axi4_drv_cb.AWID     <= '0;
    master_drv_intf.axi4_drv_cb.AWLEN    <= '0;
    master_drv_intf.axi4_drv_cb.AWLOCK   <= '0;
    master_drv_intf.axi4_drv_cb.AWPROT   <= '0;
    master_drv_intf.axi4_drv_cb.AWQOS    <= '0;
    master_drv_intf.axi4_drv_cb.AWREGION <= '0;
    master_drv_intf.axi4_drv_cb.AWSIZE   <= '0;
    master_drv_intf.axi4_drv_cb.AWVALID  <= 1'b0;

    master_drv_intf.axi4_drv_cb.WDATA    <= '0;
    master_drv_intf.axi4_drv_cb.WSTRB    <= '0;
    master_drv_intf.axi4_drv_cb.WLAST    <= 1'b0;
    master_drv_intf.axi4_drv_cb.WVALID   <= 1'b0;

    master_drv_intf.axi4_drv_cb.BREADY   <= 1'b0;

    master_drv_intf.axi4_drv_cb.ARADDR   <= '0;
    master_drv_intf.axi4_drv_cb.ARBURST  <= '0;
    master_drv_intf.axi4_drv_cb.ARCACHE  <= '0;
    master_drv_intf.axi4_drv_cb.ARID     <= '0;
    master_drv_intf.axi4_drv_cb.ARLEN    <= '0;
    master_drv_intf.axi4_drv_cb.ARLOCK   <= '0;
    master_drv_intf.axi4_drv_cb.ARPROT   <= '0;
    master_drv_intf.axi4_drv_cb.ARQOS    <= '0;
    master_drv_intf.axi4_drv_cb.ARREGION <= '0;
    master_drv_intf.axi4_drv_cb.ARSIZE   <= '0;
    master_drv_intf.axi4_drv_cb.ARVALID  <= 1'b0;

    master_drv_intf.axi4_drv_cb.RREADY   <= 1'b0;

    @(master_drv_intf.axi4_drv_cb);
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
                drive_write_add(pkt);
                drive_write_data(pkt);
                drive_write_resp(pkt);
            end
            else begin
                fork
                    drive_write_add(pkt);
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
        seq_item_port.item_done();
    end
endtask : main_phase


// Channel Drivers
task s04_driver::drive_write_add(s04_seq_item pkt);
    @(master_drv_intf.axi4_drv_cb);
    master_drv_intf.axi4_drv_cb.AWADDR   <= pkt.AWADDR;
    master_drv_intf.axi4_drv_cb.AWBURST  <= pkt.AWBURST;
    master_drv_intf.axi4_drv_cb.AWCACHE  <= pkt.AWCACHE;
    master_drv_intf.axi4_drv_cb.AWID     <= pkt.AWID;
    master_drv_intf.axi4_drv_cb.AWLEN    <= pkt.AWLEN;
    master_drv_intf.axi4_drv_cb.AWSIZE   <= pkt.AWSIZE;
    master_drv_intf.axi4_drv_cb.AWQOS    <= pkt.AWQOS;
    master_drv_intf.axi4_drv_cb.AWVALID  <= 1'b1;

    do begin
        @(master_drv_intf.axi4_drv_cb);
    end while (master_drv_intf.axi4_drv_cb.AWREADY !== 1'b1);

    master_drv_intf.axi4_drv_cb.AWVALID  <= 1'b0;
endtask : drive_write_add


task s04_driver::drive_write_data(s04_seq_item pkt);
    @(master_drv_intf.axi4_drv_cb);
    for (int i = 0; i <= pkt.AWLEN; i++) begin
        master_drv_intf.axi4_drv_cb.WDATA  <= pkt.WDATA[i];
        master_drv_intf.axi4_drv_cb.WSTRB  <= pkt.WSTRB[i];
        master_drv_intf.axi4_drv_cb.WVALID <= 1'b1;
        master_drv_intf.axi4_drv_cb.WLAST  <= (i == pkt.AWLEN) ? 1'b1 : 1'b0;

        do begin
            @(master_drv_intf.axi4_drv_cb);
        end while (master_drv_intf.axi4_drv_cb.WREADY !== 1'b1);
    end
    master_drv_intf.axi4_drv_cb.WVALID <= 1'b0;
    master_drv_intf.axi4_drv_cb.WLAST  <= 1'b0;
endtask : drive_write_data


task s04_driver::drive_write_resp(s04_seq_item pkt);
    @(master_drv_intf.axi4_drv_cb);
    master_drv_intf.axi4_drv_cb.BREADY <= 1'b1;

    do begin
        @(master_drv_intf.axi4_drv_cb);
    end while (master_drv_intf.axi4_drv_cb.BVALID !== 1'b1);
    pkt.BID     = master_drv_intf.axi4_drv_cb.BID;
    pkt.BRESP   = response_t'(master_drv_intf.axi4_drv_cb.BRESP);

    master_drv_intf.axi4_drv_cb.BREADY <= 1'b0;
    drv_burst_count++;
endtask : drive_write_resp


task s04_driver::drive_read_add(s04_seq_item pkt);
    @(master_drv_intf.axi4_drv_cb);
    master_drv_intf.axi4_drv_cb.ARADDR   <= pkt.ARADDR;
    master_drv_intf.axi4_drv_cb.ARBURST  <= pkt.ARBURST;
    master_drv_intf.axi4_drv_cb.ARCACHE  <= pkt.ARCACHE;
    master_drv_intf.axi4_drv_cb.ARID     <= pkt.ARID;
    master_drv_intf.axi4_drv_cb.ARLEN    <= pkt.ARLEN;
    master_drv_intf.axi4_drv_cb.ARSIZE   <= pkt.ARSIZE;
    master_drv_intf.axi4_drv_cb.ARQOS    <= pkt.ARQOS;
    master_drv_intf.axi4_drv_cb.ARVALID  <= 1'b1;

    do begin
        @(master_drv_intf.axi4_drv_cb);
    end while (master_drv_intf.axi4_drv_cb.ARREADY !== 1'b1);

    master_drv_intf.axi4_drv_cb.ARVALID  <= 1'b0;
endtask : drive_read_add


task s04_driver::drive_read_data(s04_seq_item pkt);
    bit rlast = 1'b0;
    int beat  = 0;

    @(master_drv_intf.axi4_drv_cb);
    master_drv_intf.axi4_drv_cb.RREADY <= 1'b1;

    do begin
        @(master_drv_intf.axi4_drv_cb);
        if (master_drv_intf.axi4_drv_cb.RVALID === 1'b1) begin
            pkt.RDATA[beat] = master_drv_intf.axi4_drv_cb.RDATA;
            pkt.RRESP[beat] = response_t'(master_drv_intf.axi4_drv_cb.RRESP);
            beat++;
            if (master_drv_intf.axi4_drv_cb.RLAST === 1'b1) begin
                rlast = 1'b1;
            end
        end
    end while (!rlast);

    master_drv_intf.axi4_drv_cb.RREADY <= 1'b0;
endtask : drive_read_data

/*
class master_driver_callback extends uvm_callback;
   `uvm_object_utils(master_driver_callback)

    `NEW_OBJ

   virtual task pre_drive (s04_seq_item pkt,mailbox #(s04_seq_item) waddress_mbx,wdata_mbx,raddress_mbx,rdata_mbx);
     `uvm_info (get_full_name () , "pre_drive :: executing s04_driver call back" , UVM_LOW)
   endtask : pre_drive

   virtual task post_drive (s04_seq_item pkt,virtual axi4_tb_intf.DRIVER_MOD vif,uvm_seq_item_pull_port #(s04_seq_item) port);
     `uvm_info (get_full_name () , "post_drive :: executing s04_driver call back" , UVM_LOW)
   endtask : post_drive

   virtual task drive_rsp(s04_seq_item pkt);
   endtask
endclass : master_driver_callback

class s04_driver extends uvm_driver #(s04_seq_item,s04_seq_item);
    `uvm_component_utils (s04_driver)
    `uvm_register_cb (s04_driver , master_driver_callback)

    virtual axi4_tb_intf.DRIVER_MOD        master_drv_intf;
    int              drv_burst_count;
    s04_seq_item     pkt;

    mailbox #(s04_seq_item) waddress_mbx, wdata_mbx, raddress_mbx, rdata_mbx, wresponse_mbx; // mailboxes for read/write channels

    `NEW_COMP
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        waddress_mbx  = new();
        wdata_mbx     = new();
        raddress_mbx  = new();
        rdata_mbx     = new();
        wresponse_mbx = new();
        if (!uvm_config_db#(virtual axi4_tb_intf.DRIVER_MOD)::get(this,"","S04",master_drv_intf))
            `uvm_fatal(get_full_name(), "s04_intf get failed!")
    endfunction

   extern task main_phase  (uvm_phase phase);
   extern task reset_phase (uvm_phase phase);
   //extern task get_packet ();
   extern task drive_write_add  (s04_seq_item pkt);
   extern task drive_write_data (s04_seq_item pkt);
   extern task drive_read_add   (s04_seq_item pkt);
   extern task drive_read_data  (s04_seq_item pkt);
   extern task drive_write_resp (s04_seq_item pkt);
endclass :s04_driver

task s04_driver :: reset_phase (uvm_phase phase);
   `uvm_info (get_full_name(), phase.get_name() , UVM_LOW)
   `uvm_info(get_full_name(),"........s04_driver.......reset_phase Driving initial values to interface", UVM_LOW);
    //drive initial values to 0
    wait(master_drv_intf.ARESETn);
    master_drv_intf.axi4_drv_cb.AWADDR   <= 'b0;
    master_drv_intf.axi4_drv_cb.AWBURST  <= 'b0;
    master_drv_intf.axi4_drv_cb.AWCACHE  <= 'b0;
    master_drv_intf.axi4_drv_cb.AWID     <= 'b0;
    master_drv_intf.axi4_drv_cb.AWLEN    <= 'b0;
    master_drv_intf.axi4_drv_cb.AWLOCK   <= 'b0;
    master_drv_intf.axi4_drv_cb.AWPROT   <= 'b0;
    master_drv_intf.axi4_drv_cb.AWQOS    <= 'b0;
    master_drv_intf.axi4_drv_cb.AWREGION <= 'b0;
    master_drv_intf.axi4_drv_cb.AWSIZE   <= 'b0;
    master_drv_intf.axi4_drv_cb.AWVALID  <= 'b0;
    master_drv_intf.axi4_drv_cb.BREADY   <= 'b0;
    master_drv_intf.axi4_drv_cb.RREADY   <= 'b0;
    master_drv_intf.axi4_drv_cb.WDATA    <= 'b0;
    master_drv_intf.axi4_drv_cb.WLAST    <= 'b0;
    master_drv_intf.axi4_drv_cb.WSTRB    <= 'b0;
    master_drv_intf.axi4_drv_cb.WVALID   <= 'b0;
    master_drv_intf.axi4_drv_cb.ARADDR   <= 'b0;
    master_drv_intf.axi4_drv_cb.ARBURST  <= 'b0;
    master_drv_intf.axi4_drv_cb.ARCACHE  <= 'b0;
    master_drv_intf.axi4_drv_cb.ARID     <= 'b0;
    master_drv_intf.axi4_drv_cb.ARLEN    <= 'b0;
    master_drv_intf.axi4_drv_cb.ARLOCK   <= 'b0;
    master_drv_intf.axi4_drv_cb.ARPROT   <= 'b0;
    master_drv_intf.axi4_drv_cb.ARQOS    <= 'b0;
    master_drv_intf.axi4_drv_cb.ARREGION <= 'b0;
    master_drv_intf.axi4_drv_cb.ARSIZE   <= 'b0;
    master_drv_intf.axi4_drv_cb.ARVALID  <= 'b0;
   `uvm_info(get_full_name(),"........s04_driver.......reset_phase Driving initial values to interface is DONE", UVM_LOW);
endtask :reset_phase

task s04_driver :: main_phase (uvm_phase phase);
    `uvm_info(get_full_name(), "main_phase running", UVM_MEDIUM)

    forever begin
        @(master_drv_intf.axi4_drv_cb);
        seq_item_port.get_next_item(pkt);
        
            if (pkt.write == WRITE) begin
                fork
                    drive_write_add(pkt);
                    drive_write_data(pkt);
                join
                drive_write_resp(pkt);
            end 
            else if (pkt.write == READ) begin
                fork
                    drive_read_add(pkt);
                    drive_read_data(pkt);
                join
            end
        
        seq_item_port.item_done(); 
    end
endtask : main_phase

/*
task s04_driver :: main_phase (uvm_phase phase);

    fork
        get_packet();
        drive_write_add();
        drive_write_data();
        drive_read_add();
        drive_read_data();
        drive_write_resp();
    join

endtask : main_phase

task s04_driver :: get_packet();
    s04_seq_item pkt;
    //waddress_mbx=new();
    //wdata_mbx=new();
    //raddress_mbx=new();
    //rdata_mbx=new();
    //wresponse_mbx=new();
    
    forever begin
        seq_item_port.get_next_item(req);
        //pre_drive task to corrupt packet
        `uvm_do_callbacks(s04_driver,master_driver_callback,pre_drive(pkt,waddress_mbx,wdata_mbx,raddress_mbx,rdata_mbx));
        $cast(pkt,req.clone);
        if(pkt.write == WRITE ) begin
            waddress_mbx.put(pkt);
            wdata_mbx.put(pkt);
        end
        if(pkt.write == READ) begin
            raddress_mbx.put(pkt);
            rdata_mbx.put(pkt);
        end
        
        `uvm_do_callbacks(s04_driver,master_driver_callback,post_drive(pkt,master_drv_intf, seq_item_port));
        seq_item_port.item_done();
   end
endtask
*/
/*
task s04_driver :: drive_write_add(s04_seq_item pkt);
//s04_seq_item pkt;

//forever begin
    //waddress_mbx.get(pkt);

    master_drv_intf.axi4_drv_cb.AWADDR   <= pkt.AWADDR;
    master_drv_intf.axi4_drv_cb.AWBURST  <= pkt.AWBURST;
    master_drv_intf.axi4_drv_cb.AWCACHE  <= pkt.AWCACHE;
    master_drv_intf.axi4_drv_cb.AWID     <= pkt.AWID;
    master_drv_intf.axi4_drv_cb.AWLEN    <= pkt.AWLEN;
    master_drv_intf.axi4_drv_cb.AWSIZE   <= pkt.AWSIZE;
    master_drv_intf.axi4_drv_cb.AWVALID  <= 1'b1;

    do begin
        @(master_drv_intf.axi4_drv_cb);
    end while (master_drv_intf.axi4_drv_cb.AWREADY !== 1'b1);
    //wait(master_drv_intf.axi4_drv_cb.AWREADY == 1);
    //@(master_drv_intf.axi4_drv_cb);
    master_drv_intf.axi4_drv_cb.AWVALID  <= 1'b0 ;
   //end
endtask

task s04_driver :: drive_write_data(s04_seq_item pkt);
    //s04_seq_item pkt;
  //forever begin
    //wdata_mbx.get(pkt); 
    for(int i=0;i<=pkt.AWLEN;i++) begin
      master_drv_intf.axi4_drv_cb.WDATA     <= pkt.WDATA[i];
      master_drv_intf.axi4_drv_cb.WSTRB     <= pkt.WSTRB[i];
      master_drv_intf.axi4_drv_cb.WVALID    <= 1'b1;
      master_drv_intf.axi4_drv_cb.WLAST     <= (i == pkt.AWLEN ) ? 1'b1 : 1'b0;
      
      do begin
            @(master_drv_intf.axi4_drv_cb);
      end while (master_drv_intf.axi4_drv_cb.WREADY !== 1'b1);
      //wait(master_drv_intf.axi4_drv_cb.WREADY == 1'b1);
      //@(master_drv_intf.axi4_drv_cb);
      master_drv_intf.axi4_drv_cb.WVALID   <= 1'b0;
      master_drv_intf.axi4_drv_cb.WLAST    <= 1'b0;
      `uvm_info("driver_pkt_from_write_data",pkt.sprint(),UVM_LOW)
    end
    wresponse_mbx.put(pkt);
 //end
endtask

task s04_driver :: drive_write_resp(s04_seq_item pkt);
//s04_seq_item pkt;
  //forever begin
      wresponse_mbx.get(pkt);

      master_drv_intf.axi4_drv_cb.BREADY <= 1'b1;
      do begin
          @(master_drv_intf.axi4_drv_cb);
      end while (master_drv_intf.axi4_drv_cb.BVALID !== 1'b1);
      //@(master_drv_intf.axi4_drv_cb);
      //wait(master_drv_intf.axi4_drv_cb.BVALID ==1'b1);
      pkt.BRESP = master_drv_intf.axi4_drv_cb.BRESP;
      @(master_drv_intf.axi4_drv_cb);
      master_drv_intf.axi4_drv_cb.BREADY <= 1'b0;
      drv_burst_count++;
      `uvm_info("driver_pkt_from_write_resp",pkt.sprint(),UVM_LOW)
  //end
endtask

task s04_driver :: drive_read_add(s04_seq_item pkt);
  //s04_seq_item pkt;
  //forever begin
      //raddress_mbx.get(pkt);
      
    master_drv_intf.axi4_drv_cb.ARADDR   <= pkt.ARADDR;
    master_drv_intf.axi4_drv_cb.ARBURST  <= pkt.ARBURST;
    master_drv_intf.axi4_drv_cb.ARCACHE  <= pkt.ARCACHE;
    master_drv_intf.axi4_drv_cb.ARID     <= pkt.ARID;
    master_drv_intf.axi4_drv_cb.ARLEN    <= pkt.ARLEN;
    master_drv_intf.axi4_drv_cb.ARSIZE   <= pkt.ARSIZE;
    master_drv_intf.axi4_drv_cb.ARVALID  <= 1'b1;

    do begin
        @(master_drv_intf.axi4_drv_cb);
    end while (master_drv_intf.axi4_drv_cb.ARREADY !== 1'b1);
    //wait(master_drv_intf.axi4_drv_cb.ARREADY ==1'b1);
    //@(master_drv_intf.axi4_drv_cb);
    master_drv_intf.axi4_drv_cb.ARVALID  <= 1'b0 ;
   //end
endtask

task s04_driver::drive_read_data(s04_seq_item pkt);
    bit rlast = 1'b0;
    int beat  = 0;

    master_drv_intf.axi4_drv_cb.RREADY <= 1'b1;

    do begin
        @(master_drv_intf.axi4_drv_cb);
        if (master_drv_intf.axi4_drv_cb.RVALID === 1'b1) begin
            pkt.RDATA[beat] = master_drv_intf.axi4_drv_cb.RDATA;
            pkt.RRESP       = master_drv_intf.axi4_drv_cb.RRESP;
            beat++;
            if (master_drv_intf.axi4_drv_cb.RLAST === 1'b1) begin
                rlast = 1'b1;
            end
        end
    end while (!rlast);

    master_drv_intf.axi4_drv_cb.RREADY <= 1'b0;
endtask : drive_read_data

/*
task s04_driver :: drive_read_data(s04_seq_item pkt);
    //s04_seq_item pkt;
    bit rlast;

    //forever begin
        //rdata_mbx.get(pkt);
        rlast = 1'b0;
        do begin
            master_drv_intf.axi4_drv_cb.RREADY <= 1'b1;
            @(master_drv_intf.axi4_drv_cb);
            if (master_drv_intf.axi4_drv_cb.RVALID === 1'b1) begin
                pkt.RDATA   = master_drv_intf.axi4_drv_cb.RDATA;
                pkt.RRESP   = master_drv_intf.axi4_drv_cb.RRESP;
                if (master_drv_intf.axi4_drv_cb.RLAST === 1'b1) begin
                    rlast = 1'b1;
                    master_drv_intf.axi4_drv_cb.RREADY <= 1'b0;
                end
            end
        end while (rlast == 1'b0);
    //end
endtask
*/
