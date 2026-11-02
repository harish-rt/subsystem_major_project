class lite_intc_seq_item extends uvm_sequence_item; 
 
    typedef enum {READ, WRITE} command_t;
	typedef enum {ISR,IPR,IER,IAR,SIE,CIE,IVR,MER,IMR,ILR,IVAR} register_t;
 		 logic          ARESETn; 
    rand logic  [8:0]   AWADDR;   
    rand logic  [31:0]  WDATA;
    rand logic  [3:0]   WSTRB;
         logic  [1:0]   BRESP;
    rand logic  [8:0]   ARADDR;    
         logic  [31:0]  RDATA;     
         logic  [1:0]   RRESP;     
    rand command_t      operation;
 
    constraint c_w_strobe {WSTRB == 4'b1111;}
 
    `uvm_object_utils_begin (lite_intc_seq_item) 
        `uvm_field_int (AWADDR,UVM_ALL_ON) 
        `uvm_field_int (WDATA,UVM_ALL_ON) 
        `uvm_field_int (WSTRB,UVM_ALL_ON) 
        `uvm_field_int (BRESP,UVM_ALL_ON) 
        `uvm_field_int (ARADDR,UVM_ALL_ON) 
        `uvm_field_int (RDATA,UVM_ALL_ON) 
        `uvm_field_int (RRESP,UVM_ALL_ON) 
        `uvm_field_enum (command_t,operation,UVM_ALL_ON)
    `uvm_object_utils_end 
 
    extern function new(string name="lite_intc_seq_item"); 
  
endclass : lite_intc_seq_item
 
    function lite_intc_seq_item :: new(string name = "lite_intc_seq_item"); 
        super.new(name); 
    endfunction
