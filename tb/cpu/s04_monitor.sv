class s04_monitor extends uvm_monitor;

   `uvm_component_utils (s04_monitor)
   //uvm_analysis_port #(axi_base_sequence_item)    mon_ap;
   uvm_analysis_port #(s04_seq_item)    mon_ap;
   uvm_analysis_port #(s04_seq_item)    resp_ap;
   virtual axi4_tb_intf.MONITOR_MOD                 mon_intf;
   mailbox #(s04_seq_item) write_address_mbx ,write_data_mbx;
   mailbox #(s04_seq_item) wresp_array [id_t];
   mailbox #(s04_seq_item) read_address_array [id_t];
   mailbox #(s04_seq_item) read_data_array[id_t];

   `NEW_COMP

   extern task main_phase (uvm_phase phase);
   extern function void build_phase (uvm_phase phase);
   extern task  merge_write_info();
   extern task  capture_reset();
   extern task  capture_write_address();
   extern task  capture_write_data();
   extern task  capture_write_response();
   extern task  capture_read_address();
   extern task  capture_read_data();
endclass :s04_monitor

function void s04_monitor :: build_phase (uvm_phase phase);
  super.build_phase (phase);
        //if (!uvm_config_db#(virtual axi4_tb_intf.MONITOR_MOD)::get(this,"","S04_MON",mon_intf)) begin
        //    `uvm_fatal(get_full_name(), "virtual axi4_tb_intf get failed from config_db!")
        //end
  mon_ap = new ("mon_ap",this);
  resp_ap = new("resp_ap",this);
  `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
endfunction : build_phase

task s04_monitor :: main_phase (uvm_phase phase);
 `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
 fork
  capture_reset();
  capture_write_address();
  capture_write_data();
  capture_write_response();
  capture_read_address();
  capture_read_data();
  merge_write_info();
 join
endtask

task  s04_monitor :: capture_write_address();
 s04_seq_item           pkt;
 write_address_mbx = new ();
 forever begin
    `uvm_info("s04_monitor :: capture_write_address","Triggred",UVM_LOW);
    pkt = s04_seq_item :: type_id :: create("pkt");
    wait(mon_intf.axi4_mon_cb.AWVALID && mon_intf.ARESETn==1); //wait for valid
    pkt.AWADDR   = mon_intf.axi4_mon_cb.AWADDR;
    pkt.AWBURST  = burst_type_t'(mon_intf.axi4_mon_cb.AWBURST);
    pkt.AWCACHE  = mon_intf.axi4_mon_cb.AWCACHE;
    pkt.AWID     = mon_intf.axi4_mon_cb.AWID;
    pkt.AWLEN    = mon_intf.axi4_mon_cb.AWLEN;
    pkt.AWLOCK   = mon_intf.axi4_mon_cb.AWLOCK;
    pkt.AWPROT   = mon_intf.axi4_mon_cb.AWPROT;
    pkt.AWQOS    = mon_intf.axi4_mon_cb.AWQOS;
    pkt.AWREGION = mon_intf.axi4_mon_cb.AWREGION;
    pkt.AWSIZE   = mon_intf.axi4_mon_cb.AWSIZE;
    //pkt.operation= command_t'(WRITE);
    pkt.operation   = WRITE;
    resp_ap.write(pkt); //write pkt to sequencer for response
    wait( mon_intf.axi4_mon_cb.AWREADY && mon_intf.axi4_mon_cb.AWVALID && mon_intf.ARESETn==1); //wait for handshake
    pkt.wadd_hndshk = $realtime();  //capturing timestamp for handshake.
    `uvm_info("s04_monitor_capture_write_address",pkt.sprint(),UVM_LOW);
    write_address_mbx.put(pkt);
    @(mon_intf.axi4_mon_cb); //wait till next clk posedge
  end
endtask

