class cpu_monitor extends uvm_monitor;
   `uvm_component_utils(cpu_monitor)

    uvm_analysis_port #(cpu_seq_item)        mon_ap;
    virtual axi4_lite_tb_intf.MONITOR_MOD    cpu_mon_intf;

    mailbox #(cpu_seq_item) write_address_mbx, write_data_mbx, read_address_mbx, read_data_mbx;
    master_e   port_id;

    function new(string name="cpu_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(master_e)::get(this, "", "port_id", port_id)) begin
            `uvm_warning("MON_CFG", "port_id not found in config_db, using default.")
        end
        mon_ap = new("mon_ap", this);
        `uvm_info(get_full_name(), phase.get_name(), UVM_MEDIUM)
        write_address_mbx = new();
        write_data_mbx = new();
        read_address_mbx = new();
        read_data_mbx = new();
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
            @(posedge cpu_mon_intf.ARESETn);
            rst_pkt = cpu_seq_item::type_id::create("rst_pkt");
            rst_pkt.reset_op = RESET_DEASSERTED;
            rst_pkt.reset_deasserted = $realtime();
            `uvm_info("cpu_monitor::capture_reset","reset_deasserted_pkt to SB",UVM_LOW);
            mon_ap.write(rst_pkt);
         end
         forever begin
            @(negedge cpu_mon_intf.ARESETn);
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
      forever begin
         `uvm_info("cpu_monitor::capture_write_address","Triggered",UVM_LOW);
         wait(cpu_mon_intf.axil_mon_cb.AWVALID && cpu_mon_intf.axil_mon_cb.AWREADY && cpu_mon_intf.ARESETn);
         pkt = cpu_seq_item::type_id::create("pkt");
         pkt.wadd_hndshk = $realtime();
         pkt.AWADDR      = cpu_mon_intf.axil_mon_cb.AWADDR;
         pkt.operation   = WRITE;
         write_address_mbx.put(pkt);
         @(cpu_mon_intf.axil_mon_cb);
      end
   endtask

   // ---------------- Write Data ----------------
   task capture_write_data();
      cpu_seq_item pkt;
      int i;
      forever begin
         `uvm_info("cpu_monitor::capture_write_data","Triggered",UVM_LOW);
         i=0;
         wait(cpu_mon_intf.axil_mon_cb.WVALID && cpu_mon_intf.axil_mon_cb.WREADY && cpu_mon_intf.ARESETn);
         pkt = cpu_seq_item::type_id::create("pkt");
         pkt.WDATA = new[1];
         pkt.WSTRB = new[1];
         pkt.wdata_hndshk[i] = $realtime();
         pkt.WDATA[0]       = cpu_mon_intf.axil_mon_cb.WDATA;
         pkt.WSTRB[0]       = cpu_mon_intf.axil_mon_cb.WSTRB;
         write_data_mbx.put(pkt);
         @(cpu_mon_intf.axil_mon_cb);
      end
   endtask

   // ---------------- Write Response ----------------
   task capture_write_response();
      cpu_seq_item addr_pkt, data_pkt, merged_pkt;
      forever begin
         `uvm_info("cpu_monitor::capture_write_response","Triggered",UVM_LOW);
         wait(cpu_mon_intf.axil_mon_cb.BVALID && cpu_mon_intf.axil_mon_cb.BREADY && cpu_mon_intf.ARESETn);
         if (write_address_mbx.num() > 0 && write_data_mbx.num() > 0) begin
            write_address_mbx.get(addr_pkt);
            write_data_mbx.get(data_pkt);
            merged_pkt = cpu_seq_item::type_id::create("merged_pkt");
            merged_pkt.WDATA = new[1];
            merged_pkt.WSTRB = new[1];

            merged_pkt.operation   = WRITE;
            merged_pkt.AWADDR      = addr_pkt.AWADDR;
            merged_pkt.wadd_hndshk = addr_pkt.wadd_hndshk;
            merged_pkt.WDATA[0]    = data_pkt.WDATA[0];
            merged_pkt.WSTRB[0]    = data_pkt.WSTRB[0];
            merged_pkt.wdata_hndshk= data_pkt.wdata_hndshk;
            merged_pkt.BRESP       = response_t'(cpu_mon_intf.axil_mon_cb.BRESP);
            merged_pkt.wresp_hndshk= $realtime();
            `uvm_info("cpu_monitor::capture_write_response","Sending pkt to SB",UVM_LOW);
            merged_pkt.master_p   = this.port_id;
            mon_ap.write(merged_pkt);
            `uvm_info("cpu_monitor_write_mon",merged_pkt.sprint(),UVM_LOW);
         end
         @(cpu_mon_intf.axil_mon_cb);
      end
   endtask

   // ---------------- Read Address ----------------
   task capture_read_address();
      cpu_seq_item pkt;
      forever begin
         `uvm_info("cpu_monitor::capture_read_address","Triggered",UVM_LOW);
         wait(cpu_mon_intf.axil_mon_cb.ARVALID && cpu_mon_intf.axil_mon_cb.ARREADY && cpu_mon_intf.ARESETn);
         pkt = cpu_seq_item::type_id::create("pkt");
         pkt.radd_hndshk = $realtime();
         pkt.ARADDR      = cpu_mon_intf.axil_mon_cb.ARADDR;
         pkt.operation   = READ;
         read_address_mbx.put(pkt);
         @(cpu_mon_intf.axil_mon_cb);
      end
   endtask

   // ---------------- Read Data ----------------
   task capture_read_data();
      cpu_seq_item addr_pkt, data_pkt;
      int i;
      forever begin
         `uvm_info("cpu_monitor::capture_read_data","Triggered",UVM_LOW);
         i=0;
         wait(cpu_mon_intf.axil_mon_cb.RVALID && cpu_mon_intf.axil_mon_cb.RREADY && cpu_mon_intf.ARESETn);
         if (read_address_mbx.num() > 0) begin
            read_address_mbx.get(addr_pkt);
            data_pkt = cpu_seq_item::type_id::create("data_pkt");
            data_pkt.RDATA = new[1];
            data_pkt.RRESP = new[1];
            data_pkt.operation   = READ;
            data_pkt.ARADDR      = addr_pkt.ARADDR;
            data_pkt.radd_hndshk = addr_pkt.radd_hndshk;
            data_pkt.RDATA[0]       = cpu_mon_intf.axil_mon_cb.RDATA;
            data_pkt.RRESP[0]       = response_t'(cpu_mon_intf.axil_mon_cb.RRESP);
            data_pkt.rdata_hndshk[i]= $realtime();
            `uvm_info("cpu_monitor::capture_read_data","Sending READ pkt to SB",UVM_LOW);
            data_pkt.master_p   = this.port_id;
            mon_ap.write(data_pkt);
            `uvm_info("cpu_monitor_read_mon",data_pkt.sprint(),UVM_LOW);
         end
         @(cpu_mon_intf.axil_mon_cb);
      end
   endtask
endclass:cpu_monitor
