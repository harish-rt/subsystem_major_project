`include "axi4_tb_intf.sv"
`include "axi4_lite_tb_intf.sv"
package soc_package;
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    //`include "axi_parameters.sv"
    `include "../common/axi_parameters.sv"
    `include "../common/config_tb.sv"
    //`include "../common/axi_base_sequence_item.sv"
    import soc_addr_pkg::*;
    import cpu_package ::*;
    import mem_package :: *;
    import axi_cdma_env_pkg ::*;
    import intc_package ::*;
    import uart_pkg ::*;
    import spi_pkg ::*;
    import gpio_pkg ::*;
    import core_perif_pkg ::*;

    `include "soc_config.sv"
    export *::*;
//IPS_CORE
    `include "../ips_core/ips_core_env.sv"
//CORE PERIPHERALS
    //`include "../core_perif/core_perif_env.sv"
// TOP
    `include "soc_virtual_sequencer.sv"
    `include "soc_virtual_sequence.sv"

    `include "../common/sb_config.sv"
    `include "../common/ss_sbd.sv"

    `include "wrapper_env.sv"
    `include "base_test.sv"
endpackage : soc_package
