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
    mem_seq_item pkt;
   forever begin
    `uvm_info("MEM_MONITOR", "Inside write_addr task", UVM_MEDIUM)
    pkt=mem_seq_item::type_id::create("pkt");
     wait(mon_if.axil_mon_cb.AWVALID && mon_if.axil_mon_cb.WREADY);
     pkt.awaddr=mon_if.axil_mon_cb.AWADDR;
     pkt.trans_type=WRITE;
     wr_addr_queue.push_back(pkt);
   end
endtask

task mem_monitor::write_data();
    mem_seq_item pkt;
    forever begin
        `uvm_info("MEM_MONITOR", "Inside write_data task", UVM_MEDIUM)
        pkt=mem_seq_item::type_id::create("pkt");
        wait(mon_if.axil_mon_cb.WVALID && mon_if.axil_mon_cb.WREADY);
        pkt=mem_seq_item::type_id::create("pkt");
        pkt.wdata=mon_if.axil_mon_cb.WDATA;
        pkt.wstrb=mon_if.axil_mon_cb.WSTRB;
        wr_data_queue.push_back(pkt);
    end
endtask

task mem_monitor::write_resp();
    mem_seq_item pkt;
    forever begin
        `uvm_info("MEM_MONITOR", "Inside write_resp task", UVM_MEDIUM)
        pkt=mem_seq_item::type_id::create("pkt");
        wait(mon_if.axil_mon_cb.BVALID && mon_if.axil_mon_cb.BREADY);
        pkt.bresp=RESPONSE_TYPE'(mon_if.axil_mon_cb.BRESP);
        wr_resp_queue.push_back(pkt);
    end
endtask

task mem_monitor::read_addr();
    mem_seq_item pkt;
    forever begin
        `uvm_info("MEM_MONITOR", "Inside read_addr task", UVM_MEDIUM)
        pkt=mem_seq_item::type_id::create("pkt");
        wait(mon_if.axil_mon_cb.ARADDR && mon_if.axil_mon_cb.ARREADY);
        pkt.araddr=mon_if.axil_mon_cb.ARADDR;
        pkt.trans_type=READ;
        rd_addr_queue.push_back(pkt);
    end
endtask

task mem_monitor::read_data();
    mem_seq_item pkt;
    forever begin
        `uvm_info("MEM_MONITOR", "Inside read_data task", UVM_MEDIUM)
        pkt=mem_seq_item::type_id::create("pkt");
        wait(mon_if.axil_mon_cb.RVALID && mon_if.axil_mon_cb.RREADY);
        pkt.rdata=mon_if.axil_mon_cb.RDATA;
        pkt.rresp=RESPONSE_TYPE'(mon_if.axil_mon_cb.RRESP);
        rd_data_queue.push_back(pkt);
    end
endtask

task mem_monitor::merge_write();
    mem_seq_item wr_pkt;
    forever begin
     wr_pkt=mem_seq_item::type_id::create("wr_pkt");
     wait(wr_data_queue.size()>0 && wr_addr_queue.size()>0 && wr_resp_queue.size()>0);//begin
            wr_pkt.awaddr=wr_addr_queue[0].awaddr;
            wr_pkt.trans_type=wr_addr_queue[0].trans_type;
            wr_pkt.wdata=wr_data_queue[0].wdata;
            wr_pkt.wstrb=wr_data_queue[0].wstrb;
            wr_pkt.bresp=wr_resp_queue[0].bresp;
            void'(wr_addr_queue.pop_front());
            void'(wr_data_queue.pop_front());
            void'(wr_resp_queue.pop_front());
            `uvm_info("WR_PKT_MERGE", wr_pkt.sprint(), UVM_MEDIUM)
            mon_ap.write(wr_pkt);
       // end
    end
endtask

task mem_monitor::merge_read();
    mem_seq_item rd_pkt;
    forever begin
        rd_pkt=mem_seq_item::type_id::create("rd_pkt");
        wait(rd_addr_queue.size()>0 && rd_data_queue.size()>0);//begin
        rd_pkt.araddr=rd_addr_queue[0].araddr;
        rd_pkt.trans_type=rd_addr_queue[0].trans_type;
        rd_pkt.rdata=rd_data_queue[0].rdata;
        rd_pkt.rresp=rd_data_queue[0].rresp;
        void'(rd_addr_queue.pop_front());
        void'(rd_data_queue.pop_front());
        `uvm_info("RD_PKT_MERGE", rd_pkt.sprint(), UVM_MEDIUM)
        mon_ap.write(rd_pkt);
      // end 
    end
endtask
