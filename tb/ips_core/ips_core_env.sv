class ips_core_env extends uvm_env;
    `uvm_component_utils(ips_core_env)
    `NEW_COMP
    
    axi_lite_intc_env   intc_env;
    axi_cdma_axi_env    cdma_env;

    function void build();
        intc_env = axi_lite_intc_env::type_id::create("intc_env",this);
        cdma_env = axi_cdma_axi_env::type_id::create("cdma_env",this);
    endfunction

endclass
