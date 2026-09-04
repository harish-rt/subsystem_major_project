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

class bram_multiple_write_read_test extends cpu_base_test;
    `uvm_component_utils(bram_multiple_write_read_test)
    `NEW_COMP

    task main_phase(uvm_phase phase);
        bram_multiple_wr_rd_seq multiple_wr_rd_seq=bram_multiple_wr_rd_seq::type_id::create("multiple_wr_rd_seq");
        phase.raise_objection(this);
            multiple_wr_rd_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this,100ns);
        phase.drop_objection(this);
    endtask
endclass


class bram_upper_invalid_addr_test extends cpu_base_test;
    `uvm_component_utils(bram_upper_invalid_addr_test)

    `NEW_COMP
    task main_phase(uvm_phase phase);
        bram_upper_invalid_addr_seq bram_seq=bram_upper_invalid_addr_seq::type_id::create("bram_seq");
        phase.raise_objection(this);
            bram_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this,100ns);
        phase.drop_objection(this);
    endtask
endclass

class bram_lower_invalid_addr_test extends cpu_base_test;
    `uvm_component_utils(bram_lower_invalid_addr_test)

    `NEW_COMP
    task main_phase(uvm_phase phase);
        bram_lower_invalid_addr_seq bram_seq=bram_lower_invalid_addr_seq::type_id::create("bram_seq");
        phase.raise_objection(this);
            bram_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this,100ns);
        phase.drop_objection(this);
    endtask
endclass

class bram_address_range_test extends cpu_base_test;
    `uvm_component_utils(bram_address_range_test)

    `NEW_COMP
    task main_phase(uvm_phase phase);
        bram_address_range_seq bram_seq=bram_address_range_seq::type_id::create("bram_seq");
        phase.raise_objection(this);
            bram_seq.start(w_env.c_env.cpu_agt.sqr);
            phase.phase_done.set_drain_time(this,100ns);
        phase.drop_objection(this);
    endtask
endclass

class sample_test extends cpu_base_test;
    `uvm_component_utils(sample_test)
    `NEW_COMP

    cpu_config_intc_vseq    intc_seq;
    cpu_isr_vseq            isr_seq;
    cdma_read_write_vseq     cdma_seq;
    load_bram_vseq           bram_seq;

    task main_phase(uvm_phase phase);
        intc_seq = cpu_config_intc_vseq ::type_id::create("intc_seq");
        isr_seq  = cpu_isr_vseq         ::type_id::create("isr_seq");
        cdma_seq = cdma_read_write_vseq ::type_id::create("cdma_seq");
        bram_seq = load_bram_vseq       ::type_id::create("bram_seq");

        fork
            isr_seq.start(w_env.vsqr);
        join_none

        phase.raise_objection(this);

            bram_seq.start(w_env.vsqr);
            intc_seq.start(w_env.vsqr);
            cdma_seq.start(w_env.vsqr);

        phase.phase_done.set_drain_time(this, 300ns);
        phase.drop_objection(this);
    endtask
endclass : sample_test

class soc_master_test extends cpu_base_test;
    `uvm_component_utils(soc_master_test)
    `NEW_COMP

    soc_master_vseq master_vseq;

    task main_phase(uvm_phase phase);
        master_vseq = soc_master_vseq::type_id::create("master_vseq");

        phase.raise_objection(this);

            master_vseq.start(w_env.vsqr);

        phase.phase_done.set_drain_time(this, 1000ns);
        phase.drop_objection(this);
    endtask
endclass : soc_master_test

class cdma_wr_rd_test extends cpu_base_test;
    `uvm_component_utils(cdma_wr_rd_test)
    `NEW_COMP

    load_mem_seq mem_seq;
    cdma_read_write_seq seq;

    task main_phase(uvm_phase phase);
        seq = cdma_read_write_seq :: type_id :: create("seq");
        mem_seq = load_mem_seq :: type_id :: create("mem_seq");

        phase.raise_objection(this);

            mem_seq.start(w_env.c_env.cpu_agt.sqr);
            seq.start(w_env.c_env.cpu_agt.sqr);

        phase.phase_done.set_drain_time(this, 1000ns);
        phase.drop_objection(this);
    endtask
endclass : cdma_wr_rd_test

class mem_wr_rd_test extends cpu_base_test;
    `uvm_component_utils(mem_wr_rd_test)
    `NEW_COMP

    load_mem_seq mem_seq;
    read_mem_seq seq;

    task main_phase(uvm_phase phase);
        seq = read_mem_seq :: type_id :: create("seq");
        mem_seq = load_mem_seq :: type_id :: create("mem_seq");

        phase.raise_objection(this);

            mem_seq.start(w_env.c_env.cpu_agt.sqr);
            seq.start(w_env.c_env.cpu_agt.sqr);

        phase.phase_done.set_drain_time(this, 1000ns);
        phase.drop_objection(this);
    endtask
endclass : mem_wr_rd_test
