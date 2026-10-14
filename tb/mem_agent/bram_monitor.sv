class bram_monitor extends uvm_monitor;
    `uvm_component_utils(bram_monitor)
    `NEW_COMP
    
    uvm_analysis_port #(bram_seq_item)          mon_ap;
	virtual axi4_intf.MONITOR_MOD               bram_if;
   mailbox #(bram_seq_item)  write_address_mbx ,write_data_mbx;      //to capture transactions on write address channel // Preserve ordering
   mailbox #(bram_seq_item) wresp_array [id_t];    //associative array of mailboxes. Will hold packets waiting for write response.Mailboxes will preserve ordering based on ID.
   mailbox #(bram_seq_item) read_address_array [id_t];
   mailbox #(bram_seq_item) read_data_array[id_t];

   extern task main_phase (uvm_phase phase);
   extern function void build_phase (uvm_phase phase);
   extern task  merge_write_info();
   //extern task  capture_reset();
   extern task  capture_write_address();
   extern task  capture_write_data();
   extern task  capture_write_response();
   extern task  capture_read_address();
   extern task  capture_read_data();

endclass :bram_monitor

   function void bram_monitor :: build_phase (uvm_phase phase);
     super.build_phase (phase);
     mon_ap = new ("mon_ap",this);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
    if(!uvm_config_db#(virtual axi4_intf.MONITOR_MOD)::get(this,"","BRAM_MON",bram_if)) begin
		`uvm_fatal("NO_VIF",{"virtual interface is not set for monitor"})
	end
   endfunction : build_phase

task bram_monitor :: main_phase (uvm_phase phase);
 `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
 fork
  //capture_reset();
  capture_write_address();
  capture_write_data();
  capture_write_response();
  capture_read_address();
  capture_read_data();
  merge_write_info();
 join
endtask

task  bram_monitor :: capture_write_address();
 bram_seq_item     pkt;
 write_address_mbx = new ();
 forever begin
    `uvm_info("bram_monitor :: capture_write_address","Triggred",UVM_LOW);
    pkt = bram_seq_item :: type_id :: create("pkt");
    wait( bram_if.axi4_mon_cb.AWREADY && bram_if.axi4_mon_cb.AWVALID && bram_if.ARESETn==1);
    pkt.AWADDR   = bram_if.axi4_mon_cb.AWADDR;
    pkt.AWBURST  = bram_seq_item::burst_t'(bram_if.axi4_mon_cb.AWBURST);
    pkt.AWCACHE  = bram_if.axi4_mon_cb.AWCACHE;
    pkt.AWID     = bram_if.axi4_mon_cb.AWID;
    pkt.AWLEN    = bram_if.axi4_mon_cb.AWLEN;
    pkt.AWLOCK   = bram_if.axi4_mon_cb.AWLOCK;
    pkt.AWPROT   = bram_if.axi4_mon_cb.AWPROT;
    pkt.AWQOS    = bram_if.axi4_mon_cb.AWQOS;
    pkt.AWSIZE   = bram_if.axi4_mon_cb.AWSIZE;
    pkt.write    = bram_seq_item::WRITE;
    `uvm_info("bram_monitor :: capture_write_address","captured address pkt put to write_address_mbx",UVM_LOW);
    //`uvm_info("MASTER_MONITOR:: capture_write_address",pkt.sprint(),UVM_MEDIUM)
    write_address_mbx.put(pkt);
    @(bram_if.axi4_mon_cb); //wait for a clk
  end
endtask

task  bram_monitor ::  capture_write_data();
 bram_seq_item     pkt;
 int i;
 bit last;
 write_data_mbx =    new ();
 forever begin
    `uvm_info("bram_monitor :: capture_write_data","Triggred",UVM_LOW);
    pkt = bram_seq_item :: type_id :: create("pkt");
    pkt.WDATA =new[0];
    pkt.WSTRB= new[0];
    i = 0;
    do begin
      wait(bram_if.axi4_mon_cb.WREADY==1 && bram_if.axi4_mon_cb.WVALID==1 && bram_if.ARESETn==1); 
      `uvm_info("bram_monitor :: capture_write_data","Inside dowhile loop",UVM_LOW);
      pkt.WDATA =new[pkt.WDATA.size() +1](pkt.WDATA);
      pkt.WSTRB =new[pkt.WSTRB.size() +1](pkt.WSTRB);
      pkt.WDATA[i]    = bram_if.axi4_mon_cb.WDATA;
      pkt.WSTRB[i]  = bram_if.axi4_mon_cb.WSTRB;
      last = bram_if.axi4_mon_cb.WLAST;
      i=i+1;
      @(bram_if.axi4_mon_cb); //wait till next clk posedge
      end while(last==0);           //keeps sampling till last indicates end of data phase.
      `uvm_info("bram_monitor :: capture_write_data","captured data pkt put to write_data_mbx",UVM_LOW);
      `uvm_info("MASTER_MONITOR:: capture_write_data",pkt.sprint(),UVM_MEDIUM)
      write_data_mbx.put(pkt);
 end
endtask

task bram_monitor :: capture_write_response();
    bram_seq_item pkt;
    bit [3:0] t_bid;
    
    forever begin
        @(bram_if.axi4_mon_cb);
        if (bram_if.axi4_mon_cb.BREADY == 1 && bram_if.axi4_mon_cb.BVALID == 1 && bram_if.ARESETn == 1) begin
            `uvm_info("bram_monitor :: capture_write_response", "Handshake detected, merging channels...", UVM_LOW);
            
            merge_write_info(); 
            t_bid = bram_if.axi4_mon_cb.BID;
            if (wresp_array.exists(t_bid)) begin
                pkt = bram_seq_item::type_id::create("pkt");
                wresp_array[t_bid].get(pkt);
                pkt.BID   = bram_if.axi4_mon_cb.BID;
                pkt.BRESP = bram_seq_item::response_t'(bram_if.axi4_mon_cb.BRESP);
                mon_ap.write(pkt); 
                `uvm_info("bram_mon_WRITE",pkt.sprint(),UVM_LOW)
            end else begin
                `uvm_error("Master_monitor :: capture_write_response", 
                    $sformatf("unexpected write response, BID not found. Sampled BID=%b. Total unique IDs tracked in array=%0d", 
                    bram_if.axi4_mon_cb.BID, wresp_array.num()))
            end
        end
    end
endtask

task  bram_monitor :: capture_read_address();
 bram_seq_item     pkt;
 forever begin
    `uvm_info("bram_monitor :: capture_read_address","Triggred",UVM_LOW);
    pkt = bram_seq_item :: type_id :: create("pkt");
    wait( bram_if.axi4_mon_cb.ARREADY==1 && bram_if.axi4_mon_cb.ARVALID==1 && bram_if.ARESETn==1);
    pkt.ARADDR   = bram_if.axi4_mon_cb.ARADDR;
    pkt.ARBURST  = bram_seq_item::burst_t'(bram_if.axi4_mon_cb.ARBURST);
    pkt.ARCACHE  = bram_if.axi4_mon_cb.ARCACHE;
    pkt.ARID     = bram_if.axi4_mon_cb.ARID;
    pkt.ARLEN    = bram_if.axi4_mon_cb.ARLEN;
    pkt.ARLOCK   = bram_if.axi4_mon_cb.ARLOCK;
    pkt.ARPROT   = bram_if.axi4_mon_cb.ARPROT;
    pkt.ARQOS    = bram_if.axi4_mon_cb.ARQOS;
    pkt.ARSIZE   = bram_if.axi4_mon_cb.ARSIZE;
    pkt.write    = bram_seq_item::READ;
    //`uvm_info("bram_monitor :: capture_read_address","captured address pkt put to read_address_array",UVM_LOW);
    if(!read_address_array.exists(pkt.ARID)) read_address_array[pkt.ARID]=new();
    //`uvm_info("MASTER_MONITOR:: capture_read_address",pkt.sprint(),UVM_MEDIUM)
    read_address_array[pkt.ARID].put(pkt);
    @(bram_if.axi4_mon_cb); //wait till next clk posedge
  end
endtask

task  bram_monitor ::  capture_read_data();
 bram_seq_item     pkt, pkt2sb;
 int i,no_of_beats;
 bit last;
 forever begin
    `uvm_info("bram_monitor :: capture_read_data","Triggred",UVM_LOW);
    i = 0;
    do begin
      pkt = bram_seq_item :: type_id :: create("pkt");
      pkt.RDATA =new [1];
      pkt.RRESP =new [1];
      wait( bram_if.axi4_mon_cb.RREADY==1 && bram_if.axi4_mon_cb.RVALID==1 && bram_if.ARESETn==1);
      pkt.RID       = bram_if.axi4_mon_cb.RID;
      pkt.RDATA[0]  = bram_if.axi4_mon_cb.RDATA;
      pkt.RRESP[0]  = bram_seq_item::response_t'(bram_if.axi4_mon_cb.RRESP);
      if(!read_data_array.exists(pkt.RID)) read_data_array[pkt.RID] = new();
      read_data_array[pkt.RID].put(pkt);
      i=i+1;
      last = bram_if.axi4_mon_cb.RLAST;
      @(bram_if.axi4_mon_cb); //wait till next clk posedge
    end while( last ==0); //keeps sampling till last indicates end of data phase.
      pkt2sb = bram_seq_item :: type_id :: create("pkt2sb");
      //get  pkt with address info and add data info.//
      read_address_array[pkt.RID].get(pkt2sb);  // this has address info for required RID pkt.
      no_of_beats = read_data_array[pkt.RID].num();
      pkt2sb.RID = pkt.RID;
      pkt2sb.RDATA = new[no_of_beats];
      pkt2sb.RRESP = new[no_of_beats];
   for(i=0 ; i<no_of_beats; i++)begin         //merges all beats with same RID to pkt having address info
      read_data_array[pkt2sb.RID].get(pkt);
      pkt2sb.RDATA[i] = pkt.RDATA[0];
      pkt2sb.RRESP[i] = pkt.RRESP[0];
   end
    `uvm_info("bram_monitor :: capture_read_data","Sending pkt to SB",UVM_LOW);
    //`uvm_info("MASTER_MONITOR:: capture_read_address: pkt",pkt.sprint(),UVM_MEDIUM)
    //`uvm_info("MASTER_MONITOR:: capture_read_address",pkt2sb.sprint(),UVM_MEDIUM)
    //pkt2sb.print_read_txn(pkt2sb);
    mon_ap.write(pkt2sb); //write pkt to sb
    `uvm_info("bram_mon_READ",pkt2sb.sprint(),UVM_LOW)
    //`uvm_info("MASTER_MONITOR:: capture_read_data",pkt2sb.sprint(),UVM_MEDIUM)
 end
endtask

task bram_monitor::merge_write_info();
    bram_seq_item addr_pkt, data_pkt, merged_pkt;
    
    forever begin
        // Block until BOTH an address and data item are available
        write_address_mbx.get(addr_pkt);
        write_data_mbx.get(data_pkt);

        merged_pkt = bram_seq_item::type_id::create("merged_pkt");
        merged_pkt.write       = bram_seq_item::WRITE;
        merged_pkt.AWBURST     = addr_pkt.AWBURST;
        merged_pkt.AWADDR      = addr_pkt.AWADDR;
        merged_pkt.AWSIZE      = addr_pkt.AWSIZE;
        merged_pkt.AWID        = addr_pkt.AWID;
        merged_pkt.AWLEN       = addr_pkt.AWLEN;
        merged_pkt.AWLOCK      = addr_pkt.AWLOCK;
        merged_pkt.AWPROT      = addr_pkt.AWPROT;
        merged_pkt.AWQOS       = addr_pkt.AWQOS;
        merged_pkt.AWCACHE     = addr_pkt.AWCACHE;
        merged_pkt.WDATA       = data_pkt.WDATA;
        merged_pkt.WSTRB       = data_pkt.WSTRB;

        if (!wresp_array.exists(merged_pkt.AWID)) begin
            wresp_array[merged_pkt.AWID] = new();
        end
        wresp_array[merged_pkt.AWID].put(merged_pkt);
        
        `uvm_info("bram_monitor::merge", $sformatf("Successfully merged and queued AWID=%0h", merged_pkt.AWID), UVM_HIGH)
    end
endtask
