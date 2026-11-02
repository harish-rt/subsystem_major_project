//`include "gpio_intf.sv"
package gpio_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    `include "../../../tb/common/config_tb.sv"
    `include "gpio_slave_responder_agent.sv"

endpackage : gpio_pkg
