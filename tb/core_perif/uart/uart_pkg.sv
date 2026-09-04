package uart_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    `include "uart_seq_item.sv"
    `include "uart_sequencer.sv"
    `include "uart_driver.sv"
    `include "uart_monitor.sv"
    `include "uart_agent.sv"

endpackage : uart_pkg
