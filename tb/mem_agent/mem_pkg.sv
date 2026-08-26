package mem_package;
    `include "uvm_macros.svh"
    import uvm_pkg::*;  
    `include "mem_enum.sv"
    `include "mem_seq_item.sv"
    `include "bram_seq_item.sv"
    `include "mem_monitor.sv"
    `include "bram_monitor.sv"
    `include "mem_agent.sv"     //having bram and mem mon
    `include "mem_env.sv"
endpackage
