class cpu_seq_item extends uvm_sequence_item;

    rand bit [31:0]         AWADDR;
    rand bit [31:0]         WDATA;
    rand bit [3:0]          WSTRB;
         response_t         BRESP;
    rand bit [31:0]         ARADDR;
         bit [31:0]         RDATA;
         response_t         RRESP;
    rand command_t          operation;


   realtime radd_hndshk, rdata_hndshk[], wadd_hndshk, wdata_hndshk[], wresp_hndshk;
   realtime reset_asserted, reset_deasserted; 
   reset_info_t reset_op = NO_RESET; 
   

    `uvm_object_utils_begin(cpu_seq_item)
        `uvm_field_int(AWADDR, UVM_ALL_ON)
        `uvm_field_int(WDATA, UVM_ALL_ON)
        `uvm_field_int(WSTRB, UVM_ALL_ON)
        `uvm_field_enum(response_t, BRESP, UVM_ALL_ON)
        `uvm_field_int(ARADDR, UVM_ALL_ON)
        `uvm_field_int(RDATA, UVM_ALL_ON)
        `uvm_field_enum(response_t, RRESP, UVM_ALL_ON)
        `uvm_field_enum (command_t,operation,UVM_ALL_ON)
    `uvm_object_utils_end

    `NEW_OBJ

    // Constraints
    constraint c_simple_exclusion{
        (operation == WRITE) -> (ARADDR == 0) && (RDATA == 0);
        (operation == READ)  -> (AWADDR == 0) && (WDATA == 0) && (WSTRB == 0);
    }

endclass : cpu_seq_item
