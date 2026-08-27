class bram_monitor extends uvm_monitor;
    `uvm_component_utils(bram_monitor)
    `NEW_COMP
    
    uvm_analysis_port #(bram_seq_item)     mon_ap;
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

task bram_monitor :: merge_write_info();
bram_seq_item addr_pkt,data_pkt,merged_pkt;
int x ,no_addr, no_data; //indicates number of completed write transactions waiting for response.
  `uvm_info("bram_monitor :: merge_write_info","Triggred",UVM_LOW);
  no_addr = write_address_mbx.num();
  no_data = write_data_mbx.num();
  x = (no_addr<no_data)? no_addr :no_data;
  //`uvm_info("bram_monitor :: merge_write_info",$sformatf("before get pkt comparing no_of_elements  addr= %d, data=%d ,x=%d",no_addr,no_data,x),UVM_LOW);
  repeat(x)begin
  merged_pkt = bram_seq_item :: type_id :: create("merged_pkt");
  write_address_mbx.get(addr_pkt);
  write_data_mbx.get(data_pkt);
  //Merging address and data phases
   //write address_phase
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
   //write data phase
   merged_pkt.WDATA    = data_pkt.WDATA;
   merged_pkt.WSTRB  = data_pkt.WSTRB;
  //adding packets to array waiting for response
   //`uvm_info("bram_monitor :: merge_write_info",$sformatf("putting merged pkt to wresp_array AWID = %b",merged_pkt.AWID),UVM_LOW);
    if(!wresp_array.exists(merged_pkt.AWID)) wresp_array[merged_pkt.AWID] = new();
    wresp_array[merged_pkt.AWID].put(merged_pkt);
  end
endtask

/*
task bram_monitor :: capture_reset();
 bram_seq_item     rst_pkt;
 `uvm_info("bram_monitor :: capture_reset","Triggred",UVM_LOW);
 fork
  forever begin //reset deasserted
    @(posedge bram_if.ARESETn) ;
    rst_pkt = bram_seq_item :: type_id :: create("rst_pkt");
    rst_pkt.reset_op = RESET_DEASSERTED;
    rst_pkt.reset_deasserted = $realtime();
    `uvm_info("bram_monitor :: capture_reset","reset_deasserted_pkt to SB",UVM_LOW);
    mon_ap.write(rst_pkt);
  end
  forever begin //reset asserted
    @(negedge bram_if.ARESETn) ;
    rst_pkt = bram_seq_item :: type_id :: create("rst_pkt");
    rst_pkt.reset_op = RESET_ASSERTED;
    rst_pkt.reset_deasserted = $realtime();
    `uvm_info("bram_monitor :: capture_reset","reset_asserted_pkt to SB",UVM_LOW);
    mon_ap.write(rst_pkt);
  end
join
endtask
*/

