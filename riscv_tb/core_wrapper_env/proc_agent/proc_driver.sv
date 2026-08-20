`include "uvm_macros.svh"
import uvm_pkg::*;

class cpu_driver extends uvm_driver #(cpu_seq_item);
   `uvm_component_utils(cpu_driver)

   virtual cpu_intf.DRV_MOD_cpu cpu_drv_intf;
   cpu_seq_item pkt;

   function new(string name = "cpu_driver", uvm_component parent);
      super.new(name, parent);
   endfunction

   task reset_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "reset_phase", UVM_MEDIUM)
      cpu_drv_intf.cpu_drv_cb.awaddr  <= '0;
      cpu_drv_intf.cpu_drv_cb.awvalid <= '0;
      cpu_drv_intf.cpu_drv_cb.wdata   <= '0;
      cpu_drv_intf.cpu_drv_cb.wstrobe   <= '0;
      cpu_drv_intf.cpu_drv_cb.wvalid  <= '0;
      cpu_drv_intf.cpu_drv_cb.bready  <= '0;
      cpu_drv_intf.cpu_drv_cb.araddr  <= '0;
      cpu_drv_intf.cpu_drv_cb.arvalid <= '0;
      cpu_drv_intf.cpu_drv_cb.rready  <= '0;
   endtask

   task main_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "main_phase", UVM_MEDIUM)
      wait(cpu_drv_intf.areset_n);
      forever begin
         @(cpu_drv_intf.cpu_drv_cb);
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
      cpu_drv_intf.cpu_drv_cb.awaddr  <= pkt.awaddr;
      cpu_drv_intf.cpu_drv_cb.awvalid <= 1;
      wait(cpu_drv_intf.cpu_drv_cb.awready);
      cpu_drv_intf.cpu_drv_cb.awvalid <= 0;

      // Data
      cpu_drv_intf.cpu_drv_cb.wdata   <= pkt.wdata;
      cpu_drv_intf.cpu_drv_cb.wstrobe   <= pkt.wstrobe;
      cpu_drv_intf.cpu_drv_cb.wvalid  <= 1;
      wait(cpu_drv_intf.cpu_drv_cb.wready);
      cpu_drv_intf.cpu_drv_cb.wvalid  <= 0;

      // Response
      cpu_drv_intf.cpu_drv_cb.bready <= 1;
      wait(cpu_drv_intf.cpu_drv_cb.bvalid);
      pkt.bresp = cpu_drv_intf.cpu_drv_cb.bresp;
      cpu_drv_intf.cpu_drv_cb.bready <= 0;
   endtask

   // ---------------- Read Transaction ----------------
   task drive_read(cpu_seq_item pkt);
      // Address
      cpu_drv_intf.cpu_drv_cb.araddr  <= pkt.araddr;
      cpu_drv_intf.cpu_drv_cb.arvalid <= 1;
      wait(cpu_drv_intf.cpu_drv_cb.arready);
      cpu_drv_intf.cpu_drv_cb.arvalid <= 0;

      // Data
      cpu_drv_intf.cpu_drv_cb.rready <= 1;
      wait(cpu_drv_intf.cpu_drv_cb.rvalid);
      pkt.rdata = cpu_drv_intf.cpu_drv_cb.rdata;
      pkt.rresp = cpu_drv_intf.cpu_drv_cb.rresp;
      cpu_drv_intf.cpu_drv_cb.rready <= 0;
   endtask

endclass : cpu_driver











