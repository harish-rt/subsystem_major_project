package soc_package;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "../common/config_tb.sv"
    import axi_cdma_env_pkg ::*;
    import intc_package ::*;
    import cpu_package ::*;


//IPS_CORE
    `include "../ips_core/ips_core_env.sv"
// TOP
    `include "wrapper_env.sv"
    `include "base_test.sv"
endpackage : soc_package
