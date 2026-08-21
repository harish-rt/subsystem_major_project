class intc_seq_item extends uvm_sequence_item;

    rand bit [31:0] intc_intr;
    bit                     intc_irq;
    bit [31:0]    intc_intr_addr;
    rand int                delay_cycles;

    `uvm_object_param_utils_begin(intc_seq_item)
        `uvm_field_int(intc_intr,       UVM_ALL_ON)
        `uvm_field_int(intc_irq,        UVM_ALL_ON)
        `uvm_field_int(intc_intr_addr,  UVM_ALL_ON)
        `uvm_field_int(delay_cycles,    UVM_ALL_ON)
    `uvm_object_utils_end
    `NEW_OBJ

    // Constraints
    constraint c_delay {
      delay_cycles inside {[0:10]};
    }

endclass

/*
class intc_seq_item extends uvm_sequence_item;   

  		    logic 			intc_procss_rst;
	rand 	logic [31:0] 	intc_intr;
  			logic 			intc_irq;
    rand 	logic [1:0] 	intc_procss_acklg;
  			logic [31:0] 	intc_intr_addr;

  			logic 			intc_irq_in;
  			logic [31:0] 	intc_intr_addr_in;
  			logic [1:0] 	intc_procss_ack_out;
	rand 	int 			cmd_2_cmd_d;

  			int 			iar,ier,ipr,isr,ilr,ivr,imr,sie,cie;
			int 			ivar[32];
  			bit 	[1:0] 	mer;			

   
    `uvm_object_utils_begin (intc_seq_item)  
        `uvm_field_int (intc_intr,UVM_ALL_ON)
        `uvm_field_int (intc_procss_acklg,UVM_ALL_ON)
        `uvm_field_int (intc_intr_addr,UVM_ALL_ON)
        `uvm_field_int (intc_irq_in,UVM_ALL_ON)
        `uvm_field_int (intc_procss_ack_out,UVM_ALL_ON)
        `uvm_field_int (intc_irq,UVM_ALL_ON)
    `uvm_object_utils_end

    constraint intc_intr_c 			{soft intc_intr inside {[32'h00000000:32'hFFFFFFFF]};}
    constraint intc_procss_acklg_c 	{soft intc_procss_acklg inside {0,1,2,3};}
    constraint intc_irq_in_c 		{soft intc_irq_in == 1;}
    constraint ack_delay			{cmd_2_cmd_d inside{[5:8]};}
  
    extern function new(string name = "intc_seq_item");  

endclass : intc_seq_item 

    function intc_seq_item :: new(string name = "intc_seq_item");
        super.new(name);
    endfunction
    */
