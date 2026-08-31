class cpu_base_test extends uvm_test;
    `uvm_component_utils(cpu_base_test)
    `NEW_COMP

    intc_config_obj                 obj;
    wrapper_env                     w_env;
    virtual axi4_lite_intc_intf     lite_intc_if;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(intc_config_obj)::get(this,"","intc_config_obj",obj))begin
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

endclass : cpu_base_test


class read_cdma_test extends cpu_base_test;
    `uvm_component_utils(read_cdma_test)
    `NEW_COMP

    read_cdma_seq master_seq;

    task main_phase(uvm_phase phase);
        master_seq = read_cdma_seq::type_id::create("master_seq");
        phase.raise_objection(this);
            master_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this, 100ns);
        phase.drop_objection(this);
    endtask
endclass : read_cdma_test


/*class config_cdma_ral_test extends cpu_base_test;
    `uvm_component_utils(config_cdma_ral_test)
    `NEW_COMP

    config_cdma_ral_seq master_seq;

    task main_phase(uvm_phase phase);
        master_seq = config_cdma_ral_seq::type_id::create("master_seq");
        phase.raise_objection(this);
            //master_seq.reg_block = w_env.c_env.reg_block;

            master_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this, 100ns);
        phase.drop_objection(this);
    endtask
endclass : config_cdma_ral_test*/


/*class read_bram_test extends cpu_base_test;
    `uvm_component_utils(read_bram_test)
    `NEW_COMP

    read_bram_seq master_seq;

    task main_phase(uvm_phase phase);
        master_seq = read_bram_seq::type_id::create("master_seq");
        phase.raise_objection(this);
            //master_seq.reg_block = w_env.c_env.reg_block;

            master_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this, 100ns);
        phase.drop_objection(this);
    endtask
endclass : read_bram_test*/


/*class load_bram_test extends cpu_base_test;
    `uvm_component_utils(load_bram_test)
    `NEW_COMP

    load_bram_seq       mem_seq;
    config_intc_seq     intc_seq;
    config_cdma_seq     cdma_seq;

    task main_phase(uvm_phase phase);
        mem_seq = load_bram_seq::type_id::create("mem_seq");
        intc_seq = config_intc_seq::type_id::create("intc_seq");
        cdma_seq = config_cdma_seq::type_id::create("cdma_seq");

        phase.raise_objection(this);
            //cdma_seq.reg_block = w_env.c_env.reg_block;

            mem_seq.start(w_env.c_env.cpu_agt.sqr);
            intc_seq.start(w_env.c_env.cpu_agt.sqr);
            cdma_seq.start(w_env.c_env.cpu_agt.sqr);

            phase.phase_done.set_drain_time(this, 1000ns);
        phase.drop_objection(this);
    endtask
endclass : load_bram_test*/

class config_intc_test extends cpu_base_test;
    `uvm_component_utils(config_intc_test)
    `NEW_COMP

    config_intc_seq     intc_seq;

    task main_phase(uvm_phase phase);
        intc_seq = config_intc_seq::type_id::create("intc_seq");

        phase.raise_objection(this);

            intc_seq.start(w_env.c_env.cpu_agt.sqr);

            phase.phase_done.set_drain_time(this, 100ns);
        phase.drop_objection(this);
    endtask
endclass : config_intc_test

class sample_test extends cpu_base_test;
    `uvm_component_utils(sample_test)
    `NEW_COMP

    cpu_config_intc_vseq     intc_seq;
    cpu_isr_vseq             isr_seq;
    //cpu_config_intc_seq     intc_seq;
    //cpu_isr_seq             isr_seq;

    task main_phase(uvm_phase phase);
        intc_seq = cpu_config_intc_vseq  ::type_id::create("intc_seq");
        isr_seq  = cpu_isr_vseq          ::type_id::create("isr_seq");

        phase.raise_objection(this);
            fork
                isr_seq.start(w_env.vsqr);
            join_none
            intc_seq.start(w_env.vsqr);
            //intc_seq.start(w_env.c_env.cpu_agt.sqr);
            //isr_seq.start(w_env.c_env.cpu_agt.sqr);

            phase.phase_done.set_drain_time(this, 100ns);
        phase.drop_objection(this);
    endtask
endclass : sample_test
