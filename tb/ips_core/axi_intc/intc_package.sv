`include "lite_intc_interface.sv"
`include "intc_interface.sv"
package intc_package;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

// COMMON
    `include "../../common/axi_parameters.sv"
    `include "intc_config_obj.sv"

//IPS_CORE
    //AXI INTERRUPT CONTROLLER
    `include "lite_intc_seq_item.sv"
    `include "lite_intc_monitor.sv"
    `include "lite_intc_agent.sv"

    `include "intc_seq_item.sv"
    `include "intc_monitor.sv"
    `include "intc_agent.sv"

    `include "lite_intc_env.sv"

endpackage : intc_package
