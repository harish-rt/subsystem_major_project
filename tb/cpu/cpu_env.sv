class cpu_env extends uvm_agent;
    `uvm_component_utils(cpu_env)
    `NEW_COMP


    cpu_agent               cpu_agt;
    cpu_config_obj          cpu_obj;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("cpu_env::build", "inside_lite_cpu_env_build_phase", UVM_MEDIUM)
        if(!uvm_config_db #(cpu_config_obj)::get(this,"","cpu_config_obj",cpu_obj))
            `uvm_fatal(get_full_name(),"Config_obj get Failure")

        cpu_agt         = cpu_agent::type_id::create("cpu_agt",this);
        cpu_agt.is_active       = cpu_obj.riscv_is_active;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
            if (cpu_obj.riscv_is_active == UVM_ACTIVE) begin            
                cpu_agt.cpu_drv.axil_drv_if   = cpu_obj.riscv_lite_if;
               cpu_agt.cpu_drv.seq_item_port.connect(cpu_agt.cpu_sqr.seq_item_export);
            end
        endfunction
endclass
