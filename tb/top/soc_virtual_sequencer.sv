class soc_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(soc_virtual_sequencer)
    `NEW_COMP

    cpu_sequencer cpu_sqr;

endclass
