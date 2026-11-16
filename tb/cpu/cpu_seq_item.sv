class cpu_seq_item extends axi_base_sequence_item;

    //rand bit [31:0]         AWADDR;
    //rand   bit  [DATA_WIDTH-1:0]   WDATA[];
    //rand   bit  [STROBE_WIDTH-1:0] WSTRB[];
    ////rand bit [31:0]         WDATA;
    ////rand bit [3:0]          WSTRB;
    //     response_t         BRESP;
    //rand bit [31:0]         ARADDR;
    //bit [DATA_WIDTH-1:0]    RDATA[];
    //response_t              RRESP[];
    //     //bit [31:0]         RDATA;
    //     //response_t         RRESP;
    //rand command_t          operation;

    //     master_e           master_p = MST_UNKNOWN;

   realtime radd_hndshk, rdata_hndshk[], wadd_hndshk, wdata_hndshk[], wresp_hndshk;
   realtime reset_asserted, reset_deasserted; 
   reset_info_t reset_op = NO_RESET; 

    `uvm_object_utils_begin(cpu_seq_item)
        `uvm_field_int(AWADDR, UVM_ALL_ON)
        `uvm_field_array_int(WDATA, UVM_ALL_ON)
        `uvm_field_array_int(WSTRB, UVM_ALL_ON)
        `uvm_field_enum(response_t, BRESP, UVM_ALL_ON)
        `uvm_field_int(ARADDR, UVM_ALL_ON)
        `uvm_field_array_int(RDATA, UVM_ALL_ON)
        `uvm_field_array_enum(response_t, RRESP, UVM_ALL_ON)
        `uvm_field_enum(command_t,operation,UVM_ALL_ON)
        `uvm_field_enum(master_e, master_p, UVM_ALL_ON)
    `uvm_object_utils_end

    `NEW_OBJ

    // Constraints
        constraint c_simple_exclusion {
        if (operation == WRITE) {
            ARADDR == 32'h0;
            foreach (RDATA[i]) {
                RDATA[i] == 0;
            }
        }
        else if (operation == READ) {
            AWADDR == 32'h0;
            foreach (WDATA[i]) {
                WDATA[i] == 0;
            }
            foreach (WSTRB[j]) {
                WSTRB[j] == 0;
            }
        }
    }

    constraint c_burst_sizes {
        if (operation == WRITE) {
            WDATA.size() == 1;
            WSTRB.size() == 1;
        } else {
            WDATA.size() == 0;
            WSTRB.size() == 0;
        }
    }
    //constraint c_simple_exclusion{
    //    foreach(WDATA[i]){
    //        (operation == WRITE) -> (ARADDR == 0) && (RDATA[i]== 0);
    //        (operation == READ)  -> (AWADDR == 0) && (WDATA[i]== 0) && (WSTRB[i]== 0);
    //    }
    //}

endclass : cpu_seq_item
