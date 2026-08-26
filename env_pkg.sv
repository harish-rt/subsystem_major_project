`include "proc_agent/proc_pkg.sv"
`include "mem_agent/mem_pkg.sv"
package soc_pkg;
     import uvm_pkg::*;
     import proc_package::*;
     import mem_package::*;
    `include "core_ips_env.sv"
    `include "core_wrapper.sv"
    `include "test.sv"

endpackage
