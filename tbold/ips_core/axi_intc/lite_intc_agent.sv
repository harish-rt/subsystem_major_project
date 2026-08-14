class lite_intc_agent extends uvm_agent;
    `uvm_component_utils(lite_intc_agent)
    `NEW_COMP
    
    lite_intc_driver            drv;
    lite_intc_sequencer         sqr;
    lite_intc_monitor           mon;
    uvm_active_passive_enum     is_active;
    intc_config_obj             obj;

    function void build();
        if(!uvm_config_db #(intc_config_obj)::get(this,"","config_obj",obj)) begin
            `uvm_fatal("\t SET THE CONFIG OBJECT","intc_agent");
        end
        else begin
            is_active = obj.lite_intc_active;
            mon = lite_intc_monitor::type_id::create("mon",this); 
            if(is_active == UVM_ACTIVE) begin
                drv = lite_intc_driver::type_id::create("drv",this);
                sqr = lite_intc_sequencer::type_id::create("sqr",this);
            end
        end
    endfunction

    function void connect();
        is_active = obj.lite_intc_active;
        if(is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction

endclass
