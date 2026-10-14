//`include "uart_intf.sv"
package uart_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    `include "uart_slave_responder_agent.sv"

endpackage : uart_pkg
