class cpu_env extends uvm_agent;
    `uvm_component_utils(cpu_env)
    `NEW_COMP

    master_agent m_agt;

    function void build();
        m_agt = master_agent::type_id::create("m_agt",this);
    endfunction

endclass

