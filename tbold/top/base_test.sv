class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    `NEW_COMP

    wrapper_env w_env;
    
    function void build();
        w_env = wrapper_env::type_id::create("w_env",this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase (phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase
endclass : base_test

class lite_intc_read_test extends base_test;
    `uvm_component_utils(lite_intc_read_test)
    `NEW_COMP

    lite_intc_read_seq read_seq;
    
    task run_phase(uvm_phase phase);
        read_seq = lite_intc_read_seq::type_id::create("read_seq");

        phase.raise_objection(this);
            read_seq.start(w_env.ips_env.intc_env.lite_agt.sqr);
        phase.drop_objection(this);
    endtask
endclass : lite_intc_read_test
