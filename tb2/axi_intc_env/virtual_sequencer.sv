class virtual_sequencer extends uvm_sequencer#(uvm_sequence_item);
  `uvm_component_utils(virtual_sequencer)
  
  function new(string name = "virtual_sequencer", uvm_component parent);
    super.new(name);
  endfunction

  axi_4_lite_seqr       axi_sqr;
  intc_sequencer        intc_sqr;

endclass
