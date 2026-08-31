class wrapper_env extends uvm_env;
    `uvm_component_utils(wrapper_env)
    `NEW_COMP
    
    cpu_env                 c_env;
    ips_core_env            ips_env;
    mem_env                 m_env;
    soc_virtual_sequencer   vsqr;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        c_env   = cpu_env::type_id::create("c_env",this);
        m_env   = mem_env::type_id::create("mem_env",this);
        ips_env = ips_core_env::type_id::create("ips_env",this);
        vsqr    = soc_virtual_sequencer::type_id::create("vsqr",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vsqr.cpu_sqr    =   c_env.cpu_agt.sqr;
    endfunction
endclass
