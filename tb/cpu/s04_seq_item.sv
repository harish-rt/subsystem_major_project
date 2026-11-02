class s04_seq_item extends axi_base_sequence_item;

    //typedef enum bit { WRITE, READ } write_t;
    ////typedef enum { OKAY, EXOKAY, SLVERR, DECERR } response_t;
    ////typedef enum bit [1:0] { FIXED=2'b00, INCR=2'b01, WRAP=2'b10, RESERVED=2'b11 } burst_type_t;

    //rand write_t        operation;

    //rand bit [31:0]     AWADDR;
    //rand bit [7:0]      AWLEN;
    //rand bit [2:0]      AWSIZE;
    //rand burst_type_t   AWBURST;
    //rand bit [ID_WIDTH-1:0]      AWID;
    //rand bit [2:0]      AWPROT;
    //rand bit [3:0]      AWCACHE;
    //rand bit [3:0]      AWQOS;
    //rand bit            AWLOCK;
    //rand bit [3:0] 		AWREGION;

    //rand bit [31:0]     WDATA[];
    //rand bit [3:0]      WSTRB[];

    //     response_t     BRESP;
    //     bit [ID_WIDTH-1:0]      BID;

    //rand bit [31:0]     ARADDR;
    //rand bit [7:0]      ARLEN;
    //rand bit [2:0]      ARSIZE;
    //rand burst_type_t   ARBURST;
    //rand bit [ID_WIDTH-1:0]      ARID;
    //rand bit [2:0]      ARPROT;
    //rand bit [3:0]      ARCACHE;
    //rand bit [3:0]      ARQOS;
    //rand bit            ARLOCK;
    //rand bit [3:0] 		ARREGION;

    //     bit [31:0]     RDATA[];
    //     response_t     RRESP[];
    //     bit [ID_WIDTH-1:0]      RID;

    //     master_e       master_p = MST_UNKNOWN;

         reset_info_t   reset_op = NO_RESET; //monitor signals reset info to sb using this enum //setting default value to be NO_RESET
    realtime reset_asserted, reset_deasserted;  //to hold reset timestamp info         
    realtime radd_hndshk, rdata_hndshk[], wadd_hndshk, wdata_hndshk[], wresp_hndshk;  // to capture timing when handshakes happen
    
    `uvm_object_utils_begin(s04_seq_item)
        `uvm_field_enum(reset_info_t, reset_op, UVM_ALL_ON)
        `uvm_field_enum(command_t, operation, UVM_ALL_ON)
        
        `uvm_field_int(AWADDR, UVM_ALL_ON)
        `uvm_field_int(AWLEN, UVM_ALL_ON)
        `uvm_field_int(AWSIZE, UVM_ALL_ON)
        `uvm_field_enum(burst_type_t, AWBURST, UVM_ALL_ON)
        `uvm_field_int(AWID, UVM_ALL_ON)

        `uvm_field_array_int(WDATA, UVM_ALL_ON)
        `uvm_field_array_int(WSTRB, UVM_ALL_ON)
        
        `uvm_field_enum(response_t, BRESP, UVM_ALL_ON)
        `uvm_field_int(BID, UVM_ALL_ON)
        
        `uvm_field_int(ARADDR, UVM_ALL_ON)
        `uvm_field_int(ARLEN, UVM_ALL_ON)
        `uvm_field_int(ARSIZE, UVM_ALL_ON)
        `uvm_field_enum(burst_type_t, ARBURST, UVM_ALL_ON)
        `uvm_field_int(ARID, UVM_ALL_ON)
        
        `uvm_field_array_int(RDATA, UVM_ALL_ON)
        `uvm_field_array_enum(response_t, RRESP, UVM_ALL_ON)
        `uvm_field_int(RID, UVM_ALL_ON)
        `uvm_field_enum(master_e, master_p, UVM_ALL_ON)
    `uvm_object_utils_end
    `NEW_OBJ

    // Constraints

    constraint c_burst_sizes {
        if (operation == WRITE) {
            WDATA.size() == int'(AWLEN) + 1;
            WSTRB.size() == int'(AWLEN) + 1;
        } else {
            WDATA.size() == 0;
            WSTRB.size() == 0;
        }
    }

    constraint c_bresp {
        if(operation == WRITE){
            BRESP   ==  OKAY;
        }
    }

    constraint c_axi_size {
        if (operation == WRITE) {
            AWSIZE == 3'b010;
        } else {
            ARSIZE == 3'b010;
        }
    }

    constraint c_channel_exclusion {
        if (operation == WRITE) {
            ARADDR  == 0;
            ARLEN   == 0;
            ARSIZE  == 0;
            ARID    == 0;
            ARBURST == FIXED;
        } else {
            AWADDR  == 0;
            AWLEN   == 0;
            AWSIZE  == 0;
            AWID    == 0;
            AWBURST == FIXED;
        }
    }

    constraint c_wstrobe{
        foreach(WSTRB[i]){
            WSTRB[i] == 'hf;
        }
    }

endclass : s04_seq_item
