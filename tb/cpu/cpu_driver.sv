`include "uvm_macros.svh"
import uvm_pkg::*;

class cpu_driver extends uvm_driver #(cpu_seq_item);
   `uvm_component_utils(cpu_driver)

   virtual axi4_lite_intf.DRIVER_MOD cpu_drv_intf;
   //virtual axi4_lite_intf.DRV_MOD_cpu cpu_drv_intf;
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
            drive_write(pkt);
         end else begin
            drive_read(pkt);
         end
         seq_item_port.item_done(pkt);
      end
   endtask

   // ---------------- Write Transaction ----------------
   task drive_write(cpu_seq_item pkt);
      // Address
      cpu_drv_intf.axil_drv_cb.AWADDR  <= pkt.AWADDR;
      cpu_drv_intf.axil_drv_cb.AWVALID <= 1;
      wait(cpu_drv_intf.axil_drv_cb.AWREADY);
      cpu_drv_intf.axil_drv_cb.AWVALID <= 0;

      // Data
      cpu_drv_intf.axil_drv_cb.WDATA   <= pkt.WDATA;
      cpu_drv_intf.axil_drv_cb.WSTRB <= pkt.WSTRB; // Unified property name
      cpu_drv_intf.axil_drv_cb.WVALID  <= 1;
      wait(cpu_drv_intf.axil_drv_cb.WREADY);
      cpu_drv_intf.axil_drv_cb.WVALID  <= 0;

      // Response
      cpu_drv_intf.axil_drv_cb.BREADY <= 1;
      wait(cpu_drv_intf.axil_drv_cb.BVALID);
      pkt.BRESP = response_t'(cpu_drv_intf.axil_drv_cb.BRESP);
      cpu_drv_intf.axil_drv_cb.BREADY <= 0;
      
   endtask

   // ---------------- Read Transaction ----------------
   task drive_read(cpu_seq_item pkt);
      // Address
      cpu_drv_intf.axil_drv_cb.ARADDR  <= pkt.ARADDR;
      cpu_drv_intf.axil_drv_cb.ARVALID <= 1;
      wait(cpu_drv_intf.axil_drv_cb.ARREADY);
      cpu_drv_intf.axil_drv_cb.ARVALID <= 0;

      // Data
      cpu_drv_intf.axil_drv_cb.RREADY <= 1;
      wait(cpu_drv_intf.axil_drv_cb.RVALID);
      pkt.RDATA = cpu_drv_intf.axil_drv_cb.RDATA;
      pkt.RRESP = response_t'(cpu_drv_intf.axil_drv_cb.RRESP);
      cpu_drv_intf.axil_drv_cb.RREADY <= 0;
      
   endtask

endclass : cpu_driver











