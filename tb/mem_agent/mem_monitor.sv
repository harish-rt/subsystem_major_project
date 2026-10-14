class mem_monitor extends uvm_monitor;
    `uvm_component_utils(mem_monitor)

    function new(string name="mem_monitor",uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual axi4_lite_intf.MONITOR_MOD   mon_if;
    uvm_analysis_port#(mem_seq_item) mon_ap;
    mem_seq_item wr_addr_queue[$],wr_data_queue[$],wr_resp_queue[$],rd_addr_queue[$],rd_data_queue[$];
    
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

function void mem_monitor::build_phase(uvm_phase phase);
    mon_ap=new("mon_ap",this);
    if(!uvm_config_db#(virtual axi4_lite_intf.MONITOR_MOD)::get(this,"","MON",mon_if)) begin
		`uvm_fatal("NO_VIF",{"virtual interface is not set for monitor"})
	end
endfunction

task mem_monitor::main_phase(uvm_phase phase);
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

task mem_monitor::write_addr();
    mem_seq_item aw_pkt;
    forever begin
        aw_pkt=mem_seq_item::type_id::create("aw_pkt");
        @(mon_if.axil_mon_cb);
        wait(mon_if.axil_mon_cb.AWVALID && mon_if.axil_mon_cb.AWREADY);
        aw_pkt.awaddr=mon_if.axil_mon_cb.AWADDR;
        aw_pkt.trans_type=WRITE;
        wr_addr_queue.push_back(aw_pkt);
        `uvm_info("MEM_MONITOR", "Inside write_addr task", UVM_MEDIUM)
   end
endtask

task mem_monitor::write_data();
    mem_seq_item w_pkt;
    forever begin
        w_pkt=mem_seq_item::type_id::create("w_pkt");
        @(mon_if.axil_mon_cb);
        wait(mon_if.axil_mon_cb.WVALID && mon_if.axil_mon_cb.WREADY);
        w_pkt.wdata=mon_if.axil_mon_cb.WDATA;
        w_pkt.wstrb=mon_if.axil_mon_cb.WSTRB;
        wr_data_queue.push_back(w_pkt);
        `uvm_info("MEM_MONITOR", "Inside write_data task", UVM_MEDIUM)
    end
endtask

task mem_monitor::write_resp();
    mem_seq_item b_pkt;
    forever begin
        b_pkt=mem_seq_item::type_id::create("b_pkt");
        @(mon_if.axil_mon_cb);
        wait(mon_if.axil_mon_cb.BVALID && mon_if.axil_mon_cb.BREADY);
        b_pkt.bresp=RESPONSE_TYPE'(mon_if.axil_mon_cb.BRESP);
        wr_resp_queue.push_back(b_pkt);
        `uvm_info("MEM_MONITOR", "Inside write_resp task", UVM_MEDIUM)
    end
endtask

task mem_monitor::read_addr();
    mem_seq_item ar_pkt;
    forever begin
        ar_pkt=mem_seq_item::type_id::create("ar_pkt");
        @(mon_if.axil_mon_cb);
        wait(mon_if.axil_mon_cb.ARVALID && mon_if.axil_mon_cb.ARREADY);
        ar_pkt.araddr=mon_if.axil_mon_cb.ARADDR;
        ar_pkt.trans_type=READ;
        rd_addr_queue.push_back(ar_pkt);
        `uvm_info("MEM_MONITOR", "Inside read_addr task", UVM_MEDIUM)
    end
endtask

task mem_monitor::read_data();
    mem_seq_item r_pkt;
    forever begin
        r_pkt=mem_seq_item::type_id::create("r_pkt");
        @(mon_if.axil_mon_cb);
        wait(mon_if.axil_mon_cb.RVALID && mon_if.axil_mon_cb.RREADY);
        r_pkt.rdata=mon_if.axil_mon_cb.RDATA;
        r_pkt.rresp=RESPONSE_TYPE'(mon_if.axil_mon_cb.RRESP);
        rd_data_queue.push_back(r_pkt);
        `uvm_info("MEM_MONITOR", "Inside read_data task", UVM_MEDIUM)
    end
endtask

task mem_monitor::merge_write();
    mem_seq_item wr_pkt;
    forever begin
        wr_pkt=mem_seq_item::type_id::create("wr_pkt");
        @(mon_if.axil_mon_cb);
        wait(wr_data_queue.size()>0 && wr_addr_queue.size()>0 && wr_resp_queue.size()>0);
        wr_pkt.awaddr=wr_addr_queue[0].awaddr;
        wr_pkt.trans_type=wr_addr_queue[0].trans_type;
        wr_pkt.wdata=wr_data_queue[0].wdata;
        wr_pkt.wstrb=wr_data_queue[0].wstrb;
        wr_pkt.bresp=wr_resp_queue[0].bresp;
        `uvm_info("WR_PKT_MERGE", wr_pkt.sprint(), UVM_MEDIUM)
        void'(wr_addr_queue.pop_front());
        void'(wr_data_queue.pop_front());
        void'(wr_resp_queue.pop_front());
        mon_ap.write(wr_pkt);
    end
endtask

task mem_monitor::merge_read();
    mem_seq_item rd_pkt;
    forever begin
        rd_pkt=mem_seq_item::type_id::create("rd_pkt");
        @(mon_if.axil_mon_cb);
        wait(rd_addr_queue.size()>0 && rd_data_queue.size()>0);
        rd_pkt.araddr=rd_addr_queue[0].araddr;
        rd_pkt.trans_type=rd_addr_queue[0].trans_type;
        rd_pkt.rdata=rd_data_queue[0].rdata;
        rd_pkt.rresp=rd_data_queue[0].rresp;
        `uvm_info("RD_PKT_MERGE", rd_pkt.sprint(), UVM_MEDIUM)
        void'(rd_addr_queue.pop_front());
        void'(rd_data_queue.pop_front());
        mon_ap.write(rd_pkt);
    end
endtask
