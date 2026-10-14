`define NEW_COMP \
function new(string name="",uvm_component parent=null); \
    super.new(name,parent); \
endfunction

`define NEW_OBJ \
function new(string name=""); \
    super.new(name); \
endfunction

// Macro to disable fork in CPU DRV
`define SET_CPU_FORK_DISABLE(VAL) \
    w_env.c_env.cpu_agt.drv.disable_cpu_fork = VAL;
