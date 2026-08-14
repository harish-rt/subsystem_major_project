class lite_intc_env extends uvm_env;
    `uvm_component_utils(lite_intc_env)
    `NEW_COMP
    
    lite_intc_agent     lite_agt;
    intr_in_agent       intr_agt;
    irq_out_agent       irq_agt;

    function void build();
        lite_agt = lite_intc_agent::type_id::create("lite_agt",this);
        intr_agt = intr_in_agent::type_id::create("intr_agt",this);
        irq_agt = irq_out_agent::type_id::create("irq_agt",this);
    endfunction

endclass
