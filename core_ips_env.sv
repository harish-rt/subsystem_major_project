class core_ips_env extends uvm_env;
    `uvm_component_utils(core_ips_env)

    function new(string name="core_ips_env",uvm_component parent);
        super.new(name,parent);
    endfunction

    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass

function void core_ips_env::build_phase(uvm_phase phase);
endfunction

function void core_ips_env::connect_phase(uvm_phase phase);
endfunction