task  s04_monitor ::  capture_write_data();
 s04_seq_item     pkt;
 int i;
 bit last;
 write_data_mbx =    new ();
 forever begin
    `uvm_info("s04_monitor :: capture_write_data","Triggred",UVM_LOW);
    pkt = s04_seq_item :: type_id :: create("pkt");
    pkt.wdata_hndshk =new[0];
    pkt.WDATA =new[0];
    pkt.WSTRB= new[0];
    i = 0;
    do begin
      @(mon_intf.axi4_mon_cb); //wait till next clk posedge
      wait( mon_intf.axi4_mon_cb.WREADY==1 && mon_intf.axi4_mon_cb.WVALID==1 && mon_intf.ARESETn==1);
      pkt.wdata_hndshk =new[pkt.wdata_hndshk.size() +1](pkt.wdata_hndshk);
      pkt.WDATA =new[pkt.WDATA.size() +1](pkt.WDATA);
      pkt.WSTRB =new[pkt.WSTRB.size() +1](pkt.WSTRB);
      pkt.wdata_hndshk[i] = $realtime();  //capturing timestamp for handshake.
      pkt.WDATA[i]    = mon_intf.axi4_mon_cb.WDATA;
      pkt.WSTRB[i]  = mon_intf.axi4_mon_cb.WSTRB;
      last = mon_intf.axi4_mon_cb.WLAST;
      i=i+1;
      end while( last==0); //keeps sampling till last indicates end of data phase.
    `uvm_info("s04_monitor_capture_write_data",pkt.sprint(),UVM_LOW)
    write_data_mbx.put(pkt);
 end
endtask

task s04_monitor :: capture_write_response();
    s04_seq_item pkt;
    bit [3:0] t_bid;
    
    forever begin
        @(mon_intf.axi4_mon_cb);
        if (mon_intf.axi4_mon_cb.BREADY == 1 && mon_intf.axi4_mon_cb.BVALID == 1 && mon_intf.ARESETn == 1) begin
            `uvm_info("bram_monitor :: capture_write_response", "Handshake detected...", UVM_LOW);
            
            t_bid = mon_intf.axi4_mon_cb.BID;

            if (!wresp_array.exists(t_bid)) begin
                wresp_array[t_bid] = new();
            end

            pkt = s04_seq_item::type_id::create("pkt");
            wresp_array[t_bid].get(pkt);
            
            pkt.BID   = mon_intf.axi4_mon_cb.BID;
            pkt.BRESP = response_t'(mon_intf.axi4_mon_cb.BRESP);
            
            pkt.master_p = MST_S04;
            mon_ap.write(pkt); 
            `uvm_info("s04_monitor_capture_write_resp",pkt.sprint(),UVM_LOW)
        end
    end
endtask:capture_write_response

task  s04_monitor :: capture_read_address();
 s04_seq_item     pkt;
 forever begin
    `uvm_info("s04_monitor :: capture_read_address","Triggred",UVM_LOW);
    pkt = s04_seq_item :: type_id :: create("pkt");
    wait(mon_intf.axi4_mon_cb.ARVALID==1 && mon_intf.ARESETn==1); //wait for valid
    pkt.ARADDR   = mon_intf.axi4_mon_cb.ARADDR;
    pkt.ARBURST  = burst_type_t'(mon_intf.axi4_mon_cb.ARBURST);
    pkt.ARCACHE  = mon_intf.axi4_mon_cb.ARCACHE;
    pkt.ARID     = mon_intf.axi4_mon_cb.ARID;
    pkt.ARLEN    = mon_intf.axi4_mon_cb.ARLEN;
    pkt.ARLOCK   = mon_intf.axi4_mon_cb.ARLOCK;
    pkt.ARPROT   = mon_intf.axi4_mon_cb.ARPROT;
    pkt.ARQOS    = mon_intf.axi4_mon_cb.ARQOS;
    pkt.ARREGION = mon_intf.axi4_mon_cb.ARREGION;
    pkt.ARSIZE   = mon_intf.axi4_mon_cb.ARSIZE;
    //pkt.operation= command_t'(READ);
    pkt.operation   = READ;
    resp_ap.write(pkt); //write pkt to sequencer for response
    wait( mon_intf.axi4_mon_cb.ARREADY==1 && mon_intf.axi4_mon_cb.ARVALID==1 && mon_intf.ARESETn==1); //handshake
    pkt.radd_hndshk = $realtime();  //capturing timestamp for handshake.
    `uvm_info("s04_monitor_capture_read_address",pkt.sprint(),UVM_LOW);
    //`uvm_info("s04_monitor :: capture_read_address",$sformatf("captured address pkt put to read_address_array arid=%d",pkt.ARID),UVM_LOW);
    if(!read_address_array.exists(pkt.ARID)) read_address_array[pkt.ARID]=new();
    read_address_array[pkt.ARID].put(pkt);
    @(mon_intf.axi4_mon_cb); //wait till next clk posedge
  end
