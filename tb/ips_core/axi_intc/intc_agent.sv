class intc_agent extends uvm_agent;
    `uvm_component_utils(intc_agent)
    `NEW_COMP
    
    intc_monitor                mon;
    uvm_active_passive_enum     is_active;

    function void build();
        mon = intc_monitor::type_id::create("mon",this); 
        if(is_active == UVM_ACTIVE) begin
            `uvm_info(get_full_name(), "intc driver created succesfully", UVM_MEDIUM)
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(is_active == UVM_ACTIVE) begin
        end
    endfunction

endclass
