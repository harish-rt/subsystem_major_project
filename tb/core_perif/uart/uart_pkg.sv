//`include "uart_intf.sv"
package uart_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    `include "../../../tb/common/config_tb.sv"
    `include "uart_slave_responder_agent.sv"

endpackage : uart_pkg
