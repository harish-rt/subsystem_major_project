class ips_core_env extends uvm_env;
    `uvm_component_utils(ips_core_env)
    `NEW_COMP
    
    lite_intc_env intc_env;

    function void build();
        intc_env = lite_intc_env::type_id::create("intc_env",this);
    endfunction

endclass
