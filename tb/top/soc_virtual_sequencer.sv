class soc_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(soc_virtual_sequencer)

    uvm_tlm_analysis_fifo#(bit) intc_af;
    intc_config_obj             cfg;

    cpu_sequencer               s00_sqr;
    cpu_sequencer               s02_sqr;
    s04_sequencer               s04_sqr;
    uart_slave_sequencer        uart_sqr;

   function new (string name = "soc_virtual_sequencer" , uvm_component parent);
      super.new(name,parent);
      intc_af   = new("intc_af",this);
   endfunction
endclass
