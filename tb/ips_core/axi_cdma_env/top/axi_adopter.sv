import uvm_pkg::*;
`include "uvm_macros.svh"


class reg_axi_cdma_adapter extends uvm_reg_adapter;
   `uvm_object_utils(reg_axi_cdma_adapter)

   master_seq_item  ms_seq_item;

   function new(string name = "reg_axi_cdma_adapter");
      super.new(name);
      supports_byte_enable = 0;
      provides_responses   = 0;

   endfunction

   virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      ms_seq_item = master_seq_item :: type_id :: create("ms_seq_item");
     

      if(rw.kind == UVM_WRITE)begin
         ms_seq_item.operation = WRITE;
         ms_seq_item.awaddr  = rw.addr;
         ms_seq_item.wdata = new[1];
         ms_seq_item.wdata[0]   = rw.data;
      `uvm_info("WRITE_DEBUG", $sformatf("wdata raw = %p, using = 0x%0h",rw.data, ms_seq_item.wdata[0]), UVM_LOW)
      end

      if(rw.kind == UVM_READ)begin
         ms_seq_item.operation = READ;
         ms_seq_item.araddr = rw.addr;
      
      end
      return ms_seq_item;
   endfunction

virtual function void bus2reg (uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
  master_seq_item ms_pkt;
  if(!($cast(ms_pkt,bus_item))) begin
    `uvm_fatal("bus2reg fn cast","Failed to cast bus item transaction")
  end
  else begin
    if(ms_pkt.operation == WRITE) begin
      rw.kind = UVM_WRITE;
      rw.addr = ms_pkt.awaddr;
      rw.data = ms_pkt.wdata[0];
      rw.status = UVM_IS_OK;
    end
    else if(ms_pkt.operation == READ) begin
      rw.kind = UVM_READ;
      rw.addr = ms_pkt.araddr;
      rw.data = ms_pkt.rdata[0];
      rw.status = UVM_IS_OK;
      `uvm_info("ADAPTER_READ_INSIDE", $sformatf("addr=0x%0h data=0x%0h",rw.addr, rw.data), UVM_LOW)
    end
  end
endfunction

endclass



 