endtask

task  s04_monitor ::  capture_read_data();
 s04_seq_item     pkt, pkt2sb;
 int i,no_of_beats;
 bit last;
 forever begin
    `uvm_info("s04_monitor :: capture_read_data","Triggred",UVM_LOW);
    i = 0;
    do begin
      pkt = s04_seq_item :: type_id :: create("pkt");
      pkt.rdata_hndshk = new[1];
      pkt.RDATA =new [1];
      pkt.RRESP =new [1];
      wait(mon_intf.axi4_mon_cb.RREADY==1 && mon_intf.axi4_mon_cb.RVALID==1 && mon_intf.ARESETn==1);
      pkt.rdata_hndshk[0] = $realtime();  //capturing timestamp for handshake.
      pkt.RID       = mon_intf.axi4_mon_cb.RID;
      pkt.RDATA[0]  = mon_intf.axi4_mon_cb.RDATA;
      pkt.RRESP[0]  = response_t'(mon_intf.axi4_mon_cb.RRESP);
      pkt.operation   = READ;
      if(!read_data_array.exists(pkt.RID)) read_data_array[pkt.RID] = new();
      read_data_array[pkt.RID].put(pkt);
      i=i+1;
      last = mon_intf.axi4_mon_cb.RLAST;
      @(mon_intf.axi4_mon_cb); //wait till next clk posedge
    end while( last ==0); //keeps sampling till last indicates end of data phase.
      pkt2sb = s04_seq_item :: type_id :: create("pkt2sb");
      //get  pkt with address info and add data info.//
      wait(read_address_array.exists(pkt.RID));
      read_address_array[pkt.RID].get(pkt2sb);  // this has address info for required RID pkt.
      no_of_beats = read_data_array[pkt.RID].num();
      pkt2sb.RID = pkt.RID;
      pkt2sb.RDATA = new[no_of_beats];
      pkt2sb.RRESP = new[no_of_beats];
      pkt2sb.rdata_hndshk = new[no_of_beats];
   //merging beats for which got RLAST
   for(i=0 ; i<no_of_beats; i++)begin         //merges all beats with same RID to pkt having address info
      read_data_array[pkt2sb.RID].get(pkt);
      pkt2sb.RDATA[i] = pkt.RDATA[0];
      pkt2sb.RRESP[i] = pkt.RRESP[0];
      pkt2sb.rdata_hndshk[i] = pkt.rdata_hndshk[0];
   end
    //`uvm_info("s04_monitor :: capture_read_data","Sending pkt to SB",UVM_LOW);
    //pkt2sb.print_read_txn(pkt2sb);
      pkt2sb.master_p = MST_S04;
    `uvm_info("s04_monitor_capture_read_data",pkt2sb.sprint(),UVM_LOW);
    mon_ap.write(pkt2sb); //write pkt to sb
 end
endtask

/*
task s04_monitor :: merge_write_info();
s04_seq_item addr_pkt,data_pkt,merged_pkt;
int x ,no_addr, no_data; //indicates number of completed write transactions waiting for response.
  `uvm_info("s04_monitor :: merge_write_info","Triggred",UVM_LOW);
  no_addr = write_address_mbx.num();
  no_data = write_data_mbx.num();
  x = (no_addr<no_data)? no_addr :no_data;
  repeat(x)begin
  merged_pkt = s04_seq_item :: type_id :: create("merged_pkt");
  write_address_mbx.get(addr_pkt);
  write_data_mbx.get(data_pkt);
  //Merging address and data phases
   //write address_phase
   //merged_pkt.write = WRITE;
   merged_pkt.wadd_hndshk = addr_pkt.wadd_hndshk;
   merged_pkt.AWBURST     = addr_pkt.AWBURST;
   merged_pkt.AWADDR      = addr_pkt.AWADDR;
   merged_pkt.AWSIZE      = addr_pkt.AWSIZE;
   merged_pkt.AWID        = addr_pkt.AWID;
   merged_pkt.AWLEN       = addr_pkt.AWLEN;
   merged_pkt.AWLOCK      = addr_pkt.AWLOCK;
   merged_pkt.AWPROT      = addr_pkt.AWPROT;
   merged_pkt.AWQOS       = addr_pkt.AWQOS;
   merged_pkt.AWCACHE     = addr_pkt.AWCACHE;
   merged_pkt.AWREGION    = addr_pkt.AWREGION;
   //write data phase
   merged_pkt.wdata_hndshk =data_pkt.wdata_hndshk;
   merged_pkt.WDATA    = data_pkt.WDATA;
   merged_pkt.WSTRB  = data_pkt.WSTRB;
    `uvm_info("s04_monitor_capture_merged_pkt",merged_pkt.sprint(),UVM_LOW);
  //adding packets to array waiting for response
    //`uvm_info("s04_monitor :: merge_write_info",$sformatf("putting merged pkt to wresp_array AWID = %b",merged_pkt.AWID),UVM_LOW);
    if(!wresp_array.exists(merged_pkt.AWID)) wresp_array[merged_pkt.AWID] = new();
    wresp_array[merged_pkt.AWID].put(merged_pkt);
  end
