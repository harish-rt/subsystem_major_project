class wrapper_env extends uvm_env;
    `uvm_component_utils(wrapper_env)
    `NEW_COMP
    
    cpu_env c_env;
    ips_core_env ips_env;
    //mem_env m_env;

    function void build();
        c_env = cpu_env::type_id::create("c_env",this);
     //   m_env = mem_env::type_id::create("mem_env",this);
        ips_env = ips_core_env::type_id::create("ips_env",this);

    endfunction

endclass