/*class cpu_driver extends uvm_driver #(cpu_seq_item,cpu_seq_item);
   `uvm_component_utils (cpu_driver)
   virtual cpu_intf.DRV_MOD_cpu        cpu_drv_intf;
   mailbox #(cpu_seq_item)waddress_mbx, wdata_mbx, raddress_mbx, rdata_mbx, wresponse_mbx;
    cpu_seq_item     pkt;

   function new (string name = "cpu_driver", uvm_component parent);
      super.new(name,parent);
   endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        waddress_mbx   = new();
        wdata_mbx      = new();
        wresponse_mbx  = new();
        raddress_mbx   = new();
        rdata_mbx      = new();
    endfunction

    task reset_phase(uvm_phase phase);
      `uvm_info(get_full_name(), phase.get_name(), UVM_MEDIUM)
      `uvm_info(get_full_name(),"AXI-Lite reset_phase: Driving initial values to interface", UVM_LOW);
      cpu_drv_intf.cpu_drv_cb.awaddr  <= 'b0;
      cpu_drv_intf.cpu_drv_cb.awvalid <= 'b0;
      cpu_drv_intf.cpu_drv_cb.wdata   <= 'b0;
      cpu_drv_intf.cpu_drv_cb.wstrobe <= 'b0;
      cpu_drv_intf.cpu_drv_cb.wvalid  <= 'b0;
      cpu_drv_intf.cpu_drv_cb.bready  <= 'b0;
      cpu_drv_intf.cpu_drv_cb.araddr  <= 'b0;
      cpu_drv_intf.cpu_drv_cb.arvalid <= 'b0;
      cpu_drv_intf.cpu_drv_cb.rready  <= 'b0;
    endtask : reset_phase
    
    task main_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "main_phase", UVM_MEDIUM);
        wait(cpu_drv_intf.areset_n);
        forever begin
            @(cpu_drv_intf.cpu_drv_cb);
            seq_item_port.get_next_item(pkt);
            if (pkt.operation == WRITE) begin
                fork
                    drive_write_add();
                    drive_write_data();
                    drive_write_resp();
                join
            end else begin
                fork
                    drive_read_add();
                    drive_read_data();
                join
            end
            seq_item_port.item_done(pkt);
        end
    endtask: main_phase
    
    task drive_write_add();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- task triggered", UVM_LOW);
        cpu_drv_intf.cpu_drv_cb.awaddr  <= pkt.awaddr;
        cpu_drv_intf.cpu_drv_cb.awvalid <= 1;
        wait(cpu_drv_intf.cpu_drv_cb.awready == 1);
        //@(cpu_drv_intf.cpu_drv_cb);
        cpu_drv_intf.cpu_drv_cb.awvalid <= 0;
        cpu_drv_intf.cpu_drv_cb.awaddr  <= 0;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_add -- address handshake complete", UVM_LOW);
    endtask
    
    task drive_write_data();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- task triggered", UVM_LOW);
        cpu_drv_intf.cpu_drv_cb.wdata   <= pkt.wdata[0];
        cpu_drv_intf.cpu_drv_cb.wvalid  <= 1;
        wait(cpu_drv_intf.cpu_drv_cb.wready == 1);
        //@(cpu_drv_intf.cpu_drv_cb);
        cpu_drv_intf.cpu_drv_cb.wvalid  <= 0;
        cpu_drv_intf.cpu_drv_cb.wdata   <= 0;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_data -- data handshake complete", UVM_LOW);
    endtask
    
    task drive_write_resp();
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- task triggered", UVM_LOW);
        cpu_drv_intf.cpu_drv_cb.bready <= 1;
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- waiting for BVALID", UVM_LOW);
        wait(cpu_drv_intf.cpu_drv_cb.bvalid == 1);
        pkt.bresp = response_t'(cpu_drv_intf.cpu_drv_cb.bresp);
        @(cpu_drv_intf.cpu_drv_cb);
        cpu_drv_intf.cpu_drv_cb.bready <= 0;
        //seq_item_port.put_response(pkt);
        `uvm_info(get_full_name(),"AXI-Lite drive_write_resp -- transaction complete", UVM_LOW);
        `uvm_info("driver_pkt_from_write_resp",pkt.sprint(),UVM_MEDIUM)
    endtask
    
    
    task drive_read_add();
        `uvm_info(get_full_name(),"MI_drive_read_add -- task triggered", UVM_LOW);
        cpu_drv_intf.cpu_drv_cb.araddr  <= pkt.araddr;
        cpu_drv_intf.cpu_drv_cb.arvalid <= 1;
        wait(cpu_drv_intf.cpu_drv_cb.arready == 1);
    
        //@(cpu_drv_intf.cpu_drv_cb);
        cpu_drv_intf.cpu_drv_cb.arvalid <= 0;
        cpu_drv_intf.cpu_drv_cb.araddr  <= 'h0;
        `uvm_info(get_full_name(),"MI_drive_read_add -- address handshake complete", UVM_LOW);
    endtask
    
    task drive_read_data();
      `uvm_info(get_full_name(),"AXI-Lite drive_read_data -- task triggered", UVM_LOW);
        cpu_drv_intf.cpu_drv_cb.rready <= 1;
       // wait (cpu_drv_intf.cpu_drv_cb.rvalid == 1);
        do begin
           @(cpu_drv_intf.cpu_drv_cb);
        end while(cpu_drv_intf.cpu_drv_cb.rvalid != 1);
        if (pkt.rdata.size() == 0) pkt.rdata = new[1];
        //@(cpu_drv_intf.cpu_drv_cb);
        pkt.rdata[0] = cpu_drv_intf.cpu_drv_cb.rdata;
        pkt.rresp[0] = response_t'(cpu_drv_intf.cpu_drv_cb.rresp);
        //@(cpu_drv_intf.cpu_drv_cb);
        cpu_drv_intf.cpu_drv_cb.rready <= 0;
        //seq_item_port.put_response(pkt);    
        //`uvm_info("driver_pkt_last",pkt.sprint(),UVM_MEDIUM)
    endtask
 endclass :cpu_driver*/


