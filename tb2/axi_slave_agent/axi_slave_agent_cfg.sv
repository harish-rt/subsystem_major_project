class axi_slave_agent_cfg extends uvm_object;

    `uvm_object_utils(axi_slave_agent_cfg)

    virtual axi_slave_intf axi_slave_vif;
    bit fixed_data_write_response;
    bit enable_bad_intg_on_uninit_access;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    function new(string name = "axi_slave_agent_cfg");
        super.new(name);
    endfunction

endclass
