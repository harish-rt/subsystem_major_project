class ips_core_env extends uvm_env;
    `uvm_component_utils(ips_core_env)
    `NEW_COMP
    
    axi_lite_intc_env intc_env;
    env axi_cdma_env;

    function void build();
        intc_env = axi_lite_intc_env::type_id::create("intc_env",this);
       axi_cdma_env=env::type_id::create("axi_cdma_env",this);
    endfunction

endclass
