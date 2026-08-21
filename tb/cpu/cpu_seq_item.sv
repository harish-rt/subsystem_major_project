class axil_cpu_seq_item extends uvm_sequence_item;

    typedef enum {READ, WRITE} write_t;
	typedef enum {NA,ISR,IPR,IER,IAR,SIE,CIE,IVR,MER,IMR,ILR,IVAR} register_t;

    rand bit [31:0]         AWADDR;
    rand bit [31:0]         WDATA;
    rand bit [3:0]          WSTRB;
         response_t         BRESP;
    rand bit [31:0]         ARADDR;
         bit [31:0]         RDATA;
         response_t         RRESP;
    rand write_t            write;
    rand register_t         reg_type;

    `uvm_object_utils_begin(axil_cpu_seq_item)
        `uvm_field_int(AWADDR, UVM_ALL_ON)
        `uvm_field_int(WDATA, UVM_ALL_ON)
        `uvm_field_int(WSTRB, UVM_ALL_ON)
        `uvm_field_enum(response_t, BRESP, UVM_ALL_ON)
        `uvm_field_int(ARADDR, UVM_ALL_ON)
        `uvm_field_int(RDATA, UVM_ALL_ON)
        `uvm_field_enum(response_t, RRESP, UVM_ALL_ON)
        `uvm_field_enum (write_t,write,UVM_ALL_ON)
        `uvm_field_enum (register_t,reg_type,UVM_ALL_ON)
    `uvm_object_utils_end

    `NEW_OBJ

    // Constraints
    constraint c_simple_exclusion{
        (write == WRITE) -> (ARADDR == 0) && (RDATA == 0);
        (write == READ)  -> (AWADDR == 0) && (WDATA == 0) && (WSTRB == 0);
    }
    constraint c_def_reg{
        soft reg_type == NA;
    }

endclass : axil_cpu_seq_item
