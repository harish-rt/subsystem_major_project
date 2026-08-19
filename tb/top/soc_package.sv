package soc_package;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import reg_block_pkg::*;

// COMMON
    `include "../common/config_tb.sv"
    `include "../ips_core/axi_intc/intc_config_obj.sv"
    `include "../cpu/cpu_config_obj.sv"
    `include "../common/axi_parameters.sv"

//IPS_CORE
    //AXI INTERRUPT CONTROLLER
    `include "../ips_core/axi_intc/lite_intc_seq_item.sv"
    `include "../ips_core/axi_intc/lite_intc_monitor.sv"
    `include "../ips_core/axi_intc/lite_intc_agent.sv"

    `include "../ips_core/axi_intc/intc_seq_item.sv"
    `include "../ips_core/axi_intc/intc_monitor.sv"
    `include "../ips_core/axi_intc/intc_agent.sv"

    `include "../ips_core/axi_intc/lite_intc_env.sv"
    `include "../ips_core/ips_core_env.sv"

// MASTER
    `include "../cpu/cpu_seq_item.sv"
    `include "../cpu/cdma_ral/cdma_reg_adapter.sv"
    `include "../cpu/cpu_sequence.sv"
    `include "../cpu/cpu_driver.sv"
    `include "../cpu/cpu_sequencer.sv"
    `include "../cpu/cpu_monitor.sv"
    `include "../cpu/cpu_agent.sv"
    `include "../cpu/cpu_env.sv"

// TOP
    `include "wrapper_env.sv"
    `include "base_test.sv"

endpackage : soc_package


/*
`include "../common/axi_parameters.sv"
`include "../cpu_agent/cpu_seq_item.sv"
`include "../cpu_agent/cpu_sequence.sv"
`include "../cpu_agent/cpu_driver.sv"
`include "../cpu_agent/cpu_sequencer.sv"
`include "../cpu_agent/cpu_agent.sv"
`include "cpu_env.sv"
`include "base_test.sv"
*/
