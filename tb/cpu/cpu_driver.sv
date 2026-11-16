class cpu_driver extends uvm_driver #(cpu_seq_item);
    `uvm_component_utils(cpu_driver)

    virtual axi4_lite_tb_intf.DRIVER_MOD cpu_drv_intf;
    cpu_seq_item               pkt;
    bit disable_cpu_fork     = 0;
    mailbox #(cpu_seq_item) wr_addr_mbx = new();
    mailbox #(cpu_seq_item) wr_data_mbx = new();
    mailbox #(cpu_seq_item) wr_resp_mbx = new();
    mailbox #(cpu_seq_item) rd_addr_mbx = new();
    mailbox #(cpu_seq_item) rd_data_mbx = new();

    function new(string name = "cpu_driver", uvm_component parent);
        super.new(name, parent);
    	void'(uvm_config_db#(bit)::get(this,"","DCF",disable_cpu_fork));
    endfunction

   task reset_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "reset_phase", UVM_MEDIUM)
      cpu_drv_intf.axil_drv_cb.AWADDR  <= '0;
      cpu_drv_intf.axil_drv_cb.AWVALID <= '0;
      cpu_drv_intf.axil_drv_cb.WDATA   <= '0;
      cpu_drv_intf.axil_drv_cb.WSTRB   <= '0;
      cpu_drv_intf.axil_drv_cb.WVALID  <= '0;
      cpu_drv_intf.axil_drv_cb.BREADY  <= '0;
      cpu_drv_intf.axil_drv_cb.ARADDR  <= '0;
      cpu_drv_intf.axil_drv_cb.ARVALID <= '0;
      cpu_drv_intf.axil_drv_cb.RREADY  <= '0;
   endtask
/*
   task main_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "main_phase", UVM_MEDIUM)
      wait(cpu_drv_intf.ARESETn);
      forever begin
         @(cpu_drv_intf.axil_drv_cb);
         seq_item_port.get_next_item(pkt);
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
         end else begin
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
         seq_item_port.item_done(pkt);
      end
   endtask
*/
    task main_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "main_phase", UVM_MEDIUM)
        wait(cpu_drv_intf.ARESETn);
        
        if(disable_cpu_fork) begin
            forever begin
               @(cpu_drv_intf.axil_drv_cb);
               seq_item_port.get_next_item(pkt);
               get_packet(phase, pkt);

               if (pkt.operation == WRITE) begin
                  drive_write_add();
                  drive_write_data();
                  drive_write_resp(phase);
               end else begin
                  drive_read_add();
                  drive_read_data(phase);
               end

               seq_item_port.item_done(pkt);
            end
        end else begin
            fork
                get_packet(phase,pkt);
                drive_write_add();
                drive_write_data();
                // ifdef for outstanding checks
                drive_write_resp(phase);
                drive_read_add();
                // ifdef for outstanding checks
                drive_read_data(phase);
            join
        end
    endtask

    task get_packet(uvm_phase phase,cpu_seq_item pkt);
        cpu_seq_item pkt_clone;
        do begin
            if(!disable_cpu_fork) begin
                seq_item_port.get_next_item(pkt);
            end
            phase.raise_objection(this);

            $cast(pkt_clone, pkt.clone()); 
            if (pkt_clone.operation == WRITE) begin
                wr_addr_mbx.put(pkt);
                wr_data_mbx.put(pkt);
                wr_resp_mbx.put(pkt);
            end else begin
                rd_addr_mbx.put(pkt);
                rd_data_mbx.put(pkt);
            end

            if(!disable_cpu_fork) begin
                seq_item_port.item_done(pkt);
            end
       end while (!disable_cpu_fork);
    endtask

   // ---------------- Write Transaction ----------------
   task drive_write_add();
    cpu_seq_item pkt;
    do begin
        wr_addr_mbx.get(pkt);
        @(cpu_drv_intf.axil_drv_cb);
      `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- task triggered", UVM_LOW);
      cpu_drv_intf.axil_drv_cb.AWADDR  <= pkt.AWADDR;
      cpu_drv_intf.axil_drv_cb.AWVALID <= 1;
        do begin
            @(cpu_drv_intf.axil_drv_cb);
        end while (cpu_drv_intf.axil_drv_cb.AWREADY != 1);
      cpu_drv_intf.axil_drv_cb.AWVALID <= 0;
      cpu_drv_intf.axil_drv_cb.AWADDR  <= 0;
      `uvm_info("driver_pkt_from_write_addr",pkt.sprint(),UVM_MEDIUM)
      end while (!disable_cpu_fork);
   endtask

   task drive_write_data();
    cpu_seq_item pkt;
    do begin
        wr_data_mbx.get(pkt);
        @(cpu_drv_intf.axil_drv_cb);
      `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- task triggered", UVM_LOW);
      cpu_drv_intf.axil_drv_cb.WDATA   <= pkt.WDATA[0];
      cpu_drv_intf.axil_drv_cb.WSTRB   <= pkt.WSTRB[0];
      cpu_drv_intf.axil_drv_cb.WVALID  <= 1;
        do begin
            @(cpu_drv_intf.axil_drv_cb);
        end while (cpu_drv_intf.axil_drv_cb.WREADY != 1);
      cpu_drv_intf.axil_drv_cb.WVALID  <= 0;
      cpu_drv_intf.axil_drv_cb.WDATA   <= 0;
      `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- data handshake complete",UVM_LOW);
      `uvm_info("driver_pkt_from_write_data",pkt.sprint(),UVM_MEDIUM)
      end while (!disable_cpu_fork);
   endtask

   task drive_write_resp(uvm_phase phase);
    cpu_seq_item pkt;
    do begin
        wr_resp_mbx.get(pkt);
        @(cpu_drv_intf.axil_drv_cb);
      `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- task triggered", UVM_LOW);
      //repeat(60)@(cpu_drv_intf.axil_drv_cb);
      cpu_drv_intf.axil_drv_cb.BREADY <= 1;
        do begin
            @(cpu_drv_intf.axil_drv_cb);
        end while (cpu_drv_intf.axil_drv_cb.BVALID != 1);
      pkt.BRESP = response_t'(cpu_drv_intf.axil_drv_cb.BRESP);
      cpu_drv_intf.axil_drv_cb.BREADY <= 0;
      `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- transaction complete", UVM_LOW);
      `uvm_info("driver_pkt_from_write_resp",pkt.sprint(),UVM_MEDIUM)
      phase.drop_objection(this);
      end while (!disable_cpu_fork);
   endtask

   // ---------------- Read Transaction ----------------
   task drive_read_add();
    cpu_seq_item pkt;
    do begin
    rd_addr_mbx.get(pkt);
        @(cpu_drv_intf.axil_drv_cb);
      `uvm_info(get_full_name(),"AXI-Lite drive_read_add -- task triggered", UVM_LOW);
      cpu_drv_intf.axil_drv_cb.ARADDR  <= pkt.ARADDR;
      cpu_drv_intf.axil_drv_cb.ARVALID <= 1;
        do begin
            @(cpu_drv_intf.axil_drv_cb);
        end while (cpu_drv_intf.axil_drv_cb.ARREADY != 1);
      cpu_drv_intf.axil_drv_cb.ARVALID <= 0;
      cpu_drv_intf.axil_drv_cb.ARADDR  <= 0;
      `uvm_info(get_full_name(),"AXI-Lite drive_read_add -- address handshake complete", UVM_LOW);
      end while (!disable_cpu_fork);
   endtask

   task drive_read_data(uvm_phase phase);
    cpu_seq_item pkt;
    do begin
    rd_data_mbx.get(pkt);
        @(cpu_drv_intf.axil_drv_cb);
      `uvm_info(get_full_name(),"AXI-Lite drive_read_data -- task triggered", UVM_LOW);
      pkt.RDATA = new[1];
      pkt.RRESP = new[1];
      cpu_drv_intf.axil_drv_cb.RREADY <= 1;
        do begin
            @(cpu_drv_intf.axil_drv_cb);
        end while (cpu_drv_intf.axil_drv_cb.RVALID != 1);
      pkt.RDATA[0] = cpu_drv_intf.axil_drv_cb.RDATA;
      pkt.RRESP[0] = response_t'(cpu_drv_intf.axil_drv_cb.RRESP);
      cpu_drv_intf.axil_drv_cb.RREADY <= 0;
      `uvm_info(get_full_name(),"AXI-Lite drive_read_data -- data handshake complete", UVM_LOW);
      phase.drop_objection(this);
      end while (!disable_cpu_fork);
   endtask

endclass : cpu_driver
