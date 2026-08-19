class cdma_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(cdma_reg_adapter)

  function new(string name = "cdma_reg_adapter");
    super.new(name);
    supports_byte_enable = 0;
    provides_responses   = 1;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    axil_cpu_seq_item bus_item = axil_cpu_seq_item::type_id::create("bus_item");

    if (rw.kind == UVM_WRITE) begin
        bus_item.write   = axil_cpu_seq_item::WRITE;
        bus_item.AWADDR  = rw.addr;
        bus_item.WDATA   = rw.data; // Straightforward scalar assignment
    end else begin
        bus_item.write   = axil_cpu_seq_item::READ;
        bus_item.ARADDR  = rw.addr;
    end
    
    `uvm_info("REG2BUS", $sformatf("%s Access to Addr: 0x%0h, Data: 0x%0h", rw.kind.name(), rw.addr, rw.data), UVM_MEDIUM)
    return bus_item;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    axil_cpu_seq_item bus_pkt;
    if (!$cast(bus_pkt, bus_item)) begin
        `uvm_fatal(get_type_name(), "Failed to cast bus_item transaction")
        return;
    end

    if (bus_pkt.write == READ) begin
        rw.kind   = UVM_READ;
        rw.addr   = bus_pkt.ARADDR;
        rw.data   = bus_pkt.RDATA; // Clean scalar copy
        rw.status = (bus_pkt.RRESP == 0) ? UVM_IS_OK : UVM_NOT_OK; 
    end else begin
        rw.kind   = UVM_WRITE;
        rw.addr   = bus_pkt.AWADDR;
        rw.data   = bus_pkt.WDATA; // Clean scalar copy
        rw.status = (bus_pkt.BRESP == 0) ? UVM_IS_OK : UVM_NOT_OK;
    end
    
    `uvm_info("BUS2REG", $sformatf("%s Return from Addr: 0x%0h, Data: 0x%0h, Status: %s", rw.kind.name(), rw.addr, rw.data, rw.status.name()), UVM_MEDIUM)    
  endfunction
endclass


/*
class cdma_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(cdma_reg_adapter)

  function new(string name = "cdma_reg_adapter");
    super.new(name);
    supports_byte_enable = 0;
    provides_responses   = 1;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    axil_cpu_seq_item bus_item = axil_cpu_seq_item::type_id::create("bus_item");

    bus_item.wdata  = new();
    bus_item.rdata  = new();
    bus_item.rresp  = new();

    if (rw.kind == UVM_WRITE) begin
        bus_item.write    = WRITE;
        bus_item.awaddr   = rw.addr;
        bus_item.wdata    = rw.data;
    end else begin
        bus_item.write    = READ;
        bus_item.araddr   = rw.addr;
    end
    `uvm_info("REG2BUS", $sformatf("%s Access to Addr: 0x%0h, Data: 0x%0h", rw.kind.name(), rw.addr, rw.data), UVM_MEDIUM)
    return bus_item;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
    axil_cpu_seq_item bus_pkt;
    if (!$cast(bus_pkt, bus_item))begin
        `uvm_fatal(get_type_name(), "Failed to cast bus_item transaction")
        return;
    end

    if (bus_pkt.write == READ) begin
        rw.kind = UVM_READ;
        rw.addr = bus_pkt.araddr;
        rw.data = bus_pkt.rdata;
        rw.status = (bus_pkt.rresp == 0) ? UVM_IS_OK : UVM_NOT_OK; 
    end
    else begin
        rw.kind = UVM_WRITE;
        rw.addr = bus_pkt.awaddr;
        rw.data = bus_pkt.wdata;
        rw.status = (bus_pkt.bresp == 0) ? UVM_IS_OK : UVM_NOT_OK;
    end
    `uvm_info("BUS2REG", $sformatf("%s Return from Addr: 0x%0h, Data: 0x%0h, Status: %s", rw.kind.name(), rw.addr, rw.data, rw.status.name()), UVM_MEDIUM)    
  endfunction
endclass
*/
