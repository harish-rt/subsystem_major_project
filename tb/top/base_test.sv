class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    `NEW_COMP

    intc_config_obj                 obj;
    wrapper_env                     w_env;
    virtual axi4_lite_intc_intf     lite_intc_if;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(intc_config_obj)::get(this,"","config_obj",obj))begin
            `uvm_fatal("OBJ_MISSING", "The intc_config_obj handle was not set in uvm_config_db!")
        end
        lite_intc_if = obj.lite_intc_intf;
        w_env = wrapper_env::type_id::create("w_env",this);
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase (phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

    task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        `uvm_info(get_full_name(),"inside_reset_phase", UVM_MEDIUM)
        phase.raise_objection(this);
            `uvm_info(get_full_name(),"inside_raise_objection", UVM_MEDIUM)
            if (lite_intc_if == null) begin
                `uvm_fatal("TEST_VIF_NULL", "lite_intc_intf is NULL inside reset_phase!")
            end
            wait (lite_intc_if.areset_n == 1'b1); 
        phase.drop_objection(this);
        `uvm_info(get_full_name(),"outside_drop_objection", UVM_MEDIUM)
    endtask: reset_phase

endclass : base_test
