package soc_package;
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import soc_addr_pkg::*;
    import cpu_package ::*;
    import axi_cdma_env_pkg ::*;
    import mem_package :: *;
    import intc_package ::*;

    `include "soc_config.sv"
    export *::*;
//IPS_CORE
    `include "../ips_core/ips_core_env.sv"
// TOP
    `include "soc_virtual_sequencer.sv"
    `include "soc_virtual_sequence.sv"
    `include "wrapper_env.sv"
    `include "base_test.sv"
endpackage : soc_package
