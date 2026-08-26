class soc_base_test extends uvm_test;
    `uvm_component_utils(soc_base_test)

    function new(string name="soc_base_test",uvm_component parent);
        super.new(name,parent);
    endfunction
    core_wrapper_env c_wrapper_env;
    extern function void build_phase(uvm_phase phase);
    extern function void end_of_elaboration_phase(uvm_phase phase);
endclass

function void soc_base_test::build_phase(uvm_phase phase);
    c_wrapper_env=core_wrapper_env::type_id::create("c_wrapper_env",this);
endfunction

function void soc_base_test::end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
endfunction
