class lite_intc_seq_item extends uvm_sequence_item; 
 
 		 logic          axi_areset_n; 
    rand logic  [8:0]   axi_awaddr;   
         logic          axi_awvalid;        
         logic          axi_awready;
    rand logic  [31:0]  axi_wdata;
    rand logic  [3:0]   axi_wstrb;
         logic          axi_wvalid;
         logic          axi_wready;
         logic  [1:0]   axi_bresp;
         logic          axi_bvalid;          
         logic          axi_bready;          
    rand logic  [8:0]   axi_araddr;    
         logic          axi_arvalid;         
         logic          axi_arready;         
         logic  [31:0]  axi_rdata;     
         logic  [1:0]   axi_rresp;     
         logic          axi_rvalid;          
         logic          axi_rready; 
    typedef enum {READ, WRITE} write_t;
	typedef enum {ISR,IPR,IER,IAR,SIE,CIE,IVR,MER,IMR,ILR,IVAR} register_t;
    rand write_t write;
    rand register_t reg_type;
 
    constraint c_w_strobe {axi_wstrb == 4'b1111;}
 
    `uvm_object_utils_begin (lite_intc_seq_item) 
        `uvm_field_int (axi_awaddr,UVM_ALL_ON) 
        `uvm_field_int (axi_awvalid,UVM_ALL_ON) 
        `uvm_field_int (axi_awready,UVM_ALL_ON) 
        `uvm_field_int (axi_wdata,UVM_ALL_ON) 
        `uvm_field_int (axi_wstrb,UVM_ALL_ON) 
        `uvm_field_int (axi_wvalid,UVM_ALL_ON) 
        `uvm_field_int (axi_wready,UVM_ALL_ON) 
        `uvm_field_int (axi_bresp,UVM_ALL_ON) 
        `uvm_field_int (axi_bready,UVM_ALL_ON) 
        `uvm_field_int (axi_bvalid,UVM_ALL_ON) 
        `uvm_field_int (axi_araddr,UVM_ALL_ON) 
        `uvm_field_int (axi_arready,UVM_ALL_ON) 
        `uvm_field_int (axi_arvalid,UVM_ALL_ON) 
        `uvm_field_int (axi_rdata,UVM_ALL_ON) 
        `uvm_field_int (axi_rready,UVM_ALL_ON) 
        `uvm_field_int (axi_rvalid,UVM_ALL_ON) 
        `uvm_field_int (axi_rresp,UVM_ALL_ON) 
        `uvm_field_enum (write_t,write,UVM_ALL_ON)
        `uvm_field_enum (register_t,reg_type,UVM_ALL_ON)
    `uvm_object_utils_end 
 
    extern function new(string name="lite_intc_seq_item"); 
  
endclass : lite_intc_seq_item
 
    function lite_intc_seq_item :: new(string name = "lite_intc_seq_item"); 
        super.new(name); 
    endfunction
