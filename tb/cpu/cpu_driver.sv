class cpu_driver extends uvm_driver #(cpu_seq_item);
   `uvm_component_utils(cpu_driver)

   virtual axi4_lite_intf.DRIVER_MOD cpu_drv_intf;
   cpu_seq_item pkt;

   function new(string name = "cpu_driver", uvm_component parent);
      super.new(name, parent);
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

   task main_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "main_phase", UVM_MEDIUM)
      wait(cpu_drv_intf.ARESETn);
      forever begin
         @(cpu_drv_intf.axil_drv_cb);
         seq_item_port.get_next_item(pkt);
         if (pkt.operation == WRITE) begin
            fork
               drive_write_add(pkt);
               drive_write_data(pkt);
               drive_write_resp(pkt);
            join
         end else begin
            fork
               drive_read_add(pkt);
               drive_read_data(pkt);
            join
         end
         seq_item_port.item_done(pkt);
      end
   endtask

   // ---------------- Write Transaction ----------------
   task drive_write_add(cpu_seq_item pkt);
      `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- task triggered", UVM_LOW);
      cpu_drv_intf.axil_drv_cb.AWADDR  <= pkt.AWADDR;
      cpu_drv_intf.axil_drv_cb.AWVALID <= 1;
      wait(cpu_drv_intf.axil_drv_cb.AWREADY);
      cpu_drv_intf.axil_drv_cb.AWVALID <= 0;
      cpu_drv_intf.axil_drv_cb.AWADDR  <= 0;
      `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- address handshake complete", UVM_LOW);
   endtask

   task drive_write_data(cpu_seq_item pkt);
      `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- task triggered", UVM_LOW);
      cpu_drv_intf.axil_drv_cb.WDATA   <= pkt.WDATA;
      cpu_drv_intf.axil_drv_cb.WSTRB   <= pkt.WSTRB;
      cpu_drv_intf.axil_drv_cb.WVALID  <= 1;
      wait(cpu_drv_intf.axil_drv_cb.WREADY);
      cpu_drv_intf.axil_drv_cb.WVALID  <= 0;
      cpu_drv_intf.axil_drv_cb.WDATA   <= 0;
      `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- data handshake complete", UVM_LOW);
      `uvm_info("driver_pkt_from_write_data",pkt.sprint(),UVM_MEDIUM)
   endtask

   task drive_write_resp(cpu_seq_item pkt);
      `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- task triggered", UVM_LOW);
      cpu_drv_intf.axil_drv_cb.BREADY <= 1;
      wait(cpu_drv_intf.axil_drv_cb.BVALID);
      pkt.BRESP = response_t'(cpu_drv_intf.axil_drv_cb.BRESP);
      cpu_drv_intf.axil_drv_cb.BREADY <= 0;
      `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- transaction complete", UVM_LOW);
      `uvm_info("driver_pkt_from_write_resp",pkt.sprint(),UVM_MEDIUM)
   endtask

   // ---------------- Read Transaction ----------------
   task drive_read_add(cpu_seq_item pkt);
      `uvm_info(get_full_name(),"AXI-Lite drive_read_add -- task triggered", UVM_LOW);
      cpu_drv_intf.axil_drv_cb.ARADDR  <= pkt.ARADDR;
      cpu_drv_intf.axil_drv_cb.ARVALID <= 1;
      wait(cpu_drv_intf.axil_drv_cb.ARREADY);
      cpu_drv_intf.axil_drv_cb.ARVALID <= 0;
      cpu_drv_intf.axil_drv_cb.ARADDR  <= 0;
      `uvm_info(get_full_name(),"AXI-Lite drive_read_add -- address handshake complete", UVM_LOW);
   endtask

   task drive_read_data(cpu_seq_item pkt);
      `uvm_info(get_full_name(),"AXI-Lite drive_read_data -- task triggered", UVM_LOW);
      cpu_drv_intf.axil_drv_cb.RREADY <= 1;
      wait(cpu_drv_intf.axil_drv_cb.RVALID);
      pkt.RDATA = cpu_drv_intf.axil_drv_cb.RDATA;
      pkt.RRESP = response_t'(cpu_drv_intf.axil_drv_cb.RRESP);
      cpu_drv_intf.axil_drv_cb.RREADY <= 0;
      `uvm_info(get_full_name(),"AXI-Lite drive_read_data -- data handshake complete", UVM_LOW);
   endtask

endclass : cpu_driver