endtask
*/

task s04_monitor :: merge_write_info();
  s04_seq_item addr_pkt, data_pkt, merged_pkt;
  `uvm_info("s04_monitor :: merge_write_info","Triggered",UVM_LOW);
  
  forever begin
    write_address_mbx.get(addr_pkt); 
    write_data_mbx.get(data_pkt);
    
    merged_pkt = s04_seq_item::type_id::create("merged_pkt");
    
    merged_pkt.wadd_hndshk = addr_pkt.wadd_hndshk;
    merged_pkt.AWBURST     = addr_pkt.AWBURST;
    merged_pkt.AWADDR      = addr_pkt.AWADDR;
    merged_pkt.AWSIZE      = addr_pkt.AWSIZE;
    merged_pkt.AWID        = addr_pkt.AWID;
    merged_pkt.AWLEN       = addr_pkt.AWLEN;
    merged_pkt.AWLOCK      = addr_pkt.AWLOCK;
    merged_pkt.AWPROT      = addr_pkt.AWPROT;
    merged_pkt.AWQOS       = addr_pkt.AWQOS;
    merged_pkt.AWCACHE     = addr_pkt.AWCACHE;
    merged_pkt.AWREGION    = addr_pkt.AWREGION;
    
    merged_pkt.wdata_hndshk = data_pkt.wdata_hndshk;
    merged_pkt.WDATA        = data_pkt.WDATA;
    merged_pkt.WSTRB        = data_pkt.WSTRB;
    merged_pkt.operation    = WRITE;
    
    `uvm_info("s04_monitor_capture_merged_pkt", merged_pkt.sprint(), UVM_LOW);
    
    if(!wresp_array.exists(merged_pkt.AWID)) 
      wresp_array[merged_pkt.AWID] = new();
      
    wresp_array[merged_pkt.AWID].put(merged_pkt);
  end
endtask:merge_write_info

task s04_monitor :: capture_reset();
 s04_seq_item     rst_pkt;
 `uvm_info("s04_monitor :: capture_reset","Triggred",UVM_LOW);
 fork
  forever begin //reset deasserted
    @(posedge mon_intf.ARESETn);
    rst_pkt = s04_seq_item :: type_id :: create("rst_pkt");
    rst_pkt.reset_op = RESET_DEASSERTED;
    rst_pkt.reset_deasserted = $realtime();
    `uvm_info("s04_monitor :: capture_reset","reset_deasserted_pkt to SB",UVM_LOW);
    mon_ap.write(rst_pkt);
  end
  forever begin //reset asserted
    @(negedge mon_intf.ARESETn) ;
    rst_pkt = s04_seq_item :: type_id :: create("rst_pkt");
    rst_pkt.reset_op = RESET_ASSERTED;
    rst_pkt.reset_deasserted = $realtime();
    `uvm_info("s04_monitor :: capture_reset","reset_asserted_pkt to SB",UVM_LOW);
    mon_ap.write(rst_pkt);
  end
join
endtask
