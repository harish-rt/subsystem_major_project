class core_wrapper_env extends uvm_env;
    `uvm_component_utils(core_wrapper_env)

    function new(string name="core_wrapper_env",uvm_component parent);
        super.new(name,parent);
    endfunction
    
    core_ips_env c_ips_env;
    proc_env p_env;
    mem_env m_env;
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass

function void core_wrapper_env::build_phase(uvm_phase phase);
    c_ips_env=core_ips_env::type_id::create("c_ips_env",this);
    p_env=proc_env::type_id::create("p_env",this);
    m_env=mem_env::type_id::create("m_env",this);
endfunction

function void core_wrapper_env::connect_phase(uvm_phase phase);
endfunction
