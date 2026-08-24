class axi_lite_intc_env extends uvm_env;
    `uvm_component_utils(axi_lite_intc_env)
    `NEW_COMP
    
    uvm_active_passive_enum     is_active;
    axi_lite_intc_agent         lite_intc_agt;
    intc_agent                  intc_agt;
    intc_config_obj             obj;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("axi_lite_intc_env::build", "inside_lite_intc_env_build_phase", UVM_MEDIUM)
        if(!uvm_config_db #(intc_config_obj)::get(this,"","intc_config_obj",obj))
            `uvm_fatal(get_full_name(),"Config_obj get Failure")

            lite_intc_agt   = axi_lite_intc_agent::type_id::create("lite_intc_agt",this);
            intc_agt        = intc_agent::type_id::create("intc_agt",this);

            lite_intc_agt.is_active     = obj.axi_lite_is_active;
            intc_agt.is_active          = obj.intc_is_active;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
            lite_intc_agt.mon.mon_if    = obj.lite_intc_intf;            
            if (obj.axi_lite_is_active == UVM_ACTIVE) begin
            end
            intc_agt.mon.mon_intc_intf  = obj.intc_if;            
            if (obj.intc_is_active == UVM_ACTIVE) begin
            end
    endfunction
endclass
