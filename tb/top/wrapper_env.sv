class wrapper_env extends uvm_env;
    `uvm_component_utils(wrapper_env)
    `NEW_COMP
    
    cpu_env                 c_env;
    ips_core_env            ips_env;
    mem_env                 m_env;
    intc_config_obj         cfg;
    soc_virtual_sequencer   vsqr;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(intc_config_obj)::get(this,"","intc_config_obj",cfg))
            `uvm_fatal("w_env", "Failed to get intc_config_obj into wrapper env from config DB")
        c_env   = cpu_env::type_id::create("c_env",this);
        m_env   = mem_env::type_id::create("mem_env",this);
        ips_env = ips_core_env::type_id::create("ips_env",this);
        vsqr    = soc_virtual_sequencer::type_id::create("vsqr",this);
        vsqr.cfg    =   cfg;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vsqr.cpu_sqr    =   c_env.cpu_agt.sqr;
        ips_env.intc_env.intc_agt.mon.resp_ap.connect(vsqr.intc_af.analysis_export);
    endfunction
endclass
