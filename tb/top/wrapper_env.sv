class wrapper_env extends uvm_env;
    `uvm_component_utils(wrapper_env)
    `NEW_COMP
    
    cpu_env                 c_env;
    ips_core_env            ips_env;
    mem_env                 m_env;
    core_perif_env          cp_env;

    intc_config_obj         cfg;
    soc_virtual_sequencer   vsqr;

    ss_scoreboard           sbd;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(intc_config_obj)::get(this,"","intc_config_obj",cfg))
            `uvm_fatal("w_env", "Failed to get intc_config_obj into wrapper env from config DB")
        c_env       = cpu_env::type_id::create("c_env",this);
        m_env       = mem_env::type_id::create("m_env",this);
        cp_env      = core_perif_env::type_id::create("cp_env",this);
        ips_env     = ips_core_env::type_id::create("ips_env",this);
        vsqr        = soc_virtual_sequencer::type_id::create("vsqr",this);
        sbd         = ss_scoreboard::type_id::create("sbd",this);
        vsqr.cfg    = cfg;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vsqr.cpu_sqr    =   c_env.cpu_agt.sqr;
        ips_env.intc_env.intc_agt.mon.resp_ap.connect(vsqr.intc_af.analysis_export);

    // Scoreboard af connections with Monitor ap
        c_env.cpu_agt.mon.mon_ap.connect(sbd.master_af.analysis_export);
        c_env.s04_agt.mon.mon_ap.connect(sbd.s04_af.analysis_export);
        m_env.mem_agt.bram_mon.mon_ap.connect(sbd.bram_af.analysis_export);
        m_env.mem_agt.mem_mon.mon_ap.connect(sbd.mem_af.analysis_export);
        ips_env.cdma_env.m_agt[0].mon.mon_ap.connect(sbd.cdma_af.analysis_export);
        ips_env.intc_env.lite_intc_agt.mon.mon_ap.connect(sbd.intc_af.analysis_export);
        cp_env.lite_mon.mon_ap.connect(sbd.core_perif_af.analysis_export);
    endfunction
endclass
