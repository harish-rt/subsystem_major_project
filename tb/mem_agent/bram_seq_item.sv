class bram_seq_item extends uvm_sequence_item;

    typedef enum bit { READ, WRITE } write_t;
typedef enum {OKAY,EXOKAY,SLVERR,DECERR}    response_t;
    typedef enum bit [1:0] { FIXED=2'b00, INCR=2'b01, WRAP=2'b10, RESERVED=2'b11 } burst_t;

    rand write_t        write;

    rand bit [31:0]     AWADDR;
    rand bit [7:0]      AWLEN;
    rand bit [2:0]      AWSIZE;
    rand burst_t        AWBURST;
    rand bit [3:0]      AWID;
    rand bit [2:0]      AWPROT;
    rand bit [3:0]      AWCACHE;
    rand bit [3:0]      AWQOS;
    rand bit            AWLOCK;

    rand bit [31:0]     WDATA[];
    rand bit [3:0]      WSTRB[];

         response_t     BRESP;
         bit [3:0]      BID;

    rand bit [31:0]     ARADDR;
    rand bit [7:0]      ARLEN;
    rand bit [2:0]      ARSIZE;
    rand burst_t        ARBURST;
    rand bit [3:0]      ARID;
    rand bit [2:0]      ARPROT;
    rand bit [3:0]      ARCACHE;
    rand bit [3:0]      ARQOS;
    rand bit            ARLOCK;

         bit [31:0]     RDATA[];
         response_t     RRESP[];
         bit [3:0]      RID;

    `uvm_object_utils_begin(bram_seq_item)
        `uvm_field_enum(write_t, write, UVM_ALL_ON)
        
        `uvm_field_int(AWADDR, UVM_ALL_ON)
        `uvm_field_int(AWLEN, UVM_ALL_ON)
        `uvm_field_int(AWSIZE, UVM_ALL_ON)
        `uvm_field_enum(burst_t, AWBURST, UVM_ALL_ON)
        `uvm_field_int(AWID, UVM_ALL_ON)

        `uvm_field_array_int(WDATA, UVM_ALL_ON)
        `uvm_field_array_int(WSTRB, UVM_ALL_ON)
        
        `uvm_field_enum(response_t, BRESP, UVM_ALL_ON)
        `uvm_field_int(BID, UVM_ALL_ON)
        
        `uvm_field_int(ARADDR, UVM_ALL_ON)
        `uvm_field_int(ARLEN, UVM_ALL_ON)
        `uvm_field_int(ARSIZE, UVM_ALL_ON)
        `uvm_field_enum(burst_t, ARBURST, UVM_ALL_ON)
        `uvm_field_int(ARID, UVM_ALL_ON)
        
        `uvm_field_array_int(RDATA, UVM_ALL_ON)
        `uvm_field_array_enum(response_t, RRESP, UVM_ALL_ON)
        `uvm_field_int(RID, UVM_ALL_ON)
    `uvm_object_utils_end
    `NEW_OBJ

    // Constraints

    constraint c_burst_sizes {
        WDATA.size() == int'(AWLEN) + 1;
        WSTRB.size() == int'(AWLEN) + 1;
    }

    constraint c_axi_size {
        AWSIZE == 3'b010; 
        ARSIZE == 3'b010;
    }

    constraint c_channel_exclusion {
        if (write == WRITE) {
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

endclass : bram_seq_item
