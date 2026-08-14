class lite_intc_seq_item extends uvm_sequence_item; 
 
    rand logic [8:0] awaddr;   
         logic awvalid;        
         logic awready;        
    rand logic [31:0] wdata;  
    rand logic [3:0] wstrb;     
         logic wvalid;          
         logic wready;          
         logic [1:0] bresp;     
         logic bvalid;          
         logic bready;          
    rand logic [8:0] araddr;    
         logic arvalid;         
         logic arready;         
         logic [31:0] rdata;     
         logic [1:0] rresp;     
         logic rvalid;          
         logic rready; 
    typedef enum {READ, WRITE} write_t;
	typedef enum {ISR,IPR,IER,IAR,SIE,CIE,IVR,MER,IMR,ILR,IVAR} register_t;
    rand write_t write;
    rand register_t reg_type;
 
    constraint c_w_strobe {wstrb == 4'b1111;}
 
    `uvm_object_utils_begin (lite_intc_seq_item) 
        `uvm_field_int (awaddr,UVM_ALL_ON) 
        `uvm_field_int (awvalid,UVM_ALL_ON) 
        `uvm_field_int (awready,UVM_ALL_ON) 
        `uvm_field_int (wdata,UVM_ALL_ON) 
        `uvm_field_int (wstrb,UVM_ALL_ON) 
        `uvm_field_int (wvalid,UVM_ALL_ON) 
        `uvm_field_int (wready,UVM_ALL_ON) 
        `uvm_field_int (bresp,UVM_ALL_ON) 
        `uvm_field_int (bready,UVM_ALL_ON) 
        `uvm_field_int (bvalid,UVM_ALL_ON) 
        `uvm_field_int (araddr,UVM_ALL_ON) 
        `uvm_field_int (arready,UVM_ALL_ON) 
        `uvm_field_int (arvalid,UVM_ALL_ON) 
        `uvm_field_int (rdata,UVM_ALL_ON) 
        `uvm_field_int (rready,UVM_ALL_ON) 
        `uvm_field_int (rvalid,UVM_ALL_ON) 
        `uvm_field_int (rresp,UVM_ALL_ON) 
        `uvm_field_enum (write_t,write,UVM_ALL_ON)
        `uvm_field_enum (register_t,reg_type,UVM_ALL_ON)
    `uvm_object_utils_end 
 
    extern function new(string name="lite_intc_seq_item"); 
  
endclass : lite_intc_seq_item
 
    function lite_intc_seq_item :: new(string name = "lite_intc_seq_item"); 
        super.new(name); 
    endfunction
