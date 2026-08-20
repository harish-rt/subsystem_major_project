   parameter ADDR_WIDTH 	= 32	;
   parameter DATA_WIDTH 	= 32	;
   parameter STRB_WIDTH   = DATA_WIDTH>>3;

class mem_seq_item extends uvm_sequence_item;
    
    rand TRANS_TYPE         trans_type;
    //Read address channel signals
   rand bit [ADDR_WIDTH-1:0]	araddr;
   rand bit [2:0] 		    	arprot;
        bit 		        	arready;
   rand bit	    	        	arvalid;
 
    //Write address channel signals
   rand bit [ADDR_WIDTH-1:0]	awaddr;
   rand bit [2:0] 	    		awprot;
        bit  		        	awready;
   rand bit  	        		awvalid;

   //Write response channel signals
   rand bit		            	bready;
        RESPONSE_TYPE		    bresp;
        bit 	        	    bvalid;

   //Read data channel signals
        bit [DATA_WIDTH-1:0]	rdata;
   rand bit 		        	rready;
        RESPONSE_TYPE    		rresp;
        bit 		        	rvalid;

   //Write data channel signals
   rand bit [DATA_WIDTH-1:0]	wdata;
        bit  		        	wready;
   rand bit [STRB_WIDTH-1:0] 	wstrb;
   rand bit  		        	wvalid;
    
    `uvm_object_utils_begin(mem_seq_item)

    `uvm_field_int(araddr,UVM_ALL_ON);
    `uvm_field_int(arprot,UVM_ALL_ON);
    `uvm_field_int(arready,UVM_ALL_ON);
    `uvm_field_int(arvalid,UVM_ALL_ON);

    `uvm_field_int(awaddr,UVM_ALL_ON);
    `uvm_field_int(awprot,UVM_ALL_ON);
    `uvm_field_int(awready,UVM_ALL_ON);
    `uvm_field_int(awvalid,UVM_ALL_ON);
    
    `uvm_field_int(bready,UVM_ALL_ON);
	`uvm_field_enum(RESPONSE_TYPE,bresp,UVM_ALL_ON);
    `uvm_field_int(bvalid,UVM_ALL_ON);

    `uvm_field_int(araddr,UVM_ALL_ON);
    `uvm_field_int(arprot,UVM_ALL_ON);
    `uvm_field_int(arready,UVM_ALL_ON);
    `uvm_field_int(arvalid,UVM_ALL_ON);

    `uvm_field_int(rdata,UVM_ALL_ON);
	`uvm_field_enum(RESPONSE_TYPE,rresp,UVM_ALL_ON);
    `uvm_field_int(rvalid,UVM_ALL_ON);
    `uvm_field_int(rready,UVM_ALL_ON);
    `uvm_object_utils_end   

    function new (string name = "mem_seq_item");
        super.new(name);
    endfunction

endclass

