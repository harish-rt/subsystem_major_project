`include "../cpu/cpu_intf.sv"
package cpu_package;
 `include "uvm_macros.svh"
  import  uvm_pkg :: *;

 `include "../cpu/parameters.sv"
 `include "../cpu/cpu_config_obj.sv"
 `include "../cpu/cpu_seq_item.sv"
 `include "../cpu/cpu_sequence.sv"
 `include "../cpu/cpu_driver.sv"
 `include "../cpu/cpu_monitor.sv"
 `include "../cpu/cpu_sequencer.sv"
 `include "../cpu/cpu_agent.sv"
 `include "../cpu/cpu_env.sv"  

endpackage


