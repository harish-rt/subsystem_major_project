`include "uvm_macros.svh"
import uvm_pkg::*;

class cpu_monitor extends uvm_monitor;
   `uvm_component_utils(cpu_monitor)

   uvm_analysis_port #(cpu_seq_item)   mon_ap;
   virtual cpu_intf.MON_MOD_cpu        cpu_mon_intf;

   // Mailboxes for write/read phases
   mailbox #(cpu_seq_item)  write_address_mbx, write_data_mbx;
   mailbox #(cpu_seq_item)  read_address_mbx, read_data_mbx;

   function new(string name="cpu_monitor", uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon_ap = new("mon_ap", this);
      `uvm_info(get_full_name(), phase.get_name(), UVM_MEDIUM)
   endfunction

   task main_phase(uvm_phase phase);
      `uvm_info(get_full_name(), phase.get_name(), UVM_MEDIUM)
      fork
         capture_reset();
         capture_write_address();
         capture_write_data();
         capture_write_response();
         capture_read_address();
         capture_read_data();
      join
   endtask

   // ---------------- Reset ----------------
   task capture_reset();
      cpu_seq_item rst_pkt;
      fork
         forever begin
            @(posedge cpu_mon_intf.areset_n);
            rst_pkt = cpu_seq_item::type_id::create("rst_pkt");
            rst_pkt.reset_op = RESET_DEASSERTED;
            rst_pkt.reset_deasserted = $realtime();
            `uvm_info("cpu_monitor::capture_reset","reset_deasserted_pkt to SB",UVM_LOW);
            mon_ap.write(rst_pkt);
         end
         forever begin
            @(negedge cpu_mon_intf.areset_n);
            rst_pkt = cpu_seq_item::type_id::create("rst_pkt");
            rst_pkt.reset_op = RESET_ASSERTED;
            rst_pkt.reset_deasserted = $realtime();
            `uvm_info("cpu_monitor::capture_reset","reset_asserted_pkt to SB",UVM_LOW);
            mon_ap.write(rst_pkt);
         end
      join
   endtask

   // ---------------- Write Address ----------------
   task capture_write_address();
      cpu_seq_item pkt;
      write_address_mbx = new();
      forever begin
         `uvm_info("cpu_monitor::capture_write_address","Triggered",UVM_LOW);
         wait(cpu_mon_intf.cpu_mon_cb.awvalid && cpu_mon_intf.cpu_mon_cb.awready && cpu_mon_intf.areset_n);
         pkt = cpu_seq_item::type_id::create("pkt");
         pkt.wadd_hndshk = $realtime();
         pkt.awaddr      = cpu_mon_intf.cpu_mon_cb.awaddr;
         pkt.operation   = WRITE;
         write_address_mbx.put(pkt);
         @(cpu_mon_intf.cpu_mon_cb);
      end
   endtask

   // ---------------- Write Data ----------------
   task capture_write_data();
      cpu_seq_item pkt;
      int i;
      write_data_mbx = new();
      forever begin
         `uvm_info("cpu_monitor::capture_write_data","Triggered",UVM_LOW);
         i=0;
         wait(cpu_mon_intf.cpu_mon_cb.wvalid && cpu_mon_intf.cpu_mon_cb.wready && cpu_mon_intf.areset_n);
         pkt = cpu_seq_item::type_id::create("pkt");
         pkt.wdata_hndshk[i] = $realtime();
         pkt.wdata        = cpu_mon_intf.cpu_mon_cb.wdata;
         pkt.wstrobe      = cpu_mon_intf.cpu_mon_cb.wstrobe;
         write_data_mbx.put(pkt);
         @(cpu_mon_intf.cpu_mon_cb);
      end
   endtask

   // ---------------- Write Response ----------------
   task capture_write_response();
      cpu_seq_item addr_pkt, data_pkt, merged_pkt;
      forever begin
         `uvm_info("cpu_monitor::capture_write_response","Triggered",UVM_LOW);
         wait(cpu_mon_intf.cpu_mon_cb.bvalid && cpu_mon_intf.cpu_mon_cb.bready && cpu_mon_intf.areset_n);
         if (write_address_mbx.num() > 0 && write_data_mbx.num() > 0) begin
            write_address_mbx.get(addr_pkt);
            write_data_mbx.get(data_pkt);
            merged_pkt = cpu_seq_item::type_id::create("merged_pkt");
            merged_pkt.operation   = WRITE;
            merged_pkt.awaddr      = addr_pkt.awaddr;
            merged_pkt.wadd_hndshk = addr_pkt.wadd_hndshk;
            merged_pkt.wdata       = data_pkt.wdata;
            merged_pkt.wstrobe     = data_pkt.wstrobe;
            merged_pkt.wdata_hndshk= data_pkt.wdata_hndshk;
            merged_pkt.bresp       = response_t'(cpu_mon_intf.cpu_mon_cb.bresp);
            merged_pkt.wresp_hndshk= $realtime();
            `uvm_info("cpu_monitor::capture_write_response","Sending pkt to SB",UVM_LOW);
            mon_ap.write(merged_pkt);
         end
         @(cpu_mon_intf.cpu_mon_cb);
      end
   endtask

   // ---------------- Read Address ----------------
   task capture_read_address();
      cpu_seq_item pkt;
      read_address_mbx = new();
      forever begin
         `uvm_info("cpu_monitor::capture_read_address","Triggered",UVM_LOW);
         wait(cpu_mon_intf.cpu_mon_cb.arvalid && cpu_mon_intf.cpu_mon_cb.arready && cpu_mon_intf.areset_n);
         pkt = cpu_seq_item::type_id::create("pkt");
         pkt.radd_hndshk = $realtime();
         pkt.araddr      = cpu_mon_intf.cpu_mon_cb.araddr;
         pkt.operation   = READ;
         read_address_mbx.put(pkt);
         @(cpu_mon_intf.cpu_mon_cb);
      end
   endtask

   // ---------------- Read Data ----------------
   task capture_read_data();
      cpu_seq_item addr_pkt, data_pkt;
      int i;
      read_data_mbx = new();
      forever begin
         `uvm_info("cpu_monitor::capture_read_data","Triggered",UVM_LOW);
         i=0;
         wait(cpu_mon_intf.cpu_mon_cb.rvalid && cpu_mon_intf.cpu_mon_cb.rready && cpu_mon_intf.areset_n);
         if (read_address_mbx.num() > 0) begin
            read_address_mbx.get(addr_pkt);
            data_pkt = cpu_seq_item::type_id::create("data_pkt");
            data_pkt.operation   = READ;
            data_pkt.araddr      = addr_pkt.araddr;
            data_pkt.radd_hndshk = addr_pkt.radd_hndshk;
            data_pkt.rdata       = cpu_mon_intf.cpu_mon_cb.rdata;
            data_pkt.rresp       = response_t'(cpu_mon_intf.cpu_mon_cb.rresp);
            data_pkt.rdata_hndshk[i]= $realtime();
            `uvm_info("cpu_monitor::capture_read_data","Sending READ pkt to SB",UVM_LOW);
            mon_ap.write(data_pkt);
         end
         @(cpu_mon_intf.cpu_mon_cb);
      end
   endtask
endclass:cpu_monitor










/*class cpu_monitor extends uvm_monitor;
   `uvm_component_utils (cpu_monitor)
   uvm_analysis_port #(cpu_seq_item)   mon_ap;
   virtual cpu_intf.MON_MOD_cpu     cpu_mon_intf;
   mailbox #(cpu_seq_item)  write_address_mbx ,write_data_mbx;      
   mailbox #(cpu_seq_item) read_address_array [id_t];
   mailbox #(cpu_seq_item) read_data_array[id_t];

   function new (string name = "cpu_monitor" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern task main_phase (uvm_phase phase);
   extern function void build_phase (uvm_phase phase);
   extern task  merge_write_info();
   extern task  capture_reset();
   extern task  capture_write_address();
   extern task  capture_write_data();
   extern task  capture_write_response();
   extern task  capture_read_address();
   extern task  capture_read_data();

endclass :cpu_monitor

   function void cpu_monitor :: build_phase (uvm_phase phase);
     super.build_phase (phase);
     mon_ap = new ("mon_ap",this);
     `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
   endfunction : build_phase

task cpu_monitor :: main_phase (uvm_phase phase);
 `uvm_info (get_full_name() , phase.get_name() , UVM_MEDIUM)
 fork
  capture_reset();
  capture_write_address();
  capture_write_data();
  capture_write_response();
  capture_read_address();
  capture_read_data();
 join
endtask

task  cpu_monitor :: capture_write_address();
 cpu_seq_item     pkt;
 write_address_mbx = new ();
 forever begin
    `uvm_info("cpu_monitor :: capture_write_address","Triggred",UVM_LOW);
    pkt = cpu_seq_item :: type_id :: create("pkt");
    wait( cpu_mon_intf.cpu_mon_cb.awready && cpu_mon_intf.cpu_mon_cb.awvalid && cpu_mon_intf.areset_n==1);
    pkt.wadd_hndshk = $realtime();  //capturing timestamp for handshake.
    pkt.awaddr   = cpu_mon_intf.cpu_mon_cb.awaddr;
    pkt.awburst  = burst_type_t'(cpu_mon_intf.cpu_mon_cb.awburst);
    pkt.awcache  = cpu_mon_intf.cpu_mon_cb.awcache;
    pkt.awid     = cpu_mon_intf.cpu_mon_cb.awid;
    pkt.awlen    = cpu_mon_intf.cpu_mon_cb.awlen;
    pkt.awlock   = cpu_mon_intf.cpu_mon_cb.awlock;
    pkt.awprot   = cpu_mon_intf.cpu_mon_cb.awprot;
    pkt.awqos    = cpu_mon_intf.cpu_mon_cb.awqos;
    pkt.awregion = cpu_mon_intf.cpu_mon_cb.awregion;
    pkt.awsize   = cpu_mon_intf.cpu_mon_cb.awsize;
    pkt.operation = WRITE;
    `uvm_info("cpu_monitor :: capture_write_address","captured address pkt put to write_address_mbx",UVM_LOW);
    //`uvm_info("MASTER_MONITOR:: capture_write_address",pkt.sprint(),UVM_MEDIUM)
    write_address_mbx.put(pkt);
    @(cpu_mon_intf.cpu_mon_cb); //wait for a clk
  end
endtask

task  cpu_monitor ::  capture_write_data();
 cpu_seq_item     pkt;
 int i;
 bit last;
 write_data_mbx =    new ();
 forever begin
    `uvm_info("cpu_monitor :: capture_write_data","Triggred",UVM_LOW);
    pkt = cpu_seq_item :: type_id :: create("pkt");
    pkt.wdata_hndshk =new[0];
    pkt.wdata =new[0];
    pkt.wstrobe= new[0];
    i = 0;
    do begin
      wait( cpu_mon_intf.cpu_mon_cb.wready==1 && cpu_mon_intf.cpu_mon_cb.wvalid==1 && cpu_mon_intf.areset_n==1); 
      `uvm_info("cpu_monitor :: capture_write_data","Inside dowhile loop",UVM_LOW);
      pkt.wdata_hndshk =new[pkt.wdata_hndshk.size() +1](pkt.wdata_hndshk);
      pkt.wdata =new[pkt.wdata.size() +1](pkt.wdata);
      pkt.wstrobe =new[pkt.wstrobe.size() +1](pkt.wstrobe);
      pkt.wdata_hndshk[i] = $realtime();  
      pkt.wdata[i]    = cpu_mon_intf.cpu_mon_cb.wdata;
      pkt.wstrobe[i]  = cpu_mon_intf.cpu_mon_cb.wstrobe;
      last = cpu_mon_intf.cpu_mon_cb.wlast;
      i=i+1;
      @(cpu_mon_intf.cpu_mon_cb); 
      end while(last==0);        
      `uvm_info("cpu_monitor :: capture_write_data","captured data pkt put to write_data_mbx",UVM_LOW);
      `uvm_info("MASTER_MONITOR:: capture_write_data",pkt.sprint(),UVM_MEDIUM)
      write_data_mbx.put(pkt);
 end
endtask

task  cpu_monitor ::  capture_write_response();
 cpu_seq_item     pkt;
 forever begin
    `uvm_info("cpu_monitor :: capture_write_response","Triggred",UVM_LOW);
    wait( cpu_mon_intf.cpu_mon_cb.bready==1 && cpu_mon_intf.cpu_mon_cb.bvalid==1 && cpu_mon_intf.areset_n==1);
    merge_write_info(); //merges addr+data info waiting for response
    if(wresp_array.exists(cpu_mon_intf.cpu_mon_cb.bid)) begin    
       pkt = cpu_seq_item :: type_id :: create("pkt");
       wresp_array[cpu_mon_intf.cpu_mon_cb.bid].get(pkt);           //this pkt already has add + data info
       pkt.wresp_hndshk = $realtime();  
       pkt.bid    = cpu_mon_intf.cpu_mon_cb.bid;
       pkt.bresp  =response_t'( cpu_mon_intf.cpu_mon_cb.bresp);
    `uvm_info("cpu_monitor :: capture_write_response","Sending pkt to SB",UVM_LOW);
    `uvm_info("MASTER_MONITOR:: capture_write_responce",pkt.sprint(),UVM_MEDIUM)
       mon_ap.write(pkt); //write pkt to sb
    `uvm_info("MASTER_MONITOR:: capture_write_response",pkt.sprint(),UVM_MEDIUM)       
    end else `uvm_warning("Master_monitor :: capture_write_response",$sformatf("unexpected write response, BID not found bid= %b",cpu_mon_intf.cpu_mon_cb.bid))
    @(cpu_mon_intf.cpu_mon_cb); 
 end
endtask

task  cpu_monitor :: capture_read_address();
 cpu_seq_item     pkt;
 forever begin
    `uvm_info("cpu_monitor :: capture_read_address","Triggred",UVM_LOW);
    pkt = cpu_seq_item :: type_id :: create("pkt");
    wait( cpu_mon_intf.cpu_mon_cb.arready==1 && cpu_mon_intf.cpu_mon_cb.arvalid==1 && cpu_mon_intf.areset_n==1);
    pkt.radd_hndshk = $realtime();  
    pkt.araddr   = cpu_mon_intf.cpu_mon_cb.araddr;
    pkt.arburst  = burst_type_t'(cpu_mon_intf.cpu_mon_cb.arburst);
    pkt.arcache  = cpu_mon_intf.cpu_mon_cb.arcache;
    pkt.arid     = cpu_mon_intf.cpu_mon_cb.arid;
    pkt.arlen    = cpu_mon_intf.cpu_mon_cb.arlen;
    pkt.arlock   = cpu_mon_intf.cpu_mon_cb.arlock;
    pkt.arprot   = cpu_mon_intf.cpu_mon_cb.arprot;
    pkt.arqos    = cpu_mon_intf.cpu_mon_cb.arqos;
    pkt.arregion = cpu_mon_intf.cpu_mon_cb.arregion;
    pkt.arsize   = cpu_mon_intf.cpu_mon_cb.arsize;
    pkt.operation = READ;
    if(!read_address_array.exists(pkt.arid)) read_address_array[pkt.arid]=new();
    read_address_array[pkt.arid].put(pkt);
    @(cpu_mon_intf.cpu_mon_cb); 
  end
endtask

task cpu_monitor::capture_read_data();
    cpu_seq_item addr_pkt, data_pkt, pkt2sb;
    int i;
    forever begin
        `uvm_info("cpu_monitor :: capture_read_data", "Triggered", UVM_LOW);
        pkt2sb = cpu_seq_item::type_id::create("pkt2sb");
        pkt2sb.operation = READ;
        wait(cpu_mon_intf.cpu_mon_cb.rready && cpu_mon_intf.cpu_mon_cb.rvalid && cpu_mon_intf.areset_n);
        if (!read_address_array.exists(cpu_mon_intf.cpu_mon_cb.rid)) begin
            `uvm_warning("MASTER_MON", $sformatf("No address packet found for RID=0x%0h", cpu_mon_intf.cpu_mon_cb.rid));
            @(cpu_mon_intf.cpu_mon_cb);
            continue;
        end
        read_address_array[cpu_mon_intf.cpu_mon_cb.rid].get(addr_pkt);
        pkt2sb.araddr   = addr_pkt.araddr;
        pkt2sb.arburst  = addr_pkt.arburst;
        pkt2sb.arlen    = addr_pkt.arlen;
        pkt2sb.arsize   = addr_pkt.arsize;
        pkt2sb.arid     = addr_pkt.arid;
        pkt2sb.radd_hndshk = addr_pkt.radd_hndshk;
        i = 0;
        do begin
            data_pkt = cpu_seq_item::type_id::create("data_pkt");
            data_pkt.rid   = cpu_mon_intf.cpu_mon_cb.rid;
            data_pkt.rdata = new[i+1](data_pkt.rdata);
            data_pkt.rresp = new[i+1](data_pkt.rresp);
            data_pkt.rdata_hndshk = new[i+1](data_pkt.rdata_hndshk);
            data_pkt.rdata[i]        = cpu_mon_intf.cpu_mon_cb.rdata;
            data_pkt.rresp[i]        = response_t'(cpu_mon_intf.cpu_mon_cb.rresp);
            data_pkt.rdata_hndshk[i] = $realtime();
            if (i == 0) pkt2sb.rid = data_pkt.rid;
            i++;
            @(cpu_mon_intf.cpu_mon_cb);
        end while (cpu_mon_intf.cpu_mon_cb.rlast == 0);
        pkt2sb.rdata = new[i];
        pkt2sb.rresp = new[i];
        pkt2sb.rdata_hndshk = new[i];
        for (int j=0; j<i; j++) begin
            pkt2sb.rdata[j]        = data_pkt.rdata[j];   
            pkt2sb.rresp[j]        = data_pkt.rresp[j];
            pkt2sb.rdata_hndshk[j] = data_pkt.rdata_hndshk[j];
        end

        `uvm_info("MASTER_MONITOR:: capture_read_data",$sformatf("Sending READ to SB/Cov | ARADDR=0x%0h | RDATA[0]=0x%0h",pkt2sb.araddr, pkt2sb.rdata[0]), UVM_MEDIUM);
        mon_ap.write(pkt2sb);     
    end
endtask

task cpu_monitor :: merge_write_info();
cpu_seq_item addr_pkt,data_pkt,merged_pkt;
int x ,no_addr, no_data; 
  `uvm_info("cpu_monitor :: merge_write_info","Triggred",UVM_LOW);
  no_addr = write_address_mbx.num();
  no_data = write_data_mbx.num();
  x = (no_addr<no_data)? no_addr :no_data;
  merged_pkt = cpu_seq_item :: type_id :: create("merged_pkt");
  write_address_mbx.get(addr_pkt);
  write_data_mbx.get(data_pkt);
  //Merging address and data phases
   //write address_phase
   merged_pkt.operation = WRITE;
   merged_pkt.wadd_hndshk = addr_pkt.wadd_hndshk;
   merged_pkt.awburst     = addr_pkt.awburst;
   merged_pkt.awaddr      = addr_pkt.awaddr;
   merged_pkt.awsize      = addr_pkt.awsize;
   merged_pkt.awid        = addr_pkt.awid;
   merged_pkt.awlen       = addr_pkt.awlen;
   merged_pkt.awlock      = addr_pkt.awlock;
   merged_pkt.awprot      = addr_pkt.awprot;
   merged_pkt.awqos       = addr_pkt.awqos;
   merged_pkt.awcache     = addr_pkt.awcache;
   merged_pkt.awregion    = addr_pkt.awregion;
   //write data phase
   merged_pkt.wdata_hndshk =data_pkt.wdata_hndshk;
   merged_pkt.wdata    = data_pkt.wdata;
   merged_pkt.wstrobe  = data_pkt.wstrobe;
  //adding packets to array waiting for response
   `uvm_info("cpu_monitor :: merge_write_info",$sformatf("putting merged pkt to wresp_array awid = %b",merged_pkt.awid),UVM_LOW);
    if(!wresp_array.exists(merged_pkt.awid)) wresp_array[merged_pkt.awid] = new();
    wresp_array[merged_pkt.awid].put(merged_pkt);
endtask

task cpu_monitor :: capture_reset();
 cpu_seq_item     rst_pkt;
 `uvm_info("cpu_monitor :: capture_reset","Triggred",UVM_LOW);
 fork
  forever begin //reset deasserted
    @(posedge cpu_mon_intf.areset_n) ;
    rst_pkt = cpu_seq_item :: type_id :: create("rst_pkt");
    rst_pkt.reset_op = RESET_DEASSERTED;
    rst_pkt.reset_deasserted = $realtime();
    `uvm_info("cpu_monitor :: capture_reset","reset_deasserted_pkt to SB",UVM_LOW);
    mon_ap.write(rst_pkt);
  end
  forever begin //reset asserted
    @(negedge cpu_mon_intf.areset_n) ;
    rst_pkt = cpu_seq_item :: type_id :: create("rst_pkt");
    rst_pkt.reset_op = RESET_ASSERTED;
    rst_pkt.reset_deasserted = $realtime();
    `uvm_info("cpu_monitor :: capture_reset","reset_asserted_pkt to SB",UVM_LOW);
    mon_ap.write(rst_pkt);
  end
join
endtask*/


