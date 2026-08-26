//`include "../../design/sub_ips/axi_intf/rtl/axi_lite_intf.sv"
package mem_package;
`include "uvm_macros.svh"
    import uvm_pkg::*;  
    `include "mem_enum.sv"
    `include "mem_seq_item.sv"
    `include "mem_monitor.sv"
    `include "mem_agent.sv"
    `include "mem_env.sv"
endpackage
