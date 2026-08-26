class proc_env extends uvm_env;
    `uvm_component_utils(proc_env)

    function new(string name="proc_env",uvm_component parent);
        super.new(name,parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass

function void proc_env::build_phase(uvm_phase phase);
endfunction

function void proc_env::connect_phase(uvm_phase phase);
endfunction
