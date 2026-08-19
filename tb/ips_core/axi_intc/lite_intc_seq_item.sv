class lite_intc_seq_item extends uvm_sequence_item; 
 
    typedef enum {READ, WRITE} write_t;
	typedef enum {ISR,IPR,IER,IAR,SIE,CIE,IVR,MER,IMR,ILR,IVAR} register_t;
 		 logic          axi_areset_n; 
    rand logic  [8:0]   axi_awaddr;   
    rand logic  [31:0]  axi_wdata;
    rand logic  [3:0]   axi_wstrb;
         logic  [1:0]   axi_bresp;
    rand logic  [8:0]   axi_araddr;    
         logic  [31:0]  axi_rdata;     
         logic  [1:0]   axi_rresp;     
    rand write_t        write;
    rand register_t     reg_type;
 
    constraint c_w_strobe {axi_wstrb == 4'b1111;}
 
    `uvm_object_utils_begin (lite_intc_seq_item) 
        `uvm_field_int (axi_awaddr,UVM_ALL_ON) 
        `uvm_field_int (axi_wdata,UVM_ALL_ON) 
        `uvm_field_int (axi_wstrb,UVM_ALL_ON) 
        `uvm_field_int (axi_bresp,UVM_ALL_ON) 
        `uvm_field_int (axi_araddr,UVM_ALL_ON) 
        `uvm_field_int (axi_rdata,UVM_ALL_ON) 
        `uvm_field_int (axi_rresp,UVM_ALL_ON) 
        `uvm_field_enum (write_t,write,UVM_ALL_ON)
        `uvm_field_enum (register_t,reg_type,UVM_ALL_ON)
    `uvm_object_utils_end 
 
    extern function new(string name="lite_intc_seq_item"); 
  
endclass : lite_intc_seq_item
 
    function lite_intc_seq_item :: new(string name = "lite_intc_seq_item"); 
        super.new(name); 
    endfunction
