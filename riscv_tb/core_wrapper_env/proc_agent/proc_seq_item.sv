class cpu_seq_item extends uvm_sequence_item;

   // AXI-Lite signals
   rand bit [31:0] araddr;   
   rand bit [31:0] awaddr;   
   rand bit [31:0] wdata;    
   rand bit [3:0]  wstrobe;    
   rand bit [31:0] rdata;    
   rand response_t bresp;   
   rand response_t rresp;    

   bit awvalid;
   bit awready;
   bit wvalid;
   bit wready;
   bit bvalid;
   bit bready;
   bit arvalid;
   bit arready;
   bit rvalid;
   bit rready;
   
   rand command_t operation;
   realtime radd_hndshk, rdata_hndshk[], wadd_hndshk, wdata_hndshk[], wresp_hndshk;
   realtime reset_asserted, reset_deasserted; 
   reset_info_t reset_op = NO_RESET; 
   
   `uvm_object_utils_begin(cpu_seq_item)
      `uvm_field_int(awaddr, UVM_ALL_ON)
      `uvm_field_int(awvalid, UVM_ALL_ON)
      `uvm_field_int(awready, UVM_ALL_ON)
      `uvm_field_int(wdata, UVM_ALL_ON)
      `uvm_field_int(wstrobe, UVM_ALL_ON)
      `uvm_field_int(wvalid, UVM_ALL_ON)
      `uvm_field_int(wready, UVM_ALL_ON)
      `uvm_field_enum(response_t, bresp, UVM_ALL_ON)
      `uvm_field_int(bvalid, UVM_ALL_ON)
      `uvm_field_int(bready, UVM_ALL_ON)
      `uvm_field_int(araddr, UVM_ALL_ON)
      `uvm_field_int(arvalid, UVM_ALL_ON)
      `uvm_field_int(arready, UVM_ALL_ON)
      `uvm_field_int(rdata, UVM_ALL_ON)
      `uvm_field_enum(response_t, rresp, UVM_ALL_ON)
      `uvm_field_int(rvalid, UVM_ALL_ON)
      `uvm_field_int(rready, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "cpu_seq_item");
      super.new(name);
   endfunction

endclass : cpu_seq_item