/*
class bram_monitor extends uvm_monitor;
    `uvm_component_utils(bram_monitor)
    `NEW_COMP
    
    uvm_analysis_port #(bram_seq_item)     mon_ap;
	virtual axi4_intf.MONITOR_MOD               bram_if;

    bram_seq_item                          aw_pkt,w_pkt,b_pkt,ar_pkt,r_pkt;

    bram_seq_item  wr_addr_queue[$],rd_addr_queue[$],wr_data_queue[$],rd_data_queue[$],wr_resp_queue[$];

   extern function void build_phase              	(uvm_phase phase);
   extern function void connect_phase            	(uvm_phase phase);
   extern function void end_of_elaboration_phase 	(uvm_phase phase);
   extern function void start_of_simulation_phase	(uvm_phase phase);
   extern function void extract_phase            	(uvm_phase phase);
   extern function void check_phase              	(uvm_phase phase);
   extern function void report_phase             	(uvm_phase phase);
   extern function void final_phase              	(uvm_phase phase);
   extern task main_phase                         	(uvm_phase phase);
   extern task mon_write_address					();
   extern task mon_write_data						();
   extern task mon_write_resp						();
   extern task mon_read_address						();
   extern task mon_read_data						();
   extern task merge_write							();
   extern task merge_read							();

endclass 

  function void bram_monitor :: build_phase (uvm_phase phase);
     super.build_phase (phase);
        mon_ap 			= new ("mon_ap",this);
        `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : build_phase

  function void bram_monitor :: connect_phase (uvm_phase phase);
     super.connect_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : connect_phase

  function void bram_monitor :: end_of_elaboration_phase (uvm_phase phase);
     super.end_of_elaboration_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : end_of_elaboration_phase

  function void bram_monitor :: start_of_simulation_phase (uvm_phase phase);
     super.start_of_simulation_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : start_of_simulation_phase

  function void bram_monitor :: extract_phase (uvm_phase phase);
     super.extract_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : extract_phase

  function void bram_monitor :: check_phase (uvm_phase phase);
     super.check_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : check_phase

  function void bram_monitor :: report_phase (uvm_phase phase);
     super.report_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : report_phase

  function void bram_monitor :: final_phase (uvm_phase phase);
     super.final_phase (phase);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
  endfunction : final_phase

    task bram_monitor :: main_phase (uvm_phase phase);
        `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)

        fork
            forever begin
                @(bram_if.axi4_mon_cb);        
                fork
                    mon_write_address();
                    mon_write_data();
                    mon_write_resp();
                join
                merge_write();
            end
            forever begin
                @(bram_if.axi4_mon_cb);   
                fork
                    mon_read_address();
                    mon_read_data();
                join
                merge_read();
            end
        join
 
    endtask:main_phase

    task bram_monitor :: mon_write_address();
        wait(bram_if.axi4_mon_cb.AWVALID && bram_if.axi4_mon_cb.AWREADY) begin
            aw_pkt = bram_seq_item :: type_id :: create ("aw_pkt");
            aw_pkt.AWADDR   = bram_if.axi4_mon_cb.AWADDR;
            aw_pkt.AWBURST  = bram_seq_item::burst_t'(bram_if.axi4_mon_cb.AWBURST);
            aw_pkt.AWCACHE  = bram_if.axi4_mon_cb.AWCACHE;
            aw_pkt.AWID     = bram_if.axi4_mon_cb.AWID;
            aw_pkt.AWLEN    = bram_if.axi4_mon_cb.AWLEN;
            aw_pkt.AWLOCK   = bram_if.axi4_mon_cb.AWLOCK;
            aw_pkt.AWPROT   = bram_if.axi4_mon_cb.AWPROT;
            aw_pkt.AWQOS    = bram_if.axi4_mon_cb.AWQOS;
            aw_pkt.AWSIZE   = bram_if.axi4_mon_cb.AWSIZE;
            aw_pkt.write    = bram_seq_item::WRITE;
            `uvm_info("axi4_lite_mon_AW",$sformatf("write_address = %0h,write=%s",aw_pkt.AWADDR,aw_pkt.write.name),UVM_NONE)
            wr_addr_queue.push_back(aw_pkt);
        end
    endtask

    task bram_monitor :: mon_write_data();
        int i;
        bit last;
    i = 0;
    do begin
        wait(bram_if.axi4_mon_cb.WVALID && bram_if.axi4_mon_cb.WREADY) begin
            w_pkt = bram_seq_item :: type_id :: create ("w_pkt");
            w_pkt.WDATA = new[w_pkt.WDATA.size() + 1](w_pkt.WDATA);
            w_pkt.WSTRB = new[w_pkt.WSTRB.size() + 1](w_pkt.WSTRB);
            w_pkt.WDATA[i] = bram_if.axi4_mon_cb.WDATA;
            w_pkt.WSTRB[i] = bram_if.axi4_mon_cb.WSTRB;
            last = bram_if.axi4_mon_cb.WLAST;
      i=i+1;
      end while(last==0);           //keeps sampling till last indicates end of data phase.
            `uvm_info("axi4_lite_mon_WD",$sformatf("write_data = %0h",w_pkt.WDATA),UVM_LOW)
            wr_data_queue.push_back(w_pkt);
        end
    endtask

    task bram_monitor :: mon_write_resp();
        wait(bram_if.axi4_mon_cb.BVALID && bram_if.axi4_mon_cb.BREADY) begin
            b_pkt = bram_seq_item :: type_id :: create ("b_pkt");
            b_pkt.BID       = bram_if.axi4_mon_cb.BID;
            b_pkt.BRESP     = bram_seq_item::response_t'(bram_if.axi4_mon_cb.BRESP);
            `uvm_info("axi4_lite_mon_bresp",$sformatf("write_bresp = %b",b_pkt.BRESP),UVM_LOW)
            wr_resp_queue.push_back(b_pkt);
        end
    endtask

    task bram_monitor :: mon_read_address();
        wait(bram_if.axi4_mon_cb.ARVALID && bram_if.axi4_mon_cb.ARREADY) begin
            ar_pkt = bram_seq_item :: type_id :: create ("ar_pkt");
            ar_pkt.ARADDR   = bram_if.axi4_mon_cb.ARADDR;
            ar_pkt.ARBURST  = bram_seq_item::burst_t'(bram_if.axi4_mon_cb.ARBURST);
            ar_pkt.ARCACHE  = bram_if.axi4_mon_cb.ARCACHE;
            ar_pkt.ARID     = bram_if.axi4_mon_cb.ARID;
            ar_pkt.ARLEN    = bram_if.axi4_mon_cb.ARLEN;
            ar_pkt.ARLOCK   = bram_if.axi4_mon_cb.ARLOCK;
            ar_pkt.ARPROT   = bram_if.axi4_mon_cb.ARPROT;
            ar_pkt.ARQOS    = bram_if.axi4_mon_cb.ARQOS;
            ar_pkt.ARSIZE   = bram_if.axi4_mon_cb.ARSIZE;            
            ar_pkt.write    = bram_seq_item::READ;
            `uvm_info("axi4_lite_mon_read_addr",$sformatf("read_address = %0h,write=%s",ar_pkt.ARADDR,ar_pkt.write),UVM_LOW)
            rd_addr_queue.push_back(ar_pkt); 
        end
    endtask

    task bram_monitor :: mon_read_data();
        int i;
        bit last;
        do begin
        wait(bram_if.axi4_mon_cb.RVALID && bram_if.axi4_mon_cb.RREADY) begin
            r_pkt = bram_seq_item :: type_id :: create ("r_pkt");
            r_pkt.RID       = bram_if.axi4_mon_cb.RID;
            r_pkt.RDATA[i]  = bram_if.axi4_mon_cb.RDATA;
            r_pkt.RRESP[i]  = bram_seq_item::response_t'(bram_if.axi4_mon_cb.RRESP);            
            last            = bram_if.axi4_mon_cb.RLAST;
            i=i+1;
        end while(last == 0);
            `uvm_info("axi4_lite_mon_read_data",$sformatf("RDATA = %0h",r_pkt.RDATA),UVM_LOW)
            rd_data_queue.push_back(r_pkt);
        end 
    endtask

    task bram_monitor :: merge_write();
        bram_seq_item w_merge = bram_seq_item :: type_id :: create("w_merge");
        if(wr_addr_queue.size() > 0 && wr_data_queue.size() > 0 && wr_resp_queue.size() > 0 )
            begin
                w_merge.AWADDR 	= wr_addr_queue[0].AWADDR;
                w_merge.WDATA 	= wr_data_queue[0].WDATA;
                w_merge.WSTRB 	= wr_data_queue[0].WSTRB;
                w_merge.BRESP 	= wr_resp_queue[0].BRESP;
                w_merge.write 		= wr_addr_queue[0].write;
                void'(wr_addr_queue.pop_front);
                void'(wr_data_queue.pop_front);
                void'(wr_resp_queue.pop_front);
                `uvm_info("axi4_lite_mon_WRITE",w_merge.sprint(),UVM_LOW)
                mon_ap.write(w_merge);
            end
    endtask

    task bram_monitor :: merge_read();
        bram_seq_item r_merge = bram_seq_item :: type_id :: create("r_merge");
        if(rd_addr_queue.size() > 0 && rd_data_queue.size() > 0 )
            begin
                r_merge.ARADDR    = rd_addr_queue[0].ARADDR;
                r_merge.RDATA     = rd_data_queue[0].RDATA;
		        r_merge.RRESP 	= rd_data_queue[0].RRESP;
                r_merge.write         = rd_addr_queue[0].write;
                void'(rd_addr_queue.pop_front);
                void'(rd_data_queue.pop_front);
                `uvm_info("axi4_lite_mon_READ",r_merge.sprint(),UVM_LOW)
                mon_ap.write(r_merge);
            end
    endtask

/*
class bram_monitor extends uvm_monitor;
    `uvm_component_utils(bram_monitor)

    function new(string name="bram_monitor",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual axi4_lite_intf.MONITOR_MOD   bram_if;
    uvm_analysis_port#(bram_seq_item) mon_ap;
    bram_seq_item wr_addr_queue[$],wr_data_queue[$],wr_resp_queue[$],rd_addr_queue[$],rd_data_queue[$];
    
    extern function void build_phase(uvm_phase phase);
    extern task main_phase(uvm_phase phase);
    extern task write_addr();
    extern task write_data();
    extern task write_resp();
    extern task read_addr();
    extern task read_data();
    extern task merge_write();
    extern task merge_read();
endclass

function void bram_monitor::build_phase(uvm_phase phase);
    mon_ap=new("mon_ap",this);
    if(!uvm_config_db#(virtual axi4_lite_intf.MONITOR_MOD)::get(this,"","MON",bram_if)) begin
		`uvm_fatal("NO_VIF",{"virtual interface is not set for monitor"})
	end

endfunction

task bram_monitor::main_phase(uvm_phase phase);
    fork 
       write_addr();
       write_data();
       write_resp();
       read_addr();
       read_data();
       merge_read();
       merge_write();
    join
endtask

task bram_monitor::write_addr();
    bram_seq_item pkt;
   forever begin
    pkt=bram_seq_item::type_id::create("pkt");
     wait(bram_if.axil_mon_cb.AWVALID && bram_if.axil_mon_cb.WREADY);
     pkt.awaddr=bram_if.axil_mon_cb.AWADDR;
     pkt.write=WRITE;
     wr_addr_queue.push_back(pkt);
   end
endtask

task bram_monitor::write_data();
    bram_seq_item pkt;
    forever begin
        pkt=bram_seq_item::type_id::create("pkt");
        wait(bram_if.axil_mon_cb.WVALID && bram_if.axil_mon_cb.WREADY);
        pkt=bram_seq_item::type_id::create("pkt");
        pkt.wdata=bram_if.axil_mon_cb.WDATA;
        pkt.wstrb=bram_if.axil_mon_cb.WSTRB;
        wr_data_queue.push_back(pkt);
    end
endtask

task bram_monitor::write_resp();
    bram_seq_item pkt;
    forever begin
        pkt=bram_seq_item::type_id::create("pkt");
        wait(bram_if.axil_mon_cb.BVALID && bram_if.axil_mon_cb.BREADY);
        pkt.bresp=RESPONSE_TYPE'(bram_if.axil_mon_cb.BRESP);
        wr_resp_queue.push_back(pkt);
    end
endtask

task bram_monitor::read_addr();
    bram_seq_item pkt;
    forever begin
        pkt=bram_seq_item::type_id::create("pkt");
        wait(bram_if.axil_mon_cb.ARADDR && bram_if.axil_mon_cb.ARREADY);
        pkt.araddr=bram_if.axil_mon_cb.ARADDR;
        pkt.write=READ;
        rd_addr_queue.push_back(pkt);
    end
endtask

task bram_monitor::read_data();
    bram_seq_item pkt;
    forever begin
        pkt=bram_seq_item::type_id::create("pkt");
        wait(bram_if.axil_mon_cb.RVALID && bram_if.axil_mon_cb.RREADY);
        pkt.rdata=bram_if.axil_mon_cb.RDATA;
        pkt.rresp=RESPONSE_TYPE'(bram_if.axil_mon_cb.RRESP);
        rd_data_queue.push_back(pkt);
    end
endtask

task bram_monitor::merge_write();
    bram_seq_item wr_pkt;
    forever begin
     wr_pkt=bram_seq_item::type_id::create("wr_pkt");
        wait(wr_data_queue.size()>0 && wr_addr_queue.size()>0 && wr_resp_queue.size()>0);//begin
            wr_pkt.awaddr=wr_addr_queue[0].awaddr;
            wr_pkt.write=wr_addr_queue[0].write;
            wr_pkt.wdata=wr_data_queue[0].wdata;
            wr_pkt.wstrb=wr_data_queue[0].wstrb;
            wr_pkt.bresp=wr_resp_queue[0].bresp;
            void'(wr_addr_queue.pop_front());
            void'(wr_data_queue.pop_front());
            void'(wr_resp_queue.pop_front());
            mon_ap.write(wr_pkt);
       // end
    end
endtask

task bram_monitor::merge_read();
    bram_seq_item rd_pkt;
    forever begin
        rd_pkt=bram_seq_item::type_id::create("rd_pkt");
        wait(rd_addr_queue.size()>0 && rd_data_queue.size()>0);//begin
        rd_pkt.araddr=rd_addr_queue[0].araddr;
        rd_pkt.write=rd_addr_queue[0].write;
        rd_pkt.rdata=rd_data_queue[0].rdata;
        rd_pkt.rresp=rd_data_queue[0].rresp;
        void'(rd_addr_queue.pop_front());
        void'(rd_data_queue.pop_front());
        mon_ap.write(rd_pkt);
      // end 
    end
endtask
